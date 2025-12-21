import 'package:get/get.dart';

import '../../common/netease_api/src/api/play/bean.dart';

class PlayListController<E, T> extends GetxController
    with GetTickerProviderStateMixin {
  late PlayList playList;

  @override
  Future<void> onReady() async {
    super.onReady();
  }
}
