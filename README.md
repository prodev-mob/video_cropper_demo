# Video Cropper Demo

This demo app offers essential video editing features, including trimming, cropping, exporting, and playing the edited video.

## Features

- **Trim Video**: Select and trim specific sections of a video.
- **Crop Video**: Crop the video to a custom aspect ratio or size.
- **Export Video**: Export the edited video.
- **Play Edited Video**: Preview the video using the Chewie player.

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) version 3.22.3 or higher

### Dependencies

Add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  image_picker: ^1.1.2 
  device_info_plus: ^10.1.2 
  permission_handler: ^11.3.1 
  video_editor: ^3.0.0 
  ffmpeg_kit_flutter_min: ^6.0.3
  fraction: ^5.0.3
  video_player: ^2.9.2
  chewie: ^1.8.5
```

## Permission Setup

### Android

Add the following permissions to your **AndroidManifest.xml** file, located in`android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

### iOS

Add the following keys to your **Info.plist** file, located in `ios/Runner/Info.plist`:
```
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select videos.</string>
```

## Example

The [example app](https://github.com/prodev-mob/video_cropper_demo.git) running on an iPhone 13 device:

<p>
  <img src="screenshots/example_app.mov" alt="Trimmer"/>
</p>
