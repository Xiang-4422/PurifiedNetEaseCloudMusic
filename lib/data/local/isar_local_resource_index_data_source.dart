import 'package:bujuan/core/database/isar_local_resource_entity.dart';
import 'package:bujuan/domain/entities/local_resource_entry.dart';
import 'package:isar/isar.dart';

import 'local_resource_index_data_source.dart';
import 'local_resource_record_codec.dart';

class IsarLocalResourceIndexDataSource implements LocalResourceIndexDataSource {
  IsarLocalResourceIndexDataSource({required Isar isar}) : _isar = isar;

  final Isar _isar;

  @override
  Future<LocalResourceEntry?> getResource(
    String trackId,
    LocalResourceKind kind,
  ) async {
    final entity = await _isar.isarLocalResourceEntitys
        .filter()
        .trackIdEqualTo(trackId)
        .and()
        .kindEqualTo(kind.name)
        .findFirst();
    if (entity == null) {
      return null;
    }
    return LocalResourceRecordCodec.decodeEntity(entity);
  }

  @override
  Future<List<LocalResourceEntry>> getTrackResources(String trackId) async {
    final entities = await _isar.isarLocalResourceEntitys
        .filter()
        .trackIdEqualTo(trackId)
        .sortByKind()
        .findAll();
    return entities.map(LocalResourceRecordCodec.decodeEntity).toList();
  }

  @override
  Future<void> saveResource(LocalResourceEntry entry) async {
    final entity = LocalResourceRecordCodec.encodeEntity(entry);
    await _isar.writeTxn(() async {
      await _isar.isarLocalResourceEntitys.putByTrackIdKind(entity);
    });
  }

  @override
  Future<void> removeResource(String trackId, LocalResourceKind kind) async {
    await _isar.writeTxn(() async {
      await _isar.isarLocalResourceEntitys
          .filter()
          .trackIdEqualTo(trackId)
          .and()
          .kindEqualTo(kind.name)
          .deleteAll();
    });
  }

  @override
  Future<void> removeTrackResources(String trackId) async {
    await _isar.writeTxn(() async {
      await _isar.isarLocalResourceEntitys
          .filter()
          .trackIdEqualTo(trackId)
          .deleteAll();
    });
  }
}
