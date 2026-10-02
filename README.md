# insta_picker

Instagram-like media picker for Flutter: gallery, photo and video tabs, with filters, crop and video trimming.

> **Maintenance mode**: this package only receives bug fixes and dependency updates.

## Usage

```dart
final InstaPickerResult? result = await InstaPicker.pick(context, options: Options());
```

See the [example](example/lib/main.dart) for the customization options.

## Setup

### Android

Add the permissions to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED" />
```

and the crop activity:

```xml
<activity
    android:name="com.yalantis.ucrop.UCropActivity"
    android:screenOrientation="portrait"
    android:theme="@style/Theme.AppCompat.Light.NoActionBar"/>
```

### iOS

Add `NSCameraUsageDescription`, `NSMicrophoneUsageDescription` and `NSPhotoLibraryUsageDescription` to `Info.plist`.
