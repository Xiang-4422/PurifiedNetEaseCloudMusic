import 'package:bujuan/data/local/local_library_data_source.dart';

abstract class AppDatabase {
  Future<void> init();

  LocalLibraryDataSource get localLibraryDataSource;
}
