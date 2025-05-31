import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomePageController());
  }
}
