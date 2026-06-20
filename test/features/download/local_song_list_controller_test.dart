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

    test('ignores stale refresh after newer refresh completes', () async {
      final oldRefresh = Completer<List<LocalSongEntry>>();
      final newRefresh = Completer<List<LocalSongEntry>>();
      final musicDataRepository = _FakeMusicDataRepository()
        ..enqueueLocalSongsFuture(oldRefresh.future)
        ..enqueueLocalSongsFuture(newRefresh.future);
      final controller = LocalSongListController(
        musicDataRepository: musicDataRepository,
        downloadRepository: _FakeDownloadRepository(),
      );
      addTearDown(controller.dispose);

      final oldRefreshFuture = controller.refresh();
      await Future<void>.delayed(Duration.zero);
      final newRefreshFuture = controller.refresh();
      await Future<void>.delayed(Duration.zero);

      newRefresh.complete([_entry('fresh')]);
      await newRefreshFuture;

      expect(controller.state.value.status, LoadStatus.data);
      expect(_titles(controller.state.value), ['Track fresh']);

      oldRefresh.complete([_entry('stale')]);
      await oldRefreshFuture;

      expect(controller.state.value.status, LoadStatus.data);
      expect(_titles(controller.state.value), ['Track fresh']);
    });

    test('ignores refresh completion after dispose', () async {
      final refresh = Completer<List<LocalSongEntry>>();
      final musicDataRepository = _FakeMusicDataRepository()..enqueueLocalSongsFuture(refresh.future);
      final controller = LocalSongListController(
        musicDataRepository: musicDataRepository,
        downloadRepository: _FakeDownloadRepository(),
      );

      final refreshFuture = controller.refresh();
      await Future<void>.delayed(Duration.zero);
      controller.dispose();

      refresh.complete([_entry('fresh')]);

      await refreshFuture;
    });

    test('removes deleted local track from visible fallback when refresh fails', () async {
      final error = StateError('refresh failed');
      final musicDataRepository = _FakeMusicDataRepository()
        ..enqueueLocalSongs([
          _entry('removed'),
          _entry('kept'),
        ])
        ..enqueueLocalSongsError(error);
      final downloadRepository = _FakeDownloadRepository();
      final controller = LocalSongListController(
        musicDataRepository: musicDataRepository,
        downloadRepository: downloadRepository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      await controller.removeLocalTrack('netease:removed');

      expect(downloadRepository.removedTrackIds, ['netease:removed']);
      expect(controller.state.value.status, LoadStatus.error);
      expect(controller.state.value.error, same(error));
      expect(_titles(controller.state.value), ['Track kept']);
    });

    test('removes playback cache entries from visible fallback when refresh fails', () async {
      final error = StateError('refresh failed');
      final musicDataRepository = _FakeMusicDataRepository()
        ..enqueueLocalSongs([
          _entry('cache', origin: TrackResourceOrigin.playbackCache),
          _entry('download'),
        ])
        ..enqueueLocalSongsError(error);
      final downloadRepository = _FakeDownloadRepository();
      final controller = LocalSongListController(
        musicDataRepository: musicDataRepository,
        downloadRepository: downloadRepository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      await controller.clearPlaybackCache();

      expect(downloadRepository.clearPlaybackCacheCount, 1);
      expect(controller.state.value.status, LoadStatus.error);
      expect(controller.state.value.error, same(error));
      expect(_titles(controller.state.value), ['Track download']);
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
  final List<Future<List<LocalSongEntry>> Function()> _responses = [];

  void enqueueLocalSongs(List<LocalSongEntry> entries) {
    _responses.add(() => Future<List<LocalSongEntry>>.value(entries));
  }

  void enqueueLocalSongsFuture(Future<List<LocalSongEntry>> future) {
    _responses.add(() => future);
  }

  void enqueueLocalSongsError(Object error) {
    _responses.add(() => Future<List<LocalSongEntry>>.error(error, StackTrace.current));
  }

  @override
  Future<List<LocalSongEntry>> getLocalSongs({
    Set<TrackResourceOrigin>? origins,
  }) {
    if (_responses.isEmpty) {
      return Future<List<LocalSongEntry>>.value(const []);
    }
    return _responses.removeAt(0)();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDownloadRepository implements DownloadRepository {
  final List<String> removedTrackIds = [];
  int clearPlaybackCacheCount = 0;

  @override
  Future<void> removeLocalTrack(String trackId) async {
    removedTrackIds.add(trackId);
  }

  @override
  Future<void> clearPlaybackCache() async {
    clearPlaybackCacheCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
