import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:insta_picker/src/models/file_model.dart';
import 'package:insta_picker/src/models/options.dart';
import 'package:insta_picker/src/models/result.dart';
import 'package:path/path.dart';
import 'package:photofilters/filters/preset_filters.dart';
import 'package:photofilters/widgets/photo_filter.dart';
import 'package:image/image.dart' as imageLib;

/// Width of the images given to the filters: photofilters processes the whole image for each filter.
const int _FILTER_IMAGE_WIDTH = 1080;

/// Decodes the image at [filePath] in its displayed orientation, at most [_FILTER_IMAGE_WIDTH] wide.
imageLib.Image? _decodeImageForFilters(String filePath) {
  final imageLib.Image? decoded = imageLib.decodeImage(File(filePath).readAsBytesSync());
  if (decoded == null) return null;

  final imageLib.Image oriented = imageLib.bakeOrientation(decoded);
  return oriented.width > _FILTER_IMAGE_WIDTH ? imageLib.copyResize(oriented, width: _FILTER_IMAGE_WIDTH) : oriented;
}

class ImagePreviewProvider extends ChangeNotifier {
  List<FileModel?>? files = [];

  late Translations _translations;

  set translations(Translations translations) {
    this._translations = translations;
  }

  _updateFiles(FileModel file, File resultFile) {
    int index = this.files!.indexOf(file);
    file.filePath = resultFile.path;
    this.files![index] = file;

    notifyListeners();
  }

  addFilter(BuildContext context, FileModel file, Options? options) async {
    final imageLib.Image? image = await compute(_decodeImageForFilters, file.filePath!);

    if (image == null || !context.mounted) return;

    Map? filterResult = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => PhotoFilterSelector(
          title: Text(
            this._translations.filters,
            style: TextStyle(color: options!.customizationOptions.iconsColor),
          ),
          image: image,
          filters: presetFiltersList,
          filename: basename(file.filePath!),
          appBarColor: options.customizationOptions.appBarColor,
          appBarIconsColor: options.customizationOptions.iconsColor,
          loader: Center(
              child: CircularProgressIndicator(
            backgroundColor: options.customizationOptions.iconsColor,
          )),
          fit: BoxFit.contain,
        ),
      ),
    );

    if (filterResult != null && filterResult.containsKey('image_filtered')) {
      File? resultFile = filterResult['image_filtered'];

      if (resultFile != null) {
        this._updateFiles(file, resultFile);
      }
    }
  }

  edit(FileModel file, Options options) async {
    CroppedFile? editResult = await ImageCropper().cropImage(
      sourcePath: file.filePath!,
      compressFormat: ImageCompressFormat.png,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '',
          toolbarColor: options.customizationOptions.appBarColor,
          backgroundColor: options.customizationOptions.appBarColor,
          toolbarWidgetColor: options.customizationOptions.iconsColor,
          activeControlsWidgetColor: options.customizationOptions.iconsColor,
          initAspectRatio: CropAspectRatioPreset.original,
          cropStyle: CropStyle.rectangle,
          lockAspectRatio: false,
          showCropGrid: true,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
          title: '',
          doneButtonTitle: this._translations.save,
          cancelButtonTitle: this._translations.cancel,
          cropStyle: CropStyle.rectangle,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        )
      ],
    );

    if (editResult != null) {
      this._updateFiles(file, File(editResult.path));
    }
  }

  submit(BuildContext context) {
    List<PickedFile> pickedFiles = [];

    if (files != null) {
      files!.map((file) {
        pickedFiles.add(PickedFile(path: file!.filePath, name: basename(file.filePath!)));
      }).toList();

      Navigator.pop(context, InstaPickerResult(pickedFiles: pickedFiles, resultType: ResultType.IMAGE));
    }
  }
}
