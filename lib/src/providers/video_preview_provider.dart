import 'dart:io';

import 'package:flutter/material.dart';
import 'package:insta_picker/src/models/file_model.dart';
import 'package:insta_picker/src/models/result.dart';
import 'package:path/path.dart';
import 'package:video_trimmer/video_trimmer.dart';

class VideoPreviewProvider extends ChangeNotifier {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool? _isPlaying = false;
  bool _progressVisibility = false;

  get trimmer => this._trimmer;

  double get endValue => this._endValue;

  bool? get isPlaying => this._isPlaying;

  double get startValue => this._startValue;

  bool get progressVisibility => this._progressVisibility;

  set isPlaying(bool? v) {
    this._isPlaying = v;
    notifyListeners();
  }

  set endValue(double v) {
    this._endValue = v;
  }

  set startValue(double v) {
    this._startValue = v;
  }

  set progressVisibility(bool v) {
    this._progressVisibility = v;
    notifyListeners();
  }

  List<FileModel?>? files;

  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    // The trimmer and its video player are released by the video_trimmer widgets.
    _disposed = true;
    super.dispose();
  }

  loadVideoTrimmer() async => await _trimmer.loadVideo(videoFile: File(files![0]!.filePath!));

  submit(BuildContext context) async {
    if (this._progressVisibility) return;

    this.progressVisibility = true;

    this._trimmer.saveTrimmedVideo(
          startValue: _startValue,
          endValue: _endValue,
          onSave: (String? outputPath) {
            this.progressVisibility = false;

            if (outputPath == null || !context.mounted) return;

            Navigator.pop(context, InstaPickerResult(pickedFiles: [PickedFile(path: outputPath, name: basename(outputPath))], resultType: ResultType.VIDEO));
          },
        );
  }
}
