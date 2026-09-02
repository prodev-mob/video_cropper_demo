import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    super.key,
    required this.videoFile,
  });

  final File videoFile;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  final _isInitialized = ValueNotifier(false);
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideoController();
  }

  Future<void> _initializeVideoController() async {
    _isInitialized.value = false;
    _errorMessage = null;

    try {
      if (!await widget.videoFile.exists()) {
        throw Exception("Video file not found at ${widget.videoFile.path}");
      }

      final fileSize = await widget.videoFile.length();
      if (fileSize == 0) {
        throw Exception("Video file is empty (0 bytes).");
      }

      final controller = VideoPlayerController.file(widget.videoFile);
      _videoController = controller;
      await controller.initialize();

      if (!mounted) return;

      final aspectRatio = (controller.value.aspectRatio > 0 &&
              !controller.value.aspectRatio.isNaN)
          ? controller.value.aspectRatio
          : 16 / 9;

      _chewieController = ChewieController(
        videoPlayerController: controller,
        aspectRatio: aspectRatio,
        allowMuting: true,
        looping: true,
        autoPlay: true,
        deviceOrientationsAfterFullScreen: const [
          DeviceOrientation.portraitUp,
        ],
        deviceOrientationsOnEnterFullScreen: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      );
    } catch (e, st) {
      debugPrint("Error initializing video player: $e\n$st");
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        _isInitialized.value = true;
      }
    }
  }

  @override
  void dispose() {
    _isInitialized.dispose();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text("Trimmed Video"),
      ),
      body: SafeArea(
        child: Center(
          child: ValueListenableBuilder<bool>(
            valueListenable: _isInitialized,
            builder: (context, isInitialized, child) {
              if (!isInitialized) {
                return const CircularProgressIndicator(color: Colors.black);
              }

              if (_errorMessage != null) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _initializeVideoController,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }

              if (_chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized) {
                return Chewie(controller: _chewieController!);
              } else {
                return const Text("Video failed to load");
              }
            },
          ),
        ),
      ),
    );
  }
}
