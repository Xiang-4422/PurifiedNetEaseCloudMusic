// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_track_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarTrackEntityCollection on Isar {
  IsarCollection<IsarTrackEntity> get isarTrackEntitys => this.collection();
}

const IsarTrackEntitySchema = CollectionSchema(
  name: r'IsarTrackEntity',
  id: -4533060763406162471,
  properties: {
    r'albumTitle': PropertySchema(
      id: 0,
      name: r'albumTitle',
      type: IsarType.string,
    ),
    r'artistNames': PropertySchema(
      id: 1,
      name: r'artistNames',
      type: IsarType.stringList,
    ),
    r'artworkUrl': PropertySchema(
      id: 2,
      name: r'artworkUrl',
      type: IsarType.string,
    ),
    r'availability': PropertySchema(
      id: 3,
      name: r'availability',
      type: IsarType.string,
    ),
    r'downloadFailureReason': PropertySchema(
      id: 4,
      name: r'downloadFailureReason',
      type: IsarType.string,
    ),
    r'downloadProgress': PropertySchema(
      id: 5,
      name: r'downloadProgress',
      type: IsarType.double,
    ),
    r'downloadState': PropertySchema(
      id: 6,
      name: r'downloadState',
      type: IsarType.string,
    ),
    r'durationMs': PropertySchema(
      id: 7,
      name: r'durationMs',
      type: IsarType.long,
    ),
    r'localArtworkPath': PropertySchema(
      id: 8,
      name: r'localArtworkPath',
      type: IsarType.string,
    ),
    r'localLyricsPath': PropertySchema(
      id: 9,
      name: r'localLyricsPath',
      type: IsarType.string,
    ),
    r'localPath': PropertySchema(
      id: 10,
      name: r'localPath',
      type: IsarType.string,
    ),
    r'lyricKey': PropertySchema(
      id: 11,
      name: r'lyricKey',
      type: IsarType.string,
    ),
    r'metadataJson': PropertySchema(
      id: 12,
      name: r'metadataJson',
      type: IsarType.string,
    ),
    r'remoteUrl': PropertySchema(
      id: 13,
      name: r'remoteUrl',
      type: IsarType.string,
    ),
    r'resourceOrigin': PropertySchema(
      id: 14,
      name: r'resourceOrigin',
      type: IsarType.string,
    ),
    r'schemaVersion': PropertySchema(
      id: 15,
      name: r'schemaVersion',
      type: IsarType.long,
    ),
    r'sourceId': PropertySchema(
      id: 16,
      name: r'sourceId',
      type: IsarType.string,
    ),
    r'sourceType': PropertySchema(
      id: 17,
      name: r'sourceType',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 18,
      name: r'title',
      type: IsarType.string,
    ),
    r'trackId': PropertySchema(
      id: 19,
      name: r'trackId',
      type: IsarType.string,
    )
  },
  estimateSize: _isarTrackEntityEstimateSize,
  serialize: _isarTrackEntitySerialize,
  deserialize: _isarTrackEntityDeserialize,
  deserializeProp: _isarTrackEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'trackId': IndexSchema(
      id: -8614467705999066844,
      name: r'trackId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'trackId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarTrackEntityGetId,
  getLinks: _isarTrackEntityGetLinks,
  attach: _isarTrackEntityAttach,
  version: '3.1.0+1',
);

int _isarTrackEntityEstimateSize(
  IsarTrackEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.albumTitle;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.artistNames.length * 3;
  {
    for (var i = 0; i < object.artistNames.length; i++) {
      final value = object.artistNames[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.artworkUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.availability.length * 3;
  {
    final value = object.downloadFailureReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.downloadState.length * 3;
  {
    final value = object.localArtworkPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.localLyricsPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.localPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lyricKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.metadataJson.length * 3;
  {
    final value = object.remoteUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.resourceOrigin.length * 3;
  bytesCount += 3 + object.sourceId.length * 3;
  bytesCount += 3 + object.sourceType.length * 3;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.trackId.length * 3;
  return bytesCount;
}

void _isarTrackEntitySerialize(
  IsarTrackEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.albumTitle);
  writer.writeStringList(offsets[1], object.artistNames);
  writer.writeString(offsets[2], object.artworkUrl);
  writer.writeString(offsets[3], object.availability);
  writer.writeString(offsets[4], object.downloadFailureReason);
  writer.writeDouble(offsets[5], object.downloadProgress);
  writer.writeString(offsets[6], object.downloadState);
  writer.writeLong(offsets[7], object.durationMs);
  writer.writeString(offsets[8], object.localArtworkPath);
  writer.writeString(offsets[9], object.localLyricsPath);
  writer.writeString(offsets[10], object.localPath);
  writer.writeString(offsets[11], object.lyricKey);
  writer.writeString(offsets[12], object.metadataJson);
  writer.writeString(offsets[13], object.remoteUrl);
  writer.writeString(offsets[14], object.resourceOrigin);
  writer.writeLong(offsets[15], object.schemaVersion);
  writer.writeString(offsets[16], object.sourceId);
  writer.writeString(offsets[17], object.sourceType);
  writer.writeString(offsets[18], object.title);
  writer.writeString(offsets[19], object.trackId);
}

IsarTrackEntity _isarTrackEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarTrackEntity(
    albumTitle: reader.readStringOrNull(offsets[0]),
    artistNames: reader.readStringList(offsets[1]) ?? const [],
    artworkUrl: reader.readStringOrNull(offsets[2]),
    availability: reader.readString(offsets[3]),
    downloadFailureReason: reader.readStringOrNull(offsets[4]),
    downloadProgress: reader.readDoubleOrNull(offsets[5]),
    downloadState: reader.readString(offsets[6]),
    durationMs: reader.readLongOrNull(offsets[7]),
    id: id,
    localArtworkPath: reader.readStringOrNull(offsets[8]),
    localLyricsPath: reader.readStringOrNull(offsets[9]),
    localPath: reader.readStringOrNull(offsets[10]),
    lyricKey: reader.readStringOrNull(offsets[11]),
    metadataJson: reader.readString(offsets[12]),
    remoteUrl: reader.readStringOrNull(offsets[13]),
    resourceOrigin: reader.readString(offsets[14]),
    schemaVersion: reader.readLong(offsets[15]),
    sourceId: reader.readString(offsets[16]),
    sourceType: reader.readString(offsets[17]),
    title: reader.readString(offsets[18]),
    trackId: reader.readString(offsets[19]),
  );
  return object;
}

P _isarTrackEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? const []) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarTrackEntityGetId(IsarTrackEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarTrackEntityGetLinks(IsarTrackEntity object) {
  return [];
}

void _isarTrackEntityAttach(
    IsarCollection<dynamic> col, Id id, IsarTrackEntity object) {
  object.id = id;
}

extension IsarTrackEntityByIndex on IsarCollection<IsarTrackEntity> {
  Future<IsarTrackEntity?> getByTrackId(String trackId) {
    return getByIndex(r'trackId', [trackId]);
  }

  IsarTrackEntity? getByTrackIdSync(String trackId) {
    return getByIndexSync(r'trackId', [trackId]);
  }

  Future<bool> deleteByTrackId(String trackId) {
    return deleteByIndex(r'trackId', [trackId]);
  }

  bool deleteByTrackIdSync(String trackId) {
    return deleteByIndexSync(r'trackId', [trackId]);
  }

  Future<List<IsarTrackEntity?>> getAllByTrackId(List<String> trackIdValues) {
    final values = trackIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'trackId', values);
  }

  List<IsarTrackEntity?> getAllByTrackIdSync(List<String> trackIdValues) {
    final values = trackIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'trackId', values);
  }

  Future<int> deleteAllByTrackId(List<String> trackIdValues) {
    final values = trackIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'trackId', values);
  }

  int deleteAllByTrackIdSync(List<String> trackIdValues) {
    final values = trackIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'trackId', values);
  }

  Future<Id> putByTrackId(IsarTrackEntity object) {
    return putByIndex(r'trackId', object);
  }

  Id putByTrackIdSync(IsarTrackEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'trackId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTrackId(List<IsarTrackEntity> objects) {
    return putAllByIndex(r'trackId', objects);
  }

  List<Id> putAllByTrackIdSync(List<IsarTrackEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'trackId', objects, saveLinks: saveLinks);
  }
}

extension IsarTrackEntityQueryWhereSort
    on QueryBuilder<IsarTrackEntity, IsarTrackEntity, QWhere> {
  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarTrackEntityQueryWhere
    on QueryBuilder<IsarTrackEntity, IsarTrackEntity, QWhereClause> {
  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterWhereClause>
      trackIdEqualTo(String trackId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'trackId',
        value: [trackId],
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterWhereClause>
      trackIdNotEqualTo(String trackId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackId',
              lower: [],
              upper: [trackId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackId',
              lower: [trackId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackId',
              lower: [trackId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackId',
              lower: [],
              upper: [trackId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarTrackEntityQueryFilter
    on QueryBuilder<IsarTrackEntity, IsarTrackEntity, QFilterCondition> {
  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      albumTitleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'albumTitle',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      albumTitleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'albumTitle',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      albumTitleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'albumTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      albumTitleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'albumTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      albumTitleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'albumTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      albumTitleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'albumTitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      albumTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'albumTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      albumTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'albumTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      albumTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'albumTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      albumTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'albumTitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      albumTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'albumTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      albumTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'albumTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artistNamesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artistNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artistNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artistNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artistNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artistNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artistNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artistNames',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artistNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artistNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artistNamesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artistNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artistNamesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artistNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artistNamesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artistNames',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artistNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artistNames',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artistNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artistNames',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artistNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'artistNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artistNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'artistNames',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artistNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'artistNames',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artistNamesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'artistNames',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artistNamesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'artistNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artistNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'artistNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artworkUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artworkUrl',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artworkUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artworkUrl',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artworkUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artworkUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artworkUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artworkUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artworkUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artworkUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artworkUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artworkUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artworkUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artworkUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artworkUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artworkUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artworkUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artworkUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artworkUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artworkUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artworkUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artworkUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      artworkUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artworkUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      availabilityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'availability',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      availabilityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'availability',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      availabilityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'availability',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      availabilityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'availability',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      availabilityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'availability',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      availabilityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'availability',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      availabilityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'availability',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      availabilityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'availability',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      availabilityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'availability',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      availabilityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'availability',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadFailureReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'downloadFailureReason',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadFailureReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'downloadFailureReason',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadFailureReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadFailureReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadFailureReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'downloadFailureReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadFailureReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'downloadFailureReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadFailureReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'downloadFailureReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadFailureReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'downloadFailureReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadFailureReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'downloadFailureReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadFailureReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'downloadFailureReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadFailureReasonMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'downloadFailureReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadFailureReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadFailureReason',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadFailureReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'downloadFailureReason',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadProgressIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'downloadProgress',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadProgressIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'downloadProgress',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadProgressEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadProgressGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'downloadProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadProgressLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'downloadProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadProgressBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'downloadProgress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadStateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadStateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'downloadState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadStateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'downloadState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadStateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'downloadState',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadStateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'downloadState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadStateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'downloadState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadStateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'downloadState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadStateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'downloadState',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadStateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadState',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      downloadStateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'downloadState',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      durationMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'durationMs',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      durationMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'durationMs',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      durationMsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      durationMsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      durationMsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      durationMsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localArtworkPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localArtworkPath',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localArtworkPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localArtworkPath',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localArtworkPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localArtworkPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localArtworkPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localArtworkPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localArtworkPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localArtworkPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localArtworkPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localArtworkPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localArtworkPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localArtworkPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localArtworkPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localArtworkPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localArtworkPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localArtworkPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localArtworkPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localArtworkPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localArtworkPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localArtworkPath',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localArtworkPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localArtworkPath',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localLyricsPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localLyricsPath',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localLyricsPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localLyricsPath',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localLyricsPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localLyricsPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localLyricsPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localLyricsPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localLyricsPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localLyricsPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localLyricsPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localLyricsPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localLyricsPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localLyricsPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localLyricsPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localLyricsPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localLyricsPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localLyricsPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localLyricsPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localLyricsPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localLyricsPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localLyricsPath',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localLyricsPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localLyricsPath',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localPath',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localPath',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localPath',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      localPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localPath',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      lyricKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lyricKey',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      lyricKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lyricKey',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      lyricKeyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lyricKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      lyricKeyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lyricKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      lyricKeyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lyricKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      lyricKeyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lyricKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      lyricKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lyricKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      lyricKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lyricKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      lyricKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lyricKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      lyricKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lyricKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      lyricKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lyricKey',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      lyricKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lyricKey',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      metadataJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      metadataJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      metadataJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      metadataJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metadataJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      metadataJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      metadataJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      metadataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      metadataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metadataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      metadataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      metadataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      remoteUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'remoteUrl',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      remoteUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'remoteUrl',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      remoteUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      remoteUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remoteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      remoteUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remoteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      remoteUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remoteUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      remoteUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'remoteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      remoteUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'remoteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      remoteUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'remoteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      remoteUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'remoteUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      remoteUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      remoteUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'remoteUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      resourceOriginEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resourceOrigin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      resourceOriginGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'resourceOrigin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      resourceOriginLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'resourceOrigin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      resourceOriginBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'resourceOrigin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      resourceOriginStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'resourceOrigin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      resourceOriginEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'resourceOrigin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      resourceOriginContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'resourceOrigin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      resourceOriginMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'resourceOrigin',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      resourceOriginIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resourceOrigin',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      resourceOriginIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'resourceOrigin',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      schemaVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      schemaVersionGreaterThan(
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

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      schemaVersionLessThan(
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

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      schemaVersionBetween(
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

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      sourceTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      trackIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      trackIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      trackIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      trackIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trackId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      trackIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'trackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      trackIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'trackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      trackIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'trackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      trackIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'trackId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      trackIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterFilterCondition>
      trackIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'trackId',
        value: '',
      ));
    });
  }
}

extension IsarTrackEntityQueryObject
    on QueryBuilder<IsarTrackEntity, IsarTrackEntity, QFilterCondition> {}

extension IsarTrackEntityQueryLinks
    on QueryBuilder<IsarTrackEntity, IsarTrackEntity, QFilterCondition> {}

extension IsarTrackEntityQuerySortBy
    on QueryBuilder<IsarTrackEntity, IsarTrackEntity, QSortBy> {
  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByAlbumTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumTitle', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByAlbumTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumTitle', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByArtworkUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkUrl', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByArtworkUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkUrl', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByAvailability() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availability', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByAvailabilityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availability', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByDownloadFailureReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadFailureReason', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByDownloadFailureReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadFailureReason', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByDownloadProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadProgress', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByDownloadProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadProgress', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByDownloadState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadState', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByDownloadStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadState', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByLocalArtworkPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localArtworkPath', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByLocalArtworkPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localArtworkPath', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByLocalLyricsPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localLyricsPath', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByLocalLyricsPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localLyricsPath', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPath', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPath', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByLyricKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricKey', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByLyricKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricKey', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByRemoteUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUrl', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByRemoteUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUrl', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByResourceOrigin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceOrigin', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByResourceOriginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceOrigin', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy> sortByTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      sortByTrackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.desc);
    });
  }
}

extension IsarTrackEntityQuerySortThenBy
    on QueryBuilder<IsarTrackEntity, IsarTrackEntity, QSortThenBy> {
  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByAlbumTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumTitle', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByAlbumTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumTitle', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByArtworkUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkUrl', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByArtworkUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkUrl', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByAvailability() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availability', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByAvailabilityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availability', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByDownloadFailureReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadFailureReason', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByDownloadFailureReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadFailureReason', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByDownloadProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadProgress', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByDownloadProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadProgress', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByDownloadState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadState', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByDownloadStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadState', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByLocalArtworkPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localArtworkPath', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByLocalArtworkPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localArtworkPath', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByLocalLyricsPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localLyricsPath', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByLocalLyricsPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localLyricsPath', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPath', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPath', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByLyricKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricKey', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByLyricKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricKey', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByRemoteUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUrl', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByRemoteUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUrl', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByResourceOrigin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceOrigin', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByResourceOriginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceOrigin', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy> thenByTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QAfterSortBy>
      thenByTrackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.desc);
    });
  }
}

extension IsarTrackEntityQueryWhereDistinct
    on QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct> {
  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct>
      distinctByAlbumTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'albumTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct>
      distinctByArtistNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artistNames');
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct>
      distinctByArtworkUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artworkUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct>
      distinctByAvailability({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'availability', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct>
      distinctByDownloadFailureReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadFailureReason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct>
      distinctByDownloadProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadProgress');
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct>
      distinctByDownloadState({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadState',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct>
      distinctByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationMs');
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct>
      distinctByLocalArtworkPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localArtworkPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct>
      distinctByLocalLyricsPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localLyricsPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct> distinctByLocalPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct> distinctByLyricKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lyricKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct>
      distinctByMetadataJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metadataJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct> distinctByRemoteUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct>
      distinctByResourceOrigin({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resourceOrigin',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct>
      distinctBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaVersion');
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct> distinctBySourceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct>
      distinctBySourceType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTrackEntity, IsarTrackEntity, QDistinct> distinctByTrackId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackId', caseSensitive: caseSensitive);
    });
  }
}

extension IsarTrackEntityQueryProperty
    on QueryBuilder<IsarTrackEntity, IsarTrackEntity, QQueryProperty> {
  QueryBuilder<IsarTrackEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarTrackEntity, String?, QQueryOperations>
      albumTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'albumTitle');
    });
  }

  QueryBuilder<IsarTrackEntity, List<String>, QQueryOperations>
      artistNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artistNames');
    });
  }

  QueryBuilder<IsarTrackEntity, String?, QQueryOperations>
      artworkUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artworkUrl');
    });
  }

  QueryBuilder<IsarTrackEntity, String, QQueryOperations>
      availabilityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'availability');
    });
  }

  QueryBuilder<IsarTrackEntity, String?, QQueryOperations>
      downloadFailureReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadFailureReason');
    });
  }

  QueryBuilder<IsarTrackEntity, double?, QQueryOperations>
      downloadProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadProgress');
    });
  }

  QueryBuilder<IsarTrackEntity, String, QQueryOperations>
      downloadStateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadState');
    });
  }

  QueryBuilder<IsarTrackEntity, int?, QQueryOperations> durationMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationMs');
    });
  }

  QueryBuilder<IsarTrackEntity, String?, QQueryOperations>
      localArtworkPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localArtworkPath');
    });
  }

  QueryBuilder<IsarTrackEntity, String?, QQueryOperations>
      localLyricsPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localLyricsPath');
    });
  }

  QueryBuilder<IsarTrackEntity, String?, QQueryOperations> localPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localPath');
    });
  }

  QueryBuilder<IsarTrackEntity, String?, QQueryOperations> lyricKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lyricKey');
    });
  }

  QueryBuilder<IsarTrackEntity, String, QQueryOperations>
      metadataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadataJson');
    });
  }

  QueryBuilder<IsarTrackEntity, String?, QQueryOperations> remoteUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteUrl');
    });
  }

  QueryBuilder<IsarTrackEntity, String, QQueryOperations>
      resourceOriginProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resourceOrigin');
    });
  }

  QueryBuilder<IsarTrackEntity, int, QQueryOperations> schemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaVersion');
    });
  }

  QueryBuilder<IsarTrackEntity, String, QQueryOperations> sourceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceId');
    });
  }

  QueryBuilder<IsarTrackEntity, String, QQueryOperations> sourceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceType');
    });
  }

  QueryBuilder<IsarTrackEntity, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<IsarTrackEntity, String, QQueryOperations> trackIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackId');
    });
  }
}
