import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/features/radio/radio_data.dart';

class RadioRepository {
  Future<DjRadioPage> fetchSubscribedRadios({
    bool total = true,
    required int offset,
    required int limit,
  }) async {
    final wrap = await NeteaseMusicApi().djRadioSubList(
      total: total,
      offset: offset,
      limit: limit,
    );
    final radios = wrap.djRadios;
    return DjRadioPage(
      items: radios
          .map(
            (radio) => RadioSummaryData(
              id: radio.id,
              name: radio.name,
              coverUrl: radio.picUrl,
              lastProgramName: radio.lastProgramName ?? '',
            ),
          )
          .toList(),
      hasMore: radios.length >= limit,
      nextOffset: offset + radios.length,
    );
  }

  Future<DjProgramPage> fetchPrograms(
    String radioId, {
    required int offset,
    required int limit,
    required bool asc,
  }) async {
    final wrap = await NeteaseMusicApi().djProgramList(
      radioId,
      offset: offset,
      limit: limit,
      asc: asc,
    );
    final programs = wrap.programs;
    return DjProgramPage(
      items: programs
          .map(
            (program) => RadioProgramData(
              id: program.id,
              mainTrackId: '${program.mainTrackId}',
              title: program.mainSong.name ?? '',
              coverUrl: program.coverUrl ?? '',
              artistName: program.dj.nickname ?? '',
              albumTitle: program.mainSong.album?.name ?? '',
              durationMs: program.duration ?? 0,
            ),
          )
          .toList(),
      hasMore: programs.length >= limit,
      nextOffset: offset + programs.length,
    );
  }

  List<MediaItem> mapProgramsToMediaItems(
    List<RadioProgramData> programs, {
    required List<int> likedSongIds,
  }) {
    return programs
        .map((program) => MediaItem(
              id: program.mainTrackId,
              title: program.title,
              artUri: Uri.tryParse(program.coverUrl),
              artist: program.artistName,
              album: program.albumTitle,
              duration: Duration(milliseconds: program.durationMs),
              extras: {
                'type': MediaType.playlist.name,
                'image': program.coverUrl,
                'liked': likedSongIds.contains(int.tryParse(program.id)),
                'mv': 0,
              },
            ))
        .toList();
  }
}

class DjRadioPage {
  const DjRadioPage({
    required this.items,
    required this.hasMore,
    required this.nextOffset,
  });

  final List<RadioSummaryData> items;
  final bool hasMore;
  final int nextOffset;
}

class DjProgramPage {
  const DjProgramPage({
    required this.items,
    required this.hasMore,
    required this.nextOffset,
  });

  final List<RadioProgramData> items;
  final bool hasMore;
  final int nextOffset;
}
