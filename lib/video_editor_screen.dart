import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_cropper_demo/crop_page.dart';
import 'package:video_cropper_demo/export_service.dart';
import 'package:video_cropper_demo/video_player_screen.dart';
import 'package:video_editor/video_editor.dart';

class VideoEditorScreen extends StatefulWidget {
  const VideoEditorScreen({super.key, required this.file});

  final File file;

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final _isInitialized = ValueNotifier<bool>(false);

  late final VideoEditorController _controller = VideoEditorController.file(
    widget.file,
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(minutes: 10),
  );

  String formatter(Duration duration) {
    return [
      duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
      duration.inSeconds.remainder(60).toString().padLeft(2, '0')
    ].join(":");
  }

  @override
  void initState() {
    _isExporting.value = false;
    _isInitialized.value = false;
    _initializeController();
    super.initState();
  }

  Future<void> _initializeController() async {
    try {
      await _controller.initialize();
      if (mounted) {
        _isInitialized.value = true;
      }
      debugPrint("Controller initialized: ${_controller.initialized}");
    } catch (error) {
      if (mounted) {
        if (error is VideoMinDurationError) {
          _showErrorSnackBar("Video too short for editing.");
          Navigator.pop(context);
        } else {
          _showErrorSnackBar("Error: Video failed to load");
        }
      }
    }
  }

  Future<void> _exportVideo() async {
    if (!_controller.initialized || _isExporting.value) return;

    _exportingProgress.value = 0;
    _isExporting.value = true;
    final config = VideoFFmpegVideoEditorConfig(_controller);

    try {
      await ExportService.runFFmpegCommand(
        await config.getExecuteConfig(),
        onProgress: (stats) {
          if (mounted) {
            _exportingProgress.value = config.getFFmpegProgress(
              stats.getTime().toInt(),
            );
          }
        },
        onError: (e, stackTrace) {
          if (mounted) {
            _isExporting.value = false;
            _showErrorSnackBar("Error on export video: $e");
          }
        },
        onCompleted: (file) {
          _isExporting.value = false;
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(
                  videoFile: file,
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        _isExporting.value = false;
        _showErrorSnackBar("Export failed: $e");
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          duration: const Duration(seconds: 10),
          showCloseIcon: true,
          closeIconColor: Colors.white,
        ),
      );
    }
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _isInitialized.dispose();
    _controller.dispose();
    ExportService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (!_controller.initialized || _isExporting.value) return;
              _controller.rotate90Degrees(RotateDirection.left);
            },
            icon: const Icon(Icons.rotate_left, color: Colors.white),
            tooltip: 'Rotate anti-clockwise',
          ),
          const SizedBox(width: 30),
          IconButton(
            onPressed: () {
              if (!_controller.initialized || _isExporting.value) return;
              _controller.rotate90Degrees(RotateDirection.right);
            },
            icon: const Icon(Icons.rotate_right, color: Colors.white),
            tooltip: 'Rotate clockwise',
          ),
          const SizedBox(width: 20),
          IconButton(
            onPressed: () {
              if (!_controller.initialized || _isExporting.value) return;
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => CropPage(controller: _controller),
                ),
              );
            },
            icon: const Icon(Icons.crop, color: Colors.white),
            tooltip: 'Open crop screen',
          ),
          const SizedBox(width: 20),
          TextButton(
            onPressed: _exportVideo,
            child: const Text(
              "Save",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: _isInitialized,
          builder: (context, isInitialized, child) {
            if (isInitialized) {
              return Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        if (_controller.isPlaying) {
                          _controller.video.pause();
                        } else {
                          _controller.video.play();
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CropGridViewer.preview(controller: _controller),
                          AnimatedBuilder(
                            animation: _controller.video,
                            builder: (_, __) => AnimatedOpacity(
                              opacity: _controller.isPlaying ? 0 : 1,
                              duration: kThemeAnimationDuration,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: _isExporting,
                            builder: (_, bool export, Widget? child) {
                              return AnimatedSize(
                                duration: kThemeAnimationDuration,
                                child: export ? child : null,
                              );
                            },
                            child: AlertDialog(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              alignment: Alignment.center,
                              title: ValueListenableBuilder(
                                valueListenable: _exportingProgress,
                                builder: (_, double value, __) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Exporting video ",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Text(
                                        "${(value * 100).ceil()}%",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatter(_controller.startTrim),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Spacer(),
                            Text(
                              formatter(_controller.endTrim),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: TrimSlider(
                          controller: _controller,
                          height: 60,
                          horizontalMargin: 15,
                        ),
                      )
                    ],
                  ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
