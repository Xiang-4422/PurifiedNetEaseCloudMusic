import 'package:bujuan/pages/user/personal_page_controller.dart';
import 'package:get/get.dart';

class UserBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => PersonalPageController());
  }
}