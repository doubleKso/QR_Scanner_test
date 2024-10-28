import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lucky_draw_dashboard/admin/screens/admin_home.dart';
import 'package:lucky_draw_dashboard/firebase_options.dart';
// import 'package:luckydraw_test/authentication/auth_check.dart';/
// import 'package:luckydraw_test/authentication/auth_login.dart';
// import 'package:luckydraw_test/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminHome(),
    );
  }
}
