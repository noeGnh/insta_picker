import 'package:flutter/material.dart';
import 'package:insta_picker/insta_picker.dart';
import 'package:insta_picker/src/models/file_model.dart';
import 'package:insta_picker/src/models/folder_model.dart';
import 'package:insta_picker/src/utils/utils.dart';
import 'package:insta_picker/src/widgets/preview/image_preview.dart';
import 'package:insta_picker/src/widgets/preview/video_preview.dart';
import 'package:logger/logger.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryProvider extends ChangeNotifier {
  final Logger logger = Logger();

  static const int VIDEO_LENGTH_LIMIT = 30;

  FileModel? _selectedFile;
  late Translations _translations;
  FolderModel? _selectedFolder;
  List<FileModel?> _files = [];
  List<FolderModel> _folders = [];

  int _multiSelectLimit = 1;
  bool _multiSelect = false;
  bool _loadStarted = false;
  bool _disposed = false;
  int _selectionToken = 0;

  List<FileModel?> get files => this._files;
  List<FolderModel> get folders => this._folders;
  FileModel? get selectedFile => this._selectedFile;
  FolderModel? get selectedFolder => this._selectedFolder;

  bool get multiSelect => this._multiSelect;

  set multiSelect(bool b) {
    this._files.clear();
    this._multiSelect = b;
    notifyListeners();
  }

  set multiSelectLimit(int limit) {
    this._multiSelectLimit = limit;
  }

  set selectedFile(FileModel? file) {
    this._selectedFile = file;
    notifyListeners();
  }

  set translations(Translations translations) {
    this._translations = translations;
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  getCheckNumber(FileModel? file) => this._files.indexOf(file) + 1;

  getCheckState(FileModel? file) => this._files.contains(file);

  toggleCheckState(FileModel? file) {
    if (getCheckState(file)) {
      this._files.remove(file);
    } else {
      if (file!.type == AssetType.video) {
        Utils.showToast(this._translations.multiSelectionDoesntSupportVideos);
        return;
      }

      if (this._files.length >= this._multiSelectLimit) {
        Utils.showToast(this._translations.maxSelectionReached.replaceAll('{max}', '${this._multiSelectLimit}'));
        return;
      }

      this._files.add(file);
    }
    notifyListeners();
  }

  /// Selects [file] once its path is known, so that the preview can display it.
  Future<void> selectFile(FileModel? file) async {
    final int token = ++_selectionToken;

    if (file != null && await file.resolveFilePath() == null) {
      logger.w('Unable to get the file of asset ${file.asset?.id}');
      return;
    }

    if (token == _selectionToken) this.selectedFile = file;
  }

  Future<void> getFilesPath() async {
    if (_loadStarted) return;
    _loadStarted = true;

    final PermissionState permission = await PhotoManager.requestPermissionExtend();
    if (!permission.hasAccess) {
      logger.w('Gallery permission denied');
      return;
    }

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.common,
        filterOption: FilterOptionGroup()
          ..setOption(
              AssetType.video,
              const FilterOption(
                  durationConstraint: DurationConstraint(
                max: Duration(minutes: VIDEO_LENGTH_LIMIT),
              ))));

    for (final AssetPathEntity path in paths) {
      final int count = await path.assetCountAsync;
      if (count == 0) continue;

      this._folders.add(FolderModel(path: path, name: path.name, id: path.id, type: path.albumType, count: count));
    }

    if (this._folders.isNotEmpty) await onFolderSelected(this._folders[0]);

    notifyListeners();
  }

  List<DropdownMenuItem<FolderModel>> getItems() {
    return this
        ._folders
        .map((e) => DropdownMenuItem<FolderModel>(
              child: SizedBox(
                width: 190,
                child: Text(
                  e.name!,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              value: e,
            ))
        .toList();
  }

  Future<void> onFolderSelected(FolderModel folder, {int index = 0}) async {
    this._selectedFolder = folder;
    notifyListeners();

    if (folder.files == null) {
      final List<AssetEntity> assets = await folder.path!.getAssetListRange(start: 0, end: folder.count ?? 0);
      folder.files = assets.map((asset) => FileModel.fromAsset(asset)).toList();
    }

    if (this._selectedFolder != folder) return;

    notifyListeners();

    if (folder.files!.length > index) await selectFile(folder.files![index]);
  }

  void submit(BuildContext context, Options options) async {
    if (this._multiSelect) {
      this._returnImageResult(context, options);
    } else {
      if (this._selectedFile != null) {
        this._files.clear();
        this._files.add(this._selectedFile);

        if (this._selectedFile!.type == AssetType.video) {
          if (this._selectedFile!.duration != null && this._selectedFile!.duration!.inMinutes <= VIDEO_LENGTH_LIMIT) {
            InstaPickerResult? result = await Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => VideoPreview(
                      files: this._files.map((file) => file!.copy()).toList(),
                      imagePreviewOptions: options,
                    )));

            if (result != null && context.mounted) Navigator.pop(context, result);
          } else {
            Utils.showToast(this._translations.videoTooLong);
          }
        } else {
          this._returnImageResult(context, options);
        }
      } else {
        logger.i('No file selected');
      }
    }
  }

  void _returnImageResult(BuildContext context, Options options) async {
    if (this._files.isEmpty) return;

    for (final FileModel? file in this._files) {
      if (await file!.resolveFilePath() == null) {
        logger.w('Unable to get the file of asset ${file.asset?.id}');
        return;
      }
    }

    if (!context.mounted) return;

    InstaPickerResult? result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => ImagePreview(
              // Copies, so that the edits made in the preview do not alter the gallery files.
              files: this._files.map((file) => file!.copy()).toList(),
              imagePreviewOptions: options,
              showAddButton: options.customizationOptions.galleryCustomization.maxSelectable > 1,
            )));

    if (result != null && context.mounted) Navigator.pop(context, result);
  }
}
