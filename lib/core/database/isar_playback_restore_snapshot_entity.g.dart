// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_playback_restore_snapshot_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarPlaybackRestoreSnapshotEntityCollection on Isar {
  IsarCollection<IsarPlaybackRestoreSnapshotEntity>
      get isarPlaybackRestoreSnapshotEntitys => this.collection();
}

const IsarPlaybackRestoreSnapshotEntitySchema = CollectionSchema(
  name: r'IsarPlaybackRestoreSnapshotEntity',
  id: -1859852404307101940,
  properties: {
    r'currentSongId': PropertySchema(
      id: 0,
      name: r'currentSongId',
      type: IsarType.string,
    ),
    r'playbackMode': PropertySchema(
      id: 1,
      name: r'playbackMode',
      type: IsarType.string,
    ),
    r'playlistHeader': PropertySchema(
      id: 2,
      name: r'playlistHeader',
      type: IsarType.string,
    ),
    r'playlistName': PropertySchema(
      id: 3,
      name: r'playlistName',
      type: IsarType.string,
    ),
    r'positionMs': PropertySchema(
      id: 4,
      name: r'positionMs',
      type: IsarType.long,
    ),
    r'queue': PropertySchema(
      id: 5,
      name: r'queue',
      type: IsarType.stringList,
    ),
    r'repeatMode': PropertySchema(
      id: 6,
      name: r'repeatMode',
      type: IsarType.string,
    ),
    r'schemaVersion': PropertySchema(
      id: 7,
      name: r'schemaVersion',
      type: IsarType.long,
    ),
    r'updatedAtMs': PropertySchema(
      id: 8,
      name: r'updatedAtMs',
      type: IsarType.long,
    )
  },
  estimateSize: _isarPlaybackRestoreSnapshotEntityEstimateSize,
  serialize: _isarPlaybackRestoreSnapshotEntitySerialize,
  deserialize: _isarPlaybackRestoreSnapshotEntityDeserialize,
  deserializeProp: _isarPlaybackRestoreSnapshotEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _isarPlaybackRestoreSnapshotEntityGetId,
  getLinks: _isarPlaybackRestoreSnapshotEntityGetLinks,
  attach: _isarPlaybackRestoreSnapshotEntityAttach,
  version: '3.1.0+1',
);

int _isarPlaybackRestoreSnapshotEntityEstimateSize(
  IsarPlaybackRestoreSnapshotEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.currentSongId.length * 3;
  bytesCount += 3 + object.playbackMode.length * 3;
  bytesCount += 3 + object.playlistHeader.length * 3;
  bytesCount += 3 + object.playlistName.length * 3;
  bytesCount += 3 + object.queue.length * 3;
  {
    for (var i = 0; i < object.queue.length; i++) {
      final value = object.queue[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.repeatMode.length * 3;
  return bytesCount;
}

void _isarPlaybackRestoreSnapshotEntitySerialize(
  IsarPlaybackRestoreSnapshotEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.currentSongId);
  writer.writeString(offsets[1], object.playbackMode);
  writer.writeString(offsets[2], object.playlistHeader);
  writer.writeString(offsets[3], object.playlistName);
  writer.writeLong(offsets[4], object.positionMs);
  writer.writeStringList(offsets[5], object.queue);
  writer.writeString(offsets[6], object.repeatMode);
  writer.writeLong(offsets[7], object.schemaVersion);
  writer.writeLong(offsets[8], object.updatedAtMs);
}

IsarPlaybackRestoreSnapshotEntity _isarPlaybackRestoreSnapshotEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarPlaybackRestoreSnapshotEntity(
    currentSongId: reader.readString(offsets[0]),
    id: id,
    playbackMode: reader.readString(offsets[1]),
    playlistHeader: reader.readString(offsets[2]),
    playlistName: reader.readString(offsets[3]),
    positionMs: reader.readLong(offsets[4]),
    queue: reader.readStringList(offsets[5]) ?? [],
    repeatMode: reader.readString(offsets[6]),
    schemaVersion: reader.readLong(offsets[7]),
    updatedAtMs: reader.readLong(offsets[8]),
  );
  return object;
}

P _isarPlaybackRestoreSnapshotEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarPlaybackRestoreSnapshotEntityGetId(
    IsarPlaybackRestoreSnapshotEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarPlaybackRestoreSnapshotEntityGetLinks(
    IsarPlaybackRestoreSnapshotEntity object) {
  return [];
}

void _isarPlaybackRestoreSnapshotEntityAttach(IsarCollection<dynamic> col,
    Id id, IsarPlaybackRestoreSnapshotEntity object) {
  object.id = id;
}

extension IsarPlaybackRestoreSnapshotEntityQueryWhereSort on QueryBuilder<
    IsarPlaybackRestoreSnapshotEntity,
    IsarPlaybackRestoreSnapshotEntity,
    QWhere> {
  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarPlaybackRestoreSnapshotEntityQueryWhere on QueryBuilder<
    IsarPlaybackRestoreSnapshotEntity,
    IsarPlaybackRestoreSnapshotEntity,
    QWhereClause> {
  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarPlaybackRestoreSnapshotEntityQueryFilter on QueryBuilder<
    IsarPlaybackRestoreSnapshotEntity,
    IsarPlaybackRestoreSnapshotEntity,
    QFilterCondition> {
  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> currentSongIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentSongId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> currentSongIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentSongId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> currentSongIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentSongId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> currentSongIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentSongId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> currentSongIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currentSongId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> currentSongIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currentSongId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
          IsarPlaybackRestoreSnapshotEntity, QAfterFilterCondition>
      currentSongIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currentSongId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
          IsarPlaybackRestoreSnapshotEntity, QAfterFilterCondition>
      currentSongIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currentSongId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> currentSongIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentSongId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> currentSongIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currentSongId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playbackModeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playbackMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playbackModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playbackMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playbackModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playbackMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playbackModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playbackMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playbackModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'playbackMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playbackModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'playbackMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
          IsarPlaybackRestoreSnapshotEntity, QAfterFilterCondition>
      playbackModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'playbackMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
          IsarPlaybackRestoreSnapshotEntity, QAfterFilterCondition>
      playbackModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'playbackMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playbackModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playbackMode',
        value: '',
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playbackModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'playbackMode',
        value: '',
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playlistHeaderEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistHeader',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playlistHeaderGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playlistHeader',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playlistHeaderLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playlistHeader',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playlistHeaderBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playlistHeader',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playlistHeaderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'playlistHeader',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playlistHeaderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'playlistHeader',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
          IsarPlaybackRestoreSnapshotEntity, QAfterFilterCondition>
      playlistHeaderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'playlistHeader',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
          IsarPlaybackRestoreSnapshotEntity, QAfterFilterCondition>
      playlistHeaderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'playlistHeader',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playlistHeaderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistHeader',
        value: '',
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playlistHeaderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'playlistHeader',
        value: '',
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playlistNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playlistNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playlistNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playlistNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playlistName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playlistNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playlistNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
          IsarPlaybackRestoreSnapshotEntity, QAfterFilterCondition>
      playlistNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
          IsarPlaybackRestoreSnapshotEntity, QAfterFilterCondition>
      playlistNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'playlistName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playlistNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistName',
        value: '',
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> playlistNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'playlistName',
        value: '',
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> positionMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'positionMs',
        value: value,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> positionMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'positionMs',
        value: value,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> positionMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'positionMs',
        value: value,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> positionMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'positionMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> queueElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'queue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> queueElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'queue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> queueElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'queue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> queueElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'queue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> queueElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'queue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> queueElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'queue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
          IsarPlaybackRestoreSnapshotEntity, QAfterFilterCondition>
      queueElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'queue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
          IsarPlaybackRestoreSnapshotEntity, QAfterFilterCondition>
      queueElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'queue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> queueElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'queue',
        value: '',
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> queueElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'queue',
        value: '',
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> queueLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'queue',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterFilterCondition> queueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'queue',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> queueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'queue',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> queueLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'queue',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> queueLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'queue',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> queueLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'queue',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> repeatModeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repeatMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> repeatModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'repeatMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> repeatModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'repeatMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> repeatModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'repeatMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> repeatModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'repeatMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> repeatModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'repeatMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
          IsarPlaybackRestoreSnapshotEntity, QAfterFilterCondition>
      repeatModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'repeatMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
          IsarPlaybackRestoreSnapshotEntity, QAfterFilterCondition>
      repeatModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'repeatMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> repeatModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repeatMode',
        value: '',
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> repeatModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'repeatMode',
        value: '',
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> schemaVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> schemaVersionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> schemaVersionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> schemaVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schemaVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> updatedAtMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> updatedAtMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> updatedAtMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterFilterCondition> updatedAtMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAtMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarPlaybackRestoreSnapshotEntityQueryObject on QueryBuilder<
    IsarPlaybackRestoreSnapshotEntity,
    IsarPlaybackRestoreSnapshotEntity,
    QFilterCondition> {}

extension IsarPlaybackRestoreSnapshotEntityQueryLinks on QueryBuilder<
    IsarPlaybackRestoreSnapshotEntity,
    IsarPlaybackRestoreSnapshotEntity,
    QFilterCondition> {}

extension IsarPlaybackRestoreSnapshotEntityQuerySortBy on QueryBuilder<
    IsarPlaybackRestoreSnapshotEntity,
    IsarPlaybackRestoreSnapshotEntity,
    QSortBy> {
  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> sortByCurrentSongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSongId', Sort.asc);
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterSortBy> sortByCurrentSongIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSongId', Sort.desc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> sortByPlaybackMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackMode', Sort.asc);
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterSortBy> sortByPlaybackModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackMode', Sort.desc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> sortByPlaylistHeader() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistHeader', Sort.asc);
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterSortBy> sortByPlaylistHeaderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistHeader', Sort.desc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> sortByPlaylistName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistName', Sort.asc);
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterSortBy> sortByPlaylistNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistName', Sort.desc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> sortByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.asc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> sortByPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.desc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> sortByRepeatMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.asc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> sortByRepeatModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.desc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> sortBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterSortBy> sortBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> sortByUpdatedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAtMs', Sort.asc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> sortByUpdatedAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAtMs', Sort.desc);
    });
  }
}

extension IsarPlaybackRestoreSnapshotEntityQuerySortThenBy on QueryBuilder<
    IsarPlaybackRestoreSnapshotEntity,
    IsarPlaybackRestoreSnapshotEntity,
    QSortThenBy> {
  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> thenByCurrentSongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSongId', Sort.asc);
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterSortBy> thenByCurrentSongIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSongId', Sort.desc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> thenByPlaybackMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackMode', Sort.asc);
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterSortBy> thenByPlaybackModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackMode', Sort.desc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> thenByPlaylistHeader() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistHeader', Sort.asc);
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterSortBy> thenByPlaylistHeaderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistHeader', Sort.desc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> thenByPlaylistName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistName', Sort.asc);
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterSortBy> thenByPlaylistNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistName', Sort.desc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> thenByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.asc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> thenByPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.desc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> thenByRepeatMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.asc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> thenByRepeatModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.desc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> thenBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QAfterSortBy> thenBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> thenByUpdatedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAtMs', Sort.asc);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QAfterSortBy> thenByUpdatedAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAtMs', Sort.desc);
    });
  }
}

extension IsarPlaybackRestoreSnapshotEntityQueryWhereDistinct on QueryBuilder<
    IsarPlaybackRestoreSnapshotEntity,
    IsarPlaybackRestoreSnapshotEntity,
    QDistinct> {
  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QDistinct> distinctByCurrentSongId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentSongId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QDistinct> distinctByPlaybackMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playbackMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QDistinct> distinctByPlaylistHeader({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playlistHeader',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QDistinct> distinctByPlaylistName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playlistName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QDistinct> distinctByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'positionMs');
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QDistinct> distinctByQueue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'queue');
    });
  }

  QueryBuilder<
      IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity,
      QDistinct> distinctByRepeatMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repeatMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QDistinct> distinctBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaVersion');
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity,
      IsarPlaybackRestoreSnapshotEntity, QDistinct> distinctByUpdatedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAtMs');
    });
  }
}

extension IsarPlaybackRestoreSnapshotEntityQueryProperty on QueryBuilder<
    IsarPlaybackRestoreSnapshotEntity,
    IsarPlaybackRestoreSnapshotEntity,
    QQueryProperty> {
  QueryBuilder<IsarPlaybackRestoreSnapshotEntity, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity, String, QQueryOperations>
      currentSongIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentSongId');
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity, String, QQueryOperations>
      playbackModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playbackMode');
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity, String, QQueryOperations>
      playlistHeaderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistHeader');
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity, String, QQueryOperations>
      playlistNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistName');
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity, int, QQueryOperations>
      positionMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'positionMs');
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity, List<String>,
      QQueryOperations> queueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'queue');
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity, String, QQueryOperations>
      repeatModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repeatMode');
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity, int, QQueryOperations>
      schemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaVersion');
    });
  }

  QueryBuilder<IsarPlaybackRestoreSnapshotEntity, int, QQueryOperations>
      updatedAtMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAtMs');
    });
  }
}
