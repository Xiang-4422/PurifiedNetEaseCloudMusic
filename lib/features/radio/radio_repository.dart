import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/data/netease/api/netease_music_api.dart';

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
      items: radios,
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
      items: programs,
      hasMore: programs.length >= limit,
      nextOffset: offset + programs.length,
    );
  }

  List<MediaItem> mapProgramsToMediaItems(
    List<DjProgram> programs, {
    required List<int> likedSongIds,
  }) {
    return programs
        .map((program) => MediaItem(
              id: '${program.mainTrackId}',
              title: program.mainSong.name ?? '',
              artUri: Uri.parse(program.mainSong.album?.picUrl ?? ''),
              artist: program.dj.nickname,
              album: program.mainSong.album?.name,
              duration: Duration(milliseconds: program.duration ?? 0),
              extras: {
                'type': MediaType.playlist.name,
                'image': program.coverUrl ?? '',
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

  final List<DjRadio> items;
  final bool hasMore;
  final int nextOffset;
}

class DjProgramPage {
  const DjProgramPage({
    required this.items,
    required this.hasMore,
    required this.nextOffset,
  });

  final List<DjProgram> items;
  final bool hasMore;
  final int nextOffset;
}
