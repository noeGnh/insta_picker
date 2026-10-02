import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:insta_picker/src/models/options.dart';
import 'package:insta_picker/src/providers/photo_provider.dart';
import 'package:provider/provider.dart';

Options? options;

class Photo extends StatelessWidget {
  Photo({required Options? photoViewOptions}) {
    options = photoViewOptions;
  }

  @override
  Widget build(BuildContext context) => PhotoView();
}

class PhotoView extends StatefulWidget {
  @override
  _PhotoViewState createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView> with AutomaticKeepAliveClientMixin {
  late PhotoProvider photoProvider;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    photoProvider = Provider.of<PhotoProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: options!.customizationOptions.bgColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: CameraPreviewWidget(),
            ),
            SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CameraTogglesRowWidget(),
                CaptureControlRowWidget(),
                FlashToggleRowWidget(),
              ],
            ),
            SizedBox(height: 20.0)
          ],
        ),
      ),
    );
  }
}

class CameraPreviewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    PhotoProvider photoProvider = Provider.of<PhotoProvider>(context, listen: true);

    if (photoProvider.controller == null || !photoProvider.controller!.value.isInitialized) {
      return Stack(
        children: [
          Positioned(
              child: Container(
                  width: size.width,
                  child: LinearProgressIndicator(backgroundColor: options!.customizationOptions.bgColor, valueColor: AlwaysStoppedAnimation<Color>(options!.customizationOptions.accentColor))))
        ],
      );
    }

    return AspectRatio(
      aspectRatio: photoProvider.controller!.value.aspectRatio,
      child: CameraPreview(photoProvider.controller!),
    );
  }
}

class CaptureControlRowWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PhotoProvider photoProvider = Provider.of<PhotoProvider>(context, listen: true);

    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            FloatingActionButton(
                heroTag: null,
                child: Icon(
                  Icons.camera,
                  color: options!.customizationOptions.bgColor,
                ),
                backgroundColor: options!.customizationOptions.iconsColor,
                onPressed: () {
                  photoProvider.onCapturePressed(context, options!);
                })
          ],
        ),
      ),
    );
  }
}

class CameraTogglesRowWidget extends StatelessWidget {

  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
    }
  }

  @override
  Widget build(BuildContext context) {
    PhotoProvider photoProvider = Provider.of<PhotoProvider>(context, listen: true);

    if (photoProvider.cameras == null || photoProvider.cameras!.isEmpty) return Spacer();

    CameraDescription selectedCamera = photoProvider.cameras![photoProvider.selectedCameraIdx];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
      child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(left: 21),
              child: Icon(
                _getCameraLensIcon(lensDirection),
                color: options!.customizationOptions.iconsColor,
                size: 32,
              ),
            ),
            onTap: () {
              photoProvider.onSwitchCamera();
            },
          )),
    );
  }
}

class FlashToggleRowWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PhotoProvider photoProvider = Provider.of<PhotoProvider>(context, listen: true);

    IconData iconData;

    switch (photoProvider.flashMode) {
      case FlashMode.auto:
        iconData = Icons.flash_auto;
        break;

      case FlashMode.torch:
        iconData = Icons.flash_on;
        break;

      default:
        iconData = Icons.flash_off;
    }

    return Expanded(
      child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(right: 21),
              child: Icon(
                iconData,
                color: options!.customizationOptions.iconsColor,
                size: 32,
              ),
            ),
            onTap: () {
              if (photoProvider.controller != null && photoProvider.controller!.value.isInitialized) {
                photoProvider.onFlashButtonPressed();
              }
            },
          )),
    );
  }
}
