import 'package:get/get.dart';
import 'package:juno/Info_Handler/app_info.dart';

Future<void> registerControllers() async {
  Get.put(AppInfoController());
}
