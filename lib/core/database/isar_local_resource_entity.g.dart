// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_local_resource_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarLocalResourceEntityCollection on Isar {
  IsarCollection<IsarLocalResourceEntity> get isarLocalResourceEntitys =>
      this.collection();
}

const IsarLocalResourceEntitySchema = CollectionSchema(
  name: r'IsarLocalResourceEntity',
  id: -2842557220919896598,
  properties: {
    r'kind': PropertySchema(
      id: 0,
      name: r'kind',
      type: IsarType.string,
    ),
    r'origin': PropertySchema(
      id: 1,
      name: r'origin',
      type: IsarType.string,
    ),
    r'path': PropertySchema(
      id: 2,
      name: r'path',
      type: IsarType.string,
    ),
    r'schemaVersion': PropertySchema(
      id: 3,
      name: r'schemaVersion',
      type: IsarType.long,
    ),
    r'trackId': PropertySchema(
      id: 4,
      name: r'trackId',
      type: IsarType.string,
    ),
    r'updatedAtMs': PropertySchema(
      id: 5,
      name: r'updatedAtMs',
      type: IsarType.long,
    )
  },
  estimateSize: _isarLocalResourceEntityEstimateSize,
  serialize: _isarLocalResourceEntitySerialize,
  deserialize: _isarLocalResourceEntityDeserialize,
  deserializeProp: _isarLocalResourceEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'trackId_kind': IndexSchema(
      id: 5236591128785662544,
      name: r'trackId_kind',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'trackId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'kind',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarLocalResourceEntityGetId,
  getLinks: _isarLocalResourceEntityGetLinks,
  attach: _isarLocalResourceEntityAttach,
  version: '3.1.0+1',
);

int _isarLocalResourceEntityEstimateSize(
  IsarLocalResourceEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.kind.length * 3;
  bytesCount += 3 + object.origin.length * 3;
  bytesCount += 3 + object.path.length * 3;
  bytesCount += 3 + object.trackId.length * 3;
  return bytesCount;
}

void _isarLocalResourceEntitySerialize(
  IsarLocalResourceEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.kind);
  writer.writeString(offsets[1], object.origin);
  writer.writeString(offsets[2], object.path);
  writer.writeLong(offsets[3], object.schemaVersion);
  writer.writeString(offsets[4], object.trackId);
  writer.writeLong(offsets[5], object.updatedAtMs);
}

IsarLocalResourceEntity _isarLocalResourceEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarLocalResourceEntity(
    id: id,
    kind: reader.readString(offsets[0]),
    origin: reader.readString(offsets[1]),
    path: reader.readString(offsets[2]),
    schemaVersion: reader.readLong(offsets[3]),
    trackId: reader.readString(offsets[4]),
    updatedAtMs: reader.readLong(offsets[5]),
  );
  return object;
}

P _isarLocalResourceEntityDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarLocalResourceEntityGetId(IsarLocalResourceEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarLocalResourceEntityGetLinks(
    IsarLocalResourceEntity object) {
  return [];
}

void _isarLocalResourceEntityAttach(
    IsarCollection<dynamic> col, Id id, IsarLocalResourceEntity object) {
  object.id = id;
}

extension IsarLocalResourceEntityByIndex
    on IsarCollection<IsarLocalResourceEntity> {
  Future<IsarLocalResourceEntity?> getByTrackIdKind(
      String trackId, String kind) {
    return getByIndex(r'trackId_kind', [trackId, kind]);
  }

  IsarLocalResourceEntity? getByTrackIdKindSync(String trackId, String kind) {
    return getByIndexSync(r'trackId_kind', [trackId, kind]);
  }

  Future<bool> deleteByTrackIdKind(String trackId, String kind) {
    return deleteByIndex(r'trackId_kind', [trackId, kind]);
  }

  bool deleteByTrackIdKindSync(String trackId, String kind) {
    return deleteByIndexSync(r'trackId_kind', [trackId, kind]);
  }

  Future<List<IsarLocalResourceEntity?>> getAllByTrackIdKind(
      List<String> trackIdValues, List<String> kindValues) {
    final len = trackIdValues.length;
    assert(
        kindValues.length == len, 'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([trackIdValues[i], kindValues[i]]);
    }

    return getAllByIndex(r'trackId_kind', values);
  }

  List<IsarLocalResourceEntity?> getAllByTrackIdKindSync(
      List<String> trackIdValues, List<String> kindValues) {
    final len = trackIdValues.length;
    assert(
        kindValues.length == len, 'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([trackIdValues[i], kindValues[i]]);
    }

    return getAllByIndexSync(r'trackId_kind', values);
  }

  Future<int> deleteAllByTrackIdKind(
      List<String> trackIdValues, List<String> kindValues) {
    final len = trackIdValues.length;
    assert(
        kindValues.length == len, 'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([trackIdValues[i], kindValues[i]]);
    }

    return deleteAllByIndex(r'trackId_kind', values);
  }

  int deleteAllByTrackIdKindSync(
      List<String> trackIdValues, List<String> kindValues) {
    final len = trackIdValues.length;
    assert(
        kindValues.length == len, 'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([trackIdValues[i], kindValues[i]]);
    }

    return deleteAllByIndexSync(r'trackId_kind', values);
  }

  Future<Id> putByTrackIdKind(IsarLocalResourceEntity object) {
    return putByIndex(r'trackId_kind', object);
  }

  Id putByTrackIdKindSync(IsarLocalResourceEntity object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'trackId_kind', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTrackIdKind(List<IsarLocalResourceEntity> objects) {
    return putAllByIndex(r'trackId_kind', objects);
  }

  List<Id> putAllByTrackIdKindSync(List<IsarLocalResourceEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'trackId_kind', objects, saveLinks: saveLinks);
  }
}

extension IsarLocalResourceEntityQueryWhereSort
    on QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QWhere> {
  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarLocalResourceEntityQueryWhere on QueryBuilder<
    IsarLocalResourceEntity, IsarLocalResourceEntity, QWhereClause> {
  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
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

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterWhereClause> trackIdEqualToAnyKind(String trackId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'trackId_kind',
        value: [trackId],
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterWhereClause> trackIdNotEqualToAnyKind(String trackId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackId_kind',
              lower: [],
              upper: [trackId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackId_kind',
              lower: [trackId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackId_kind',
              lower: [trackId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackId_kind',
              lower: [],
              upper: [trackId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterWhereClause> trackIdKindEqualTo(String trackId, String kind) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'trackId_kind',
        value: [trackId, kind],
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
          QAfterWhereClause>
      trackIdEqualToKindNotEqualTo(String trackId, String kind) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackId_kind',
              lower: [trackId],
              upper: [trackId, kind],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackId_kind',
              lower: [trackId, kind],
              includeLower: false,
              upper: [trackId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackId_kind',
              lower: [trackId, kind],
              includeLower: false,
              upper: [trackId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackId_kind',
              lower: [trackId],
              upper: [trackId, kind],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarLocalResourceEntityQueryFilter on QueryBuilder<
    IsarLocalResourceEntity, IsarLocalResourceEntity, QFilterCondition> {
  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> kindEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> kindGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> kindLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> kindBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kind',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> kindStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> kindEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
          QAfterFilterCondition>
      kindContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
          QAfterFilterCondition>
      kindMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'kind',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> originEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> originGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'origin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> originLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'origin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> originBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'origin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> originStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'origin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> originEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'origin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
          QAfterFilterCondition>
      originContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'origin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
          QAfterFilterCondition>
      originMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'origin',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> originIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origin',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> originIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'origin',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> pathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> pathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> pathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> pathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'path',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> pathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> pathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
          QAfterFilterCondition>
      pathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
          QAfterFilterCondition>
      pathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'path',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> pathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> pathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> schemaVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
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

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
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

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
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

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> trackIdEqualTo(
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

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> trackIdGreaterThan(
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

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> trackIdLessThan(
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

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> trackIdBetween(
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

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> trackIdStartsWith(
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

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> trackIdEndsWith(
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

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
          QAfterFilterCondition>
      trackIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'trackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
          QAfterFilterCondition>
      trackIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'trackId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> trackIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> trackIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'trackId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
      QAfterFilterCondition> updatedAtMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
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

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
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

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity,
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

extension IsarLocalResourceEntityQueryObject on QueryBuilder<
    IsarLocalResourceEntity, IsarLocalResourceEntity, QFilterCondition> {}

extension IsarLocalResourceEntityQueryLinks on QueryBuilder<
    IsarLocalResourceEntity, IsarLocalResourceEntity, QFilterCondition> {}

extension IsarLocalResourceEntityQuerySortBy
    on QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QSortBy> {
  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      sortByOrigin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.asc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      sortByOriginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.desc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      sortByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      sortByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      sortBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      sortBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      sortByTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.asc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      sortByTrackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.desc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      sortByUpdatedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAtMs', Sort.asc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      sortByUpdatedAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAtMs', Sort.desc);
    });
  }
}

extension IsarLocalResourceEntityQuerySortThenBy on QueryBuilder<
    IsarLocalResourceEntity, IsarLocalResourceEntity, QSortThenBy> {
  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      thenByOrigin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.asc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      thenByOriginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.desc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      thenByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      thenByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      thenBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      thenBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      thenByTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.asc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      thenByTrackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.desc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      thenByUpdatedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAtMs', Sort.asc);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QAfterSortBy>
      thenByUpdatedAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAtMs', Sort.desc);
    });
  }
}

extension IsarLocalResourceEntityQueryWhereDistinct on QueryBuilder<
    IsarLocalResourceEntity, IsarLocalResourceEntity, QDistinct> {
  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QDistinct>
      distinctByKind({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QDistinct>
      distinctByOrigin({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origin', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QDistinct>
      distinctByPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'path', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QDistinct>
      distinctBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaVersion');
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QDistinct>
      distinctByTrackId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLocalResourceEntity, IsarLocalResourceEntity, QDistinct>
      distinctByUpdatedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAtMs');
    });
  }
}

extension IsarLocalResourceEntityQueryProperty on QueryBuilder<
    IsarLocalResourceEntity, IsarLocalResourceEntity, QQueryProperty> {
  QueryBuilder<IsarLocalResourceEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarLocalResourceEntity, String, QQueryOperations>
      kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<IsarLocalResourceEntity, String, QQueryOperations>
      originProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origin');
    });
  }

  QueryBuilder<IsarLocalResourceEntity, String, QQueryOperations>
      pathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'path');
    });
  }

  QueryBuilder<IsarLocalResourceEntity, int, QQueryOperations>
      schemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaVersion');
    });
  }

  QueryBuilder<IsarLocalResourceEntity, String, QQueryOperations>
      trackIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackId');
    });
  }

  QueryBuilder<IsarLocalResourceEntity, int, QQueryOperations>
      updatedAtMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAtMs');
    });
  }
}
