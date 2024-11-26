import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lucky_draw_dashboard/admin/screens/admin_home.dart';
import 'package:lucky_draw_dashboard/admin/screens/read_qr_codes.dart';
import 'package:lucky_draw_dashboard/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: AdminHome(),
      initialRoute: '/',
      routes: {
        '/': (context) => const AdminHome(), // Your home page
        '/readQRCodes': (context) =>
            const ReadQrCodes(), // Define your read QR codes page route
        // Add other routes here
      },
    );
  }
}
