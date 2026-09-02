# Video Cropper Demo

This demo app offers essential video editing features, including trimming, cropping, exporting, and playing the edited video.

## Features

- **Trim Video**: Select and trim specific sections of a video.
- **Crop Video**: Crop the video to a custom aspect ratio or size.
- **Export Video**: Export the edited video.
- **Play Edited Video**: Preview the video using the Chewie player.

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) version 3.38.7 or higher

### Dependencies

Add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  image_picker: ^1.2.3
  device_info_plus: ^13.2.0
  permission_handler: ^12.0.1
  video_editor: ^3.0.0
  ffmpeg_kit_flutter_new: ^4.6.2
  fraction: ^5.0.5
  video_player: ^2.11.1
  chewie: ^1.13.1
```

## Permission Setup

### Android

Add the following permissions to your **AndroidManifest.xml** file, located in `android/app/src/main/AndroidManifest.xml`:
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

https://github.com/prodev-mob/video_cropper_demo/blob/main/screenshots/example_app.mp4?raw=true

<video src="screenshots/example_app.mp4" controls="controls" width="300" muted="muted"></video>
