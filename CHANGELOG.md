## 0.1.0

Stabilization release. The package is now in maintenance mode: bug fixes and dependency updates only.

### Fixes

* Gallery: works on Android 13+ (media permissions requested through photo_manager instead of the storage permission).
* Gallery: HEIC, MOV, WEBP and every other format supported by the platform are listed (no more extension whitelist).
* Gallery: albums load quickly; thumbnails are generated lazily by photo_manager and files are only resolved when selected.
* `InstaPicker.pick()` no longer crashes when no `Options` are given.
* Camera: only one tab holds the camera at a time, and it is released when the app goes to the background.
* `GalleryCustomization.maxSelectable` is now applied (it was fixed to 5), with a message when the limit is reached.
* Filters: images are processed at 1080 px instead of 600 px, decoded off the UI thread and in their EXIF orientation.
* Edits made in the preview no longer alter the gallery files.
* Video recording: no double stop when the duration limit is reached; "Delete" now deletes the recorded file.
* Photo flash cycles through off / on / auto instead of using the torch.
* Multiple selection preview: each image fits the screen.
* Various "used after dispose" errors (video previews, providers).

### Changes

* New translations: `maxSelectionReached` and `videoTooLong`.
* Requires Dart 3.13 and Flutter 3.44 or later.
* Dependencies updated; `flutter_image_compress`, `get_thumbnail_video`, `path_provider`, `permission_handler` and `platform` removed.
* Example: Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0, Android 13+ media permissions and iOS usage descriptions.
