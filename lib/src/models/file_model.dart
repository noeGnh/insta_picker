import 'dart:ui';

import 'package:photo_manager/photo_manager.dart';

class FileModel {
  AssetEntity? asset;
  AssetType? type;
  Duration? duration;
  Size? size;
  int? width;
  int? height;
  DateTime? createDt;
  DateTime? modifiedDt;
  double? latitude;
  double? longitude;
  LatLng? ll;
  String? mediaUrl;
  String? title;
  String? relativePath;
  String? filePath;
  String? thumbPath;

  FileModel(
      {this.asset,
      this.duration,
      this.type,
      this.size,
      this.width,
      this.height,
      this.createDt,
      this.modifiedDt,
      this.latitude,
      this.longitude,
      this.ll,
      this.mediaUrl,
      this.title,
      this.relativePath,
      this.filePath,
      this.thumbPath});

  factory FileModel.fromAsset(AssetEntity asset) => FileModel(
      asset: asset,
      duration: asset.videoDuration,
      type: asset.type,
      size: asset.size,
      width: asset.width,
      height: asset.height,
      createDt: asset.createDateTime,
      modifiedDt: asset.modifiedDateTime,
      latitude: asset.latitude,
      longitude: asset.longitude,
      title: asset.title,
      relativePath: asset.relativePath);

  FileModel copy() => FileModel(
      asset: asset,
      duration: duration,
      type: type,
      size: size,
      width: width,
      height: height,
      createDt: createDt,
      modifiedDt: modifiedDt,
      latitude: latitude,
      longitude: longitude,
      ll: ll,
      mediaUrl: mediaUrl,
      title: title,
      relativePath: relativePath,
      filePath: filePath,
      thumbPath: thumbPath);

  /// Resolves [filePath] from [asset] when it is not known yet (it may require a download from iCloud).
  Future<String?> resolveFilePath() async {
    if (filePath == null && asset != null) filePath = (await asset!.file)?.path;
    return filePath;
  }
}
