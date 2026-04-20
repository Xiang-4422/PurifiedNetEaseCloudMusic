// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_track_lyrics_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarTrackLyricsEntityCollection on Isar {
  IsarCollection<IsarTrackLyricsEntity> get isarTrackLyricsEntitys =>
      this.collection();
}

const IsarTrackLyricsEntitySchema = CollectionSchema(
  name: r'IsarTrackLyricsEntity',
  id: 7348265159638019506,
  properties: {
    r'main': PropertySchema(
      id: 0,
      name: r'main',
      type: IsarType.string,
    ),
    r'schemaVersion': PropertySchema(
      id: 1,
      name: r'schemaVersion',
      type: IsarType.long,
    ),
    r'trackId': PropertySchema(
      id: 2,
      name: r'trackId',
      type: IsarType.string,
    ),
    r'translated': PropertySchema(
      id: 3,
      name: r'translated',
      type: IsarType.string,
    )
  },
  estimateSize: _isarTrackLyricsEntityEstimateSize,
  serialize: _isarTrackLyricsEntitySerialize,
  deserialize: _isarTrackLyricsEntityDeserialize,
  deserializeProp: _isarTrackLyricsEntityDeserializeProp,
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
  getId: _isarTrackLyricsEntityGetId,
  getLinks: _isarTrackLyricsEntityGetLinks,
  attach: _isarTrackLyricsEntityAttach,
  version: '3.1.0+1',
);

int _isarTrackLyricsEntityEstimateSize(
  IsarTrackLyricsEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.main.length * 3;
  bytesCount += 3 + object.trackId.length * 3;
  bytesCount += 3 + object.translated.length * 3;
  return bytesCount;
}

void _isarTrackLyricsEntitySerialize(
  IsarTrackLyricsEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.main);
  writer.writeLong(offsets[1], object.schemaVersion);
  writer.writeString(offsets[2], object.trackId);
  writer.writeString(offsets[3], object.translated);
}

IsarTrackLyricsEntity _isarTrackLyricsEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarTrackLyricsEntity(
    id: id,
    main: reader.readString(offsets[0]),
    schemaVersion: reader.readLong(offsets[1]),
    trackId: reader.readString(offsets[2]),
    translated: reader.readString(offsets[3]),
  );
  return object;
}

P _isarTrackLyricsEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarTrackLyricsEntityGetId(IsarTrackLyricsEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarTrackLyricsEntityGetLinks(
    IsarTrackLyricsEntity object) {
  return [];
}

void _isarTrackLyricsEntityAttach(
    IsarCollection<dynamic> col, Id id, IsarTrackLyricsEntity object) {
  object.id = id;
}

extension IsarTrackLyricsEntityByIndex
    on IsarCollection<IsarTrackLyricsEntity> {
  Future<IsarTrackLyricsEntity?> getByTrackId(String trackId) {
    return getByIndex(r'trackId', [trackId]);
  }

  IsarTrackLyricsEntity? getByTrackIdSync(String trackId) {
    return getByIndexSync(r'trackId', [trackId]);
  }

  Future<bool> deleteByTrackId(String trackId) {
    return deleteByIndex(r'trackId', [trackId]);
  }

  bool deleteByTrackIdSync(String trackId) {
    return deleteByIndexSync(r'trackId', [trackId]);
  }

  Future<List<IsarTrackLyricsEntity?>> getAllByTrackId(
      List<String> trackIdValues) {
    final values = trackIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'trackId', values);
  }

  List<IsarTrackLyricsEntity?> getAllByTrackIdSync(List<String> trackIdValues) {
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

  Future<Id> putByTrackId(IsarTrackLyricsEntity object) {
    return putByIndex(r'trackId', object);
  }

  Id putByTrackIdSync(IsarTrackLyricsEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'trackId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTrackId(List<IsarTrackLyricsEntity> objects) {
    return putAllByIndex(r'trackId', objects);
  }

  List<Id> putAllByTrackIdSync(List<IsarTrackLyricsEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'trackId', objects, saveLinks: saveLinks);
  }
}

extension IsarTrackLyricsEntityQueryWhereSort
    on QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QWhere> {
  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarTrackLyricsEntityQueryWhere on QueryBuilder<IsarTrackLyricsEntity,
    IsarTrackLyricsEntity, QWhereClause> {
  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterWhereClause>
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

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterWhereClause>
      trackIdEqualTo(String trackId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'trackId',
        value: [trackId],
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterWhereClause>
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

extension IsarTrackLyricsEntityQueryFilter on QueryBuilder<
    IsarTrackLyricsEntity, IsarTrackLyricsEntity, QFilterCondition> {
  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
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

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
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

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
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

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> mainEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'main',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> mainGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'main',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> mainLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'main',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> mainBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'main',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> mainStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'main',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> mainEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'main',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
          QAfterFilterCondition>
      mainContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'main',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
          QAfterFilterCondition>
      mainMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'main',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> mainIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'main',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> mainIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'main',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> schemaVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
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

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
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

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
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

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
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

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
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

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
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

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
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

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
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

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
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

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
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

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
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

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> trackIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> trackIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'trackId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> translatedEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'translated',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> translatedGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'translated',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> translatedLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'translated',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> translatedBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'translated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> translatedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'translated',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> translatedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'translated',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
          QAfterFilterCondition>
      translatedContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'translated',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
          QAfterFilterCondition>
      translatedMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'translated',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> translatedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'translated',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity,
      QAfterFilterCondition> translatedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'translated',
        value: '',
      ));
    });
  }
}

extension IsarTrackLyricsEntityQueryObject on QueryBuilder<
    IsarTrackLyricsEntity, IsarTrackLyricsEntity, QFilterCondition> {}

extension IsarTrackLyricsEntityQueryLinks on QueryBuilder<IsarTrackLyricsEntity,
    IsarTrackLyricsEntity, QFilterCondition> {}

extension IsarTrackLyricsEntityQuerySortBy
    on QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QSortBy> {
  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterSortBy>
      sortByMain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'main', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterSortBy>
      sortByMainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'main', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterSortBy>
      sortBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterSortBy>
      sortBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterSortBy>
      sortByTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterSortBy>
      sortByTrackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterSortBy>
      sortByTranslated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translated', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterSortBy>
      sortByTranslatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translated', Sort.desc);
    });
  }
}

extension IsarTrackLyricsEntityQuerySortThenBy
    on QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QSortThenBy> {
  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterSortBy>
      thenByMain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'main', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterSortBy>
      thenByMainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'main', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterSortBy>
      thenBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterSortBy>
      thenBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterSortBy>
      thenByTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterSortBy>
      thenByTrackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.desc);
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterSortBy>
      thenByTranslated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translated', Sort.asc);
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QAfterSortBy>
      thenByTranslatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translated', Sort.desc);
    });
  }
}

extension IsarTrackLyricsEntityQueryWhereDistinct
    on QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QDistinct> {
  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QDistinct>
      distinctByMain({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'main', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QDistinct>
      distinctBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaVersion');
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QDistinct>
      distinctByTrackId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, IsarTrackLyricsEntity, QDistinct>
      distinctByTranslated({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'translated', caseSensitive: caseSensitive);
    });
  }
}

extension IsarTrackLyricsEntityQueryProperty on QueryBuilder<
    IsarTrackLyricsEntity, IsarTrackLyricsEntity, QQueryProperty> {
  QueryBuilder<IsarTrackLyricsEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, String, QQueryOperations> mainProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'main');
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, int, QQueryOperations>
      schemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaVersion');
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, String, QQueryOperations>
      trackIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackId');
    });
  }

  QueryBuilder<IsarTrackLyricsEntity, String, QQueryOperations>
      translatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'translated');
    });
  }
}
