import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// Camera logic shared by the photo and video tabs.
///
/// Only one tab may hold the camera at a time: the picker calls [disposeCamera] on the tab that is left.
abstract class CameraProvider extends ChangeNotifier {
  final Logger logger = Logger();

  CameraController? controller;
  int selectedCameraIdx = 0;
  List<CameraDescription>? cameras;

  FlashMode flashMode = FlashMode.off;

  bool _disposed = false;

  /// Incremented on each camera (re)initialization or release, to drop the results of outdated initializations.
  int _cameraToken = 0;

  /// Flash modes the flash button cycles through.
  List<FlashMode> get flashModes;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cameraToken++;
    controller?.dispose();
    controller = null;
    super.dispose();
  }

  Future<void> onFlashButtonPressed() async {
    final int index = flashModes.indexOf(flashMode);
    final FlashMode next = flashModes[(index + 1) % flashModes.length];

    try {
      await controller!.setFlashMode(next);
      flashMode = next;
    } on CameraException catch (e) {
      logger.e(e);
    }

    notifyListeners();
  }

  Future<void> getAvailableCameras() async {
    final int token = ++_cameraToken;

    try {
      cameras ??= await availableCameras();
    } on CameraException catch (e) {
      logger.e('Error: ${e.code}\nError Message: ${e.description}');
      return;
    }

    if (cameras!.isEmpty) {
      logger.w("No camera available");
      return;
    }

    if (selectedCameraIdx >= cameras!.length) selectedCameraIdx = 0;

    notifyListeners();

    await _initCameraController(cameras![selectedCameraIdx], token);
  }

  Future<void> _initCameraController(CameraDescription cameraDescription, int token) async {
    final CameraController? previous = controller;
    if (previous != null) {
      controller = null;
      notifyListeners();
      await previous.dispose();
    }

    if (token != _cameraToken) return;

    final CameraController newController = CameraController(cameraDescription, ResolutionPreset.high);

    newController.addListener(() {
      if (newController.value.hasError) {
        logger.e('Camera error ${newController.value.errorDescription}');
      }
    });

    try {
      await newController.initialize();
      await newController.setFlashMode(flashMode);
    } on CameraException catch (e) {
      logger.e(e);
    }

    if (token != _cameraToken) {
      await newController.dispose();
      return;
    }

    controller = newController;
    notifyListeners();
  }

  /// Releases the camera, so that the other tab or the system can use it.
  Future<void> disposeCamera() async {
    _cameraToken++;

    final CameraController? previous = controller;
    if (previous == null) return;

    controller = null;
    notifyListeners();

    await previous.dispose();
  }

  void onSwitchCamera() {
    if (cameras == null || cameras!.isEmpty) return;

    selectedCameraIdx = selectedCameraIdx < cameras!.length - 1 ? selectedCameraIdx + 1 : 0;
    _initCameraController(cameras![selectedCameraIdx], ++_cameraToken);
  }
}
