import 'package:flutter/material.dart';
import 'package:insta_picker/src/models/options.dart';
import 'package:insta_picker/src/models/result.dart';
import 'package:insta_picker/src/providers/gallery_provider.dart';
import 'package:insta_picker/src/providers/photo_provider.dart';
import 'package:insta_picker/src/providers/picker_provider.dart';
import 'package:insta_picker/src/providers/video_provider.dart';
import 'package:insta_picker/src/widgets/gallery.dart';
import 'package:insta_picker/src/widgets/photo.dart';
import 'package:insta_picker/src/widgets/video.dart';
import 'package:provider/provider.dart';

class InstaPicker {
  static Future<InstaPickerResult?> pick(BuildContext context, {Options? options}) async =>
      await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => Picker(options: options ?? Options())));
}

class Picker extends StatelessWidget {
  final Options options;

  Picker({Options? options}) : options = options ?? Options();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PhotoProvider>(create: (_) => PhotoProvider()),
        ChangeNotifierProvider<VideoProvider>(create: (_) => VideoProvider()),
        ChangeNotifierProvider<PickerProvider>(create: (_) => PickerProvider()),
        ChangeNotifierProvider<GalleryProvider>(create: (_) => GalleryProvider()),
      ],
      child: PickerView(options: options),
    );
  }
}

class PickerView extends StatefulWidget {
  final Options options;

  PickerView({Key? key, required this.options}) : super(key: key);

  @override
  _PickerViewState createState() => _PickerViewState();
}

class _PickerViewState extends State<PickerView> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late PickerProvider _pickerProvider;
  List<Widget> _pages = [];
  List<Widget> _tabs = [];

  Map<String, int> _indexes = {'GALLERY_PAGE_INDEX': -1, 'PHOTO_PAGE_INDEX': -1, 'VIDEO_PAGE_INDEX': -1};

  @override
  void initState() {
    super.initState();

    if (widget.options.showGalleryTab) {
      _pages.add(Gallery(galleryViewOptions: widget.options));
      _tabs.add(Tab(text: widget.options.translations.galleryTabTitle));

      _indexes['GALLERY_PAGE_INDEX'] = 0;
    }

    if (widget.options.showPhotoTab) {
      _pages.add(Photo(photoViewOptions: widget.options));
      _tabs.add(Tab(text: widget.options.translations.photoTabTitle));

      _indexes['PHOTO_PAGE_INDEX'] = _indexes['GALLERY_PAGE_INDEX'] == -1 ? 0 : 1;
    }

    if (widget.options.showVideoTab) {
      _pages.add(Video(videoViewOptions: widget.options));
      _tabs.add(Tab(text: widget.options.translations.videoTabTitle));

      if (_indexes['GALLERY_PAGE_INDEX'] == -1 && _indexes['PHOTO_PAGE_INDEX'] == -1)
        _indexes['VIDEO_PAGE_INDEX'] = 0;
      else if (_indexes['GALLERY_PAGE_INDEX'] != -1 && _indexes['PHOTO_PAGE_INDEX'] == -1)
        _indexes['VIDEO_PAGE_INDEX'] = 1;
      else if (_indexes['GALLERY_PAGE_INDEX'] == -1 && _indexes['PHOTO_PAGE_INDEX'] != -1)
        _indexes['VIDEO_PAGE_INDEX'] = 1;
      else
        _indexes['VIDEO_PAGE_INDEX'] = 2;
    }

    _pickerProvider = Provider.of<PickerProvider>(context, listen: false);
    _pickerProvider.tabController = TabController(length: _pages.length, vsync: this);
    _pickerProvider.pageController = PageController();

    _pickerProvider.init(context, _indexes);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The camera must be released when the app goes to the background, and reopened when it comes back.
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _pickerProvider.releaseCameras(context);
    } else if (state == AppLifecycleState.resumed) {
      _pickerProvider.activateCamera(context, _pickerProvider.currentIndex, _indexes);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pickerProvider.pageController!.dispose();
    _pickerProvider.tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PickerProvider>(builder: (context, provider, child) {
      return Scaffold(
        body: PageView(
          controller: provider.pageController,
          children: _pages,
          onPageChanged: (index) {
            provider.onPageChange(context, index, _indexes);
            if (!provider.pageIsChanging) provider.pageIsChanging = true;
          },
        ),
        bottomNavigationBar: SizedBox(
          child: TabBar(
            controller: provider.tabController,
            tabs: _tabs,
            isScrollable: false,
            indicatorWeight: 1.5,
            labelColor: widget.options.customizationOptions.tabBarTextColor,
            indicatorColor: widget.options.customizationOptions.tabBarIndicatorColor,
            unselectedLabelColor: widget.options.customizationOptions.tabBarTextColor,
            onTap: (index) {
              provider.onPageChange(context, index, _indexes);
              if (!provider.pageIsChanging) provider.pageIsChanging = true;
            },
          ),
        ),
      );
    });
  }
}
