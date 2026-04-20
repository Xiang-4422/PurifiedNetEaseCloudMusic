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
  static const VerificationMeta _albumTitleMeta =
      const VerificationMeta('albumTitle');
  @override
  late final GeneratedColumn<String> albumTitle = GeneratedColumn<String>(
      'album_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [trackId, title, artistSearchText, albumTitle, payloadJson];
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
    if (data.containsKey('album_title')) {
      context.handle(
          _albumTitleMeta,
          albumTitle.isAcceptableOrUnknown(
              data['album_title']!, _albumTitleMeta));
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
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
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      artistSearchText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}artist_search_text'])!,
      albumTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album_title']),
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
    );
  }

  @override
  $TracksTable createAlias(String alias) {
    return $TracksTable(attachedDatabase, alias);
  }
}

class Track extends DataClass implements Insertable<Track> {
  final String trackId;
  final String title;
  final String artistSearchText;
  final String? albumTitle;
  final String payloadJson;
  const Track(
      {required this.trackId,
      required this.title,
      required this.artistSearchText,
      this.albumTitle,
      required this.payloadJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['title'] = Variable<String>(title);
    map['artist_search_text'] = Variable<String>(artistSearchText);
    if (!nullToAbsent || albumTitle != null) {
      map['album_title'] = Variable<String>(albumTitle);
    }
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  TracksCompanion toCompanion(bool nullToAbsent) {
    return TracksCompanion(
      trackId: Value(trackId),
      title: Value(title),
      artistSearchText: Value(artistSearchText),
      albumTitle: albumTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(albumTitle),
      payloadJson: Value(payloadJson),
    );
  }

  factory Track.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Track(
      trackId: serializer.fromJson<String>(json['trackId']),
      title: serializer.fromJson<String>(json['title']),
      artistSearchText: serializer.fromJson<String>(json['artistSearchText']),
      albumTitle: serializer.fromJson<String?>(json['albumTitle']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'title': serializer.toJson<String>(title),
      'artistSearchText': serializer.toJson<String>(artistSearchText),
      'albumTitle': serializer.toJson<String?>(albumTitle),
      'payloadJson': serializer.toJson<String>(payloadJson),
    };
  }

  Track copyWith(
          {String? trackId,
          String? title,
          String? artistSearchText,
          Value<String?> albumTitle = const Value.absent(),
          String? payloadJson}) =>
      Track(
        trackId: trackId ?? this.trackId,
        title: title ?? this.title,
        artistSearchText: artistSearchText ?? this.artistSearchText,
        albumTitle: albumTitle.present ? albumTitle.value : this.albumTitle,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  @override
  String toString() {
    return (StringBuffer('Track(')
          ..write('trackId: $trackId, ')
          ..write('title: $title, ')
          ..write('artistSearchText: $artistSearchText, ')
          ..write('albumTitle: $albumTitle, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(trackId, title, artistSearchText, albumTitle, payloadJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Track &&
          other.trackId == this.trackId &&
          other.title == this.title &&
          other.artistSearchText == this.artistSearchText &&
          other.albumTitle == this.albumTitle &&
          other.payloadJson == this.payloadJson);
}

class TracksCompanion extends UpdateCompanion<Track> {
  final Value<String> trackId;
  final Value<String> title;
  final Value<String> artistSearchText;
  final Value<String?> albumTitle;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const TracksCompanion({
    this.trackId = const Value.absent(),
    this.title = const Value.absent(),
    this.artistSearchText = const Value.absent(),
    this.albumTitle = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TracksCompanion.insert({
    required String trackId,
    required String title,
    required String artistSearchText,
    this.albumTitle = const Value.absent(),
    required String payloadJson,
    this.rowid = const Value.absent(),
  })  : trackId = Value(trackId),
        title = Value(title),
        artistSearchText = Value(artistSearchText),
        payloadJson = Value(payloadJson);
  static Insertable<Track> custom({
    Expression<String>? trackId,
    Expression<String>? title,
    Expression<String>? artistSearchText,
    Expression<String>? albumTitle,
    Expression<String>? payloadJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (title != null) 'title': title,
      if (artistSearchText != null) 'artist_search_text': artistSearchText,
      if (albumTitle != null) 'album_title': albumTitle,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TracksCompanion copyWith(
      {Value<String>? trackId,
      Value<String>? title,
      Value<String>? artistSearchText,
      Value<String?>? albumTitle,
      Value<String>? payloadJson,
      Value<int>? rowid}) {
    return TracksCompanion(
      trackId: trackId ?? this.trackId,
      title: title ?? this.title,
      artistSearchText: artistSearchText ?? this.artistSearchText,
      albumTitle: albumTitle ?? this.albumTitle,
      payloadJson: payloadJson ?? this.payloadJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artistSearchText.present) {
      map['artist_search_text'] = Variable<String>(artistSearchText.value);
    }
    if (albumTitle.present) {
      map['album_title'] = Variable<String>(albumTitle.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
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
          ..write('title: $title, ')
          ..write('artistSearchText: $artistSearchText, ')
          ..write('albumTitle: $albumTitle, ')
          ..write('payloadJson: $payloadJson, ')
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [playlistId, title, payloadJson];
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
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
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
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class Playlist extends DataClass implements Insertable<Playlist> {
  final String playlistId;
  final String title;
  final String payloadJson;
  const Playlist(
      {required this.playlistId,
      required this.title,
      required this.payloadJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['title'] = Variable<String>(title);
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      playlistId: Value(playlistId),
      title: Value(title),
      payloadJson: Value(payloadJson),
    );
  }

  factory Playlist.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Playlist(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      title: serializer.fromJson<String>(json['title']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'title': serializer.toJson<String>(title),
      'payloadJson': serializer.toJson<String>(payloadJson),
    };
  }

  Playlist copyWith({String? playlistId, String? title, String? payloadJson}) =>
      Playlist(
        playlistId: playlistId ?? this.playlistId,
        title: title ?? this.title,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  @override
  String toString() {
    return (StringBuffer('Playlist(')
          ..write('playlistId: $playlistId, ')
          ..write('title: $title, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, title, payloadJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Playlist &&
          other.playlistId == this.playlistId &&
          other.title == this.title &&
          other.payloadJson == this.payloadJson);
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<String> playlistId;
  final Value<String> title;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const PlaylistsCompanion({
    this.playlistId = const Value.absent(),
    this.title = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    required String playlistId,
    required String title,
    required String payloadJson,
    this.rowid = const Value.absent(),
  })  : playlistId = Value(playlistId),
        title = Value(title),
        payloadJson = Value(payloadJson);
  static Insertable<Playlist> custom({
    Expression<String>? playlistId,
    Expression<String>? title,
    Expression<String>? payloadJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (title != null) 'title': title,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsCompanion copyWith(
      {Value<String>? playlistId,
      Value<String>? title,
      Value<String>? payloadJson,
      Value<int>? rowid}) {
    return PlaylistsCompanion(
      playlistId: playlistId ?? this.playlistId,
      title: title ?? this.title,
      payloadJson: payloadJson ?? this.payloadJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
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
          ..write('title: $title, ')
          ..write('payloadJson: $payloadJson, ')
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
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [albumId, title, artistSearchText, payloadJson];
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
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
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
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      artistSearchText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}artist_search_text'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
    );
  }

  @override
  $AlbumsTable createAlias(String alias) {
    return $AlbumsTable(attachedDatabase, alias);
  }
}

class Album extends DataClass implements Insertable<Album> {
  final String albumId;
  final String title;
  final String artistSearchText;
  final String payloadJson;
  const Album(
      {required this.albumId,
      required this.title,
      required this.artistSearchText,
      required this.payloadJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['album_id'] = Variable<String>(albumId);
    map['title'] = Variable<String>(title);
    map['artist_search_text'] = Variable<String>(artistSearchText);
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  AlbumsCompanion toCompanion(bool nullToAbsent) {
    return AlbumsCompanion(
      albumId: Value(albumId),
      title: Value(title),
      artistSearchText: Value(artistSearchText),
      payloadJson: Value(payloadJson),
    );
  }

  factory Album.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Album(
      albumId: serializer.fromJson<String>(json['albumId']),
      title: serializer.fromJson<String>(json['title']),
      artistSearchText: serializer.fromJson<String>(json['artistSearchText']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'albumId': serializer.toJson<String>(albumId),
      'title': serializer.toJson<String>(title),
      'artistSearchText': serializer.toJson<String>(artistSearchText),
      'payloadJson': serializer.toJson<String>(payloadJson),
    };
  }

  Album copyWith(
          {String? albumId,
          String? title,
          String? artistSearchText,
          String? payloadJson}) =>
      Album(
        albumId: albumId ?? this.albumId,
        title: title ?? this.title,
        artistSearchText: artistSearchText ?? this.artistSearchText,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  @override
  String toString() {
    return (StringBuffer('Album(')
          ..write('albumId: $albumId, ')
          ..write('title: $title, ')
          ..write('artistSearchText: $artistSearchText, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(albumId, title, artistSearchText, payloadJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Album &&
          other.albumId == this.albumId &&
          other.title == this.title &&
          other.artistSearchText == this.artistSearchText &&
          other.payloadJson == this.payloadJson);
}

class AlbumsCompanion extends UpdateCompanion<Album> {
  final Value<String> albumId;
  final Value<String> title;
  final Value<String> artistSearchText;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const AlbumsCompanion({
    this.albumId = const Value.absent(),
    this.title = const Value.absent(),
    this.artistSearchText = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlbumsCompanion.insert({
    required String albumId,
    required String title,
    required String artistSearchText,
    required String payloadJson,
    this.rowid = const Value.absent(),
  })  : albumId = Value(albumId),
        title = Value(title),
        artistSearchText = Value(artistSearchText),
        payloadJson = Value(payloadJson);
  static Insertable<Album> custom({
    Expression<String>? albumId,
    Expression<String>? title,
    Expression<String>? artistSearchText,
    Expression<String>? payloadJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (albumId != null) 'album_id': albumId,
      if (title != null) 'title': title,
      if (artistSearchText != null) 'artist_search_text': artistSearchText,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlbumsCompanion copyWith(
      {Value<String>? albumId,
      Value<String>? title,
      Value<String>? artistSearchText,
      Value<String>? payloadJson,
      Value<int>? rowid}) {
    return AlbumsCompanion(
      albumId: albumId ?? this.albumId,
      title: title ?? this.title,
      artistSearchText: artistSearchText ?? this.artistSearchText,
      payloadJson: payloadJson ?? this.payloadJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artistSearchText.present) {
      map['artist_search_text'] = Variable<String>(artistSearchText.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
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
          ..write('title: $title, ')
          ..write('artistSearchText: $artistSearchText, ')
          ..write('payloadJson: $payloadJson, ')
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [artistId, name, payloadJson];
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
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
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
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
    );
  }

  @override
  $ArtistsTable createAlias(String alias) {
    return $ArtistsTable(attachedDatabase, alias);
  }
}

class Artist extends DataClass implements Insertable<Artist> {
  final String artistId;
  final String name;
  final String payloadJson;
  const Artist(
      {required this.artistId, required this.name, required this.payloadJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['artist_id'] = Variable<String>(artistId);
    map['name'] = Variable<String>(name);
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  ArtistsCompanion toCompanion(bool nullToAbsent) {
    return ArtistsCompanion(
      artistId: Value(artistId),
      name: Value(name),
      payloadJson: Value(payloadJson),
    );
  }

  factory Artist.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Artist(
      artistId: serializer.fromJson<String>(json['artistId']),
      name: serializer.fromJson<String>(json['name']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'artistId': serializer.toJson<String>(artistId),
      'name': serializer.toJson<String>(name),
      'payloadJson': serializer.toJson<String>(payloadJson),
    };
  }

  Artist copyWith({String? artistId, String? name, String? payloadJson}) =>
      Artist(
        artistId: artistId ?? this.artistId,
        name: name ?? this.name,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  @override
  String toString() {
    return (StringBuffer('Artist(')
          ..write('artistId: $artistId, ')
          ..write('name: $name, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(artistId, name, payloadJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Artist &&
          other.artistId == this.artistId &&
          other.name == this.name &&
          other.payloadJson == this.payloadJson);
}

class ArtistsCompanion extends UpdateCompanion<Artist> {
  final Value<String> artistId;
  final Value<String> name;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const ArtistsCompanion({
    this.artistId = const Value.absent(),
    this.name = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArtistsCompanion.insert({
    required String artistId,
    required String name,
    required String payloadJson,
    this.rowid = const Value.absent(),
  })  : artistId = Value(artistId),
        name = Value(name),
        payloadJson = Value(payloadJson);
  static Insertable<Artist> custom({
    Expression<String>? artistId,
    Expression<String>? name,
    Expression<String>? payloadJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (artistId != null) 'artist_id': artistId,
      if (name != null) 'name': name,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArtistsCompanion copyWith(
      {Value<String>? artistId,
      Value<String>? name,
      Value<String>? payloadJson,
      Value<int>? rowid}) {
    return ArtistsCompanion(
      artistId: artistId ?? this.artistId,
      name: name ?? this.name,
      payloadJson: payloadJson ?? this.payloadJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
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
          ..write('name: $name, ')
          ..write('payloadJson: $payloadJson, ')
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
