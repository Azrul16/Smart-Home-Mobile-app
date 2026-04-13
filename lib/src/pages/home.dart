import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:smart_home_app/src/controllers/home_controller.dart';
import 'package:smart_home_app/src/pages/home_page.dart';
import 'package:smart_home_app/src/pages/power_user.dart';
import 'package:smart_home_app/src/widgets/hex_color.dart';

import 'smart_home.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final HomeController controller = Get.find<HomeController>();

  final List<Widget> _screens = [
    HomePage(),
    SmartHome(),
    PowerUser(),
  ];

  BottomNavigationBarItem _item(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = Colors.white;
    final backgroundColor = HexColor('#4C7380');

    return GetBuilder<HomeController>(
      builder: (controller) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          final shouldLeave = controller.handleShellBack();
          if (shouldLeave) {
            Navigator.of(context).maybePop();
          }
        },
        child: Scaffold(
          body: IndexedStack(
            index: controller.currentNavIndex,
            children: _screens,
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: controller.currentNavIndex,
                onTap: controller.updateNavIndex,
                backgroundColor: backgroundColor,
                selectedItemColor: activeColor,
                unselectedItemColor:
                    CupertinoColors.white.withValues(alpha: 0.7),
                selectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w500),
                items: [
                  _item(EvaIcons.home, 'Home'),
                  _item(EvaIcons.optionsOutline, 'Smart'),
                  _item(EvaIcons.pieChart, 'Usage'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
