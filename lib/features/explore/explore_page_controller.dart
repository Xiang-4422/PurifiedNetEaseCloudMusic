import 'package:audio_service/audio_service.dart';
import 'package:bujuan/features/explore/explore_repository.dart';
import 'package:bujuan/features/explore/ranking_playlist_data.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playlist/playlist_summary_data.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/shell/app_controller.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 维护探索页榜单、分类歌单和加载状态。
///
/// 这里暂时仍直接驱动部分旧页面交互，是因为探索页还没有完整拆成独立 view model。
class ExplorePageController extends GetxController {
  final ExploreRepository _repository = ExploreRepository();
  final PlaylistRepository _playlistRepository = PlaylistRepository();

  final Map<String, List<RankingPlaylistData>> topPlayListCategory = {
    "官方榜": [
      const RankingPlaylistData(name: '云音乐新歌榜', id: '3779629'),
      const RankingPlaylistData(name: '云音乐热歌榜', id: '3778678'),
      const RankingPlaylistData(name: '云音乐原创榜', id: '2884035'),
      const RankingPlaylistData(name: '云音乐飙升榜', id: '19723756'),
      const RankingPlaylistData(name: '云音乐电音榜', id: '10520166'),
    ],
    "全球榜": [
      const RankingPlaylistData(name: 'UK排行榜周榜', id: '180106'),
      const RankingPlaylistData(name: '美国Billboard周榜', id: '60198'),
      const RankingPlaylistData(name: 'KTV嗨榜', id: '21845217'),
      const RankingPlaylistData(name: 'iTunes榜', id: '11641012'),
      const RankingPlaylistData(name: 'Hit FM Top榜', id: '120001'),
      const RankingPlaylistData(name: '日本Oricon周榜', id: '60131'),
      const RankingPlaylistData(name: '韩国Melon排行榜周榜', id: '3733003'),
      const RankingPlaylistData(name: '韩国Mnet排行榜周榜', id: '60255'),
      const RankingPlaylistData(name: '韩国Melon原声周榜', id: '46772709'),
      const RankingPlaylistData(name: '中国TOP排行榜(港台榜)', id: '112504'),
      const RankingPlaylistData(name: '中国TOP排行榜(内地榜)', id: '64016'),
      const RankingPlaylistData(name: '香港电台中文歌曲龙虎榜', id: '10169002'),
      const RankingPlaylistData(name: '华语金曲榜', id: '4395559'),
      const RankingPlaylistData(name: '中国嘻哈榜', id: '1899724'),
      const RankingPlaylistData(name: '法国 NRJ EuroHot 30周榜', id: '27135204'),
      const RankingPlaylistData(name: '台湾Hito排行榜', id: '112463'),
      const RankingPlaylistData(name: 'Beatport全球电子舞曲榜', id: '3812895'),
    ],
    "语种榜": [
      const RankingPlaylistData(name: '云音乐欧美热歌榜', id: '2809513713'),
      const RankingPlaylistData(name: '云音乐欧美新歌榜', id: '2809577409'),
    ],
    "精选榜": [
      const RankingPlaylistData(name: '云音乐ACG音乐榜', id: '71385702'),
      const RankingPlaylistData(name: '云音乐说唱榜', id: '991319590'),
      const RankingPlaylistData(name: '云音乐古典音乐榜', id: '71384707'),
      const RankingPlaylistData(name: '云音乐电音榜', id: '1978921795'),
      const RankingPlaylistData(name: '抖音排行榜', id: '2250011882'),
      const RankingPlaylistData(name: '新声榜', id: '2617766278'),
      const RankingPlaylistData(name: '云音乐韩语榜', id: '745956260'),
      const RankingPlaylistData(name: '英国Q杂志中文版周榜', id: '2023401535'),
      const RankingPlaylistData(name: '电竞音乐榜', id: '2006508653'),
      const RankingPlaylistData(name: '说唱TOP榜', id: '2847251561'),
      const RankingPlaylistData(name: '云音乐ACG动画榜', id: '3001835560'),
      const RankingPlaylistData(name: '云音乐ACG游戏榜', id: '3001795926'),
      const RankingPlaylistData(name: '云音乐ACG VOCALOID榜', id: '3001890046'),
    ]
  };

  RxList tagCategorys = <String>[].obs;
  RxMap tags = {}.obs;

  RxString curTagCategoryName = "".obs;
  RxString curTag = "全部".obs;

  RxBool showChooseCategory = false.obs;
  RxBool showChoosePlayList = false.obs;

  List<String> topPlayListCategoryNames = [];
  RxString curTopPlayListCategoryName = "".obs;
  RxList<RankingPlaylistData> curCategoryTopPlayLists =
      <RankingPlaylistData>[].obs;
  RxString curTopPlayListName = "".obs;
  RxString curTopPlayListId = "".obs;
  RxList<MediaItem> curTopPlayListSongs = <MediaItem>[].obs;
  RxList<PlaylistSummaryData> playLists = <PlaylistSummaryData>[].obs;

  RxBool loading = true.obs;

  RefreshController refreshController = RefreshController();

  @override
  void onReady() async {
    super.onReady();
    initData();
    await updateData();
    loading.value = false;
  }

  initData() async {
    topPlayListCategoryNames.addAll(topPlayListCategory.keys);
    curTopPlayListCategoryName.value = topPlayListCategoryNames[0];
    curCategoryTopPlayLists
        .addAll(topPlayListCategory[curTopPlayListCategoryName.value]!);
    curTopPlayListName.value = curCategoryTopPlayLists[0].name;
    curTopPlayListId.value = curCategoryTopPlayLists[0].id;

    _repository.fetchPlaylistCatalogue().then((value) {
      tagCategorys.addAll(value.categoryNames);
      tags.assignAll(value.tagsByCategory);
    });
  }

  updateData() async {
    await updatePlayLists();
    await updateRankingPlayListSongs();
    refreshController.refreshCompleted();
    refreshController.resetNoData();
  }

  updatePlayLists() async {
    final data = await _repository.fetchCategoryPlaylists(curTag.value);
    playLists
      ..clear()
      ..addAll(data);
  }

  changeCurRankingPlayList(String rankingPlayListid) {
    curTopPlayListId.value = rankingPlayListid;
    updateRankingPlayListSongs();
  }

  updateRankingPlayListSongs({int offset = 0, limit = 10}) async {
    if (offset == 0) curTopPlayListSongs.clear();
    final songs = await _playlistRepository.fetchPlaylistSongs(
      playlistId: curTopPlayListId.value,
      likedSongIds: AppController.to.likedSongIds.toList(),
      offset: offset,
      limit: limit,
    );
    curTopPlayListSongs.addAll(songs);
    if (songs.length < 10) {
      refreshController.loadNoData();
    } else {
      refreshController.loadComplete();
    }
  }

  playCurRankingPlayListSongs() async {
    await updateRankingPlayListSongs(
        offset: curTopPlayListSongs.length, limit: -1);
    await PlayerController.to.playPlaylist(
      curTopPlayListSongs,
      0,
      playListName: curTopPlayListName.value,
    );
  }

  changeCurTopPlayListCategory(String name) {
    curTopPlayListCategoryName.value = name;
    showChooseCategory.value = false;
    showChoosePlayList.value = false;

    curCategoryTopPlayLists.clear();
    curCategoryTopPlayLists
        .addAll(topPlayListCategory[curTopPlayListCategoryName.value]!);
    changeCurTopPlayList(curCategoryTopPlayLists[0]);
  }

  changeCurTopPlayList(RankingPlaylistData topPlayList) {
    curTopPlayListName.value = topPlayList.name;
    curTopPlayListId.value = topPlayList.id;
    showChooseCategory.value = false;
    showChoosePlayList.value = false;

    updateRankingPlayListSongs();
  }
}
