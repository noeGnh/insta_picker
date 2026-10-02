import 'package:flutter/material.dart';
import 'package:insta_picker/src/providers/photo_provider.dart';
import 'package:insta_picker/src/providers/video_provider.dart';
import 'package:provider/provider.dart';

class PickerProvider extends ChangeNotifier {
  PageController? pageController;
  TabController? tabController;

  bool pageIsChanging = false;

  int currentIndex = 0;

  void init(BuildContext context, Map<String, int> indexes) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) activateCamera(context, 0, indexes);
    });
  }

  /// Opens the camera of the tab at [index] (if it has one) and releases the camera of the other tab.
  void activateCamera(BuildContext context, int index, Map<String, int> indexes) {
    PhotoProvider photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    VideoProvider videoProvider = Provider.of<VideoProvider>(context, listen: false);

    if (index == indexes['PHOTO_PAGE_INDEX']) {
      videoProvider.disposeCamera().then((_) => photoProvider.getAvailableCameras());
    } else if (index == indexes['VIDEO_PAGE_INDEX']) {
      photoProvider.disposeCamera().then((_) => videoProvider.getAvailableCameras());
    } else {
      releaseCameras(context);
    }
  }

  void releaseCameras(BuildContext context) {
    Provider.of<PhotoProvider>(context, listen: false).disposeCamera();
    Provider.of<VideoProvider>(context, listen: false).disposeCamera();
  }

  void onPageChange(BuildContext context, int index, Map<String, int> indexes) async {
    if (tabController == null || pageController == null || pageIsChanging) return;

    currentIndex = index;

    await pageController!.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);

    tabController!.animateTo(index);

    pageIsChanging = false;

    if (context.mounted) activateCamera(context, index, indexes);
  }
}
