import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jocs/Dashboard/Controllers/dashboard_controller.dart';
import 'package:jocs/Dashboard/Layout/top_menu.dart';
import 'package:jocs/Dashboard/Screens/main_screen.dart';

/// Screens Layout Contains All the widget Except Navigation Menu that are
/// displayed on the screen.
///
/// To Lay the screen [TopMenu] and [MainScreen] are put in a column.
class ScreensLayout extends StatelessWidget {
  ScreensLayout({Key? key}) : super(key: key);
  final DashboardController _dashboardController =
  Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(()=> Padding(
        padding: _dashboardController.mobileDisplay.value? const EdgeInsets.only(left: 0.0):const EdgeInsets.only(left: 8.0),
        child: Column(
          children: [
            TopMenu(),
            Expanded(
                child: MainScreen()
            )
          ],
        ),
      ),
    );
  }
}
