import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucky_draw_dashboard/pages/lucky_draw_page.dart';
import 'package:lucky_draw_dashboard/pages/user_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(LuckyDrawPage());
              },
              child: const Text("Manage Lucky Draws"),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(AppUserPage());
              },
              child: const Text("Manage App Users"),
            ),
          ],
        ),
      ),
    );
  }
}
