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
  static const VerificationMeta _updatedAtMsMeta =
      const VerificationMeta('updatedAtMs');
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
      'updated_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [trackId, kind, path, origin, updatedAtMs];
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
      updatedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at_ms'])!,
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
  final int updatedAtMs;
  const LocalResourceEntrie(
      {required this.trackId,
      required this.kind,
      required this.path,
      required this.origin,
      required this.updatedAtMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['kind'] = Variable<String>(kind);
    map['path'] = Variable<String>(path);
    map['origin'] = Variable<String>(origin);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  LocalResourceEntriesCompanion toCompanion(bool nullToAbsent) {
    return LocalResourceEntriesCompanion(
      trackId: Value(trackId),
      kind: Value(kind),
      path: Value(path),
      origin: Value(origin),
      updatedAtMs: Value(updatedAtMs),
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
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
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
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  LocalResourceEntrie copyWith(
          {String? trackId,
          String? kind,
          String? path,
          String? origin,
          int? updatedAtMs}) =>
      LocalResourceEntrie(
        trackId: trackId ?? this.trackId,
        kind: kind ?? this.kind,
        path: path ?? this.path,
        origin: origin ?? this.origin,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      );
  @override
  String toString() {
    return (StringBuffer('LocalResourceEntrie(')
          ..write('trackId: $trackId, ')
          ..write('kind: $kind, ')
          ..write('path: $path, ')
          ..write('origin: $origin, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackId, kind, path, origin, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalResourceEntrie &&
          other.trackId == this.trackId &&
          other.kind == this.kind &&
          other.path == this.path &&
          other.origin == this.origin &&
          other.updatedAtMs == this.updatedAtMs);
}

class LocalResourceEntriesCompanion
    extends UpdateCompanion<LocalResourceEntrie> {
  final Value<String> trackId;
  final Value<String> kind;
  final Value<String> path;
  final Value<String> origin;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const LocalResourceEntriesCompanion({
    this.trackId = const Value.absent(),
    this.kind = const Value.absent(),
    this.path = const Value.absent(),
    this.origin = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalResourceEntriesCompanion.insert({
    required String trackId,
    required String kind,
    required String path,
    required String origin,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  })  : trackId = Value(trackId),
        kind = Value(kind),
        path = Value(path),
        origin = Value(origin),
        updatedAtMs = Value(updatedAtMs);
  static Insertable<LocalResourceEntrie> custom({
    Expression<String>? trackId,
    Expression<String>? kind,
    Expression<String>? path,
    Expression<String>? origin,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (kind != null) 'kind': kind,
      if (path != null) 'path': path,
      if (origin != null) 'origin': origin,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalResourceEntriesCompanion copyWith(
      {Value<String>? trackId,
      Value<String>? kind,
      Value<String>? path,
      Value<String>? origin,
      Value<int>? updatedAtMs,
      Value<int>? rowid}) {
    return LocalResourceEntriesCompanion(
      trackId: trackId ?? this.trackId,
      kind: kind ?? this.kind,
      path: path ?? this.path,
      origin: origin ?? this.origin,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
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
    return (StringBuffer('LocalResourceEntriesCompanion(')
          ..write('trackId: $trackId, ')
          ..write('kind: $kind, ')
          ..write('path: $path, ')
          ..write('origin: $origin, ')
          ..write('updatedAtMs: $updatedAtMs, ')
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
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _artworkPathMeta =
      const VerificationMeta('artworkPath');
  @override
  late final GeneratedColumn<String> artworkPath = GeneratedColumn<String>(
      'artwork_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lyricsPathMeta =
      const VerificationMeta('lyricsPath');
  @override
  late final GeneratedColumn<String> lyricsPath = GeneratedColumn<String>(
      'lyrics_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _failureReasonMeta =
      const VerificationMeta('failureReason');
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
      'failure_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        trackId,
        status,
        updatedAtMs,
        progress,
        localPath,
        artworkPath,
        lyricsPath,
        failureReason
      ];
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
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    }
    if (data.containsKey('artwork_path')) {
      context.handle(
          _artworkPathMeta,
          artworkPath.isAcceptableOrUnknown(
              data['artwork_path']!, _artworkPathMeta));
    }
    if (data.containsKey('lyrics_path')) {
      context.handle(
          _lyricsPathMeta,
          lyricsPath.isAcceptableOrUnknown(
              data['lyrics_path']!, _lyricsPathMeta));
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
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path']),
      artworkPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artwork_path']),
      lyricsPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lyrics_path']),
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
  final String? localPath;
  final String? artworkPath;
  final String? lyricsPath;
  final String? failureReason;
  const DownloadTask(
      {required this.trackId,
      required this.status,
      required this.updatedAtMs,
      this.progress,
      this.localPath,
      this.artworkPath,
      this.lyricsPath,
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
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || artworkPath != null) {
      map['artwork_path'] = Variable<String>(artworkPath);
    }
    if (!nullToAbsent || lyricsPath != null) {
      map['lyrics_path'] = Variable<String>(lyricsPath);
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
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      artworkPath: artworkPath == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkPath),
      lyricsPath: lyricsPath == null && nullToAbsent
          ? const Value.absent()
          : Value(lyricsPath),
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
      localPath: serializer.fromJson<String?>(json['localPath']),
      artworkPath: serializer.fromJson<String?>(json['artworkPath']),
      lyricsPath: serializer.fromJson<String?>(json['lyricsPath']),
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
      'localPath': serializer.toJson<String?>(localPath),
      'artworkPath': serializer.toJson<String?>(artworkPath),
      'lyricsPath': serializer.toJson<String?>(lyricsPath),
      'failureReason': serializer.toJson<String?>(failureReason),
    };
  }

  DownloadTask copyWith(
          {String? trackId,
          String? status,
          int? updatedAtMs,
          Value<double?> progress = const Value.absent(),
          Value<String?> localPath = const Value.absent(),
          Value<String?> artworkPath = const Value.absent(),
          Value<String?> lyricsPath = const Value.absent(),
          Value<String?> failureReason = const Value.absent()}) =>
      DownloadTask(
        trackId: trackId ?? this.trackId,
        status: status ?? this.status,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
        progress: progress.present ? progress.value : this.progress,
        localPath: localPath.present ? localPath.value : this.localPath,
        artworkPath: artworkPath.present ? artworkPath.value : this.artworkPath,
        lyricsPath: lyricsPath.present ? lyricsPath.value : this.lyricsPath,
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
          ..write('localPath: $localPath, ')
          ..write('artworkPath: $artworkPath, ')
          ..write('lyricsPath: $lyricsPath, ')
          ..write('failureReason: $failureReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackId, status, updatedAtMs, progress,
      localPath, artworkPath, lyricsPath, failureReason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadTask &&
          other.trackId == this.trackId &&
          other.status == this.status &&
          other.updatedAtMs == this.updatedAtMs &&
          other.progress == this.progress &&
          other.localPath == this.localPath &&
          other.artworkPath == this.artworkPath &&
          other.lyricsPath == this.lyricsPath &&
          other.failureReason == this.failureReason);
}

class DownloadTasksCompanion extends UpdateCompanion<DownloadTask> {
  final Value<String> trackId;
  final Value<String> status;
  final Value<int> updatedAtMs;
  final Value<double?> progress;
  final Value<String?> localPath;
  final Value<String?> artworkPath;
  final Value<String?> lyricsPath;
  final Value<String?> failureReason;
  final Value<int> rowid;
  const DownloadTasksCompanion({
    this.trackId = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.progress = const Value.absent(),
    this.localPath = const Value.absent(),
    this.artworkPath = const Value.absent(),
    this.lyricsPath = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadTasksCompanion.insert({
    required String trackId,
    required String status,
    required int updatedAtMs,
    this.progress = const Value.absent(),
    this.localPath = const Value.absent(),
    this.artworkPath = const Value.absent(),
    this.lyricsPath = const Value.absent(),
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
    Expression<String>? localPath,
    Expression<String>? artworkPath,
    Expression<String>? lyricsPath,
    Expression<String>? failureReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (status != null) 'status': status,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (progress != null) 'progress': progress,
      if (localPath != null) 'local_path': localPath,
      if (artworkPath != null) 'artwork_path': artworkPath,
      if (lyricsPath != null) 'lyrics_path': lyricsPath,
      if (failureReason != null) 'failure_reason': failureReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadTasksCompanion copyWith(
      {Value<String>? trackId,
      Value<String>? status,
      Value<int>? updatedAtMs,
      Value<double?>? progress,
      Value<String?>? localPath,
      Value<String?>? artworkPath,
      Value<String?>? lyricsPath,
      Value<String?>? failureReason,
      Value<int>? rowid}) {
    return DownloadTasksCompanion(
      trackId: trackId ?? this.trackId,
      status: status ?? this.status,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      progress: progress ?? this.progress,
      localPath: localPath ?? this.localPath,
      artworkPath: artworkPath ?? this.artworkPath,
      lyricsPath: lyricsPath ?? this.lyricsPath,
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
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (artworkPath.present) {
      map['artwork_path'] = Variable<String>(artworkPath.value);
    }
    if (lyricsPath.present) {
      map['lyrics_path'] = Variable<String>(lyricsPath.value);
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
          ..write('localPath: $localPath, ')
          ..write('artworkPath: $artworkPath, ')
          ..write('lyricsPath: $lyricsPath, ')
          ..write('failureReason: $failureReason, ')
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
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localArtworkPathMeta =
      const VerificationMeta('localArtworkPath');
  @override
  late final GeneratedColumn<String> localArtworkPath = GeneratedColumn<String>(
      'local_artwork_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localLyricsPathMeta =
      const VerificationMeta('localLyricsPath');
  @override
  late final GeneratedColumn<String> localLyricsPath = GeneratedColumn<String>(
      'local_lyrics_path', aliasedName, true,
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
  static const VerificationMeta _downloadStateMeta =
      const VerificationMeta('downloadState');
  @override
  late final GeneratedColumn<String> downloadState = GeneratedColumn<String>(
      'download_state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resourceOriginMeta =
      const VerificationMeta('resourceOrigin');
  @override
  late final GeneratedColumn<String> resourceOrigin = GeneratedColumn<String>(
      'resource_origin', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _downloadProgressMeta =
      const VerificationMeta('downloadProgress');
  @override
  late final GeneratedColumn<double> downloadProgress = GeneratedColumn<double>(
      'download_progress', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _downloadFailureReasonMeta =
      const VerificationMeta('downloadFailureReason');
  @override
  late final GeneratedColumn<String> downloadFailureReason =
      GeneratedColumn<String>('download_failure_reason', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
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
        localPath,
        localArtworkPath,
        localLyricsPath,
        lyricKey,
        availability,
        downloadState,
        resourceOrigin,
        downloadProgress,
        downloadFailureReason,
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
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    }
    if (data.containsKey('local_artwork_path')) {
      context.handle(
          _localArtworkPathMeta,
          localArtworkPath.isAcceptableOrUnknown(
              data['local_artwork_path']!, _localArtworkPathMeta));
    }
    if (data.containsKey('local_lyrics_path')) {
      context.handle(
          _localLyricsPathMeta,
          localLyricsPath.isAcceptableOrUnknown(
              data['local_lyrics_path']!, _localLyricsPathMeta));
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
    if (data.containsKey('download_state')) {
      context.handle(
          _downloadStateMeta,
          downloadState.isAcceptableOrUnknown(
              data['download_state']!, _downloadStateMeta));
    } else if (isInserting) {
      context.missing(_downloadStateMeta);
    }
    if (data.containsKey('resource_origin')) {
      context.handle(
          _resourceOriginMeta,
          resourceOrigin.isAcceptableOrUnknown(
              data['resource_origin']!, _resourceOriginMeta));
    } else if (isInserting) {
      context.missing(_resourceOriginMeta);
    }
    if (data.containsKey('download_progress')) {
      context.handle(
          _downloadProgressMeta,
          downloadProgress.isAcceptableOrUnknown(
              data['download_progress']!, _downloadProgressMeta));
    }
    if (data.containsKey('download_failure_reason')) {
      context.handle(
          _downloadFailureReasonMeta,
          downloadFailureReason.isAcceptableOrUnknown(
              data['download_failure_reason']!, _downloadFailureReasonMeta));
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
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path']),
      localArtworkPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_artwork_path']),
      localLyricsPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_lyrics_path']),
      lyricKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lyric_key']),
      availability: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}availability'])!,
      downloadState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}download_state'])!,
      resourceOrigin: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}resource_origin'])!,
      downloadProgress: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}download_progress']),
      downloadFailureReason: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}download_failure_reason']),
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
  final String? localPath;
  final String? localArtworkPath;
  final String? localLyricsPath;
  final String? lyricKey;
  final String availability;
  final String downloadState;
  final String resourceOrigin;
  final double? downloadProgress;
  final String? downloadFailureReason;
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
      this.localPath,
      this.localArtworkPath,
      this.localLyricsPath,
      this.lyricKey,
      required this.availability,
      required this.downloadState,
      required this.resourceOrigin,
      this.downloadProgress,
      this.downloadFailureReason,
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
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || localArtworkPath != null) {
      map['local_artwork_path'] = Variable<String>(localArtworkPath);
    }
    if (!nullToAbsent || localLyricsPath != null) {
      map['local_lyrics_path'] = Variable<String>(localLyricsPath);
    }
    if (!nullToAbsent || lyricKey != null) {
      map['lyric_key'] = Variable<String>(lyricKey);
    }
    map['availability'] = Variable<String>(availability);
    map['download_state'] = Variable<String>(downloadState);
    map['resource_origin'] = Variable<String>(resourceOrigin);
    if (!nullToAbsent || downloadProgress != null) {
      map['download_progress'] = Variable<double>(downloadProgress);
    }
    if (!nullToAbsent || downloadFailureReason != null) {
      map['download_failure_reason'] = Variable<String>(downloadFailureReason);
    }
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
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      localArtworkPath: localArtworkPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localArtworkPath),
      localLyricsPath: localLyricsPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localLyricsPath),
      lyricKey: lyricKey == null && nullToAbsent
          ? const Value.absent()
          : Value(lyricKey),
      availability: Value(availability),
      downloadState: Value(downloadState),
      resourceOrigin: Value(resourceOrigin),
      downloadProgress: downloadProgress == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadProgress),
      downloadFailureReason: downloadFailureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadFailureReason),
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
      localPath: serializer.fromJson<String?>(json['localPath']),
      localArtworkPath: serializer.fromJson<String?>(json['localArtworkPath']),
      localLyricsPath: serializer.fromJson<String?>(json['localLyricsPath']),
      lyricKey: serializer.fromJson<String?>(json['lyricKey']),
      availability: serializer.fromJson<String>(json['availability']),
      downloadState: serializer.fromJson<String>(json['downloadState']),
      resourceOrigin: serializer.fromJson<String>(json['resourceOrigin']),
      downloadProgress: serializer.fromJson<double?>(json['downloadProgress']),
      downloadFailureReason:
          serializer.fromJson<String?>(json['downloadFailureReason']),
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
      'localPath': serializer.toJson<String?>(localPath),
      'localArtworkPath': serializer.toJson<String?>(localArtworkPath),
      'localLyricsPath': serializer.toJson<String?>(localLyricsPath),
      'lyricKey': serializer.toJson<String?>(lyricKey),
      'availability': serializer.toJson<String>(availability),
      'downloadState': serializer.toJson<String>(downloadState),
      'resourceOrigin': serializer.toJson<String>(resourceOrigin),
      'downloadProgress': serializer.toJson<double?>(downloadProgress),
      'downloadFailureReason':
          serializer.toJson<String?>(downloadFailureReason),
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
          Value<String?> localPath = const Value.absent(),
          Value<String?> localArtworkPath = const Value.absent(),
          Value<String?> localLyricsPath = const Value.absent(),
          Value<String?> lyricKey = const Value.absent(),
          String? availability,
          String? downloadState,
          String? resourceOrigin,
          Value<double?> downloadProgress = const Value.absent(),
          Value<String?> downloadFailureReason = const Value.absent(),
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
        localPath: localPath.present ? localPath.value : this.localPath,
        localArtworkPath: localArtworkPath.present
            ? localArtworkPath.value
            : this.localArtworkPath,
        localLyricsPath: localLyricsPath.present
            ? localLyricsPath.value
            : this.localLyricsPath,
        lyricKey: lyricKey.present ? lyricKey.value : this.lyricKey,
        availability: availability ?? this.availability,
        downloadState: downloadState ?? this.downloadState,
        resourceOrigin: resourceOrigin ?? this.resourceOrigin,
        downloadProgress: downloadProgress.present
            ? downloadProgress.value
            : this.downloadProgress,
        downloadFailureReason: downloadFailureReason.present
            ? downloadFailureReason.value
            : this.downloadFailureReason,
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
          ..write('localPath: $localPath, ')
          ..write('localArtworkPath: $localArtworkPath, ')
          ..write('localLyricsPath: $localLyricsPath, ')
          ..write('lyricKey: $lyricKey, ')
          ..write('availability: $availability, ')
          ..write('downloadState: $downloadState, ')
          ..write('resourceOrigin: $resourceOrigin, ')
          ..write('downloadProgress: $downloadProgress, ')
          ..write('downloadFailureReason: $downloadFailureReason, ')
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
      localPath,
      localArtworkPath,
      localLyricsPath,
      lyricKey,
      availability,
      downloadState,
      resourceOrigin,
      downloadProgress,
      downloadFailureReason,
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
          other.localPath == this.localPath &&
          other.localArtworkPath == this.localArtworkPath &&
          other.localLyricsPath == this.localLyricsPath &&
          other.lyricKey == this.lyricKey &&
          other.availability == this.availability &&
          other.downloadState == this.downloadState &&
          other.resourceOrigin == this.resourceOrigin &&
          other.downloadProgress == this.downloadProgress &&
          other.downloadFailureReason == this.downloadFailureReason &&
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
  final Value<String?> localPath;
  final Value<String?> localArtworkPath;
  final Value<String?> localLyricsPath;
  final Value<String?> lyricKey;
  final Value<String> availability;
  final Value<String> downloadState;
  final Value<String> resourceOrigin;
  final Value<double?> downloadProgress;
  final Value<String?> downloadFailureReason;
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
    this.localPath = const Value.absent(),
    this.localArtworkPath = const Value.absent(),
    this.localLyricsPath = const Value.absent(),
    this.lyricKey = const Value.absent(),
    this.availability = const Value.absent(),
    this.downloadState = const Value.absent(),
    this.resourceOrigin = const Value.absent(),
    this.downloadProgress = const Value.absent(),
    this.downloadFailureReason = const Value.absent(),
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
    this.localPath = const Value.absent(),
    this.localArtworkPath = const Value.absent(),
    this.localLyricsPath = const Value.absent(),
    this.lyricKey = const Value.absent(),
    required String availability,
    required String downloadState,
    required String resourceOrigin,
    this.downloadProgress = const Value.absent(),
    this.downloadFailureReason = const Value.absent(),
    required String metadataJson,
    this.rowid = const Value.absent(),
  })  : trackId = Value(trackId),
        sourceType = Value(sourceType),
        sourceId = Value(sourceId),
        title = Value(title),
        artistSearchText = Value(artistSearchText),
        artistNamesJson = Value(artistNamesJson),
        availability = Value(availability),
        downloadState = Value(downloadState),
        resourceOrigin = Value(resourceOrigin),
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
    Expression<String>? localPath,
    Expression<String>? localArtworkPath,
    Expression<String>? localLyricsPath,
    Expression<String>? lyricKey,
    Expression<String>? availability,
    Expression<String>? downloadState,
    Expression<String>? resourceOrigin,
    Expression<double>? downloadProgress,
    Expression<String>? downloadFailureReason,
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
      if (localPath != null) 'local_path': localPath,
      if (localArtworkPath != null) 'local_artwork_path': localArtworkPath,
      if (localLyricsPath != null) 'local_lyrics_path': localLyricsPath,
      if (lyricKey != null) 'lyric_key': lyricKey,
      if (availability != null) 'availability': availability,
      if (downloadState != null) 'download_state': downloadState,
      if (resourceOrigin != null) 'resource_origin': resourceOrigin,
      if (downloadProgress != null) 'download_progress': downloadProgress,
      if (downloadFailureReason != null)
        'download_failure_reason': downloadFailureReason,
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
      Value<String?>? localPath,
      Value<String?>? localArtworkPath,
      Value<String?>? localLyricsPath,
      Value<String?>? lyricKey,
      Value<String>? availability,
      Value<String>? downloadState,
      Value<String>? resourceOrigin,
      Value<double?>? downloadProgress,
      Value<String?>? downloadFailureReason,
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
      localPath: localPath ?? this.localPath,
      localArtworkPath: localArtworkPath ?? this.localArtworkPath,
      localLyricsPath: localLyricsPath ?? this.localLyricsPath,
      lyricKey: lyricKey ?? this.lyricKey,
      availability: availability ?? this.availability,
      downloadState: downloadState ?? this.downloadState,
      resourceOrigin: resourceOrigin ?? this.resourceOrigin,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadFailureReason:
          downloadFailureReason ?? this.downloadFailureReason,
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
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (localArtworkPath.present) {
      map['local_artwork_path'] = Variable<String>(localArtworkPath.value);
    }
    if (localLyricsPath.present) {
      map['local_lyrics_path'] = Variable<String>(localLyricsPath.value);
    }
    if (lyricKey.present) {
      map['lyric_key'] = Variable<String>(lyricKey.value);
    }
    if (availability.present) {
      map['availability'] = Variable<String>(availability.value);
    }
    if (downloadState.present) {
      map['download_state'] = Variable<String>(downloadState.value);
    }
    if (resourceOrigin.present) {
      map['resource_origin'] = Variable<String>(resourceOrigin.value);
    }
    if (downloadProgress.present) {
      map['download_progress'] = Variable<double>(downloadProgress.value);
    }
    if (downloadFailureReason.present) {
      map['download_failure_reason'] =
          Variable<String>(downloadFailureReason.value);
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
          ..write('localPath: $localPath, ')
          ..write('localArtworkPath: $localArtworkPath, ')
          ..write('localLyricsPath: $localLyricsPath, ')
          ..write('lyricKey: $lyricKey, ')
          ..write('availability: $availability, ')
          ..write('downloadState: $downloadState, ')
          ..write('resourceOrigin: $resourceOrigin, ')
          ..write('downloadProgress: $downloadProgress, ')
          ..write('downloadFailureReason: $downloadFailureReason, ')
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
  static const VerificationMeta _trackRefsJsonMeta =
      const VerificationMeta('trackRefsJson');
  @override
  late final GeneratedColumn<String> trackRefsJson = GeneratedColumn<String>(
      'track_refs_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        playlistId,
        sourceType,
        sourceId,
        title,
        description,
        coverUrl,
        trackCount,
        trackRefsJson
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
    if (data.containsKey('track_refs_json')) {
      context.handle(
          _trackRefsJsonMeta,
          trackRefsJson.isAcceptableOrUnknown(
              data['track_refs_json']!, _trackRefsJsonMeta));
    } else if (isInserting) {
      context.missing(_trackRefsJsonMeta);
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
      trackRefsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}track_refs_json'])!,
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
  final String trackRefsJson;
  const Playlist(
      {required this.playlistId,
      required this.sourceType,
      required this.sourceId,
      required this.title,
      this.description,
      this.coverUrl,
      this.trackCount,
      required this.trackRefsJson});
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
    map['track_refs_json'] = Variable<String>(trackRefsJson);
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
      trackRefsJson: Value(trackRefsJson),
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
      trackRefsJson: serializer.fromJson<String>(json['trackRefsJson']),
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
      'trackRefsJson': serializer.toJson<String>(trackRefsJson),
    };
  }

  Playlist copyWith(
          {String? playlistId,
          String? sourceType,
          String? sourceId,
          String? title,
          Value<String?> description = const Value.absent(),
          Value<String?> coverUrl = const Value.absent(),
          Value<int?> trackCount = const Value.absent(),
          String? trackRefsJson}) =>
      Playlist(
        playlistId: playlistId ?? this.playlistId,
        sourceType: sourceType ?? this.sourceType,
        sourceId: sourceId ?? this.sourceId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
        trackCount: trackCount.present ? trackCount.value : this.trackCount,
        trackRefsJson: trackRefsJson ?? this.trackRefsJson,
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
          ..write('trackCount: $trackCount, ')
          ..write('trackRefsJson: $trackRefsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, sourceType, sourceId, title,
      description, coverUrl, trackCount, trackRefsJson);
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
          other.trackCount == this.trackCount &&
          other.trackRefsJson == this.trackRefsJson);
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<String> playlistId;
  final Value<String> sourceType;
  final Value<String> sourceId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> coverUrl;
  final Value<int?> trackCount;
  final Value<String> trackRefsJson;
  final Value<int> rowid;
  const PlaylistsCompanion({
    this.playlistId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.trackCount = const Value.absent(),
    this.trackRefsJson = const Value.absent(),
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
    required String trackRefsJson,
    this.rowid = const Value.absent(),
  })  : playlistId = Value(playlistId),
        sourceType = Value(sourceType),
        sourceId = Value(sourceId),
        title = Value(title),
        trackRefsJson = Value(trackRefsJson);
  static Insertable<Playlist> custom({
    Expression<String>? playlistId,
    Expression<String>? sourceType,
    Expression<String>? sourceId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? coverUrl,
    Expression<int>? trackCount,
    Expression<String>? trackRefsJson,
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
      if (trackRefsJson != null) 'track_refs_json': trackRefsJson,
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
      Value<String>? trackRefsJson,
      Value<int>? rowid}) {
    return PlaylistsCompanion(
      playlistId: playlistId ?? this.playlistId,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      trackCount: trackCount ?? this.trackCount,
      trackRefsJson: trackRefsJson ?? this.trackRefsJson,
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
    if (trackRefsJson.present) {
      map['track_refs_json'] = Variable<String>(trackRefsJson.value);
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
          ..write('trackRefsJson: $trackRefsJson, ')
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

abstract class _$BujuanDriftDatabase extends GeneratedDatabase {
  _$BujuanDriftDatabase(QueryExecutor e) : super(e);
  late final $PlaybackRestoreSnapshotsTable playbackRestoreSnapshots =
      $PlaybackRestoreSnapshotsTable(this);
  late final $LocalResourceEntriesTable localResourceEntries =
      $LocalResourceEntriesTable(this);
  late final $DownloadTasksTable downloadTasks = $DownloadTasksTable(this);
  late final $TracksTable tracks = $TracksTable(this);
  late final $TrackLyricsEntriesTable trackLyricsEntries =
      $TrackLyricsEntriesTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $AlbumsTable albums = $AlbumsTable(this);
  late final $ArtistsTable artists = $ArtistsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        playbackRestoreSnapshots,
        localResourceEntries,
        downloadTasks,
        tracks,
        trackLyricsEntries,
        playlists,
        albums,
        artists
      ];
}
