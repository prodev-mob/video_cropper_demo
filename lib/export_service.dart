import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/statistics.dart';
import 'package:video_editor/video_editor.dart';

class ExportService {
  static Future<void> dispose() async {
    final executions = await FFmpegKit.listSessions();
    if (executions.isNotEmpty) await FFmpegKit.cancel();
  }

  static String _sanitizeCommand(String command) {
    // Fix floating point / odd dimensions in crop filter:
    var formattedCommand = command.replaceAllMapped(
      RegExp(r"crop=([0-9.]+):([0-9.]+):([0-9.]+):([0-9.]+)"),
      (match) {
        double w = double.tryParse(match.group(1) ?? '') ?? 0;
        double h = double.tryParse(match.group(2) ?? '') ?? 0;
        double x = double.tryParse(match.group(3) ?? '') ?? 0;
        double y = double.tryParse(match.group(4) ?? '') ?? 0;

        // Ensure width and height are even integers (divisible by 2) for H.264
        int evenW = (w.round() ~/ 2) * 2;
        int evenH = (h.round() ~/ 2) * 2;
        int intX = x.round();
        int intY = y.round();

        return "crop=$evenW:$evenH:$intX:$intY";
      },
    );

    // Ensure reliable software encoder libx264 with yuv420p pixel format
    if (!formattedCommand.contains('-c:v') &&
        !formattedCommand.contains('-vcodec')) {
      if (formattedCommand.contains('-y')) {
        formattedCommand = formattedCommand.replaceFirst(
          '-y',
          '-c:v libx264 -preset ultrafast -pix_fmt yuv420p -y',
        );
      } else {
        formattedCommand =
            '$formattedCommand -c:v libx264 -preset ultrafast -pix_fmt yuv420p';
      }
    }

    return formattedCommand;
  }

  static Future<FFmpegSession> runFFmpegCommand(
    FFmpegVideoEditorExecute execute, {
    required void Function(File file) onCompleted,
    void Function(Object, StackTrace)? onError,
    void Function(Statistics)? onProgress,
  }) {
    final sanitizedCommand = _sanitizeCommand(execute.command);
    log('FFmpeg start process with command = $sanitizedCommand');
    return FFmpegKit.executeAsync(
      sanitizedCommand,
      (session) async {
        final state = FFmpegKitConfig.sessionStateToString(
          await session.getState(),
        );
        final code = await session.getReturnCode();

        if (ReturnCode.isSuccess(code)) {
          final file = File(execute.outputPath);
          if (await file.exists() && await file.length() > 0) {
            onCompleted(file);
          } else {
            if (onError != null) {
              onError(
                Exception(
                  'FFmpeg finished but exported video file is empty or missing at ${execute.outputPath}',
                ),
                StackTrace.current,
              );
            }
          }
        } else {
          if (onError != null) {
            onError(
              Exception(
                'FFmpeg process exited with state $state and return code $code.\n${await session.getOutput()}',
              ),
              StackTrace.current,
            );
          }
          return;
        }
      },
      null,
      onProgress,
    );
  }
}
