import 'package:audio_service/audio_service.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/core/network/request_repository.dart';
import 'package:bujuan/generated/json/base/json_convert_content.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../common/netease_api/src/api/play/bean.dart';
import '../../common/netease_api/src/dio_ext.dart';
import '../../common/netease_api/src/netease_handler.dart';
import 'request_loadmore_view.dart';

typedef RequestChildBuilder<T> = Widget Function(List<T> data);
typedef OnData<T> = Function(T data);

class RequestPlaylistLoadMoreWidget extends StatefulWidget {
  final RequestChildBuilder<MediaItem> childBuilder;
  final RequestRefreshController? refreshController;
  final bool enableLoad;
  final List<String> ids;
  final int pageSize;
  final ScrollController? scrollController;
  final OnData<SongDetailWrap>? onData;
  final List<String> listKey;
  final String? lastField;

  const RequestPlaylistLoadMoreWidget({
    Key? key,
    required this.ids,
    required this.childBuilder,
    this.refreshController,
    this.enableLoad = true,
    this.onData,
    required this.listKey,
    this.scrollController,
    this.pageSize = 30,
    this.lastField,
  }) : super(key: key);

  @override
  State<RequestPlaylistLoadMoreWidget> createState() =>
      RequestPlaylistLoadMoreWidgetState();
}

class RequestPlaylistLoadMoreWidgetState
    extends State<RequestPlaylistLoadMoreWidget> with RefreshState {
  final RequestRepository _repository = RequestRepository();
  bool _loading = true;
  bool _error = false;
  bool _empty = false;
  DioMetaData? dioMetaData;
  List<MediaItem> list = [];
  final RefreshController _refreshController = RefreshController();
  int pageNum = 0;
  CancelToken cancelToken = CancelToken();
  bool noMore = false;
  Map<String, dynamic>? map;

  @override
  void initState() {
    dioMetaData = songDetailDioMetaData(widget.ids);
    super.initState();
    _bindController();
  }

  DioMetaData songDetailDioMetaData(List<String> songIds) {
    var params = setPage();
    return DioMetaData(joinUri('/api/v3/song/detail'),
        data: params, options: joinOptions());
  }

  void _bindController() {
    widget.refreshController?.bindEasyRefreshState(this);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    widget.refreshController?.dispose();
    cancelToken.cancel();
    super.dispose();
  }

  Map<String, dynamic>? setPage() {
    int start = 0;
    int end = 0;
    if (pageNum * widget.pageSize > widget.ids.length - 1) {
      return null;
    }
    start = pageNum * widget.pageSize;
    end = pageNum * widget.pageSize + widget.pageSize;
    if (pageNum * widget.pageSize + widget.pageSize > widget.ids.length - 1) {
      end = widget.ids.length;
    }
    return {
      'c':
          '[${widget.ids.sublist(start, end).map((id) => '{"id":$id}').join(',')}]',
    };
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const LoadingView()
        : _empty
            ? const EmptyView()
            : _error
                ? const ErrorView()
                : SmartRefresher(
                    enablePullUp: widget.enableLoad,
                    scrollController: widget.scrollController,
                    header: WaterDropHeader(
                      waterDropColor: Theme.of(context).colorScheme.onSecondary,
                      refresh: CupertinoActivityIndicator(
                        color: Theme.of(context).iconTheme.color,
                      ),
                      complete: RichText(
                          text: TextSpan(children: [
                        const WidgetSpan(
                            child: Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Icon(TablerIcons.mood_unamused),
                        )),
                        TextSpan(
                            text: '呼～  搞定',
                            style: TextStyle(
                                color: Theme.of(context).iconTheme.color))
                      ])),
                      idleIcon: Icon(
                        TablerIcons.refresh,
                        size: 15,
                        color: Theme.of(context).cardColor,
                      ),
                    ),
                    controller: _refreshController,
                    onRefresh: () async {
                      noMore = false;
                      _refreshController.resetNoData();
                      pageNum = 0;
                      dioMetaData?.data = setPage();
                      callRefresh();
                    },
                    onLoading: () async {
                      if (noMore) return;
                      pageNum++;
                      dioMetaData?.data = setPage();
                      callRefresh();
                    },
                    child: widget.childBuilder(list),
                  );
  }

  @override
  Future<void> callRefresh() async {
    if (widget.ids.isEmpty) {
      setState(() {
        _loading = false;
        _empty = true;
      });
      return;
    }
    try {
      Response value =
          await _repository.post(dioMetaData!, cancelToken: cancelToken);
      int code = value.data['code'];
      if (widget.listKey.length == 2) {
        map = value.data[widget.listKey.first];
      }
      _loading = false;
      if (code == 200) {
        _error = false;
        SongDetailWrap data =
            JsonConvert.fromJsonAsT<SongDetailWrap>(value.data)
                as SongDetailWrap;
        if (widget.onData != null) {
          widget.onData?.call(data);
        }
        if (pageNum == 0) list.clear();
        setState(() {
          list.addAll(AppController.to.song2ToMedia(data.songs ?? []));
          _empty = list.isEmpty;
        });
        if (pageNum == 0) {
          _refreshController.refreshCompleted();
        } else {
          _refreshController.loadComplete();
        }
        if ((data.songs ?? []).length < widget.pageSize) {
          noMore = true;
          _refreshController.loadNoData();
        }
      } else {
        _error = true;
        if (mounted) setState(() {});
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  void setParams(DioMetaData params) {
    setState(() {
      _loading = true;
      _error = false;
      _empty = false;
    });
    pageNum = 0;
    dioMetaData = params;
  }
}
