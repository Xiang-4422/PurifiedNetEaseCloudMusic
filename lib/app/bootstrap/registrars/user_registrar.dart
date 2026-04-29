import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/features/auth/auth_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/home_shell_controller.dart';
import 'package:bujuan/features/user/application/user_home_application_service.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:get/get.dart';

class UserRegistrar {
  const UserRegistrar._();

  static void register() {
    Get.lazyPut(() => HomeShellController(), fenix: true);
    Get.lazyPut(() => SettingsController(), fenix: true);
    Get.lazyPut(
      () => UserSessionController(
        repository: Get.find<UserRepository>(),
        box: CacheBox.instance,
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => UserLibraryController(
        repository: Get.find<UserRepository>(),
        sessionController: Get.find<UserSessionController>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => UserHomeApplicationService(
        repository: Get.find<UserRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => RecommendationController(
        homeService: Get.find<UserHomeApplicationService>(),
        sessionController: Get.find<UserSessionController>(),
        libraryController: Get.find<UserLibraryController>(),
        validateLoginStateInBackground: () =>
            Get.find<AuthController>().validateLoginStateInBackgroundIfNeeded(),
      ),
      fenix: true,
    );
  }
}
