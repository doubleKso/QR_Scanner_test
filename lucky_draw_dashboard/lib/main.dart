import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucky_draw_dashboard/firebase_options.dart';
import 'package:lucky_draw_dashboard/pages/dashboard_page.dart';
import 'package:lucky_draw_dashboard/pages/lucky_draw_page.dart';
import 'package:lucky_draw_dashboard/pages/user_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lucky Draw Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const DashboardPage()),
        GetPage(name: '/lucky_draw', page: () => LuckyDrawPage()),
        GetPage(name: '/app_users', page: () => AppUserPage()),
      ],
    );
  }
}
