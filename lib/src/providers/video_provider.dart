import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:insta_picker/src/models/options.dart';
import 'package:insta_picker/src/models/result.dart';
import 'package:insta_picker/src/providers/camera_provider.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:path/path.dart';

class VideoProvider extends CameraProvider {
  String? videoPath;

  Timer? _timer;
  int? _duration;
  int? _durationLimit;
  bool _stopping = false;

  late Translations _translations;

  set translations(Translations translations) {
    this._translations = translations;
  }

  @override
  List<FlashMode> get flashModes => const [FlashMode.off, FlashMode.torch];

  void startVideoRecording(BuildContext context) async {
    if (controller == null || !controller!.value.isInitialized) return;

    if (controller!.value.isRecordingVideo) return;

    try {
      await controller!.startVideoRecording();
      if (context.mounted) _startTimer(context);
    } on CameraException catch (e) {
      logger.e(e);
      videoPath = null;
    }

    notifyListeners();
  }

  void stopVideoRecording(BuildContext context) async {
    if (_stopping || controller == null || !controller!.value.isRecordingVideo) return;

    _stopping = true;
    cancelTimer();

    try {
      final XFile file = await controller!.stopVideoRecording();
      videoPath = file.path;
    } on CameraException catch (e) {
      logger.e(e);
      videoPath = null;
    } finally {
      _stopping = false;
    }

    notifyListeners();

    if (videoPath == null || !context.mounted) return;

    final String recordedPath = videoPath!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            this._translations.recordedVideo,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(this._translations.whatDoYouWantToDo),
          actions: <Widget>[
            TextButton(
                child: Text(this._translations.delete),
                onPressed: () {
                  Navigator.of(dialogContext, rootNavigator: true).pop();

                  File(recordedPath).delete().catchError((e) {
                    logger.w(e);
                    return File(recordedPath);
                  });
                }),
            TextButton(
                child: Text(this._translations.validate),
                onPressed: () {
                  Navigator.of(dialogContext, rootNavigator: true).pop();

                  if (context.mounted) {
                    Navigator.pop(context, InstaPickerResult(pickedFiles: [PickedFile(path: recordedPath, name: basename(recordedPath))], resultType: ResultType.VIDEO));
                  }
                }),
          ],
        );
      },
    );
  }

  void manageTooltip(JustTheController controller) {
    if (controller.value == TooltipStatus.isShowing) {
      controller.hideTooltip();
    } else {
      controller.showTooltip();
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (controller.value == TooltipStatus.isShowing) controller.hideTooltip();
      });
    }
  }

  void _startTimer(BuildContext context) {
    _timer?.cancel();
    _duration = 0;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_duration! >= _durationLimit!) {
          stopVideoRecording(context);
        } else {
          _duration = _duration! + 1;
        }
        notifyListeners();
      },
    );
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _duration = 0;
  }

  @override
  Future<void> disposeCamera() async {
    cancelTimer();
    await super.disposeCamera();
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }

  double getIndicatorProgress() {
    return _duration != null && _durationLimit != null ? _duration! / _durationLimit! : 0.0;
  }

  String showDuration() {
    if (_duration == null) return '00';

    return _duration.toString().length < 2 ? '0$_duration' : '$_duration';
  }

  set durationLimit(int d) {
    _durationLimit = d <= 60 ? d : 60;
  }
}
