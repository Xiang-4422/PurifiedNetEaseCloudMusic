import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/common/netease_api/src/api/play/bean.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/pages/play_list/playlist_page_view.dart';
import 'package:bujuan/widget/request_widget/request_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../common/netease_api/src/dio_ext.dart';
import '../../common/netease_api/src/netease_handler.dart';
import '../../widget/request_widget/request_loadmore_view.dart';
import '../../widget/simple_extended_image.dart';

class ArtistPageView extends StatefulWidget {
  const ArtistPageView({Key? key}) : super(key: key);

  @override
  State<ArtistPageView> createState() => _ArtistPageViewState();
}

class _ArtistPageViewState extends State<ArtistPageView> with SingleTickerProviderStateMixin {
  late String artistId;
  final List<MediaItem> _items = [];
  final List<Tab> _tabs = [
    const Tab(text: '详情'),
    const Tab(text: '单曲'),
    const Tab(text: '专辑'),
  ];
  TabController? _tabController;

  DioMetaData artistDetailDioMetaData(String artistId) {
    var params = {'id': artistId};
    return DioMetaData(joinUri('/api/artist/head/info/get'), data: params, options: joinOptions());
  }

  DioMetaData artistTopSongListDioMetaData(String artistId) {
    var params = {'id': artistId};
    return DioMetaData(joinUri('/api/artist/top/song'), data: params, options: joinOptions());
  }

  DioMetaData artistAlbumListDioMetaData(String artistId, {int offset = 0, int limit = 30, bool total = true}) {
    var params = {'total': total, 'limit': limit, 'offset': offset};
    return DioMetaData(joinUri('/weapi/artist/albums/$artistId'), data: params, options: joinOptions());
  }

  @override
  void initState() {
    super.initState();
    artistId = context.routeData.queryParams.get("artistId");
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(padding: EdgeInsets.only(top: AppDimensions.appBarHeight + context.mediaQueryPadding.top)),
        Expanded(
          child: DefaultTabController(
            length: _tabs.length,
            child: Column(
              children: [
                TabBar(tabs: _tabs),
                Expanded(
                  child: TabBarView(
                    children: [_buildDetails(), _buildSongList(), _buildAlbumView()],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(padding: EdgeInsets.only(top: AppDimensions.bottomPanelHeaderHeight)),
      ],
    );
  }

  Widget _buildDetails(){
    return RequestWidget<ArtistDetailWrap>(
        dioMetaData: artistDetailDioMetaData(artistId),
        childBuilder: (artistDetails) {
          print('======${jsonEncode(artistDetails.toJson())}');
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: context.width,
                      margin: EdgeInsets.only(top: 150),
                      padding: EdgeInsets.only(left: 15, right: 15, bottom: 25, top: 80),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary, borderRadius: BorderRadius.circular(25)),
                      child: Column(
                        children: [
                          Padding(padding: EdgeInsets.symmetric(vertical: 15),child: Text(
                            artistDetails.data?.artist?.name??"",
                            style: TextStyle(fontSize: 56),
                          ),),
                          Padding(padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('${artistDetails.data?.artist?.albumSize??''} 专辑'),
                              Text('${artistDetails.data?.artist?.musicSize??''} 单曲'),
                              Text('${artistDetails.data?.artist?.mvSize??''} MV'),
                            ],
                          ),)
                        ],
                      ),
                    ),
                    SimpleExtendedImage.avatar(
                      '${artistDetails.data?.artist?.cover??''}?param=300y300',
                      width: 220,
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 30),child: Text(artistDetails.data?.artist?.briefDesc??"",style: TextStyle(color: Theme.of(context).iconTheme.color),),),
              ],
            ),
          );
        });
  }

  Widget _buildSongList() {
    return RequestWidget<ArtistSongListWrap>(
        dioMetaData: artistTopSongListDioMetaData(artistId),
        childBuilder: (artistDetails) {
          _items
            ..clear()
            ..addAll(AppController.to.song2ToMedia(artistDetails.songs ?? []));
          return ListView.builder(
            itemBuilder: (context, index) => SongItem(
              index: index,
              playlist: _items,
            ),
            itemCount: _items.length,
          );
        });
  }

  Widget _buildAlbumView() {
    return RequestLoadMoreWidget<ArtistAlbumListWrap, Album>(
      dioMetaData: artistAlbumListDioMetaData(artistId),
      pageSize: 30,
      childBuilder: (List<Album> albums) {
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20),
          itemBuilder: (context, index) => AlbumItem(album: albums[index]),
          itemCount: albums.length,
        );
      },
      listKey: const ['hotAlbums'],
    );
  }
}
