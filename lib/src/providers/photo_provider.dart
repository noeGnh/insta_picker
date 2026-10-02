import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:insta_picker/insta_picker.dart';
import 'package:insta_picker/src/models/file_model.dart';
import 'package:insta_picker/src/providers/camera_provider.dart';
import 'package:insta_picker/src/widgets/preview/image_preview.dart';
import 'package:path/path.dart';

class PhotoProvider extends CameraProvider {
  bool _capturing = false;

  @override
  List<FlashMode> get flashModes => const [FlashMode.off, FlashMode.always, FlashMode.auto];

  void onCapturePressed(BuildContext context, Options options) async {
    if (_capturing || controller == null || !controller!.value.isInitialized || controller!.value.isTakingPicture) return;

    _capturing = true;

    try {
      final XFile file = await controller!.takePicture();

      if (!context.mounted) return;

      InstaPickerResult? result = await Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => ImagePreview(
                files: [FileModel(filePath: file.path, title: basename(file.path))],
                imagePreviewOptions: options,
                showAddButton: false,
              )));

      if (result != null && context.mounted) Navigator.pop(context, result);
    } catch (e) {
      logger.e(e);
    } finally {
      _capturing = false;
    }
  }
}
