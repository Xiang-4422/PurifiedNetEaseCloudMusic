import 'package:get/get.dart';

import 'explore_page_controller.dart';

class ExploreBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => ExplorePageController());
  }

}