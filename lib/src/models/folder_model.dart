import 'package:insta_picker/src/models/file_model.dart';
import 'package:photo_manager/photo_manager.dart';

class FolderModel {
  AssetPathEntity? path;
  List<FileModel>? files;
  String? name;
  String? id;
  int? type;
  int? count;

  FolderModel({this.path, this.files, this.name, this.id, this.type, this.count});
}
