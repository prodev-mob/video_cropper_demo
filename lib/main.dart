import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_cropper_demo/permission_handler.dart';
import 'package:video_cropper_demo/video_editor_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Cropper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();

    Future<void> getVideoFromGalley(BuildContext context) async {
      if (await PermissionHandler.requestGalleryPermission(context)) {
        final XFile? video =
            await picker.pickVideo(source: ImageSource.gallery);
        if (video != null) {
          File file = File(video.path);
          if (!context.mounted) return;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return VideoEditorScreen(file: file);
              },
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("HomePage")),
      body: SafeArea(
        child: Center(
          child: ElevatedButton(
            onPressed: () async {
              await getVideoFromGalley(context);
            },
            child: const Text("Pick Video"),
          ),
        ),
      ),
    );
  }
}
