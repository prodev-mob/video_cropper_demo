import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<bool> requestGalleryPermission(BuildContext context) async {
    if (Platform.isIOS) {
      return requestPhotosPermission(context);
    } else if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (!context.mounted) return false;
      if (androidInfo.version.sdkInt <= 32) {
        return requestStoragePermission(context);
      } else {
        return requestPhotosPermission(context);
      }
    } else {
      return false;
    }
  }

  static Future<bool> requestPhotosPermission(BuildContext context) async {
    const permission = Permission.photos;
    if (await permission.isGranted) {
      return true;
    } else if (await permission.isDenied) {
      final result = await permission.request();
      return (result.isGranted);
    } else {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Photo permission is required please open Settings to grant the permission.",
          ),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: "Open App Settings",
            onPressed: () => openAppSettings(),
          ),
        ),
      );
      return false;
    }
  }

  static Future<bool> requestStoragePermission(BuildContext context) async {
    const permission = Permission.storage;
    if (await permission.isGranted) {
      return true;
    } else if (await permission.isDenied) {
      final result = await permission.request();
      return (result.isGranted);
    } else {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Storage permission is required please open Settings to grant the permission.",
          ),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: "Open App Settings",
            onPressed: () => openAppSettings(),
          ),
        ),
      );
      return false;
    }
  }
}
