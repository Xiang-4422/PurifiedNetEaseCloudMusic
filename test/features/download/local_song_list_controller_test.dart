import 'dart:async';

import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/local_song_entry.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/download/local_song_list_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalSongListController', () {
    test('keeps visible songs while refresh is loading and after refresh fails', () async {
      final musicDataRepository = _FakeMusicDataRepository()..enqueueLocalSongs([_entry('cached')]);
      final controller = LocalSongListController(
        musicDataRepository: musicDataRepository,
        downloadRepository: _FakeDownloadRepository(),
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      expect(controller.state.value.status, LoadStatus.data);
      expect(_titles(controller.state.value), ['Track cached']);

      final refresh = Completer<List<LocalSongEntry>>();
      final error = StateError('offline');
      musicDataRepository.enqueueLocalSongsFuture(refresh.future);
      final refreshFuture = controller.refresh();

      expect(controller.state.value.status, LoadStatus.loading);
      expect(_titles(controller.state.value), ['Track cached']);

      refresh.completeError(error, StackTrace.current);
      await refreshFuture;

      expect(controller.state.value.status, LoadStatus.error);
      expect(controller.state.value.error, same(error));
      expect(_titles(controller.state.value), ['Track cached']);
      expect(controller.state.value.hasData, isTrue);
    });

    test('uses initial error when no local songs are visible', () async {
      final error = StateError('offline');
      final musicDataRepository = _FakeMusicDataRepository()..enqueueLocalSongsError(error);
      final controller = LocalSongListController(
        musicDataRepository: musicDataRepository,
        downloadRepository: _FakeDownloadRepository(),
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();

      expect(controller.state.value.status, LoadStatus.error);
      expect(controller.state.value.error, same(error));
      expect(controller.state.value.data, isNull);
      expect(controller.state.value.hasData, isFalse);
    });
  });
}

List<String> _titles(LoadState<List<LocalSongEntry>> state) {
  return state.data?.map((entry) => entry.track.title).toList() ?? const <String>[];
}

LocalSongEntry _entry(
  String id, {
  TrackResourceOrigin origin = TrackResourceOrigin.managedDownload,
}) {
  final resource = _audioResource(id, origin: origin);
  return LocalSongEntry(
    track: Track(
      id: 'netease:$id',
      sourceType: SourceType.netease,
      sourceId: id,
      title: 'Track $id',
      artistNames: const ['Artist'],
    ),
    resources: TrackResourceBundle(audio: resource),
    origin: origin,
    totalSizeBytes: resource.sizeBytes,
  );
}

LocalResourceEntry _audioResource(
  String id, {
  required TrackResourceOrigin origin,
}) {
  final now = DateTime(2026);
  return LocalResourceEntry(
    trackId: 'netease:$id',
    kind: LocalResourceKind.audio,
    path: '/cache/$id.mp3',
    origin: origin,
    sizeBytes: 1,
    createdAt: now,
    lastAccessedAt: now,
  );
}

class _FakeMusicDataRepository implements MusicDataRepository {
  final List<Future<List<LocalSongEntry>>> _responses = [];

  void enqueueLocalSongs(List<LocalSongEntry> entries) {
    _responses.add(Future<List<LocalSongEntry>>.value(entries));
  }

  void enqueueLocalSongsFuture(Future<List<LocalSongEntry>> future) {
    _responses.add(future);
  }

  void enqueueLocalSongsError(Object error) {
    _responses.add(Future<List<LocalSongEntry>>.error(error, StackTrace.current));
  }

  @override
  Future<List<LocalSongEntry>> getLocalSongs({
    Set<TrackResourceOrigin>? origins,
  }) {
    if (_responses.isEmpty) {
      return Future<List<LocalSongEntry>>.value(const []);
    }
    return _responses.removeAt(0);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDownloadRepository implements DownloadRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
