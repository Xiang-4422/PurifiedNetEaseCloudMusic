import 'package:bujuan/core/database/drift_database.dart';

class DownloadTaskDao {
  DownloadTaskDao({required BujuanDriftDatabase database})
      : _database = database;

  final BujuanDriftDatabase _database;

  BujuanDriftDatabase get database => _database;
}
