import 'package:bujuan/core/database/drift_database.dart';

class UserDao {
  UserDao({required BujuanDriftDatabase database}) : _database = database;

  final BujuanDriftDatabase _database;

  BujuanDriftDatabase get database => _database;
}
