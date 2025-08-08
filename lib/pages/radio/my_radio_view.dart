
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/routes/router.gr.dart';
import 'package:bujuan/widget/request_widget/request_loadmore_view.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../common/netease_api/src/api/dj/bean.dart';
import '../../common/netease_api/src/dio_ext.dart';
import '../../common/netease_api/src/netease_handler.dart';
import '../../widget/simple_extended_image.dart';

class MyRadioView extends StatefulWidget {
  const MyRadioView({Key? key}) : super(key: key);

  @override
  State<MyRadioView> createState() => _MyRadioViewState();
}

class _MyRadioViewState extends State<MyRadioView> {
  DioMetaData djRadioSubListDioMetaData({bool total = true, int offset = 0, int limit = 30}) {
    var params = {'total': total, 'limit': limit, 'offset': offset};
    return DioMetaData(joinUri('/weapi/djradio/get/subed'), data: params, options: joinOptions());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: AppDimensions.appBarHeight + context.mediaQueryPadding.top,
        ),
        Expanded(
          child: RequestLoadMoreWidget<DjRadioListWrap, DjRadio>(
              listKey: const ['djRadios'],
              dioMetaData: djRadioSubListDioMetaData(),
              childBuilder: (List<DjRadio> list) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) => _buildItem(list[index]),
                  itemCount: list.length,
                );
              }),
        ),
        Container(
          height: AppDimensions.bottomPanelHeaderHeight,
        ),
      ],
    );
  }

  Widget _buildItem(DjRadio data) {
    return InkWell(
        child: SizedBox(
          height: 120,
          child: Row(
            children: [
              SimpleExtendedImage(
                '${data.picUrl ?? ''}?param=200y200',
                width: 85,
                height: 85,
                borderRadius: BorderRadius.circular(10),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data.name,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                    Text(
                      data.lastProgramName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 26, color: Colors.grey),
                    )
                  ],
                ),
              ))
            ],
          ),
        ),
        onTap: () {
          context.router.push(const RadioDetailsView().copyWith(args: data));
        });
  }
}
