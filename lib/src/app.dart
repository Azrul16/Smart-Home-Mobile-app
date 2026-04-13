import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'config/app_them.dart';
import 'controllers/home_controller.dart';
import 'pages/home.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.appTheme,
      initialBinding: BindingsBuilder(() {
        Get.put(HomeController());
      }),
      home: const Home(),
    );
  }
}
