// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $PlaybackRestoreSnapshotsTable extends PlaybackRestoreSnapshots
    with TableInfo<$PlaybackRestoreSnapshotsTable, PlaybackRestoreSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackRestoreSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMsMeta =
      const VerificationMeta('updatedAtMs');
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
      'updated_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _playbackModeMeta =
      const VerificationMeta('playbackMode');
  @override
  late final GeneratedColumn<String> playbackMode = GeneratedColumn<String>(
      'playback_mode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _repeatModeMeta =
      const VerificationMeta('repeatMode');
  @override
  late final GeneratedColumn<String> repeatMode = GeneratedColumn<String>(
      'repeat_mode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _queueJsonMeta =
      const VerificationMeta('queueJson');
  @override
  late final GeneratedColumn<String> queueJson = GeneratedColumn<String>(
      'queue_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currentSongIdMeta =
      const VerificationMeta('currentSongId');
  @override
  late final GeneratedColumn<String> currentSongId = GeneratedColumn<String>(
      'current_song_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _playlistNameMeta =
      const VerificationMeta('playlistName');
  @override
  late final GeneratedColumn<String> playlistName = GeneratedColumn<String>(
      'playlist_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _playlistHeaderMeta =
      const VerificationMeta('playlistHeader');
  @override
  late final GeneratedColumn<String> playlistHeader = GeneratedColumn<String>(
      'playlist_header', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMsMeta =
      const VerificationMeta('positionMs');
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
      'position_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        updatedAtMs,
        playbackMode,
        repeatMode,
        queueJson,
        currentSongId,
        playlistName,
        playlistHeader,
        positionMs
      ];
  @override
  String get aliasedName => _alias ?? 'playback_restore_snapshots';
  @override
  String get actualTableName => 'playback_restore_snapshots';
  @override
  VerificationContext validateIntegrity(
      Insertable<PlaybackRestoreSnapshot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
          _updatedAtMsMeta,
          updatedAtMs.isAcceptableOrUnknown(
              data['updated_at_ms']!, _updatedAtMsMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('playback_mode')) {
      context.handle(
          _playbackModeMeta,
          playbackMode.isAcceptableOrUnknown(
              data['playback_mode']!, _playbackModeMeta));
    } else if (isInserting) {
      context.missing(_playbackModeMeta);
    }
    if (data.containsKey('repeat_mode')) {
      context.handle(
          _repeatModeMeta,
          repeatMode.isAcceptableOrUnknown(
              data['repeat_mode']!, _repeatModeMeta));
    } else if (isInserting) {
      context.missing(_repeatModeMeta);
    }
    if (data.containsKey('queue_json')) {
      context.handle(_queueJsonMeta,
          queueJson.isAcceptableOrUnknown(data['queue_json']!, _queueJsonMeta));
    } else if (isInserting) {
      context.missing(_queueJsonMeta);
    }
    if (data.containsKey('current_song_id')) {
      context.handle(
          _currentSongIdMeta,
          currentSongId.isAcceptableOrUnknown(
              data['current_song_id']!, _currentSongIdMeta));
    } else if (isInserting) {
      context.missing(_currentSongIdMeta);
    }
    if (data.containsKey('playlist_name')) {
      context.handle(
          _playlistNameMeta,
          playlistName.isAcceptableOrUnknown(
              data['playlist_name']!, _playlistNameMeta));
    } else if (isInserting) {
      context.missing(_playlistNameMeta);
    }
    if (data.containsKey('playlist_header')) {
      context.handle(
          _playlistHeaderMeta,
          playlistHeader.isAcceptableOrUnknown(
              data['playlist_header']!, _playlistHeaderMeta));
    } else if (isInserting) {
      context.missing(_playlistHeaderMeta);
    }
    if (data.containsKey('position_ms')) {
      context.handle(
          _positionMsMeta,
          positionMs.isAcceptableOrUnknown(
              data['position_ms']!, _positionMsMeta));
    } else if (isInserting) {
      context.missing(_positionMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaybackRestoreSnapshot map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackRestoreSnapshot(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      updatedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at_ms'])!,
      playbackMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}playback_mode'])!,
      repeatMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}repeat_mode'])!,
      queueJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}queue_json'])!,
      currentSongId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}current_song_id'])!,
      playlistName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}playlist_name'])!,
      playlistHeader: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}playlist_header'])!,
      positionMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position_ms'])!,
    );
  }

  @override
  $PlaybackRestoreSnapshotsTable createAlias(String alias) {
    return $PlaybackRestoreSnapshotsTable(attachedDatabase, alias);
  }
}

class PlaybackRestoreSnapshot extends DataClass
    implements Insertable<PlaybackRestoreSnapshot> {
  final int id;
  final int updatedAtMs;
  final String playbackMode;
  final String repeatMode;
  final String queueJson;
  final String currentSongId;
  final String playlistName;
  final String playlistHeader;
  final int positionMs;
  const PlaybackRestoreSnapshot(
      {required this.id,
      required this.updatedAtMs,
      required this.playbackMode,
      required this.repeatMode,
      required this.queueJson,
      required this.currentSongId,
      required this.playlistName,
      required this.playlistHeader,
      required this.positionMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['playback_mode'] = Variable<String>(playbackMode);
    map['repeat_mode'] = Variable<String>(repeatMode);
    map['queue_json'] = Variable<String>(queueJson);
    map['current_song_id'] = Variable<String>(currentSongId);
    map['playlist_name'] = Variable<String>(playlistName);
    map['playlist_header'] = Variable<String>(playlistHeader);
    map['position_ms'] = Variable<int>(positionMs);
    return map;
  }

  PlaybackRestoreSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return PlaybackRestoreSnapshotsCompanion(
      id: Value(id),
      updatedAtMs: Value(updatedAtMs),
      playbackMode: Value(playbackMode),
      repeatMode: Value(repeatMode),
      queueJson: Value(queueJson),
      currentSongId: Value(currentSongId),
      playlistName: Value(playlistName),
      playlistHeader: Value(playlistHeader),
      positionMs: Value(positionMs),
    );
  }

  factory PlaybackRestoreSnapshot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackRestoreSnapshot(
      id: serializer.fromJson<int>(json['id']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      playbackMode: serializer.fromJson<String>(json['playbackMode']),
      repeatMode: serializer.fromJson<String>(json['repeatMode']),
      queueJson: serializer.fromJson<String>(json['queueJson']),
      currentSongId: serializer.fromJson<String>(json['currentSongId']),
      playlistName: serializer.fromJson<String>(json['playlistName']),
      playlistHeader: serializer.fromJson<String>(json['playlistHeader']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'playbackMode': serializer.toJson<String>(playbackMode),
      'repeatMode': serializer.toJson<String>(repeatMode),
      'queueJson': serializer.toJson<String>(queueJson),
      'currentSongId': serializer.toJson<String>(currentSongId),
      'playlistName': serializer.toJson<String>(playlistName),
      'playlistHeader': serializer.toJson<String>(playlistHeader),
      'positionMs': serializer.toJson<int>(positionMs),
    };
  }

  PlaybackRestoreSnapshot copyWith(
          {int? id,
          int? updatedAtMs,
          String? playbackMode,
          String? repeatMode,
          String? queueJson,
          String? currentSongId,
          String? playlistName,
          String? playlistHeader,
          int? positionMs}) =>
      PlaybackRestoreSnapshot(
        id: id ?? this.id,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
        playbackMode: playbackMode ?? this.playbackMode,
        repeatMode: repeatMode ?? this.repeatMode,
        queueJson: queueJson ?? this.queueJson,
        currentSongId: currentSongId ?? this.currentSongId,
        playlistName: playlistName ?? this.playlistName,
        playlistHeader: playlistHeader ?? this.playlistHeader,
        positionMs: positionMs ?? this.positionMs,
      );
  @override
  String toString() {
    return (StringBuffer('PlaybackRestoreSnapshot(')
          ..write('id: $id, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('playbackMode: $playbackMode, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('queueJson: $queueJson, ')
          ..write('currentSongId: $currentSongId, ')
          ..write('playlistName: $playlistName, ')
          ..write('playlistHeader: $playlistHeader, ')
          ..write('positionMs: $positionMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAtMs, playbackMode, repeatMode,
      queueJson, currentSongId, playlistName, playlistHeader, positionMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackRestoreSnapshot &&
          other.id == this.id &&
          other.updatedAtMs == this.updatedAtMs &&
          other.playbackMode == this.playbackMode &&
          other.repeatMode == this.repeatMode &&
          other.queueJson == this.queueJson &&
          other.currentSongId == this.currentSongId &&
          other.playlistName == this.playlistName &&
          other.playlistHeader == this.playlistHeader &&
          other.positionMs == this.positionMs);
}

class PlaybackRestoreSnapshotsCompanion
    extends UpdateCompanion<PlaybackRestoreSnapshot> {
  final Value<int> id;
  final Value<int> updatedAtMs;
  final Value<String> playbackMode;
  final Value<String> repeatMode;
  final Value<String> queueJson;
  final Value<String> currentSongId;
  final Value<String> playlistName;
  final Value<String> playlistHeader;
  final Value<int> positionMs;
  const PlaybackRestoreSnapshotsCompanion({
    this.id = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.playbackMode = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.queueJson = const Value.absent(),
    this.currentSongId = const Value.absent(),
    this.playlistName = const Value.absent(),
    this.playlistHeader = const Value.absent(),
    this.positionMs = const Value.absent(),
  });
  PlaybackRestoreSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required int updatedAtMs,
    required String playbackMode,
    required String repeatMode,
    required String queueJson,
    required String currentSongId,
    required String playlistName,
    required String playlistHeader,
    required int positionMs,
  })  : updatedAtMs = Value(updatedAtMs),
        playbackMode = Value(playbackMode),
        repeatMode = Value(repeatMode),
        queueJson = Value(queueJson),
        currentSongId = Value(currentSongId),
        playlistName = Value(playlistName),
        playlistHeader = Value(playlistHeader),
        positionMs = Value(positionMs);
  static Insertable<PlaybackRestoreSnapshot> custom({
    Expression<int>? id,
    Expression<int>? updatedAtMs,
    Expression<String>? playbackMode,
    Expression<String>? repeatMode,
    Expression<String>? queueJson,
    Expression<String>? currentSongId,
    Expression<String>? playlistName,
    Expression<String>? playlistHeader,
    Expression<int>? positionMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (playbackMode != null) 'playback_mode': playbackMode,
      if (repeatMode != null) 'repeat_mode': repeatMode,
      if (queueJson != null) 'queue_json': queueJson,
      if (currentSongId != null) 'current_song_id': currentSongId,
      if (playlistName != null) 'playlist_name': playlistName,
      if (playlistHeader != null) 'playlist_header': playlistHeader,
      if (positionMs != null) 'position_ms': positionMs,
    });
  }

  PlaybackRestoreSnapshotsCompanion copyWith(
      {Value<int>? id,
      Value<int>? updatedAtMs,
      Value<String>? playbackMode,
      Value<String>? repeatMode,
      Value<String>? queueJson,
      Value<String>? currentSongId,
      Value<String>? playlistName,
      Value<String>? playlistHeader,
      Value<int>? positionMs}) {
    return PlaybackRestoreSnapshotsCompanion(
      id: id ?? this.id,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      playbackMode: playbackMode ?? this.playbackMode,
      repeatMode: repeatMode ?? this.repeatMode,
      queueJson: queueJson ?? this.queueJson,
      currentSongId: currentSongId ?? this.currentSongId,
      playlistName: playlistName ?? this.playlistName,
      playlistHeader: playlistHeader ?? this.playlistHeader,
      positionMs: positionMs ?? this.positionMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (playbackMode.present) {
      map['playback_mode'] = Variable<String>(playbackMode.value);
    }
    if (repeatMode.present) {
      map['repeat_mode'] = Variable<String>(repeatMode.value);
    }
    if (queueJson.present) {
      map['queue_json'] = Variable<String>(queueJson.value);
    }
    if (currentSongId.present) {
      map['current_song_id'] = Variable<String>(currentSongId.value);
    }
    if (playlistName.present) {
      map['playlist_name'] = Variable<String>(playlistName.value);
    }
    if (playlistHeader.present) {
      map['playlist_header'] = Variable<String>(playlistHeader.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackRestoreSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('playbackMode: $playbackMode, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('queueJson: $queueJson, ')
          ..write('currentSongId: $currentSongId, ')
          ..write('playlistName: $playlistName, ')
          ..write('playlistHeader: $playlistHeader, ')
          ..write('positionMs: $positionMs')
          ..write(')'))
        .toString();
  }
}

class $LocalResourceEntriesTable extends LocalResourceEntries
    with TableInfo<$LocalResourceEntriesTable, LocalResourceEntrie> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalResourceEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta =
      const VerificationMeta('trackId');
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
      'track_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
      'origin', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sizeBytesMeta =
      const VerificationMeta('sizeBytes');
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
      'size_bytes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMsMeta =
      const VerificationMeta('createdAtMs');
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
      'created_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastAccessedAtMsMeta =
      const VerificationMeta('lastAccessedAtMs');
  @override
  late final GeneratedColumn<int> lastAccessedAtMs = GeneratedColumn<int>(
      'last_accessed_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [trackId, kind, path, origin, sizeBytes, createdAtMs, lastAccessedAtMs];
  @override
  String get aliasedName => _alias ?? 'local_resource_entries';
  @override
  String get actualTableName => 'local_resource_entries';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalResourceEntrie> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(_trackIdMeta,
          trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta));
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(_originMeta,
          origin.isAcceptableOrUnknown(data['origin']!, _originMeta));
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(_sizeBytesMeta,
          sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta));
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
          _createdAtMsMeta,
          createdAtMs.isAcceptableOrUnknown(
              data['created_at_ms']!, _createdAtMsMeta));
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('last_accessed_at_ms')) {
      context.handle(
          _lastAccessedAtMsMeta,
          lastAccessedAtMs.isAcceptableOrUnknown(
              data['last_accessed_at_ms']!, _lastAccessedAtMsMeta));
    } else if (isInserting) {
      context.missing(_lastAccessedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId, kind};
  @override
  LocalResourceEntrie map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalResourceEntrie(
      trackId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}track_id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      origin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}origin'])!,
      sizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size_bytes'])!,
      createdAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at_ms'])!,
      lastAccessedAtMs: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}last_accessed_at_ms'])!,
    );
  }

  @override
  $LocalResourceEntriesTable createAlias(String alias) {
    return $LocalResourceEntriesTable(attachedDatabase, alias);
  }
}

class LocalResourceEntrie extends DataClass
    implements Insertable<LocalResourceEntrie> {
  final String trackId;
  final String kind;
  final String path;
  final String origin;
  final int sizeBytes;
  final int createdAtMs;
  final int lastAccessedAtMs;
  const LocalResourceEntrie(
      {required this.trackId,
      required this.kind,
      required this.path,
      required this.origin,
      required this.sizeBytes,
      required this.createdAtMs,
      required this.lastAccessedAtMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['kind'] = Variable<String>(kind);
    map['path'] = Variable<String>(path);
    map['origin'] = Variable<String>(origin);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['last_accessed_at_ms'] = Variable<int>(lastAccessedAtMs);
    return map;
  }

  LocalResourceEntriesCompanion toCompanion(bool nullToAbsent) {
    return LocalResourceEntriesCompanion(
      trackId: Value(trackId),
      kind: Value(kind),
      path: Value(path),
      origin: Value(origin),
      sizeBytes: Value(sizeBytes),
      createdAtMs: Value(createdAtMs),
      lastAccessedAtMs: Value(lastAccessedAtMs),
    );
  }

  factory LocalResourceEntrie.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalResourceEntrie(
      trackId: serializer.fromJson<String>(json['trackId']),
      kind: serializer.fromJson<String>(json['kind']),
      path: serializer.fromJson<String>(json['path']),
      origin: serializer.fromJson<String>(json['origin']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      lastAccessedAtMs: serializer.fromJson<int>(json['lastAccessedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'kind': serializer.toJson<String>(kind),
      'path': serializer.toJson<String>(path),
      'origin': serializer.toJson<String>(origin),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'lastAccessedAtMs': serializer.toJson<int>(lastAccessedAtMs),
    };
  }

  LocalResourceEntrie copyWith(
          {String? trackId,
          String? kind,
          String? path,
          String? origin,
          int? sizeBytes,
          int? createdAtMs,
          int? lastAccessedAtMs}) =>
      LocalResourceEntrie(
        trackId: trackId ?? this.trackId,
        kind: kind ?? this.kind,
        path: path ?? this.path,
        origin: origin ?? this.origin,
        sizeBytes: sizeBytes ?? this.sizeBytes,
        createdAtMs: createdAtMs ?? this.createdAtMs,
        lastAccessedAtMs: lastAccessedAtMs ?? this.lastAccessedAtMs,
      );
  @override
  String toString() {
    return (StringBuffer('LocalResourceEntrie(')
          ..write('trackId: $trackId, ')
          ..write('kind: $kind, ')
          ..write('path: $path, ')
          ..write('origin: $origin, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('lastAccessedAtMs: $lastAccessedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      trackId, kind, path, origin, sizeBytes, createdAtMs, lastAccessedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalResourceEntrie &&
          other.trackId == this.trackId &&
          other.kind == this.kind &&
          other.path == this.path &&
          other.origin == this.origin &&
          other.sizeBytes == this.sizeBytes &&
          other.createdAtMs == this.createdAtMs &&
          other.lastAccessedAtMs == this.lastAccessedAtMs);
}

class LocalResourceEntriesCompanion
    extends UpdateCompanion<LocalResourceEntrie> {
  final Value<String> trackId;
  final Value<String> kind;
  final Value<String> path;
  final Value<String> origin;
  final Value<int> sizeBytes;
  final Value<int> createdAtMs;
  final Value<int> lastAccessedAtMs;
  final Value<int> rowid;
  const LocalResourceEntriesCompanion({
    this.trackId = const Value.absent(),
    this.kind = const Value.absent(),
    this.path = const Value.absent(),
    this.origin = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.lastAccessedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalResourceEntriesCompanion.insert({
    required String trackId,
    required String kind,
    required String path,
    required String origin,
    required int sizeBytes,
    required int createdAtMs,
    required int lastAccessedAtMs,
    this.rowid = const Value.absent(),
  })  : trackId = Value(trackId),
        kind = Value(kind),
        path = Value(path),
        origin = Value(origin),
        sizeBytes = Value(sizeBytes),
        createdAtMs = Value(createdAtMs),
        lastAccessedAtMs = Value(lastAccessedAtMs);
  static Insertable<LocalResourceEntrie> custom({
    Expression<String>? trackId,
    Expression<String>? kind,
    Expression<String>? path,
    Expression<String>? origin,
    Expression<int>? sizeBytes,
    Expression<int>? createdAtMs,
    Expression<int>? lastAccessedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (kind != null) 'kind': kind,
      if (path != null) 'path': path,
      if (origin != null) 'origin': origin,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (lastAccessedAtMs != null) 'last_accessed_at_ms': lastAccessedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalResourceEntriesCompanion copyWith(
      {Value<String>? trackId,
      Value<String>? kind,
      Value<String>? path,
      Value<String>? origin,
      Value<int>? sizeBytes,
      Value<int>? createdAtMs,
      Value<int>? lastAccessedAtMs,
      Value<int>? rowid}) {
    return LocalResourceEntriesCompanion(
      trackId: trackId ?? this.trackId,
      kind: kind ?? this.kind,
      path: path ?? this.path,
      origin: origin ?? this.origin,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      lastAccessedAtMs: lastAccessedAtMs ?? this.lastAccessedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (lastAccessedAtMs.present) {
      map['last_accessed_at_ms'] = Variable<int>(lastAccessedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalResourceEntriesCompanion(')
          ..write('trackId: $trackId, ')
          ..write('kind: $kind, ')
          ..write('path: $path, ')
          ..write('origin: $origin, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('lastAccessedAtMs: $lastAccessedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadTasksTable extends DownloadTasks
    with TableInfo<$DownloadTasksTable, DownloadTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta =
      const VerificationMeta('trackId');
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
      'track_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMsMeta =
      const VerificationMeta('updatedAtMs');
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
      'updated_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _progressMeta =
      const VerificationMeta('progress');
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
      'progress', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _temporaryPathMeta =
      const VerificationMeta('temporaryPath');
  @override
  late final GeneratedColumn<String> temporaryPath = GeneratedColumn<String>(
      'temporary_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _failureReasonMeta =
      const VerificationMeta('failureReason');
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
      'failure_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [trackId, status, updatedAtMs, progress, temporaryPath, failureReason];
  @override
  String get aliasedName => _alias ?? 'download_tasks';
  @override
  String get actualTableName => 'download_tasks';
  @override
  VerificationContext validateIntegrity(Insertable<DownloadTask> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(_trackIdMeta,
          trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta));
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
          _updatedAtMsMeta,
          updatedAtMs.isAcceptableOrUnknown(
              data['updated_at_ms']!, _updatedAtMsMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(_progressMeta,
          progress.isAcceptableOrUnknown(data['progress']!, _progressMeta));
    }
    if (data.containsKey('temporary_path')) {
      context.handle(
          _temporaryPathMeta,
          temporaryPath.isAcceptableOrUnknown(
              data['temporary_path']!, _temporaryPathMeta));
    }
    if (data.containsKey('failure_reason')) {
      context.handle(
          _failureReasonMeta,
          failureReason.isAcceptableOrUnknown(
              data['failure_reason']!, _failureReasonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  DownloadTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadTask(
      trackId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}track_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      updatedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at_ms'])!,
      progress: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}progress']),
      temporaryPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}temporary_path']),
      failureReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}failure_reason']),
    );
  }

  @override
  $DownloadTasksTable createAlias(String alias) {
    return $DownloadTasksTable(attachedDatabase, alias);
  }
}

class DownloadTask extends DataClass implements Insertable<DownloadTask> {
  final String trackId;
  final String status;
  final int updatedAtMs;
  final double? progress;
  final String? temporaryPath;
  final String? failureReason;
  const DownloadTask(
      {required this.trackId,
      required this.status,
      required this.updatedAtMs,
      this.progress,
      this.temporaryPath,
      this.failureReason});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['status'] = Variable<String>(status);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || progress != null) {
      map['progress'] = Variable<double>(progress);
    }
    if (!nullToAbsent || temporaryPath != null) {
      map['temporary_path'] = Variable<String>(temporaryPath);
    }
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(failureReason);
    }
    return map;
  }

  DownloadTasksCompanion toCompanion(bool nullToAbsent) {
    return DownloadTasksCompanion(
      trackId: Value(trackId),
      status: Value(status),
      updatedAtMs: Value(updatedAtMs),
      progress: progress == null && nullToAbsent
          ? const Value.absent()
          : Value(progress),
      temporaryPath: temporaryPath == null && nullToAbsent
          ? const Value.absent()
          : Value(temporaryPath),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
    );
  }

  factory DownloadTask.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadTask(
      trackId: serializer.fromJson<String>(json['trackId']),
      status: serializer.fromJson<String>(json['status']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      progress: serializer.fromJson<double?>(json['progress']),
      temporaryPath: serializer.fromJson<String?>(json['temporaryPath']),
      failureReason: serializer.fromJson<String?>(json['failureReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'status': serializer.toJson<String>(status),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'progress': serializer.toJson<double?>(progress),
      'temporaryPath': serializer.toJson<String?>(temporaryPath),
      'failureReason': serializer.toJson<String?>(failureReason),
    };
  }

  DownloadTask copyWith(
          {String? trackId,
          String? status,
          int? updatedAtMs,
          Value<double?> progress = const Value.absent(),
          Value<String?> temporaryPath = const Value.absent(),
          Value<String?> failureReason = const Value.absent()}) =>
      DownloadTask(
        trackId: trackId ?? this.trackId,
        status: status ?? this.status,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
        progress: progress.present ? progress.value : this.progress,
        temporaryPath:
            temporaryPath.present ? temporaryPath.value : this.temporaryPath,
        failureReason:
            failureReason.present ? failureReason.value : this.failureReason,
      );
  @override
  String toString() {
    return (StringBuffer('DownloadTask(')
          ..write('trackId: $trackId, ')
          ..write('status: $status, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('progress: $progress, ')
          ..write('temporaryPath: $temporaryPath, ')
          ..write('failureReason: $failureReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      trackId, status, updatedAtMs, progress, temporaryPath, failureReason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadTask &&
          other.trackId == this.trackId &&
          other.status == this.status &&
          other.updatedAtMs == this.updatedAtMs &&
          other.progress == this.progress &&
          other.temporaryPath == this.temporaryPath &&
          other.failureReason == this.failureReason);
}

class DownloadTasksCompanion extends UpdateCompanion<DownloadTask> {
  final Value<String> trackId;
  final Value<String> status;
  final Value<int> updatedAtMs;
  final Value<double?> progress;
  final Value<String?> temporaryPath;
  final Value<String?> failureReason;
  final Value<int> rowid;
  const DownloadTasksCompanion({
    this.trackId = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.progress = const Value.absent(),
    this.temporaryPath = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadTasksCompanion.insert({
    required String trackId,
    required String status,
    required int updatedAtMs,
    this.progress = const Value.absent(),
    this.temporaryPath = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : trackId = Value(trackId),
        status = Value(status),
        updatedAtMs = Value(updatedAtMs);
  static Insertable<DownloadTask> custom({
    Expression<String>? trackId,
    Expression<String>? status,
    Expression<int>? updatedAtMs,
    Expression<double>? progress,
    Expression<String>? temporaryPath,
    Expression<String>? failureReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (status != null) 'status': status,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (progress != null) 'progress': progress,
      if (temporaryPath != null) 'temporary_path': temporaryPath,
      if (failureReason != null) 'failure_reason': failureReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadTasksCompanion copyWith(
      {Value<String>? trackId,
      Value<String>? status,
      Value<int>? updatedAtMs,
      Value<double?>? progress,
      Value<String?>? temporaryPath,
      Value<String?>? failureReason,
      Value<int>? rowid}) {
    return DownloadTasksCompanion(
      trackId: trackId ?? this.trackId,
      status: status ?? this.status,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      progress: progress ?? this.progress,
      temporaryPath: temporaryPath ?? this.temporaryPath,
      failureReason: failureReason ?? this.failureReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (temporaryPath.present) {
      map['temporary_path'] = Variable<String>(temporaryPath.value);
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(failureReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTasksCompanion(')
          ..write('trackId: $trackId, ')
          ..write('status: $status, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('progress: $progress, ')
          ..write('temporaryPath: $temporaryPath, ')
          ..write('failureReason: $failureReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppCacheEntriesTable extends AppCacheEntries
    with TableInfo<$AppCacheEntriesTable, AppCacheEntrie> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta =
      const VerificationMeta('cacheKey');
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
      'cache_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMsMeta =
      const VerificationMeta('updatedAtMs');
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
      'updated_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [cacheKey, payloadJson, updatedAtMs];
  @override
  String get aliasedName => _alias ?? 'app_cache_entries';
  @override
  String get actualTableName => 'app_cache_entries';
  @override
  VerificationContext validateIntegrity(Insertable<AppCacheEntrie> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(_cacheKeyMeta,
          cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta));
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
          _updatedAtMsMeta,
          updatedAtMs.isAcceptableOrUnknown(
              data['updated_at_ms']!, _updatedAtMsMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  AppCacheEntrie map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppCacheEntrie(
      cacheKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cache_key'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      updatedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at_ms'])!,
    );
  }

  @override
  $AppCacheEntriesTable createAlias(String alias) {
    return $AppCacheEntriesTable(attachedDatabase, alias);
  }
}

class AppCacheEntrie extends DataClass implements Insertable<AppCacheEntrie> {
  final String cacheKey;
  final String payloadJson;
  final int updatedAtMs;
  const AppCacheEntrie(
      {required this.cacheKey,
      required this.payloadJson,
      required this.updatedAtMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['payload_json'] = Variable<String>(payloadJson);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  AppCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return AppCacheEntriesCompanion(
      cacheKey: Value(cacheKey),
      payloadJson: Value(payloadJson),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory AppCacheEntrie.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppCacheEntrie(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  AppCacheEntrie copyWith(
          {String? cacheKey, String? payloadJson, int? updatedAtMs}) =>
      AppCacheEntrie(
        cacheKey: cacheKey ?? this.cacheKey,
        payloadJson: payloadJson ?? this.payloadJson,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      );
  @override
  String toString() {
    return (StringBuffer('AppCacheEntrie(')
          ..write('cacheKey: $cacheKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cacheKey, payloadJson, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppCacheEntrie &&
          other.cacheKey == this.cacheKey &&
          other.payloadJson == this.payloadJson &&
          other.updatedAtMs == this.updatedAtMs);
}

class AppCacheEntriesCompanion extends UpdateCompanion<AppCacheEntrie> {
  final Value<String> cacheKey;
  final Value<String> payloadJson;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const AppCacheEntriesCompanion({
    this.cacheKey = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppCacheEntriesCompanion.insert({
    required String cacheKey,
    required String payloadJson,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  })  : cacheKey = Value(cacheKey),
        payloadJson = Value(payloadJson),
        updatedAtMs = Value(updatedAtMs);
  static Insertable<AppCacheEntrie> custom({
    Expression<String>? cacheKey,
    Expression<String>? payloadJson,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppCacheEntriesCompanion copyWith(
      {Value<String>? cacheKey,
      Value<String>? payloadJson,
      Value<int>? updatedAtMs,
      Value<int>? rowid}) {
    return AppCacheEntriesCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppCacheEntriesCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TracksTable extends Tracks with TableInfo<$TracksTable, Track> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta =
      const VerificationMeta('trackId');
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
      'track_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _artistSearchTextMeta =
      const VerificationMeta('artistSearchText');
  @override
  late final GeneratedColumn<String> artistSearchText = GeneratedColumn<String>(
      'artist_search_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _artistNamesJsonMeta =
      const VerificationMeta('artistNamesJson');
  @override
  late final GeneratedColumn<String> artistNamesJson = GeneratedColumn<String>(
      'artist_names_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _albumTitleMeta =
      const VerificationMeta('albumTitle');
  @override
  late final GeneratedColumn<String> albumTitle = GeneratedColumn<String>(
      'album_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _artworkUrlMeta =
      const VerificationMeta('artworkUrl');
  @override
  late final GeneratedColumn<String> artworkUrl = GeneratedColumn<String>(
      'artwork_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _remoteUrlMeta =
      const VerificationMeta('remoteUrl');
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
      'remote_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lyricKeyMeta =
      const VerificationMeta('lyricKey');
  @override
  late final GeneratedColumn<String> lyricKey = GeneratedColumn<String>(
      'lyric_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _availabilityMeta =
      const VerificationMeta('availability');
  @override
  late final GeneratedColumn<String> availability = GeneratedColumn<String>(
      'availability', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _metadataJsonMeta =
      const VerificationMeta('metadataJson');
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
      'metadata_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        trackId,
        sourceType,
        sourceId,
        title,
        artistSearchText,
        artistNamesJson,
        albumTitle,
        durationMs,
        artworkUrl,
        remoteUrl,
        lyricKey,
        availability,
        metadataJson
      ];
  @override
  String get aliasedName => _alias ?? 'tracks';
  @override
  String get actualTableName => 'tracks';
  @override
  VerificationContext validateIntegrity(Insertable<Track> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(_trackIdMeta,
          trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta));
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist_search_text')) {
      context.handle(
          _artistSearchTextMeta,
          artistSearchText.isAcceptableOrUnknown(
              data['artist_search_text']!, _artistSearchTextMeta));
    } else if (isInserting) {
      context.missing(_artistSearchTextMeta);
    }
    if (data.containsKey('artist_names_json')) {
      context.handle(
          _artistNamesJsonMeta,
          artistNamesJson.isAcceptableOrUnknown(
              data['artist_names_json']!, _artistNamesJsonMeta));
    } else if (isInserting) {
      context.missing(_artistNamesJsonMeta);
    }
    if (data.containsKey('album_title')) {
      context.handle(
          _albumTitleMeta,
          albumTitle.isAcceptableOrUnknown(
              data['album_title']!, _albumTitleMeta));
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    }
    if (data.containsKey('artwork_url')) {
      context.handle(
          _artworkUrlMeta,
          artworkUrl.isAcceptableOrUnknown(
              data['artwork_url']!, _artworkUrlMeta));
    }
    if (data.containsKey('remote_url')) {
      context.handle(_remoteUrlMeta,
          remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta));
    }
    if (data.containsKey('lyric_key')) {
      context.handle(_lyricKeyMeta,
          lyricKey.isAcceptableOrUnknown(data['lyric_key']!, _lyricKeyMeta));
    }
    if (data.containsKey('availability')) {
      context.handle(
          _availabilityMeta,
          availability.isAcceptableOrUnknown(
              data['availability']!, _availabilityMeta));
    } else if (isInserting) {
      context.missing(_availabilityMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
          _metadataJsonMeta,
          metadataJson.isAcceptableOrUnknown(
              data['metadata_json']!, _metadataJsonMeta));
    } else if (isInserting) {
      context.missing(_metadataJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  Track map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Track(
      trackId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}track_id'])!,
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      artistSearchText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}artist_search_text'])!,
      artistNamesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}artist_names_json'])!,
      albumTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album_title']),
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms']),
      artworkUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artwork_url']),
      remoteUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_url']),
      lyricKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lyric_key']),
      availability: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}availability'])!,
      metadataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_json'])!,
    );
  }

  @override
  $TracksTable createAlias(String alias) {
    return $TracksTable(attachedDatabase, alias);
  }
}

class Track extends DataClass implements Insertable<Track> {
  final String trackId;
  final String sourceType;
  final String sourceId;
  final String title;
  final String artistSearchText;
  final String artistNamesJson;
  final String? albumTitle;
  final int? durationMs;
  final String? artworkUrl;
  final String? remoteUrl;
  final String? lyricKey;
  final String availability;
  final String metadataJson;
  const Track(
      {required this.trackId,
      required this.sourceType,
      required this.sourceId,
      required this.title,
      required this.artistSearchText,
      required this.artistNamesJson,
      this.albumTitle,
      this.durationMs,
      this.artworkUrl,
      this.remoteUrl,
      this.lyricKey,
      required this.availability,
      required this.metadataJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['source_type'] = Variable<String>(sourceType);
    map['source_id'] = Variable<String>(sourceId);
    map['title'] = Variable<String>(title);
    map['artist_search_text'] = Variable<String>(artistSearchText);
    map['artist_names_json'] = Variable<String>(artistNamesJson);
    if (!nullToAbsent || albumTitle != null) {
      map['album_title'] = Variable<String>(albumTitle);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || artworkUrl != null) {
      map['artwork_url'] = Variable<String>(artworkUrl);
    }
    if (!nullToAbsent || remoteUrl != null) {
      map['remote_url'] = Variable<String>(remoteUrl);
    }
    if (!nullToAbsent || lyricKey != null) {
      map['lyric_key'] = Variable<String>(lyricKey);
    }
    map['availability'] = Variable<String>(availability);
    map['metadata_json'] = Variable<String>(metadataJson);
    return map;
  }

  TracksCompanion toCompanion(bool nullToAbsent) {
    return TracksCompanion(
      trackId: Value(trackId),
      sourceType: Value(sourceType),
      sourceId: Value(sourceId),
      title: Value(title),
      artistSearchText: Value(artistSearchText),
      artistNamesJson: Value(artistNamesJson),
      albumTitle: albumTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(albumTitle),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      artworkUrl: artworkUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUrl),
      remoteUrl: remoteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUrl),
      lyricKey: lyricKey == null && nullToAbsent
          ? const Value.absent()
          : Value(lyricKey),
      availability: Value(availability),
      metadataJson: Value(metadataJson),
    );
  }

  factory Track.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Track(
      trackId: serializer.fromJson<String>(json['trackId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      title: serializer.fromJson<String>(json['title']),
      artistSearchText: serializer.fromJson<String>(json['artistSearchText']),
      artistNamesJson: serializer.fromJson<String>(json['artistNamesJson']),
      albumTitle: serializer.fromJson<String?>(json['albumTitle']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      artworkUrl: serializer.fromJson<String?>(json['artworkUrl']),
      remoteUrl: serializer.fromJson<String?>(json['remoteUrl']),
      lyricKey: serializer.fromJson<String?>(json['lyricKey']),
      availability: serializer.fromJson<String>(json['availability']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceId': serializer.toJson<String>(sourceId),
      'title': serializer.toJson<String>(title),
      'artistSearchText': serializer.toJson<String>(artistSearchText),
      'artistNamesJson': serializer.toJson<String>(artistNamesJson),
      'albumTitle': serializer.toJson<String?>(albumTitle),
      'durationMs': serializer.toJson<int?>(durationMs),
      'artworkUrl': serializer.toJson<String?>(artworkUrl),
      'remoteUrl': serializer.toJson<String?>(remoteUrl),
      'lyricKey': serializer.toJson<String?>(lyricKey),
      'availability': serializer.toJson<String>(availability),
      'metadataJson': serializer.toJson<String>(metadataJson),
    };
  }

  Track copyWith(
          {String? trackId,
          String? sourceType,
          String? sourceId,
          String? title,
          String? artistSearchText,
          String? artistNamesJson,
          Value<String?> albumTitle = const Value.absent(),
          Value<int?> durationMs = const Value.absent(),
          Value<String?> artworkUrl = const Value.absent(),
          Value<String?> remoteUrl = const Value.absent(),
          Value<String?> lyricKey = const Value.absent(),
          String? availability,
          String? metadataJson}) =>
      Track(
        trackId: trackId ?? this.trackId,
        sourceType: sourceType ?? this.sourceType,
        sourceId: sourceId ?? this.sourceId,
        title: title ?? this.title,
        artistSearchText: artistSearchText ?? this.artistSearchText,
        artistNamesJson: artistNamesJson ?? this.artistNamesJson,
        albumTitle: albumTitle.present ? albumTitle.value : this.albumTitle,
        durationMs: durationMs.present ? durationMs.value : this.durationMs,
        artworkUrl: artworkUrl.present ? artworkUrl.value : this.artworkUrl,
        remoteUrl: remoteUrl.present ? remoteUrl.value : this.remoteUrl,
        lyricKey: lyricKey.present ? lyricKey.value : this.lyricKey,
        availability: availability ?? this.availability,
        metadataJson: metadataJson ?? this.metadataJson,
      );
  @override
  String toString() {
    return (StringBuffer('Track(')
          ..write('trackId: $trackId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('artistSearchText: $artistSearchText, ')
          ..write('artistNamesJson: $artistNamesJson, ')
          ..write('albumTitle: $albumTitle, ')
          ..write('durationMs: $durationMs, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('lyricKey: $lyricKey, ')
          ..write('availability: $availability, ')
          ..write('metadataJson: $metadataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      trackId,
      sourceType,
      sourceId,
      title,
      artistSearchText,
      artistNamesJson,
      albumTitle,
      durationMs,
      artworkUrl,
      remoteUrl,
      lyricKey,
      availability,
      metadataJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Track &&
          other.trackId == this.trackId &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.title == this.title &&
          other.artistSearchText == this.artistSearchText &&
          other.artistNamesJson == this.artistNamesJson &&
          other.albumTitle == this.albumTitle &&
          other.durationMs == this.durationMs &&
          other.artworkUrl == this.artworkUrl &&
          other.remoteUrl == this.remoteUrl &&
          other.lyricKey == this.lyricKey &&
          other.availability == this.availability &&
          other.metadataJson == this.metadataJson);
}

class TracksCompanion extends UpdateCompanion<Track> {
  final Value<String> trackId;
  final Value<String> sourceType;
  final Value<String> sourceId;
  final Value<String> title;
  final Value<String> artistSearchText;
  final Value<String> artistNamesJson;
  final Value<String?> albumTitle;
  final Value<int?> durationMs;
  final Value<String?> artworkUrl;
  final Value<String?> remoteUrl;
  final Value<String?> lyricKey;
  final Value<String> availability;
  final Value<String> metadataJson;
  final Value<int> rowid;
  const TracksCompanion({
    this.trackId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.title = const Value.absent(),
    this.artistSearchText = const Value.absent(),
    this.artistNamesJson = const Value.absent(),
    this.albumTitle = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.lyricKey = const Value.absent(),
    this.availability = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TracksCompanion.insert({
    required String trackId,
    required String sourceType,
    required String sourceId,
    required String title,
    required String artistSearchText,
    required String artistNamesJson,
    this.albumTitle = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.lyricKey = const Value.absent(),
    required String availability,
    required String metadataJson,
    this.rowid = const Value.absent(),
  })  : trackId = Value(trackId),
        sourceType = Value(sourceType),
        sourceId = Value(sourceId),
        title = Value(title),
        artistSearchText = Value(artistSearchText),
        artistNamesJson = Value(artistNamesJson),
        availability = Value(availability),
        metadataJson = Value(metadataJson);
  static Insertable<Track> custom({
    Expression<String>? trackId,
    Expression<String>? sourceType,
    Expression<String>? sourceId,
    Expression<String>? title,
    Expression<String>? artistSearchText,
    Expression<String>? artistNamesJson,
    Expression<String>? albumTitle,
    Expression<int>? durationMs,
    Expression<String>? artworkUrl,
    Expression<String>? remoteUrl,
    Expression<String>? lyricKey,
    Expression<String>? availability,
    Expression<String>? metadataJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (title != null) 'title': title,
      if (artistSearchText != null) 'artist_search_text': artistSearchText,
      if (artistNamesJson != null) 'artist_names_json': artistNamesJson,
      if (albumTitle != null) 'album_title': albumTitle,
      if (durationMs != null) 'duration_ms': durationMs,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (lyricKey != null) 'lyric_key': lyricKey,
      if (availability != null) 'availability': availability,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TracksCompanion copyWith(
      {Value<String>? trackId,
      Value<String>? sourceType,
      Value<String>? sourceId,
      Value<String>? title,
      Value<String>? artistSearchText,
      Value<String>? artistNamesJson,
      Value<String?>? albumTitle,
      Value<int?>? durationMs,
      Value<String?>? artworkUrl,
      Value<String?>? remoteUrl,
      Value<String?>? lyricKey,
      Value<String>? availability,
      Value<String>? metadataJson,
      Value<int>? rowid}) {
    return TracksCompanion(
      trackId: trackId ?? this.trackId,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      artistSearchText: artistSearchText ?? this.artistSearchText,
      artistNamesJson: artistNamesJson ?? this.artistNamesJson,
      albumTitle: albumTitle ?? this.albumTitle,
      durationMs: durationMs ?? this.durationMs,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      lyricKey: lyricKey ?? this.lyricKey,
      availability: availability ?? this.availability,
      metadataJson: metadataJson ?? this.metadataJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artistSearchText.present) {
      map['artist_search_text'] = Variable<String>(artistSearchText.value);
    }
    if (artistNamesJson.present) {
      map['artist_names_json'] = Variable<String>(artistNamesJson.value);
    }
    if (albumTitle.present) {
      map['album_title'] = Variable<String>(albumTitle.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (artworkUrl.present) {
      map['artwork_url'] = Variable<String>(artworkUrl.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (lyricKey.present) {
      map['lyric_key'] = Variable<String>(lyricKey.value);
    }
    if (availability.present) {
      map['availability'] = Variable<String>(availability.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TracksCompanion(')
          ..write('trackId: $trackId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('artistSearchText: $artistSearchText, ')
          ..write('artistNamesJson: $artistNamesJson, ')
          ..write('albumTitle: $albumTitle, ')
          ..write('durationMs: $durationMs, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('lyricKey: $lyricKey, ')
          ..write('availability: $availability, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackLyricsEntriesTable extends TrackLyricsEntries
    with TableInfo<$TrackLyricsEntriesTable, TrackLyricsEntrie> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackLyricsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta =
      const VerificationMeta('trackId');
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
      'track_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mainMeta = const VerificationMeta('main');
  @override
  late final GeneratedColumn<String> main = GeneratedColumn<String>(
      'main', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _translatedMeta =
      const VerificationMeta('translated');
  @override
  late final GeneratedColumn<String> translated = GeneratedColumn<String>(
      'translated', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [trackId, main, translated];
  @override
  String get aliasedName => _alias ?? 'track_lyrics_entries';
  @override
  String get actualTableName => 'track_lyrics_entries';
  @override
  VerificationContext validateIntegrity(Insertable<TrackLyricsEntrie> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(_trackIdMeta,
          trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta));
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('main')) {
      context.handle(
          _mainMeta, main.isAcceptableOrUnknown(data['main']!, _mainMeta));
    } else if (isInserting) {
      context.missing(_mainMeta);
    }
    if (data.containsKey('translated')) {
      context.handle(
          _translatedMeta,
          translated.isAcceptableOrUnknown(
              data['translated']!, _translatedMeta));
    } else if (isInserting) {
      context.missing(_translatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  TrackLyricsEntrie map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackLyricsEntrie(
      trackId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}track_id'])!,
      main: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}main'])!,
      translated: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}translated'])!,
    );
  }

  @override
  $TrackLyricsEntriesTable createAlias(String alias) {
    return $TrackLyricsEntriesTable(attachedDatabase, alias);
  }
}

class TrackLyricsEntrie extends DataClass
    implements Insertable<TrackLyricsEntrie> {
  final String trackId;
  final String main;
  final String translated;
  const TrackLyricsEntrie(
      {required this.trackId, required this.main, required this.translated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['main'] = Variable<String>(main);
    map['translated'] = Variable<String>(translated);
    return map;
  }

  TrackLyricsEntriesCompanion toCompanion(bool nullToAbsent) {
    return TrackLyricsEntriesCompanion(
      trackId: Value(trackId),
      main: Value(main),
      translated: Value(translated),
    );
  }

  factory TrackLyricsEntrie.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackLyricsEntrie(
      trackId: serializer.fromJson<String>(json['trackId']),
      main: serializer.fromJson<String>(json['main']),
      translated: serializer.fromJson<String>(json['translated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'main': serializer.toJson<String>(main),
      'translated': serializer.toJson<String>(translated),
    };
  }

  TrackLyricsEntrie copyWith(
          {String? trackId, String? main, String? translated}) =>
      TrackLyricsEntrie(
        trackId: trackId ?? this.trackId,
        main: main ?? this.main,
        translated: translated ?? this.translated,
      );
  @override
  String toString() {
    return (StringBuffer('TrackLyricsEntrie(')
          ..write('trackId: $trackId, ')
          ..write('main: $main, ')
          ..write('translated: $translated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackId, main, translated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackLyricsEntrie &&
          other.trackId == this.trackId &&
          other.main == this.main &&
          other.translated == this.translated);
}

class TrackLyricsEntriesCompanion extends UpdateCompanion<TrackLyricsEntrie> {
  final Value<String> trackId;
  final Value<String> main;
  final Value<String> translated;
  final Value<int> rowid;
  const TrackLyricsEntriesCompanion({
    this.trackId = const Value.absent(),
    this.main = const Value.absent(),
    this.translated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackLyricsEntriesCompanion.insert({
    required String trackId,
    required String main,
    required String translated,
    this.rowid = const Value.absent(),
  })  : trackId = Value(trackId),
        main = Value(main),
        translated = Value(translated);
  static Insertable<TrackLyricsEntrie> custom({
    Expression<String>? trackId,
    Expression<String>? main,
    Expression<String>? translated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (main != null) 'main': main,
      if (translated != null) 'translated': translated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackLyricsEntriesCompanion copyWith(
      {Value<String>? trackId,
      Value<String>? main,
      Value<String>? translated,
      Value<int>? rowid}) {
    return TrackLyricsEntriesCompanion(
      trackId: trackId ?? this.trackId,
      main: main ?? this.main,
      translated: translated ?? this.translated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (main.present) {
      map['main'] = Variable<String>(main.value);
    }
    if (translated.present) {
      map['translated'] = Variable<String>(translated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackLyricsEntriesCompanion(')
          ..write('trackId: $trackId, ')
          ..write('main: $main, ')
          ..write('translated: $translated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, Playlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta =
      const VerificationMeta('playlistId');
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
      'playlist_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverUrlMeta =
      const VerificationMeta('coverUrl');
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
      'cover_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _trackCountMeta =
      const VerificationMeta('trackCount');
  @override
  late final GeneratedColumn<int> trackCount = GeneratedColumn<int>(
      'track_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        playlistId,
        sourceType,
        sourceId,
        title,
        description,
        coverUrl,
        trackCount
      ];
  @override
  String get aliasedName => _alias ?? 'playlists';
  @override
  String get actualTableName => 'playlists';
  @override
  VerificationContext validateIntegrity(Insertable<Playlist> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
          _playlistIdMeta,
          playlistId.isAcceptableOrUnknown(
              data['playlist_id']!, _playlistIdMeta));
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('cover_url')) {
      context.handle(_coverUrlMeta,
          coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta));
    }
    if (data.containsKey('track_count')) {
      context.handle(
          _trackCountMeta,
          trackCount.isAcceptableOrUnknown(
              data['track_count']!, _trackCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId};
  @override
  Playlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Playlist(
      playlistId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}playlist_id'])!,
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      coverUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_url']),
      trackCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}track_count']),
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class Playlist extends DataClass implements Insertable<Playlist> {
  final String playlistId;
  final String sourceType;
  final String sourceId;
  final String title;
  final String? description;
  final String? coverUrl;
  final int? trackCount;
  const Playlist(
      {required this.playlistId,
      required this.sourceType,
      required this.sourceId,
      required this.title,
      this.description,
      this.coverUrl,
      this.trackCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['source_type'] = Variable<String>(sourceType);
    map['source_id'] = Variable<String>(sourceId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || trackCount != null) {
      map['track_count'] = Variable<int>(trackCount);
    }
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      playlistId: Value(playlistId),
      sourceType: Value(sourceType),
      sourceId: Value(sourceId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      trackCount: trackCount == null && nullToAbsent
          ? const Value.absent()
          : Value(trackCount),
    );
  }

  factory Playlist.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Playlist(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      trackCount: serializer.fromJson<int?>(json['trackCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceId': serializer.toJson<String>(sourceId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'trackCount': serializer.toJson<int?>(trackCount),
    };
  }

  Playlist copyWith(
          {String? playlistId,
          String? sourceType,
          String? sourceId,
          String? title,
          Value<String?> description = const Value.absent(),
          Value<String?> coverUrl = const Value.absent(),
          Value<int?> trackCount = const Value.absent()}) =>
      Playlist(
        playlistId: playlistId ?? this.playlistId,
        sourceType: sourceType ?? this.sourceType,
        sourceId: sourceId ?? this.sourceId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
        trackCount: trackCount.present ? trackCount.value : this.trackCount,
      );
  @override
  String toString() {
    return (StringBuffer('Playlist(')
          ..write('playlistId: $playlistId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('trackCount: $trackCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, sourceType, sourceId, title,
      description, coverUrl, trackCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Playlist &&
          other.playlistId == this.playlistId &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.title == this.title &&
          other.description == this.description &&
          other.coverUrl == this.coverUrl &&
          other.trackCount == this.trackCount);
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<String> playlistId;
  final Value<String> sourceType;
  final Value<String> sourceId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> coverUrl;
  final Value<int?> trackCount;
  final Value<int> rowid;
  const PlaylistsCompanion({
    this.playlistId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.trackCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    required String playlistId,
    required String sourceType,
    required String sourceId,
    required String title,
    this.description = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.trackCount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : playlistId = Value(playlistId),
        sourceType = Value(sourceType),
        sourceId = Value(sourceId),
        title = Value(title);
  static Insertable<Playlist> custom({
    Expression<String>? playlistId,
    Expression<String>? sourceType,
    Expression<String>? sourceId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? coverUrl,
    Expression<int>? trackCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (trackCount != null) 'track_count': trackCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsCompanion copyWith(
      {Value<String>? playlistId,
      Value<String>? sourceType,
      Value<String>? sourceId,
      Value<String>? title,
      Value<String?>? description,
      Value<String?>? coverUrl,
      Value<int?>? trackCount,
      Value<int>? rowid}) {
    return PlaylistsCompanion(
      playlistId: playlistId ?? this.playlistId,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      trackCount: trackCount ?? this.trackCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (trackCount.present) {
      map['track_count'] = Variable<int>(trackCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('trackCount: $trackCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistTrackRefsTable extends PlaylistTrackRefs
    with TableInfo<$PlaylistTrackRefsTable, PlaylistTrackRef> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistTrackRefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta =
      const VerificationMeta('playlistId');
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
      'playlist_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _trackIdMeta =
      const VerificationMeta('trackId');
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
      'track_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<int> addedAt = GeneratedColumn<int>(
      'added_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [playlistId, trackId, order, addedAt];
  @override
  String get aliasedName => _alias ?? 'playlist_track_refs';
  @override
  String get actualTableName => 'playlist_track_refs';
  @override
  VerificationContext validateIntegrity(Insertable<PlaylistTrackRef> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
          _playlistIdMeta,
          playlistId.isAcceptableOrUnknown(
              data['playlist_id']!, _playlistIdMeta));
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(_trackIdMeta,
          trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta));
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, trackId};
  @override
  PlaylistTrackRef map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistTrackRef(
      playlistId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}playlist_id'])!,
      trackId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}track_id'])!,
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}added_at']),
    );
  }

  @override
  $PlaylistTrackRefsTable createAlias(String alias) {
    return $PlaylistTrackRefsTable(attachedDatabase, alias);
  }
}

class PlaylistTrackRef extends DataClass
    implements Insertable<PlaylistTrackRef> {
  final String playlistId;
  final String trackId;
  final int order;
  final int? addedAt;
  const PlaylistTrackRef(
      {required this.playlistId,
      required this.trackId,
      required this.order,
      this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['track_id'] = Variable<String>(trackId);
    map['order'] = Variable<int>(order);
    if (!nullToAbsent || addedAt != null) {
      map['added_at'] = Variable<int>(addedAt);
    }
    return map;
  }

  PlaylistTrackRefsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistTrackRefsCompanion(
      playlistId: Value(playlistId),
      trackId: Value(trackId),
      order: Value(order),
      addedAt: addedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(addedAt),
    );
  }

  factory PlaylistTrackRef.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistTrackRef(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      trackId: serializer.fromJson<String>(json['trackId']),
      order: serializer.fromJson<int>(json['order']),
      addedAt: serializer.fromJson<int?>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'trackId': serializer.toJson<String>(trackId),
      'order': serializer.toJson<int>(order),
      'addedAt': serializer.toJson<int?>(addedAt),
    };
  }

  PlaylistTrackRef copyWith(
          {String? playlistId,
          String? trackId,
          int? order,
          Value<int?> addedAt = const Value.absent()}) =>
      PlaylistTrackRef(
        playlistId: playlistId ?? this.playlistId,
        trackId: trackId ?? this.trackId,
        order: order ?? this.order,
        addedAt: addedAt.present ? addedAt.value : this.addedAt,
      );
  @override
  String toString() {
    return (StringBuffer('PlaylistTrackRef(')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('order: $order, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, trackId, order, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistTrackRef &&
          other.playlistId == this.playlistId &&
          other.trackId == this.trackId &&
          other.order == this.order &&
          other.addedAt == this.addedAt);
}

class PlaylistTrackRefsCompanion extends UpdateCompanion<PlaylistTrackRef> {
  final Value<String> playlistId;
  final Value<String> trackId;
  final Value<int> order;
  final Value<int?> addedAt;
  final Value<int> rowid;
  const PlaylistTrackRefsCompanion({
    this.playlistId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.order = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistTrackRefsCompanion.insert({
    required String playlistId,
    required String trackId,
    required int order,
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : playlistId = Value(playlistId),
        trackId = Value(trackId),
        order = Value(order);
  static Insertable<PlaylistTrackRef> custom({
    Expression<String>? playlistId,
    Expression<String>? trackId,
    Expression<int>? order,
    Expression<int>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (trackId != null) 'track_id': trackId,
      if (order != null) 'order': order,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistTrackRefsCompanion copyWith(
      {Value<String>? playlistId,
      Value<String>? trackId,
      Value<int>? order,
      Value<int?>? addedAt,
      Value<int>? rowid}) {
    return PlaylistTrackRefsCompanion(
      playlistId: playlistId ?? this.playlistId,
      trackId: trackId ?? this.trackId,
      order: order ?? this.order,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<int>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTrackRefsCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('order: $order, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlbumsTable extends Albums with TableInfo<$AlbumsTable, Album> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _albumIdMeta =
      const VerificationMeta('albumId');
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
      'album_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _artistSearchTextMeta =
      const VerificationMeta('artistSearchText');
  @override
  late final GeneratedColumn<String> artistSearchText = GeneratedColumn<String>(
      'artist_search_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _artistNamesJsonMeta =
      const VerificationMeta('artistNamesJson');
  @override
  late final GeneratedColumn<String> artistNamesJson = GeneratedColumn<String>(
      'artist_names_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _artworkUrlMeta =
      const VerificationMeta('artworkUrl');
  @override
  late final GeneratedColumn<String> artworkUrl = GeneratedColumn<String>(
      'artwork_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _trackCountMeta =
      const VerificationMeta('trackCount');
  @override
  late final GeneratedColumn<int> trackCount = GeneratedColumn<int>(
      'track_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _publishTimeMeta =
      const VerificationMeta('publishTime');
  @override
  late final GeneratedColumn<int> publishTime = GeneratedColumn<int>(
      'publish_time', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        albumId,
        sourceType,
        sourceId,
        title,
        artistSearchText,
        artistNamesJson,
        artworkUrl,
        description,
        trackCount,
        publishTime
      ];
  @override
  String get aliasedName => _alias ?? 'albums';
  @override
  String get actualTableName => 'albums';
  @override
  VerificationContext validateIntegrity(Insertable<Album> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('album_id')) {
      context.handle(_albumIdMeta,
          albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta));
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist_search_text')) {
      context.handle(
          _artistSearchTextMeta,
          artistSearchText.isAcceptableOrUnknown(
              data['artist_search_text']!, _artistSearchTextMeta));
    } else if (isInserting) {
      context.missing(_artistSearchTextMeta);
    }
    if (data.containsKey('artist_names_json')) {
      context.handle(
          _artistNamesJsonMeta,
          artistNamesJson.isAcceptableOrUnknown(
              data['artist_names_json']!, _artistNamesJsonMeta));
    } else if (isInserting) {
      context.missing(_artistNamesJsonMeta);
    }
    if (data.containsKey('artwork_url')) {
      context.handle(
          _artworkUrlMeta,
          artworkUrl.isAcceptableOrUnknown(
              data['artwork_url']!, _artworkUrlMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('track_count')) {
      context.handle(
          _trackCountMeta,
          trackCount.isAcceptableOrUnknown(
              data['track_count']!, _trackCountMeta));
    }
    if (data.containsKey('publish_time')) {
      context.handle(
          _publishTimeMeta,
          publishTime.isAcceptableOrUnknown(
              data['publish_time']!, _publishTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {albumId};
  @override
  Album map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Album(
      albumId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album_id'])!,
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      artistSearchText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}artist_search_text'])!,
      artistNamesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}artist_names_json'])!,
      artworkUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artwork_url']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      trackCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}track_count']),
      publishTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}publish_time']),
    );
  }

  @override
  $AlbumsTable createAlias(String alias) {
    return $AlbumsTable(attachedDatabase, alias);
  }
}

class Album extends DataClass implements Insertable<Album> {
  final String albumId;
  final String sourceType;
  final String sourceId;
  final String title;
  final String artistSearchText;
  final String artistNamesJson;
  final String? artworkUrl;
  final String? description;
  final int? trackCount;
  final int? publishTime;
  const Album(
      {required this.albumId,
      required this.sourceType,
      required this.sourceId,
      required this.title,
      required this.artistSearchText,
      required this.artistNamesJson,
      this.artworkUrl,
      this.description,
      this.trackCount,
      this.publishTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['album_id'] = Variable<String>(albumId);
    map['source_type'] = Variable<String>(sourceType);
    map['source_id'] = Variable<String>(sourceId);
    map['title'] = Variable<String>(title);
    map['artist_search_text'] = Variable<String>(artistSearchText);
    map['artist_names_json'] = Variable<String>(artistNamesJson);
    if (!nullToAbsent || artworkUrl != null) {
      map['artwork_url'] = Variable<String>(artworkUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || trackCount != null) {
      map['track_count'] = Variable<int>(trackCount);
    }
    if (!nullToAbsent || publishTime != null) {
      map['publish_time'] = Variable<int>(publishTime);
    }
    return map;
  }

  AlbumsCompanion toCompanion(bool nullToAbsent) {
    return AlbumsCompanion(
      albumId: Value(albumId),
      sourceType: Value(sourceType),
      sourceId: Value(sourceId),
      title: Value(title),
      artistSearchText: Value(artistSearchText),
      artistNamesJson: Value(artistNamesJson),
      artworkUrl: artworkUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      trackCount: trackCount == null && nullToAbsent
          ? const Value.absent()
          : Value(trackCount),
      publishTime: publishTime == null && nullToAbsent
          ? const Value.absent()
          : Value(publishTime),
    );
  }

  factory Album.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Album(
      albumId: serializer.fromJson<String>(json['albumId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      title: serializer.fromJson<String>(json['title']),
      artistSearchText: serializer.fromJson<String>(json['artistSearchText']),
      artistNamesJson: serializer.fromJson<String>(json['artistNamesJson']),
      artworkUrl: serializer.fromJson<String?>(json['artworkUrl']),
      description: serializer.fromJson<String?>(json['description']),
      trackCount: serializer.fromJson<int?>(json['trackCount']),
      publishTime: serializer.fromJson<int?>(json['publishTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'albumId': serializer.toJson<String>(albumId),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceId': serializer.toJson<String>(sourceId),
      'title': serializer.toJson<String>(title),
      'artistSearchText': serializer.toJson<String>(artistSearchText),
      'artistNamesJson': serializer.toJson<String>(artistNamesJson),
      'artworkUrl': serializer.toJson<String?>(artworkUrl),
      'description': serializer.toJson<String?>(description),
      'trackCount': serializer.toJson<int?>(trackCount),
      'publishTime': serializer.toJson<int?>(publishTime),
    };
  }

  Album copyWith(
          {String? albumId,
          String? sourceType,
          String? sourceId,
          String? title,
          String? artistSearchText,
          String? artistNamesJson,
          Value<String?> artworkUrl = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<int?> trackCount = const Value.absent(),
          Value<int?> publishTime = const Value.absent()}) =>
      Album(
        albumId: albumId ?? this.albumId,
        sourceType: sourceType ?? this.sourceType,
        sourceId: sourceId ?? this.sourceId,
        title: title ?? this.title,
        artistSearchText: artistSearchText ?? this.artistSearchText,
        artistNamesJson: artistNamesJson ?? this.artistNamesJson,
        artworkUrl: artworkUrl.present ? artworkUrl.value : this.artworkUrl,
        description: description.present ? description.value : this.description,
        trackCount: trackCount.present ? trackCount.value : this.trackCount,
        publishTime: publishTime.present ? publishTime.value : this.publishTime,
      );
  @override
  String toString() {
    return (StringBuffer('Album(')
          ..write('albumId: $albumId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('artistSearchText: $artistSearchText, ')
          ..write('artistNamesJson: $artistNamesJson, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('description: $description, ')
          ..write('trackCount: $trackCount, ')
          ..write('publishTime: $publishTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      albumId,
      sourceType,
      sourceId,
      title,
      artistSearchText,
      artistNamesJson,
      artworkUrl,
      description,
      trackCount,
      publishTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Album &&
          other.albumId == this.albumId &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.title == this.title &&
          other.artistSearchText == this.artistSearchText &&
          other.artistNamesJson == this.artistNamesJson &&
          other.artworkUrl == this.artworkUrl &&
          other.description == this.description &&
          other.trackCount == this.trackCount &&
          other.publishTime == this.publishTime);
}

class AlbumsCompanion extends UpdateCompanion<Album> {
  final Value<String> albumId;
  final Value<String> sourceType;
  final Value<String> sourceId;
  final Value<String> title;
  final Value<String> artistSearchText;
  final Value<String> artistNamesJson;
  final Value<String?> artworkUrl;
  final Value<String?> description;
  final Value<int?> trackCount;
  final Value<int?> publishTime;
  final Value<int> rowid;
  const AlbumsCompanion({
    this.albumId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.title = const Value.absent(),
    this.artistSearchText = const Value.absent(),
    this.artistNamesJson = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.trackCount = const Value.absent(),
    this.publishTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlbumsCompanion.insert({
    required String albumId,
    required String sourceType,
    required String sourceId,
    required String title,
    required String artistSearchText,
    required String artistNamesJson,
    this.artworkUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.trackCount = const Value.absent(),
    this.publishTime = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : albumId = Value(albumId),
        sourceType = Value(sourceType),
        sourceId = Value(sourceId),
        title = Value(title),
        artistSearchText = Value(artistSearchText),
        artistNamesJson = Value(artistNamesJson);
  static Insertable<Album> custom({
    Expression<String>? albumId,
    Expression<String>? sourceType,
    Expression<String>? sourceId,
    Expression<String>? title,
    Expression<String>? artistSearchText,
    Expression<String>? artistNamesJson,
    Expression<String>? artworkUrl,
    Expression<String>? description,
    Expression<int>? trackCount,
    Expression<int>? publishTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (albumId != null) 'album_id': albumId,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (title != null) 'title': title,
      if (artistSearchText != null) 'artist_search_text': artistSearchText,
      if (artistNamesJson != null) 'artist_names_json': artistNamesJson,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (description != null) 'description': description,
      if (trackCount != null) 'track_count': trackCount,
      if (publishTime != null) 'publish_time': publishTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlbumsCompanion copyWith(
      {Value<String>? albumId,
      Value<String>? sourceType,
      Value<String>? sourceId,
      Value<String>? title,
      Value<String>? artistSearchText,
      Value<String>? artistNamesJson,
      Value<String?>? artworkUrl,
      Value<String?>? description,
      Value<int?>? trackCount,
      Value<int?>? publishTime,
      Value<int>? rowid}) {
    return AlbumsCompanion(
      albumId: albumId ?? this.albumId,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      artistSearchText: artistSearchText ?? this.artistSearchText,
      artistNamesJson: artistNamesJson ?? this.artistNamesJson,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      description: description ?? this.description,
      trackCount: trackCount ?? this.trackCount,
      publishTime: publishTime ?? this.publishTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artistSearchText.present) {
      map['artist_search_text'] = Variable<String>(artistSearchText.value);
    }
    if (artistNamesJson.present) {
      map['artist_names_json'] = Variable<String>(artistNamesJson.value);
    }
    if (artworkUrl.present) {
      map['artwork_url'] = Variable<String>(artworkUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (trackCount.present) {
      map['track_count'] = Variable<int>(trackCount.value);
    }
    if (publishTime.present) {
      map['publish_time'] = Variable<int>(publishTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumsCompanion(')
          ..write('albumId: $albumId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('artistSearchText: $artistSearchText, ')
          ..write('artistNamesJson: $artistNamesJson, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('description: $description, ')
          ..write('trackCount: $trackCount, ')
          ..write('publishTime: $publishTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArtistsTable extends Artists with TableInfo<$ArtistsTable, Artist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _artistIdMeta =
      const VerificationMeta('artistId');
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
      'artist_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _artworkUrlMeta =
      const VerificationMeta('artworkUrl');
  @override
  late final GeneratedColumn<String> artworkUrl = GeneratedColumn<String>(
      'artwork_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [artistId, sourceType, sourceId, name, artworkUrl, description];
  @override
  String get aliasedName => _alias ?? 'artists';
  @override
  String get actualTableName => 'artists';
  @override
  VerificationContext validateIntegrity(Insertable<Artist> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('artist_id')) {
      context.handle(_artistIdMeta,
          artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta));
    } else if (isInserting) {
      context.missing(_artistIdMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('artwork_url')) {
      context.handle(
          _artworkUrlMeta,
          artworkUrl.isAcceptableOrUnknown(
              data['artwork_url']!, _artworkUrlMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {artistId};
  @override
  Artist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Artist(
      artistId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artist_id'])!,
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      artworkUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artwork_url']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
    );
  }

  @override
  $ArtistsTable createAlias(String alias) {
    return $ArtistsTable(attachedDatabase, alias);
  }
}

class Artist extends DataClass implements Insertable<Artist> {
  final String artistId;
  final String sourceType;
  final String sourceId;
  final String name;
  final String? artworkUrl;
  final String? description;
  const Artist(
      {required this.artistId,
      required this.sourceType,
      required this.sourceId,
      required this.name,
      this.artworkUrl,
      this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['artist_id'] = Variable<String>(artistId);
    map['source_type'] = Variable<String>(sourceType);
    map['source_id'] = Variable<String>(sourceId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || artworkUrl != null) {
      map['artwork_url'] = Variable<String>(artworkUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  ArtistsCompanion toCompanion(bool nullToAbsent) {
    return ArtistsCompanion(
      artistId: Value(artistId),
      sourceType: Value(sourceType),
      sourceId: Value(sourceId),
      name: Value(name),
      artworkUrl: artworkUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory Artist.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Artist(
      artistId: serializer.fromJson<String>(json['artistId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      name: serializer.fromJson<String>(json['name']),
      artworkUrl: serializer.fromJson<String?>(json['artworkUrl']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'artistId': serializer.toJson<String>(artistId),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceId': serializer.toJson<String>(sourceId),
      'name': serializer.toJson<String>(name),
      'artworkUrl': serializer.toJson<String?>(artworkUrl),
      'description': serializer.toJson<String?>(description),
    };
  }

  Artist copyWith(
          {String? artistId,
          String? sourceType,
          String? sourceId,
          String? name,
          Value<String?> artworkUrl = const Value.absent(),
          Value<String?> description = const Value.absent()}) =>
      Artist(
        artistId: artistId ?? this.artistId,
        sourceType: sourceType ?? this.sourceType,
        sourceId: sourceId ?? this.sourceId,
        name: name ?? this.name,
        artworkUrl: artworkUrl.present ? artworkUrl.value : this.artworkUrl,
        description: description.present ? description.value : this.description,
      );
  @override
  String toString() {
    return (StringBuffer('Artist(')
          ..write('artistId: $artistId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      artistId, sourceType, sourceId, name, artworkUrl, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Artist &&
          other.artistId == this.artistId &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.name == this.name &&
          other.artworkUrl == this.artworkUrl &&
          other.description == this.description);
}

class ArtistsCompanion extends UpdateCompanion<Artist> {
  final Value<String> artistId;
  final Value<String> sourceType;
  final Value<String> sourceId;
  final Value<String> name;
  final Value<String?> artworkUrl;
  final Value<String?> description;
  final Value<int> rowid;
  const ArtistsCompanion({
    this.artistId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.name = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArtistsCompanion.insert({
    required String artistId,
    required String sourceType,
    required String sourceId,
    required String name,
    this.artworkUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : artistId = Value(artistId),
        sourceType = Value(sourceType),
        sourceId = Value(sourceId),
        name = Value(name);
  static Insertable<Artist> custom({
    Expression<String>? artistId,
    Expression<String>? sourceType,
    Expression<String>? sourceId,
    Expression<String>? name,
    Expression<String>? artworkUrl,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (artistId != null) 'artist_id': artistId,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (name != null) 'name': name,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArtistsCompanion copyWith(
      {Value<String>? artistId,
      Value<String>? sourceType,
      Value<String>? sourceId,
      Value<String>? name,
      Value<String?>? artworkUrl,
      Value<String?>? description,
      Value<int>? rowid}) {
    return ArtistsCompanion(
      artistId: artistId ?? this.artistId,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      name: name ?? this.name,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (artworkUrl.present) {
      map['artwork_url'] = Variable<String>(artworkUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtistsCompanion(')
          ..write('artistId: $artistId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nicknameMeta =
      const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _signatureMeta =
      const VerificationMeta('signature');
  @override
  late final GeneratedColumn<String> signature = GeneratedColumn<String>(
      'signature', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _followsMeta =
      const VerificationMeta('follows');
  @override
  late final GeneratedColumn<int> follows = GeneratedColumn<int>(
      'follows', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _followedsMeta =
      const VerificationMeta('followeds');
  @override
  late final GeneratedColumn<int> followeds = GeneratedColumn<int>(
      'followeds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _playlistCountMeta =
      const VerificationMeta('playlistCount');
  @override
  late final GeneratedColumn<int> playlistCount = GeneratedColumn<int>(
      'playlist_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMsMeta =
      const VerificationMeta('updatedAtMs');
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
      'updated_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        userId,
        nickname,
        signature,
        follows,
        followeds,
        playlistCount,
        avatarUrl,
        updatedAtMs
      ];
  @override
  String get aliasedName => _alias ?? 'user_profiles';
  @override
  String get actualTableName => 'user_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<UserProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('signature')) {
      context.handle(_signatureMeta,
          signature.isAcceptableOrUnknown(data['signature']!, _signatureMeta));
    } else if (isInserting) {
      context.missing(_signatureMeta);
    }
    if (data.containsKey('follows')) {
      context.handle(_followsMeta,
          follows.isAcceptableOrUnknown(data['follows']!, _followsMeta));
    } else if (isInserting) {
      context.missing(_followsMeta);
    }
    if (data.containsKey('followeds')) {
      context.handle(_followedsMeta,
          followeds.isAcceptableOrUnknown(data['followeds']!, _followedsMeta));
    } else if (isInserting) {
      context.missing(_followedsMeta);
    }
    if (data.containsKey('playlist_count')) {
      context.handle(
          _playlistCountMeta,
          playlistCount.isAcceptableOrUnknown(
              data['playlist_count']!, _playlistCountMeta));
    } else if (isInserting) {
      context.missing(_playlistCountMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    } else if (isInserting) {
      context.missing(_avatarUrlMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
          _updatedAtMsMeta,
          updatedAtMs.isAcceptableOrUnknown(
              data['updated_at_ms']!, _updatedAtMsMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      nickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nickname'])!,
      signature: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}signature'])!,
      follows: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}follows'])!,
      followeds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}followeds'])!,
      playlistCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}playlist_count'])!,
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url'])!,
      updatedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at_ms'])!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final String userId;
  final String nickname;
  final String signature;
  final int follows;
  final int followeds;
  final int playlistCount;
  final String avatarUrl;
  final int updatedAtMs;
  const UserProfile(
      {required this.userId,
      required this.nickname,
      required this.signature,
      required this.follows,
      required this.followeds,
      required this.playlistCount,
      required this.avatarUrl,
      required this.updatedAtMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['nickname'] = Variable<String>(nickname);
    map['signature'] = Variable<String>(signature);
    map['follows'] = Variable<int>(follows);
    map['followeds'] = Variable<int>(followeds);
    map['playlist_count'] = Variable<int>(playlistCount);
    map['avatar_url'] = Variable<String>(avatarUrl);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      userId: Value(userId),
      nickname: Value(nickname),
      signature: Value(signature),
      follows: Value(follows),
      followeds: Value(followeds),
      playlistCount: Value(playlistCount),
      avatarUrl: Value(avatarUrl),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      userId: serializer.fromJson<String>(json['userId']),
      nickname: serializer.fromJson<String>(json['nickname']),
      signature: serializer.fromJson<String>(json['signature']),
      follows: serializer.fromJson<int>(json['follows']),
      followeds: serializer.fromJson<int>(json['followeds']),
      playlistCount: serializer.fromJson<int>(json['playlistCount']),
      avatarUrl: serializer.fromJson<String>(json['avatarUrl']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'nickname': serializer.toJson<String>(nickname),
      'signature': serializer.toJson<String>(signature),
      'follows': serializer.toJson<int>(follows),
      'followeds': serializer.toJson<int>(followeds),
      'playlistCount': serializer.toJson<int>(playlistCount),
      'avatarUrl': serializer.toJson<String>(avatarUrl),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  UserProfile copyWith(
          {String? userId,
          String? nickname,
          String? signature,
          int? follows,
          int? followeds,
          int? playlistCount,
          String? avatarUrl,
          int? updatedAtMs}) =>
      UserProfile(
        userId: userId ?? this.userId,
        nickname: nickname ?? this.nickname,
        signature: signature ?? this.signature,
        follows: follows ?? this.follows,
        followeds: followeds ?? this.followeds,
        playlistCount: playlistCount ?? this.playlistCount,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      );
  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('userId: $userId, ')
          ..write('nickname: $nickname, ')
          ..write('signature: $signature, ')
          ..write('follows: $follows, ')
          ..write('followeds: $followeds, ')
          ..write('playlistCount: $playlistCount, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, nickname, signature, follows,
      followeds, playlistCount, avatarUrl, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.userId == this.userId &&
          other.nickname == this.nickname &&
          other.signature == this.signature &&
          other.follows == this.follows &&
          other.followeds == this.followeds &&
          other.playlistCount == this.playlistCount &&
          other.avatarUrl == this.avatarUrl &&
          other.updatedAtMs == this.updatedAtMs);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> userId;
  final Value<String> nickname;
  final Value<String> signature;
  final Value<int> follows;
  final Value<int> followeds;
  final Value<int> playlistCount;
  final Value<String> avatarUrl;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.userId = const Value.absent(),
    this.nickname = const Value.absent(),
    this.signature = const Value.absent(),
    this.follows = const Value.absent(),
    this.followeds = const Value.absent(),
    this.playlistCount = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String userId,
    required String nickname,
    required String signature,
    required int follows,
    required int followeds,
    required int playlistCount,
    required String avatarUrl,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        nickname = Value(nickname),
        signature = Value(signature),
        follows = Value(follows),
        followeds = Value(followeds),
        playlistCount = Value(playlistCount),
        avatarUrl = Value(avatarUrl),
        updatedAtMs = Value(updatedAtMs);
  static Insertable<UserProfile> custom({
    Expression<String>? userId,
    Expression<String>? nickname,
    Expression<String>? signature,
    Expression<int>? follows,
    Expression<int>? followeds,
    Expression<int>? playlistCount,
    Expression<String>? avatarUrl,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (nickname != null) 'nickname': nickname,
      if (signature != null) 'signature': signature,
      if (follows != null) 'follows': follows,
      if (followeds != null) 'followeds': followeds,
      if (playlistCount != null) 'playlist_count': playlistCount,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith(
      {Value<String>? userId,
      Value<String>? nickname,
      Value<String>? signature,
      Value<int>? follows,
      Value<int>? followeds,
      Value<int>? playlistCount,
      Value<String>? avatarUrl,
      Value<int>? updatedAtMs,
      Value<int>? rowid}) {
    return UserProfilesCompanion(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      signature: signature ?? this.signature,
      follows: follows ?? this.follows,
      followeds: followeds ?? this.followeds,
      playlistCount: playlistCount ?? this.playlistCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (signature.present) {
      map['signature'] = Variable<String>(signature.value);
    }
    if (follows.present) {
      map['follows'] = Variable<int>(follows.value);
    }
    if (followeds.present) {
      map['followeds'] = Variable<int>(followeds.value);
    }
    if (playlistCount.present) {
      map['playlist_count'] = Variable<int>(playlistCount.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('userId: $userId, ')
          ..write('nickname: $nickname, ')
          ..write('signature: $signature, ')
          ..write('follows: $follows, ')
          ..write('followeds: $followeds, ')
          ..write('playlistCount: $playlistCount, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserTrackListRefsTable extends UserTrackListRefs
    with TableInfo<$UserTrackListRefsTable, UserTrackListRef> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserTrackListRefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _listKindMeta =
      const VerificationMeta('listKind');
  @override
  late final GeneratedColumn<String> listKind = GeneratedColumn<String>(
      'list_kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _trackIdMeta =
      const VerificationMeta('trackId');
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
      'track_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMsMeta =
      const VerificationMeta('updatedAtMs');
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
      'updated_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [userId, listKind, trackId, sortOrder, updatedAtMs];
  @override
  String get aliasedName => _alias ?? 'user_track_list_refs';
  @override
  String get actualTableName => 'user_track_list_refs';
  @override
  VerificationContext validateIntegrity(Insertable<UserTrackListRef> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('list_kind')) {
      context.handle(_listKindMeta,
          listKind.isAcceptableOrUnknown(data['list_kind']!, _listKindMeta));
    } else if (isInserting) {
      context.missing(_listKindMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(_trackIdMeta,
          trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta));
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
          _updatedAtMsMeta,
          updatedAtMs.isAcceptableOrUnknown(
              data['updated_at_ms']!, _updatedAtMsMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, listKind, sortOrder};
  @override
  UserTrackListRef map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserTrackListRef(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      listKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}list_kind'])!,
      trackId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}track_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      updatedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at_ms'])!,
    );
  }

  @override
  $UserTrackListRefsTable createAlias(String alias) {
    return $UserTrackListRefsTable(attachedDatabase, alias);
  }
}

class UserTrackListRef extends DataClass
    implements Insertable<UserTrackListRef> {
  final String userId;
  final String listKind;
  final String trackId;
  final int sortOrder;
  final int updatedAtMs;
  const UserTrackListRef(
      {required this.userId,
      required this.listKind,
      required this.trackId,
      required this.sortOrder,
      required this.updatedAtMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['list_kind'] = Variable<String>(listKind);
    map['track_id'] = Variable<String>(trackId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  UserTrackListRefsCompanion toCompanion(bool nullToAbsent) {
    return UserTrackListRefsCompanion(
      userId: Value(userId),
      listKind: Value(listKind),
      trackId: Value(trackId),
      sortOrder: Value(sortOrder),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory UserTrackListRef.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserTrackListRef(
      userId: serializer.fromJson<String>(json['userId']),
      listKind: serializer.fromJson<String>(json['listKind']),
      trackId: serializer.fromJson<String>(json['trackId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'listKind': serializer.toJson<String>(listKind),
      'trackId': serializer.toJson<String>(trackId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  UserTrackListRef copyWith(
          {String? userId,
          String? listKind,
          String? trackId,
          int? sortOrder,
          int? updatedAtMs}) =>
      UserTrackListRef(
        userId: userId ?? this.userId,
        listKind: listKind ?? this.listKind,
        trackId: trackId ?? this.trackId,
        sortOrder: sortOrder ?? this.sortOrder,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      );
  @override
  String toString() {
    return (StringBuffer('UserTrackListRef(')
          ..write('userId: $userId, ')
          ..write('listKind: $listKind, ')
          ..write('trackId: $trackId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, listKind, trackId, sortOrder, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserTrackListRef &&
          other.userId == this.userId &&
          other.listKind == this.listKind &&
          other.trackId == this.trackId &&
          other.sortOrder == this.sortOrder &&
          other.updatedAtMs == this.updatedAtMs);
}

class UserTrackListRefsCompanion extends UpdateCompanion<UserTrackListRef> {
  final Value<String> userId;
  final Value<String> listKind;
  final Value<String> trackId;
  final Value<int> sortOrder;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const UserTrackListRefsCompanion({
    this.userId = const Value.absent(),
    this.listKind = const Value.absent(),
    this.trackId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserTrackListRefsCompanion.insert({
    required String userId,
    required String listKind,
    required String trackId,
    required int sortOrder,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        listKind = Value(listKind),
        trackId = Value(trackId),
        sortOrder = Value(sortOrder),
        updatedAtMs = Value(updatedAtMs);
  static Insertable<UserTrackListRef> custom({
    Expression<String>? userId,
    Expression<String>? listKind,
    Expression<String>? trackId,
    Expression<int>? sortOrder,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (listKind != null) 'list_kind': listKind,
      if (trackId != null) 'track_id': trackId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserTrackListRefsCompanion copyWith(
      {Value<String>? userId,
      Value<String>? listKind,
      Value<String>? trackId,
      Value<int>? sortOrder,
      Value<int>? updatedAtMs,
      Value<int>? rowid}) {
    return UserTrackListRefsCompanion(
      userId: userId ?? this.userId,
      listKind: listKind ?? this.listKind,
      trackId: trackId ?? this.trackId,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (listKind.present) {
      map['list_kind'] = Variable<String>(listKind.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserTrackListRefsCompanion(')
          ..write('userId: $userId, ')
          ..write('listKind: $listKind, ')
          ..write('trackId: $trackId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPlaylistListRefsTable extends UserPlaylistListRefs
    with TableInfo<$UserPlaylistListRefsTable, UserPlaylistListRef> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPlaylistListRefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _listKindMeta =
      const VerificationMeta('listKind');
  @override
  late final GeneratedColumn<String> listKind = GeneratedColumn<String>(
      'list_kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _playlistIdMeta =
      const VerificationMeta('playlistId');
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
      'playlist_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMsMeta =
      const VerificationMeta('updatedAtMs');
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
      'updated_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [userId, listKind, playlistId, sortOrder, updatedAtMs];
  @override
  String get aliasedName => _alias ?? 'user_playlist_list_refs';
  @override
  String get actualTableName => 'user_playlist_list_refs';
  @override
  VerificationContext validateIntegrity(
      Insertable<UserPlaylistListRef> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('list_kind')) {
      context.handle(_listKindMeta,
          listKind.isAcceptableOrUnknown(data['list_kind']!, _listKindMeta));
    } else if (isInserting) {
      context.missing(_listKindMeta);
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
          _playlistIdMeta,
          playlistId.isAcceptableOrUnknown(
              data['playlist_id']!, _playlistIdMeta));
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
          _updatedAtMsMeta,
          updatedAtMs.isAcceptableOrUnknown(
              data['updated_at_ms']!, _updatedAtMsMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, listKind, playlistId};
  @override
  UserPlaylistListRef map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPlaylistListRef(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      listKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}list_kind'])!,
      playlistId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}playlist_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      updatedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at_ms'])!,
    );
  }

  @override
  $UserPlaylistListRefsTable createAlias(String alias) {
    return $UserPlaylistListRefsTable(attachedDatabase, alias);
  }
}

class UserPlaylistListRef extends DataClass
    implements Insertable<UserPlaylistListRef> {
  final String userId;
  final String listKind;
  final String playlistId;
  final int sortOrder;
  final int updatedAtMs;
  const UserPlaylistListRef(
      {required this.userId,
      required this.listKind,
      required this.playlistId,
      required this.sortOrder,
      required this.updatedAtMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['list_kind'] = Variable<String>(listKind);
    map['playlist_id'] = Variable<String>(playlistId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  UserPlaylistListRefsCompanion toCompanion(bool nullToAbsent) {
    return UserPlaylistListRefsCompanion(
      userId: Value(userId),
      listKind: Value(listKind),
      playlistId: Value(playlistId),
      sortOrder: Value(sortOrder),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory UserPlaylistListRef.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPlaylistListRef(
      userId: serializer.fromJson<String>(json['userId']),
      listKind: serializer.fromJson<String>(json['listKind']),
      playlistId: serializer.fromJson<String>(json['playlistId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'listKind': serializer.toJson<String>(listKind),
      'playlistId': serializer.toJson<String>(playlistId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  UserPlaylistListRef copyWith(
          {String? userId,
          String? listKind,
          String? playlistId,
          int? sortOrder,
          int? updatedAtMs}) =>
      UserPlaylistListRef(
        userId: userId ?? this.userId,
        listKind: listKind ?? this.listKind,
        playlistId: playlistId ?? this.playlistId,
        sortOrder: sortOrder ?? this.sortOrder,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      );
  @override
  String toString() {
    return (StringBuffer('UserPlaylistListRef(')
          ..write('userId: $userId, ')
          ..write('listKind: $listKind, ')
          ..write('playlistId: $playlistId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, listKind, playlistId, sortOrder, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPlaylistListRef &&
          other.userId == this.userId &&
          other.listKind == this.listKind &&
          other.playlistId == this.playlistId &&
          other.sortOrder == this.sortOrder &&
          other.updatedAtMs == this.updatedAtMs);
}

class UserPlaylistListRefsCompanion
    extends UpdateCompanion<UserPlaylistListRef> {
  final Value<String> userId;
  final Value<String> listKind;
  final Value<String> playlistId;
  final Value<int> sortOrder;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const UserPlaylistListRefsCompanion({
    this.userId = const Value.absent(),
    this.listKind = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPlaylistListRefsCompanion.insert({
    required String userId,
    required String listKind,
    required String playlistId,
    required int sortOrder,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        listKind = Value(listKind),
        playlistId = Value(playlistId),
        sortOrder = Value(sortOrder),
        updatedAtMs = Value(updatedAtMs);
  static Insertable<UserPlaylistListRef> custom({
    Expression<String>? userId,
    Expression<String>? listKind,
    Expression<String>? playlistId,
    Expression<int>? sortOrder,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (listKind != null) 'list_kind': listKind,
      if (playlistId != null) 'playlist_id': playlistId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPlaylistListRefsCompanion copyWith(
      {Value<String>? userId,
      Value<String>? listKind,
      Value<String>? playlistId,
      Value<int>? sortOrder,
      Value<int>? updatedAtMs,
      Value<int>? rowid}) {
    return UserPlaylistListRefsCompanion(
      userId: userId ?? this.userId,
      listKind: listKind ?? this.listKind,
      playlistId: playlistId ?? this.playlistId,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (listKind.present) {
      map['list_kind'] = Variable<String>(listKind.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPlaylistListRefsCompanion(')
          ..write('userId: $userId, ')
          ..write('listKind: $listKind, ')
          ..write('playlistId: $playlistId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPlaylistSnapshotsTable extends UserPlaylistSnapshots
    with TableInfo<$UserPlaylistSnapshotsTable, UserPlaylistSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPlaylistSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta =
      const VerificationMeta('playlistId');
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
      'playlist_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _coverUrlMeta =
      const VerificationMeta('coverUrl');
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
      'cover_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _trackCountMeta =
      const VerificationMeta('trackCount');
  @override
  late final GeneratedColumn<int> trackCount = GeneratedColumn<int>(
      'track_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMsMeta =
      const VerificationMeta('updatedAtMs');
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
      'updated_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        playlistId,
        sourceId,
        title,
        coverUrl,
        trackCount,
        description,
        updatedAtMs
      ];
  @override
  String get aliasedName => _alias ?? 'user_playlist_snapshots';
  @override
  String get actualTableName => 'user_playlist_snapshots';
  @override
  VerificationContext validateIntegrity(
      Insertable<UserPlaylistSnapshot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
          _playlistIdMeta,
          playlistId.isAcceptableOrUnknown(
              data['playlist_id']!, _playlistIdMeta));
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cover_url')) {
      context.handle(_coverUrlMeta,
          coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta));
    }
    if (data.containsKey('track_count')) {
      context.handle(
          _trackCountMeta,
          trackCount.isAcceptableOrUnknown(
              data['track_count']!, _trackCountMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
          _updatedAtMsMeta,
          updatedAtMs.isAcceptableOrUnknown(
              data['updated_at_ms']!, _updatedAtMsMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId};
  @override
  UserPlaylistSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPlaylistSnapshot(
      playlistId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}playlist_id'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      coverUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_url']),
      trackCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}track_count']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      updatedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at_ms'])!,
    );
  }

  @override
  $UserPlaylistSnapshotsTable createAlias(String alias) {
    return $UserPlaylistSnapshotsTable(attachedDatabase, alias);
  }
}

class UserPlaylistSnapshot extends DataClass
    implements Insertable<UserPlaylistSnapshot> {
  final String playlistId;
  final String sourceId;
  final String title;
  final String? coverUrl;
  final int? trackCount;
  final String? description;
  final int updatedAtMs;
  const UserPlaylistSnapshot(
      {required this.playlistId,
      required this.sourceId,
      required this.title,
      this.coverUrl,
      this.trackCount,
      this.description,
      required this.updatedAtMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['source_id'] = Variable<String>(sourceId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || trackCount != null) {
      map['track_count'] = Variable<int>(trackCount);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  UserPlaylistSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return UserPlaylistSnapshotsCompanion(
      playlistId: Value(playlistId),
      sourceId: Value(sourceId),
      title: Value(title),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      trackCount: trackCount == null && nullToAbsent
          ? const Value.absent()
          : Value(trackCount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory UserPlaylistSnapshot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPlaylistSnapshot(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      title: serializer.fromJson<String>(json['title']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      trackCount: serializer.fromJson<int?>(json['trackCount']),
      description: serializer.fromJson<String?>(json['description']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'sourceId': serializer.toJson<String>(sourceId),
      'title': serializer.toJson<String>(title),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'trackCount': serializer.toJson<int?>(trackCount),
      'description': serializer.toJson<String?>(description),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  UserPlaylistSnapshot copyWith(
          {String? playlistId,
          String? sourceId,
          String? title,
          Value<String?> coverUrl = const Value.absent(),
          Value<int?> trackCount = const Value.absent(),
          Value<String?> description = const Value.absent(),
          int? updatedAtMs}) =>
      UserPlaylistSnapshot(
        playlistId: playlistId ?? this.playlistId,
        sourceId: sourceId ?? this.sourceId,
        title: title ?? this.title,
        coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
        trackCount: trackCount.present ? trackCount.value : this.trackCount,
        description: description.present ? description.value : this.description,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      );
  @override
  String toString() {
    return (StringBuffer('UserPlaylistSnapshot(')
          ..write('playlistId: $playlistId, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('trackCount: $trackCount, ')
          ..write('description: $description, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, sourceId, title, coverUrl,
      trackCount, description, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPlaylistSnapshot &&
          other.playlistId == this.playlistId &&
          other.sourceId == this.sourceId &&
          other.title == this.title &&
          other.coverUrl == this.coverUrl &&
          other.trackCount == this.trackCount &&
          other.description == this.description &&
          other.updatedAtMs == this.updatedAtMs);
}

class UserPlaylistSnapshotsCompanion
    extends UpdateCompanion<UserPlaylistSnapshot> {
  final Value<String> playlistId;
  final Value<String> sourceId;
  final Value<String> title;
  final Value<String?> coverUrl;
  final Value<int?> trackCount;
  final Value<String?> description;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const UserPlaylistSnapshotsCompanion({
    this.playlistId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.title = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.trackCount = const Value.absent(),
    this.description = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPlaylistSnapshotsCompanion.insert({
    required String playlistId,
    required String sourceId,
    required String title,
    this.coverUrl = const Value.absent(),
    this.trackCount = const Value.absent(),
    this.description = const Value.absent(),
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  })  : playlistId = Value(playlistId),
        sourceId = Value(sourceId),
        title = Value(title),
        updatedAtMs = Value(updatedAtMs);
  static Insertable<UserPlaylistSnapshot> custom({
    Expression<String>? playlistId,
    Expression<String>? sourceId,
    Expression<String>? title,
    Expression<String>? coverUrl,
    Expression<int>? trackCount,
    Expression<String>? description,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (sourceId != null) 'source_id': sourceId,
      if (title != null) 'title': title,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (trackCount != null) 'track_count': trackCount,
      if (description != null) 'description': description,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPlaylistSnapshotsCompanion copyWith(
      {Value<String>? playlistId,
      Value<String>? sourceId,
      Value<String>? title,
      Value<String?>? coverUrl,
      Value<int?>? trackCount,
      Value<String?>? description,
      Value<int>? updatedAtMs,
      Value<int>? rowid}) {
    return UserPlaylistSnapshotsCompanion(
      playlistId: playlistId ?? this.playlistId,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      trackCount: trackCount ?? this.trackCount,
      description: description ?? this.description,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (trackCount.present) {
      map['track_count'] = Variable<int>(trackCount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPlaylistSnapshotsCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('trackCount: $trackCount, ')
          ..write('description: $description, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPlaylistStatesTable extends UserPlaylistStates
    with TableInfo<$UserPlaylistStatesTable, UserPlaylistState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPlaylistStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _playlistIdMeta =
      const VerificationMeta('playlistId');
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
      'playlist_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isSubscribedMeta =
      const VerificationMeta('isSubscribed');
  @override
  late final GeneratedColumn<bool> isSubscribed =
      GeneratedColumn<bool>('is_subscribed', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("is_subscribed" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }));
  static const VerificationMeta _updatedAtMsMeta =
      const VerificationMeta('updatedAtMs');
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
      'updated_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [userId, playlistId, isSubscribed, updatedAtMs];
  @override
  String get aliasedName => _alias ?? 'user_playlist_states';
  @override
  String get actualTableName => 'user_playlist_states';
  @override
  VerificationContext validateIntegrity(Insertable<UserPlaylistState> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
          _playlistIdMeta,
          playlistId.isAcceptableOrUnknown(
              data['playlist_id']!, _playlistIdMeta));
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('is_subscribed')) {
      context.handle(
          _isSubscribedMeta,
          isSubscribed.isAcceptableOrUnknown(
              data['is_subscribed']!, _isSubscribedMeta));
    } else if (isInserting) {
      context.missing(_isSubscribedMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
          _updatedAtMsMeta,
          updatedAtMs.isAcceptableOrUnknown(
              data['updated_at_ms']!, _updatedAtMsMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, playlistId};
  @override
  UserPlaylistState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPlaylistState(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      playlistId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}playlist_id'])!,
      isSubscribed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_subscribed'])!,
      updatedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at_ms'])!,
    );
  }

  @override
  $UserPlaylistStatesTable createAlias(String alias) {
    return $UserPlaylistStatesTable(attachedDatabase, alias);
  }
}

class UserPlaylistState extends DataClass
    implements Insertable<UserPlaylistState> {
  final String userId;
  final String playlistId;
  final bool isSubscribed;
  final int updatedAtMs;
  const UserPlaylistState(
      {required this.userId,
      required this.playlistId,
      required this.isSubscribed,
      required this.updatedAtMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['playlist_id'] = Variable<String>(playlistId);
    map['is_subscribed'] = Variable<bool>(isSubscribed);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  UserPlaylistStatesCompanion toCompanion(bool nullToAbsent) {
    return UserPlaylistStatesCompanion(
      userId: Value(userId),
      playlistId: Value(playlistId),
      isSubscribed: Value(isSubscribed),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory UserPlaylistState.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPlaylistState(
      userId: serializer.fromJson<String>(json['userId']),
      playlistId: serializer.fromJson<String>(json['playlistId']),
      isSubscribed: serializer.fromJson<bool>(json['isSubscribed']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'playlistId': serializer.toJson<String>(playlistId),
      'isSubscribed': serializer.toJson<bool>(isSubscribed),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  UserPlaylistState copyWith(
          {String? userId,
          String? playlistId,
          bool? isSubscribed,
          int? updatedAtMs}) =>
      UserPlaylistState(
        userId: userId ?? this.userId,
        playlistId: playlistId ?? this.playlistId,
        isSubscribed: isSubscribed ?? this.isSubscribed,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      );
  @override
  String toString() {
    return (StringBuffer('UserPlaylistState(')
          ..write('userId: $userId, ')
          ..write('playlistId: $playlistId, ')
          ..write('isSubscribed: $isSubscribed, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, playlistId, isSubscribed, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPlaylistState &&
          other.userId == this.userId &&
          other.playlistId == this.playlistId &&
          other.isSubscribed == this.isSubscribed &&
          other.updatedAtMs == this.updatedAtMs);
}

class UserPlaylistStatesCompanion extends UpdateCompanion<UserPlaylistState> {
  final Value<String> userId;
  final Value<String> playlistId;
  final Value<bool> isSubscribed;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const UserPlaylistStatesCompanion({
    this.userId = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.isSubscribed = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPlaylistStatesCompanion.insert({
    required String userId,
    required String playlistId,
    required bool isSubscribed,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        playlistId = Value(playlistId),
        isSubscribed = Value(isSubscribed),
        updatedAtMs = Value(updatedAtMs);
  static Insertable<UserPlaylistState> custom({
    Expression<String>? userId,
    Expression<String>? playlistId,
    Expression<bool>? isSubscribed,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (playlistId != null) 'playlist_id': playlistId,
      if (isSubscribed != null) 'is_subscribed': isSubscribed,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPlaylistStatesCompanion copyWith(
      {Value<String>? userId,
      Value<String>? playlistId,
      Value<bool>? isSubscribed,
      Value<int>? updatedAtMs,
      Value<int>? rowid}) {
    return UserPlaylistStatesCompanion(
      userId: userId ?? this.userId,
      playlistId: playlistId ?? this.playlistId,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (isSubscribed.present) {
      map['is_subscribed'] = Variable<bool>(isSubscribed.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPlaylistStatesCompanion(')
          ..write('userId: $userId, ')
          ..write('playlistId: $playlistId, ')
          ..write('isSubscribed: $isSubscribed, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserRadioSubscriptionsTable extends UserRadioSubscriptions
    with TableInfo<$UserRadioSubscriptionsTable, UserRadioSubscription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserRadioSubscriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _radioIdMeta =
      const VerificationMeta('radioId');
  @override
  late final GeneratedColumn<String> radioId = GeneratedColumn<String>(
      'radio_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _coverUrlMeta =
      const VerificationMeta('coverUrl');
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
      'cover_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastProgramNameMeta =
      const VerificationMeta('lastProgramName');
  @override
  late final GeneratedColumn<String> lastProgramName = GeneratedColumn<String>(
      'last_program_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMsMeta =
      const VerificationMeta('updatedAtMs');
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
      'updated_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        userId,
        radioId,
        sortOrder,
        name,
        coverUrl,
        lastProgramName,
        updatedAtMs
      ];
  @override
  String get aliasedName => _alias ?? 'user_radio_subscriptions';
  @override
  String get actualTableName => 'user_radio_subscriptions';
  @override
  VerificationContext validateIntegrity(
      Insertable<UserRadioSubscription> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('radio_id')) {
      context.handle(_radioIdMeta,
          radioId.isAcceptableOrUnknown(data['radio_id']!, _radioIdMeta));
    } else if (isInserting) {
      context.missing(_radioIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cover_url')) {
      context.handle(_coverUrlMeta,
          coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta));
    } else if (isInserting) {
      context.missing(_coverUrlMeta);
    }
    if (data.containsKey('last_program_name')) {
      context.handle(
          _lastProgramNameMeta,
          lastProgramName.isAcceptableOrUnknown(
              data['last_program_name']!, _lastProgramNameMeta));
    } else if (isInserting) {
      context.missing(_lastProgramNameMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
          _updatedAtMsMeta,
          updatedAtMs.isAcceptableOrUnknown(
              data['updated_at_ms']!, _updatedAtMsMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, radioId};
  @override
  UserRadioSubscription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRadioSubscription(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      radioId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}radio_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      coverUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_url'])!,
      lastProgramName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_program_name'])!,
      updatedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at_ms'])!,
    );
  }

  @override
  $UserRadioSubscriptionsTable createAlias(String alias) {
    return $UserRadioSubscriptionsTable(attachedDatabase, alias);
  }
}

class UserRadioSubscription extends DataClass
    implements Insertable<UserRadioSubscription> {
  final String userId;
  final String radioId;
  final int sortOrder;
  final String name;
  final String coverUrl;
  final String lastProgramName;
  final int updatedAtMs;
  const UserRadioSubscription(
      {required this.userId,
      required this.radioId,
      required this.sortOrder,
      required this.name,
      required this.coverUrl,
      required this.lastProgramName,
      required this.updatedAtMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['radio_id'] = Variable<String>(radioId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['name'] = Variable<String>(name);
    map['cover_url'] = Variable<String>(coverUrl);
    map['last_program_name'] = Variable<String>(lastProgramName);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  UserRadioSubscriptionsCompanion toCompanion(bool nullToAbsent) {
    return UserRadioSubscriptionsCompanion(
      userId: Value(userId),
      radioId: Value(radioId),
      sortOrder: Value(sortOrder),
      name: Value(name),
      coverUrl: Value(coverUrl),
      lastProgramName: Value(lastProgramName),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory UserRadioSubscription.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRadioSubscription(
      userId: serializer.fromJson<String>(json['userId']),
      radioId: serializer.fromJson<String>(json['radioId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      name: serializer.fromJson<String>(json['name']),
      coverUrl: serializer.fromJson<String>(json['coverUrl']),
      lastProgramName: serializer.fromJson<String>(json['lastProgramName']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'radioId': serializer.toJson<String>(radioId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'name': serializer.toJson<String>(name),
      'coverUrl': serializer.toJson<String>(coverUrl),
      'lastProgramName': serializer.toJson<String>(lastProgramName),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  UserRadioSubscription copyWith(
          {String? userId,
          String? radioId,
          int? sortOrder,
          String? name,
          String? coverUrl,
          String? lastProgramName,
          int? updatedAtMs}) =>
      UserRadioSubscription(
        userId: userId ?? this.userId,
        radioId: radioId ?? this.radioId,
        sortOrder: sortOrder ?? this.sortOrder,
        name: name ?? this.name,
        coverUrl: coverUrl ?? this.coverUrl,
        lastProgramName: lastProgramName ?? this.lastProgramName,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      );
  @override
  String toString() {
    return (StringBuffer('UserRadioSubscription(')
          ..write('userId: $userId, ')
          ..write('radioId: $radioId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('name: $name, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('lastProgramName: $lastProgramName, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      userId, radioId, sortOrder, name, coverUrl, lastProgramName, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRadioSubscription &&
          other.userId == this.userId &&
          other.radioId == this.radioId &&
          other.sortOrder == this.sortOrder &&
          other.name == this.name &&
          other.coverUrl == this.coverUrl &&
          other.lastProgramName == this.lastProgramName &&
          other.updatedAtMs == this.updatedAtMs);
}

class UserRadioSubscriptionsCompanion
    extends UpdateCompanion<UserRadioSubscription> {
  final Value<String> userId;
  final Value<String> radioId;
  final Value<int> sortOrder;
  final Value<String> name;
  final Value<String> coverUrl;
  final Value<String> lastProgramName;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const UserRadioSubscriptionsCompanion({
    this.userId = const Value.absent(),
    this.radioId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.name = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.lastProgramName = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserRadioSubscriptionsCompanion.insert({
    required String userId,
    required String radioId,
    required int sortOrder,
    required String name,
    required String coverUrl,
    required String lastProgramName,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        radioId = Value(radioId),
        sortOrder = Value(sortOrder),
        name = Value(name),
        coverUrl = Value(coverUrl),
        lastProgramName = Value(lastProgramName),
        updatedAtMs = Value(updatedAtMs);
  static Insertable<UserRadioSubscription> custom({
    Expression<String>? userId,
    Expression<String>? radioId,
    Expression<int>? sortOrder,
    Expression<String>? name,
    Expression<String>? coverUrl,
    Expression<String>? lastProgramName,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (radioId != null) 'radio_id': radioId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (name != null) 'name': name,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (lastProgramName != null) 'last_program_name': lastProgramName,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserRadioSubscriptionsCompanion copyWith(
      {Value<String>? userId,
      Value<String>? radioId,
      Value<int>? sortOrder,
      Value<String>? name,
      Value<String>? coverUrl,
      Value<String>? lastProgramName,
      Value<int>? updatedAtMs,
      Value<int>? rowid}) {
    return UserRadioSubscriptionsCompanion(
      userId: userId ?? this.userId,
      radioId: radioId ?? this.radioId,
      sortOrder: sortOrder ?? this.sortOrder,
      name: name ?? this.name,
      coverUrl: coverUrl ?? this.coverUrl,
      lastProgramName: lastProgramName ?? this.lastProgramName,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (radioId.present) {
      map['radio_id'] = Variable<String>(radioId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (lastProgramName.present) {
      map['last_program_name'] = Variable<String>(lastProgramName.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserRadioSubscriptionsCompanion(')
          ..write('userId: $userId, ')
          ..write('radioId: $radioId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('name: $name, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('lastProgramName: $lastProgramName, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserRadioProgramsTable extends UserRadioPrograms
    with TableInfo<$UserRadioProgramsTable, UserRadioProgram> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserRadioProgramsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _radioIdMeta =
      const VerificationMeta('radioId');
  @override
  late final GeneratedColumn<String> radioId = GeneratedColumn<String>(
      'radio_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ascMeta = const VerificationMeta('asc');
  @override
  late final GeneratedColumn<bool> asc =
      GeneratedColumn<bool>('asc', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("asc" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }));
  static const VerificationMeta _programIdMeta =
      const VerificationMeta('programId');
  @override
  late final GeneratedColumn<String> programId = GeneratedColumn<String>(
      'program_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _mainTrackIdMeta =
      const VerificationMeta('mainTrackId');
  @override
  late final GeneratedColumn<String> mainTrackId = GeneratedColumn<String>(
      'main_track_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _coverUrlMeta =
      const VerificationMeta('coverUrl');
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
      'cover_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _artistNameMeta =
      const VerificationMeta('artistName');
  @override
  late final GeneratedColumn<String> artistName = GeneratedColumn<String>(
      'artist_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _albumTitleMeta =
      const VerificationMeta('albumTitle');
  @override
  late final GeneratedColumn<String> albumTitle = GeneratedColumn<String>(
      'album_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMsMeta =
      const VerificationMeta('updatedAtMs');
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
      'updated_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        userId,
        radioId,
        asc,
        programId,
        sortOrder,
        mainTrackId,
        title,
        coverUrl,
        artistName,
        albumTitle,
        durationMs,
        updatedAtMs
      ];
  @override
  String get aliasedName => _alias ?? 'user_radio_programs';
  @override
  String get actualTableName => 'user_radio_programs';
  @override
  VerificationContext validateIntegrity(Insertable<UserRadioProgram> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('radio_id')) {
      context.handle(_radioIdMeta,
          radioId.isAcceptableOrUnknown(data['radio_id']!, _radioIdMeta));
    } else if (isInserting) {
      context.missing(_radioIdMeta);
    }
    if (data.containsKey('asc')) {
      context.handle(
          _ascMeta, asc.isAcceptableOrUnknown(data['asc']!, _ascMeta));
    } else if (isInserting) {
      context.missing(_ascMeta);
    }
    if (data.containsKey('program_id')) {
      context.handle(_programIdMeta,
          programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta));
    } else if (isInserting) {
      context.missing(_programIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('main_track_id')) {
      context.handle(
          _mainTrackIdMeta,
          mainTrackId.isAcceptableOrUnknown(
              data['main_track_id']!, _mainTrackIdMeta));
    } else if (isInserting) {
      context.missing(_mainTrackIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cover_url')) {
      context.handle(_coverUrlMeta,
          coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta));
    } else if (isInserting) {
      context.missing(_coverUrlMeta);
    }
    if (data.containsKey('artist_name')) {
      context.handle(
          _artistNameMeta,
          artistName.isAcceptableOrUnknown(
              data['artist_name']!, _artistNameMeta));
    } else if (isInserting) {
      context.missing(_artistNameMeta);
    }
    if (data.containsKey('album_title')) {
      context.handle(
          _albumTitleMeta,
          albumTitle.isAcceptableOrUnknown(
              data['album_title']!, _albumTitleMeta));
    } else if (isInserting) {
      context.missing(_albumTitleMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
          _updatedAtMsMeta,
          updatedAtMs.isAcceptableOrUnknown(
              data['updated_at_ms']!, _updatedAtMsMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, radioId, asc, programId};
  @override
  UserRadioProgram map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRadioProgram(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      radioId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}radio_id'])!,
      asc: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}asc'])!,
      programId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}program_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      mainTrackId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}main_track_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      coverUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_url'])!,
      artistName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artist_name'])!,
      albumTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album_title'])!,
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      updatedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at_ms'])!,
    );
  }

  @override
  $UserRadioProgramsTable createAlias(String alias) {
    return $UserRadioProgramsTable(attachedDatabase, alias);
  }
}

class UserRadioProgram extends DataClass
    implements Insertable<UserRadioProgram> {
  final String userId;
  final String radioId;
  final bool asc;
  final String programId;
  final int sortOrder;
  final String mainTrackId;
  final String title;
  final String coverUrl;
  final String artistName;
  final String albumTitle;
  final int durationMs;
  final int updatedAtMs;
  const UserRadioProgram(
      {required this.userId,
      required this.radioId,
      required this.asc,
      required this.programId,
      required this.sortOrder,
      required this.mainTrackId,
      required this.title,
      required this.coverUrl,
      required this.artistName,
      required this.albumTitle,
      required this.durationMs,
      required this.updatedAtMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['radio_id'] = Variable<String>(radioId);
    map['asc'] = Variable<bool>(asc);
    map['program_id'] = Variable<String>(programId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['main_track_id'] = Variable<String>(mainTrackId);
    map['title'] = Variable<String>(title);
    map['cover_url'] = Variable<String>(coverUrl);
    map['artist_name'] = Variable<String>(artistName);
    map['album_title'] = Variable<String>(albumTitle);
    map['duration_ms'] = Variable<int>(durationMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  UserRadioProgramsCompanion toCompanion(bool nullToAbsent) {
    return UserRadioProgramsCompanion(
      userId: Value(userId),
      radioId: Value(radioId),
      asc: Value(asc),
      programId: Value(programId),
      sortOrder: Value(sortOrder),
      mainTrackId: Value(mainTrackId),
      title: Value(title),
      coverUrl: Value(coverUrl),
      artistName: Value(artistName),
      albumTitle: Value(albumTitle),
      durationMs: Value(durationMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory UserRadioProgram.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRadioProgram(
      userId: serializer.fromJson<String>(json['userId']),
      radioId: serializer.fromJson<String>(json['radioId']),
      asc: serializer.fromJson<bool>(json['asc']),
      programId: serializer.fromJson<String>(json['programId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      mainTrackId: serializer.fromJson<String>(json['mainTrackId']),
      title: serializer.fromJson<String>(json['title']),
      coverUrl: serializer.fromJson<String>(json['coverUrl']),
      artistName: serializer.fromJson<String>(json['artistName']),
      albumTitle: serializer.fromJson<String>(json['albumTitle']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'radioId': serializer.toJson<String>(radioId),
      'asc': serializer.toJson<bool>(asc),
      'programId': serializer.toJson<String>(programId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'mainTrackId': serializer.toJson<String>(mainTrackId),
      'title': serializer.toJson<String>(title),
      'coverUrl': serializer.toJson<String>(coverUrl),
      'artistName': serializer.toJson<String>(artistName),
      'albumTitle': serializer.toJson<String>(albumTitle),
      'durationMs': serializer.toJson<int>(durationMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  UserRadioProgram copyWith(
          {String? userId,
          String? radioId,
          bool? asc,
          String? programId,
          int? sortOrder,
          String? mainTrackId,
          String? title,
          String? coverUrl,
          String? artistName,
          String? albumTitle,
          int? durationMs,
          int? updatedAtMs}) =>
      UserRadioProgram(
        userId: userId ?? this.userId,
        radioId: radioId ?? this.radioId,
        asc: asc ?? this.asc,
        programId: programId ?? this.programId,
        sortOrder: sortOrder ?? this.sortOrder,
        mainTrackId: mainTrackId ?? this.mainTrackId,
        title: title ?? this.title,
        coverUrl: coverUrl ?? this.coverUrl,
        artistName: artistName ?? this.artistName,
        albumTitle: albumTitle ?? this.albumTitle,
        durationMs: durationMs ?? this.durationMs,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      );
  @override
  String toString() {
    return (StringBuffer('UserRadioProgram(')
          ..write('userId: $userId, ')
          ..write('radioId: $radioId, ')
          ..write('asc: $asc, ')
          ..write('programId: $programId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('mainTrackId: $mainTrackId, ')
          ..write('title: $title, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('artistName: $artistName, ')
          ..write('albumTitle: $albumTitle, ')
          ..write('durationMs: $durationMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      userId,
      radioId,
      asc,
      programId,
      sortOrder,
      mainTrackId,
      title,
      coverUrl,
      artistName,
      albumTitle,
      durationMs,
      updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRadioProgram &&
          other.userId == this.userId &&
          other.radioId == this.radioId &&
          other.asc == this.asc &&
          other.programId == this.programId &&
          other.sortOrder == this.sortOrder &&
          other.mainTrackId == this.mainTrackId &&
          other.title == this.title &&
          other.coverUrl == this.coverUrl &&
          other.artistName == this.artistName &&
          other.albumTitle == this.albumTitle &&
          other.durationMs == this.durationMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class UserRadioProgramsCompanion extends UpdateCompanion<UserRadioProgram> {
  final Value<String> userId;
  final Value<String> radioId;
  final Value<bool> asc;
  final Value<String> programId;
  final Value<int> sortOrder;
  final Value<String> mainTrackId;
  final Value<String> title;
  final Value<String> coverUrl;
  final Value<String> artistName;
  final Value<String> albumTitle;
  final Value<int> durationMs;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const UserRadioProgramsCompanion({
    this.userId = const Value.absent(),
    this.radioId = const Value.absent(),
    this.asc = const Value.absent(),
    this.programId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.mainTrackId = const Value.absent(),
    this.title = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.artistName = const Value.absent(),
    this.albumTitle = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserRadioProgramsCompanion.insert({
    required String userId,
    required String radioId,
    required bool asc,
    required String programId,
    required int sortOrder,
    required String mainTrackId,
    required String title,
    required String coverUrl,
    required String artistName,
    required String albumTitle,
    required int durationMs,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        radioId = Value(radioId),
        asc = Value(asc),
        programId = Value(programId),
        sortOrder = Value(sortOrder),
        mainTrackId = Value(mainTrackId),
        title = Value(title),
        coverUrl = Value(coverUrl),
        artistName = Value(artistName),
        albumTitle = Value(albumTitle),
        durationMs = Value(durationMs),
        updatedAtMs = Value(updatedAtMs);
  static Insertable<UserRadioProgram> custom({
    Expression<String>? userId,
    Expression<String>? radioId,
    Expression<bool>? asc,
    Expression<String>? programId,
    Expression<int>? sortOrder,
    Expression<String>? mainTrackId,
    Expression<String>? title,
    Expression<String>? coverUrl,
    Expression<String>? artistName,
    Expression<String>? albumTitle,
    Expression<int>? durationMs,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (radioId != null) 'radio_id': radioId,
      if (asc != null) 'asc': asc,
      if (programId != null) 'program_id': programId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (mainTrackId != null) 'main_track_id': mainTrackId,
      if (title != null) 'title': title,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (artistName != null) 'artist_name': artistName,
      if (albumTitle != null) 'album_title': albumTitle,
      if (durationMs != null) 'duration_ms': durationMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserRadioProgramsCompanion copyWith(
      {Value<String>? userId,
      Value<String>? radioId,
      Value<bool>? asc,
      Value<String>? programId,
      Value<int>? sortOrder,
      Value<String>? mainTrackId,
      Value<String>? title,
      Value<String>? coverUrl,
      Value<String>? artistName,
      Value<String>? albumTitle,
      Value<int>? durationMs,
      Value<int>? updatedAtMs,
      Value<int>? rowid}) {
    return UserRadioProgramsCompanion(
      userId: userId ?? this.userId,
      radioId: radioId ?? this.radioId,
      asc: asc ?? this.asc,
      programId: programId ?? this.programId,
      sortOrder: sortOrder ?? this.sortOrder,
      mainTrackId: mainTrackId ?? this.mainTrackId,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      artistName: artistName ?? this.artistName,
      albumTitle: albumTitle ?? this.albumTitle,
      durationMs: durationMs ?? this.durationMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (radioId.present) {
      map['radio_id'] = Variable<String>(radioId.value);
    }
    if (asc.present) {
      map['asc'] = Variable<bool>(asc.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<String>(programId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (mainTrackId.present) {
      map['main_track_id'] = Variable<String>(mainTrackId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (artistName.present) {
      map['artist_name'] = Variable<String>(artistName.value);
    }
    if (albumTitle.present) {
      map['album_title'] = Variable<String>(albumTitle.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserRadioProgramsCompanion(')
          ..write('userId: $userId, ')
          ..write('radioId: $radioId, ')
          ..write('asc: $asc, ')
          ..write('programId: $programId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('mainTrackId: $mainTrackId, ')
          ..write('title: $title, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('artistName: $artistName, ')
          ..write('albumTitle: $albumTitle, ')
          ..write('durationMs: $durationMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSyncMarkersTable extends UserSyncMarkers
    with TableInfo<$UserSyncMarkersTable, UserSyncMarker> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSyncMarkersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _markerKeyMeta =
      const VerificationMeta('markerKey');
  @override
  late final GeneratedColumn<String> markerKey = GeneratedColumn<String>(
      'marker_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMsMeta =
      const VerificationMeta('updatedAtMs');
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
      'updated_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [userId, markerKey, updatedAtMs];
  @override
  String get aliasedName => _alias ?? 'user_sync_markers';
  @override
  String get actualTableName => 'user_sync_markers';
  @override
  VerificationContext validateIntegrity(Insertable<UserSyncMarker> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('marker_key')) {
      context.handle(_markerKeyMeta,
          markerKey.isAcceptableOrUnknown(data['marker_key']!, _markerKeyMeta));
    } else if (isInserting) {
      context.missing(_markerKeyMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
          _updatedAtMsMeta,
          updatedAtMs.isAcceptableOrUnknown(
              data['updated_at_ms']!, _updatedAtMsMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, markerKey};
  @override
  UserSyncMarker map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSyncMarker(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      markerKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}marker_key'])!,
      updatedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at_ms'])!,
    );
  }

  @override
  $UserSyncMarkersTable createAlias(String alias) {
    return $UserSyncMarkersTable(attachedDatabase, alias);
  }
}

class UserSyncMarker extends DataClass implements Insertable<UserSyncMarker> {
  final String userId;
  final String markerKey;
  final int updatedAtMs;
  const UserSyncMarker(
      {required this.userId,
      required this.markerKey,
      required this.updatedAtMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['marker_key'] = Variable<String>(markerKey);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  UserSyncMarkersCompanion toCompanion(bool nullToAbsent) {
    return UserSyncMarkersCompanion(
      userId: Value(userId),
      markerKey: Value(markerKey),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory UserSyncMarker.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSyncMarker(
      userId: serializer.fromJson<String>(json['userId']),
      markerKey: serializer.fromJson<String>(json['markerKey']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'markerKey': serializer.toJson<String>(markerKey),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  UserSyncMarker copyWith(
          {String? userId, String? markerKey, int? updatedAtMs}) =>
      UserSyncMarker(
        userId: userId ?? this.userId,
        markerKey: markerKey ?? this.markerKey,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      );
  @override
  String toString() {
    return (StringBuffer('UserSyncMarker(')
          ..write('userId: $userId, ')
          ..write('markerKey: $markerKey, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, markerKey, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSyncMarker &&
          other.userId == this.userId &&
          other.markerKey == this.markerKey &&
          other.updatedAtMs == this.updatedAtMs);
}

class UserSyncMarkersCompanion extends UpdateCompanion<UserSyncMarker> {
  final Value<String> userId;
  final Value<String> markerKey;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const UserSyncMarkersCompanion({
    this.userId = const Value.absent(),
    this.markerKey = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSyncMarkersCompanion.insert({
    required String userId,
    required String markerKey,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        markerKey = Value(markerKey),
        updatedAtMs = Value(updatedAtMs);
  static Insertable<UserSyncMarker> custom({
    Expression<String>? userId,
    Expression<String>? markerKey,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (markerKey != null) 'marker_key': markerKey,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSyncMarkersCompanion copyWith(
      {Value<String>? userId,
      Value<String>? markerKey,
      Value<int>? updatedAtMs,
      Value<int>? rowid}) {
    return UserSyncMarkersCompanion(
      userId: userId ?? this.userId,
      markerKey: markerKey ?? this.markerKey,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (markerKey.present) {
      map['marker_key'] = Variable<String>(markerKey.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSyncMarkersCompanion(')
          ..write('userId: $userId, ')
          ..write('markerKey: $markerKey, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BujuanDriftDatabase extends GeneratedDatabase {
  _$BujuanDriftDatabase(QueryExecutor e) : super(e);
  late final $PlaybackRestoreSnapshotsTable playbackRestoreSnapshots =
      $PlaybackRestoreSnapshotsTable(this);
  late final $LocalResourceEntriesTable localResourceEntries =
      $LocalResourceEntriesTable(this);
  late final $DownloadTasksTable downloadTasks = $DownloadTasksTable(this);
  late final $AppCacheEntriesTable appCacheEntries =
      $AppCacheEntriesTable(this);
  late final $TracksTable tracks = $TracksTable(this);
  late final $TrackLyricsEntriesTable trackLyricsEntries =
      $TrackLyricsEntriesTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistTrackRefsTable playlistTrackRefs =
      $PlaylistTrackRefsTable(this);
  late final $AlbumsTable albums = $AlbumsTable(this);
  late final $ArtistsTable artists = $ArtistsTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $UserTrackListRefsTable userTrackListRefs =
      $UserTrackListRefsTable(this);
  late final $UserPlaylistListRefsTable userPlaylistListRefs =
      $UserPlaylistListRefsTable(this);
  late final $UserPlaylistSnapshotsTable userPlaylistSnapshots =
      $UserPlaylistSnapshotsTable(this);
  late final $UserPlaylistStatesTable userPlaylistStates =
      $UserPlaylistStatesTable(this);
  late final $UserRadioSubscriptionsTable userRadioSubscriptions =
      $UserRadioSubscriptionsTable(this);
  late final $UserRadioProgramsTable userRadioPrograms =
      $UserRadioProgramsTable(this);
  late final $UserSyncMarkersTable userSyncMarkers =
      $UserSyncMarkersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        playbackRestoreSnapshots,
        localResourceEntries,
        downloadTasks,
        appCacheEntries,
        tracks,
        trackLyricsEntries,
        playlists,
        playlistTrackRefs,
        albums,
        artists,
        userProfiles,
        userTrackListRefs,
        userPlaylistListRefs,
        userPlaylistSnapshots,
        userPlaylistStates,
        userRadioSubscriptions,
        userRadioPrograms,
        userSyncMarkers
      ];
}
