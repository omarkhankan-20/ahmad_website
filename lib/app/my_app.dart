import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../ui/shared/colors.dart';
import 'my_app_controeller.dart';
import 'routes/app_pages.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Get.put(MyAppController(), permanent: true);

    return GetMaterialApp(
      title: 'أحمد الحسيني',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.espresso,
          surface: AppColors.cream,
        ),
        useMaterial3: true,
      ),
      // Direction is set once at the root instead of per widget.
      builder: (context, child) => Obx(
        () => Directionality(
          textDirection: app.isRtl.value
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
      // initialRoute + getPages replaces `home:`. Keeping `home:` alongside
      // them makes GetX ignore the route table for the first screen.
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      unknownRoute: AppPages.unknownRoute,
    );
  }
}
