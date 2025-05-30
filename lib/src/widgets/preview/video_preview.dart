import 'package:flutter/material.dart';
import 'package:insta_picker/src/models/file_model.dart';
import 'package:insta_picker/src/models/options.dart';
import 'package:insta_picker/src/providers/video_preview_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_trimmer/video_trimmer.dart';

Options? options;

class VideoPreview extends StatelessWidget {
  final List<FileModel?>? files;

  VideoPreview({required Options? imagePreviewOptions, this.files}) {
    options = imagePreviewOptions;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VideoPreviewProvider>(
      create: (_) => VideoPreviewProvider(),
      child: VideoPreviewContent(files: this.files),
    );
  }
}

class VideoPreviewContent extends StatefulWidget {
  final List<FileModel?>? files;

  VideoPreviewContent({Key? key, this.files}) : super(key: key);

  @override
  _VideoPreviewContentState createState() => _VideoPreviewContentState();
}

class _VideoPreviewContentState extends State<VideoPreviewContent> {
  late VideoPreviewProvider _videoPreviewProvider;

  @override
  void initState() {
    super.initState();

    _videoPreviewProvider = Provider.of<VideoPreviewProvider>(context, listen: false);
    _videoPreviewProvider.files = widget.files;

    _videoPreviewProvider.loadVideoTrimmer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: options!.customizationOptions.bgColor,
        appBar: AppBar(
          elevation: 0.0,
          title: Text(
            options!.translations.preview,
            style: TextStyle(color: options!.customizationOptions.textColor),
          ),
          leading: GestureDetector(
            child: Icon(
              Icons.arrow_back,
              color: options!.customizationOptions.iconsColor,
            ),
            onTap: () {
              Navigator.pop(context, null);
            },
          ),
          actions: [
            GestureDetector(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.check,
                  color: options!.customizationOptions.iconsColor,
                ),
              ),
              onTap: () {
                _videoPreviewProvider.submit(context);
              },
            )
          ],
          backgroundColor: options!.customizationOptions.appBarColor,
        ),
        body: TrimmerView());
  }
}

class TrimmerView extends StatefulWidget {
  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<VideoPreviewProvider>(builder: (ctx, provider, child) {
      return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Visibility(
              visible: provider.progressVisibility,
              child: LinearProgressIndicator(
                backgroundColor: options!.customizationOptions.accentColor,
              ),
            ),
            Expanded(
              child: VideoViewer(trimmer: provider.trimmer),
            ),
            Center(
              child: TrimViewer(
                viewerHeight: 50.0,
                trimmer: provider.trimmer,
                viewerWidth: MediaQuery.of(context).size.width,
                maxVideoLength: Duration(seconds: options!.customizationOptions.videoCustomization.maximumRecordingDuration.inSeconds),
                durationTextStyle: TextStyle(color: options!.customizationOptions.textColor),
                editorProperties: TrimEditorProperties(
                  scrubberPaintColor: options!.customizationOptions.accentColor,
                  borderPaintColor: options!.customizationOptions.accentColor,
                  circlePaintColor: options!.customizationOptions.accentColor,
                ),
                onChangeStart: (value) {
                  provider.startValue = value;
                },
                onChangeEnd: (value) {
                  provider.endValue = value;
                },
                onChangePlaybackState: (value) {
                  provider.isPlaying = value;
                },
              ),
            ),
            TextButton(
              child: provider.isPlaying!
                  ? Icon(
                      Icons.pause,
                      size: 80.0,
                      color: options!.customizationOptions.iconsColor,
                    )
                  : Icon(
                      Icons.play_arrow,
                      size: 80.0,
                      color: options!.customizationOptions.iconsColor,
                    ),
              onPressed: () async {
                bool? playbackState = await provider.trimmer.videPlaybackControl(
                  startValue: provider.startValue,
                  endValue: provider.endValue,
                );
                provider.isPlaying = playbackState;
              },
            )
          ],
        ),
      );
    });
  }
}
