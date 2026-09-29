import 'package:ahmad_website/core/data/repository/storage_repository.dart';
import 'package:ahmad_website/core/services/app_data_service.dart';
import 'package:ahmad_website/core/services/auth_service.dart';
import 'package:ahmad_website/core/services/courses_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/my_app.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await GetStorage.init();
  Get.put(StorageRepository(), permanent: true);
  Get.put(AuthService(), permanent: true);
  Get.put(AppDataService(), permanent: true);
  Get.put(CoursesService(), permanent: true);
  runApp(const MyApp());
}
