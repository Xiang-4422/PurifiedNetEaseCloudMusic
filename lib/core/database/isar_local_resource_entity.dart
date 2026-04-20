import 'package:isar/isar.dart';

part 'isar_local_resource_entity.g.dart';

@collection
class IsarLocalResourceEntity {
  IsarLocalResourceEntity({
    this.id = Isar.autoIncrement,
    required this.schemaVersion,
    required this.trackId,
    required this.kind,
    required this.path,
    required this.origin,
    required this.updatedAtMs,
  });

  Id id;
  int schemaVersion;
  @Index(
    composite: [CompositeIndex('kind')],
    unique: true,
    replace: true,
  )
  String trackId;
  String kind;
  String path;
  String origin;
  int updatedAtMs;
}
