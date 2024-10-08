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
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  final _isInitialized = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _isInitialized.value = false;
    _initializeVideoController();
  }

  void _initializeVideoController() {
    _videoController = VideoPlayerController.file(widget.videoFile);
    _videoController.initialize().then((_) {
      if (mounted) {
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          aspectRatio: _videoController.value.aspectRatio,
          allowMuting: true,
          looping: true,
          useRootNavigator: true,
          autoInitialize: true,
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
          ],
          deviceOrientationsOnEnterFullScreen: [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ],
        );
      }
    }).then((_) {
      return _isInitialized.value = true;
    });
  }

  @override
  void dispose() {
    _isInitialized.dispose();
    _videoController.dispose();
    _chewieController?.dispose();
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
          child: ValueListenableBuilder(
            valueListenable: _isInitialized,
            builder: (context, isInitialized, child) {
              if (isInitialized) {
                if (_chewieController != null &&
                    _chewieController!
                        .videoPlayerController.value.isInitialized) {
                  return Chewie(controller: _chewieController!);
                } else {
                  return const Text("Video failed to load");
                }
              } else {
                return const CircularProgressIndicator(color: Colors.black);
              }
            },
          ),
        ),
      ),
    );
  }
}
