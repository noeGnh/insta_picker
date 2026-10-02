import 'package:flutter/material.dart';

class Options {
  bool showGalleryTab;
  bool showPhotoTab;
  bool showVideoTab;
  Translations translations;
  CustomizationOptions customizationOptions;

  Options({this.showGalleryTab = true, this.showPhotoTab = true, this.showVideoTab = true, Translations? translations, CustomizationOptions? customizationOptions})
      : this.translations = translations ?? Translations(),
        this.customizationOptions = customizationOptions ?? CustomizationOptions(),
        assert(showGalleryTab || showPhotoTab || showVideoTab);
}

class CustomizationOptions {
  Color bgColor;
  Color textColor;
  Color iconsColor;
  Color accentColor;
  Color appBarColor;
  Color tabBarColor;
  Color tabBarTextColor;
  Color tabBarIndicatorColor;
  GalleryCustomization galleryCustomization;
  PhotoCustomization photoCustomization;
  VideoCustomization videoCustomization;

  CustomizationOptions(
      {this.bgColor = Colors.white,
      this.textColor = Colors.black,
      this.accentColor = Colors.black,
      this.appBarColor = Colors.white,
      this.iconsColor = Colors.black,
      this.tabBarColor = Colors.white,
      this.tabBarTextColor = Colors.black,
      this.tabBarIndicatorColor = Colors.black,
      GalleryCustomization? galleryCustomization,
      PhotoCustomization? photoCustomization,
      VideoCustomization? videoCustomization})
      : this.galleryCustomization = galleryCustomization ?? GalleryCustomization(),
        this.photoCustomization = photoCustomization ?? PhotoCustomization(),
        this.videoCustomization = videoCustomization ?? VideoCustomization();
}

class GalleryCustomization {
  Color gridBgColor;
  int maxSelectable;
  Color selectedFileContainerColor;

  GalleryCustomization({
    this.maxSelectable = 1,
    this.gridBgColor = Colors.white,
    this.selectedFileContainerColor = Colors.white,
  }) {
    if (this.maxSelectable <= 0) {
      throw ArgumentError('The maximum gallery selectable items value must be greater than 0');
    }
  }
}

class PhotoCustomization {
  PhotoCustomization();
}

class VideoCustomization {
  Duration maximumRecordingDuration;

  VideoCustomization({this.maximumRecordingDuration = const Duration(seconds: 30)}) : assert(maximumRecordingDuration.inSeconds > 0 && maximumRecordingDuration.inSeconds <= 60);
}

class Translations {
  String galleryTabTitle;
  String photoTabTitle;
  String videoTabTitle;
  String pressAndHoldToRecord;
  String preview;
  String multiSelectionDoesntSupportVideos;
  String filters;
  String save;
  String cancel;
  String recordedVideo;
  String whatDoYouWantToDo;
  String delete;
  String validate;
  String maxSelectionReached;
  String videoTooLong;

  Translations(
      {this.galleryTabTitle = 'Gallery',
      this.photoTabTitle = 'Photo',
      this.videoTabTitle = 'Video',
      this.pressAndHoldToRecord = 'Press and hold to record',
      this.preview = 'Preview',
      this.multiSelectionDoesntSupportVideos = 'Multi-selection does not support videos',
      this.filters = 'Filters',
      this.save = 'Save',
      this.cancel = 'Cancel',
      this.recordedVideo = 'Recorded Video',
      this.whatDoYouWantToDo = 'What do you want to do ?',
      this.delete = 'Delete',
      this.validate = 'Validate',
      this.maxSelectionReached = 'You can select up to {max} items',
      this.videoTooLong = 'This video is too long'});
}
