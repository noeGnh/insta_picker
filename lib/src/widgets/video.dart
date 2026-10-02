import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:insta_picker/src/models/options.dart';
import 'package:insta_picker/src/providers/video_provider.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';

Options? options;

class Video extends StatelessWidget {
  Video({required Options? videoViewOptions}) {
    options = videoViewOptions;
  }

  @override
  Widget build(BuildContext context) => VideoView();
}

class VideoView extends StatefulWidget {
  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> with AutomaticKeepAliveClientMixin {
  late VideoProvider provider;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    provider = Provider.of<VideoProvider>(context, listen: false);

    provider.translations = options!.translations;
    provider.durationLimit = options!.customizationOptions.videoCustomization.maximumRecordingDuration.inSeconds;
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
            Consumer<VideoProvider>(builder: (ctx, provider, child) {
              return LinearProgressIndicator(
                value: provider.getIndicatorProgress(),
                valueColor: AlwaysStoppedAnimation<Color>(options!.customizationOptions.accentColor),
                backgroundColor: Colors.white,
              );
            }),
            SizedBox(height: 5.0),
            Consumer<VideoProvider>(builder: (ctx, provider, child) {
              return Text(
                "00 : ${provider.showDuration()}",
                textAlign: TextAlign.center,
              );
            }),
            SizedBox(height: 15.0),
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

    VideoProvider videoProvider = Provider.of<VideoProvider>(context, listen: true);

    if (videoProvider.controller == null || !videoProvider.controller!.value.isInitialized) {
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
      aspectRatio: videoProvider.controller!.value.aspectRatio,
      child: CameraPreview(videoProvider.controller!),
    );
  }
}

class CaptureControlRowWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    VideoProvider videoProvider = Provider.of<VideoProvider>(context, listen: true);

    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [VideoCaptureButton(videoProvider)],
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
    VideoProvider videoProvider = Provider.of<VideoProvider>(context, listen: true);

    if (videoProvider.cameras == null || videoProvider.cameras!.isEmpty) return Spacer();

    CameraDescription selectedCamera = videoProvider.cameras![videoProvider.selectedCameraIdx];
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
              videoProvider.onSwitchCamera();
            },
          )),
    );
  }
}

class FlashToggleRowWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    VideoProvider videoProvider = Provider.of<VideoProvider>(context, listen: true);

    IconData iconData;

    switch (videoProvider.flashMode) {
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
              if (videoProvider.controller != null && videoProvider.controller!.value.isInitialized) {
                videoProvider.onFlashButtonPressed();
              }
            },
          )),
    );
  }
}

class VideoCaptureButton extends StatefulWidget {
  final VideoProvider videoProvider;

  VideoCaptureButton(this.videoProvider, {Key? key}) : super(key: key);

  @override
  _VideoCaptureButtonState createState() => _VideoCaptureButtonState();
}

class _VideoCaptureButtonState extends State<VideoCaptureButton> {
  final tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return JustTheTooltip(
      preferredDirection: AxisDirection.up,
      controller: tooltipController,
      child: GestureDetector(
        onLongPressStart: (d) => widget.videoProvider.startVideoRecording(context),
        onLongPressEnd: (d) => widget.videoProvider.stopVideoRecording(context),
        child: FloatingActionButton(
          heroTag: null,
          child: Icon(
            Icons.camera,
            color: options!.customizationOptions.bgColor,
          ),
          backgroundColor: options!.customizationOptions.iconsColor,
          onPressed: () => widget.videoProvider.manageTooltip(tooltipController),
        ),
      ),
      content: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          options!.translations.pressAndHoldToRecord,
        ),
      ),
    );
  }
}
