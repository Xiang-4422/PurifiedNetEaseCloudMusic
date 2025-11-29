import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/constants/other.dart';
import '../../common/netease_api/src/api/bean.dart';
import '../../common/netease_api/src/api/play/bean.dart';
import '../../common/netease_api/src/netease_api.dart';

class PlayListController<E, T> extends GetxController with GetTickerProviderStateMixin{

  late PlayList playList;



  @override
  Future<void> onReady() async {
    super.onReady();

  }


}
