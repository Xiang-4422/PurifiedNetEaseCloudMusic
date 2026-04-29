import 'package:bujuan/app/bootstrap/registrars/feature_controller_registrar.dart';
import 'package:bujuan/app/bootstrap/registrars/infrastructure_registrar.dart';
import 'package:bujuan/app/bootstrap/registrars/playback_registrar.dart';
import 'package:bujuan/app/bootstrap/registrars/presentation_adapter_registrar.dart';
import 'package:bujuan/app/bootstrap/registrars/user_registrar.dart';
import 'package:get/get.dart';

class AppBinding extends Bindings {
  AppBinding();

  static Future<void> initInfrastructure() {
    return InfrastructureRegistrar.init();
  }

  @override
  void dependencies() {
    UserRegistrar.register();
    PlaybackRegistrar.register();
    PresentationAdapterRegistrar.register();
    FeatureControllerRegistrar.register();
  }
}
