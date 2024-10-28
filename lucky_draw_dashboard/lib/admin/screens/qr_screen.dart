// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucky_draw_dashboard/admin/screens/create_qr_codes.dart';
import 'package:lucky_draw_dashboard/admin/screens/read_qr_codes.dart';
import 'package:lucky_draw_dashboard/widgets/widgets.dart';

// import 'package:luckydraw_test/admin/services/firestore_service.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:uuid/uuid.dart';

class QrScreens extends StatefulWidget {
  const QrScreens({super.key});
  @override
  State<QrScreens> createState() => _QrScreensState();
}

class _QrScreensState extends State<QrScreens> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ElevatedButton(
              //   onPressed: () {
              //     // Navigate to Create QR Codes page
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => const CreateQrCodes()),
              //     );
              //   },
              //   child: const Text('Create QR Codes'),
              // ),
              buildFilledButton(
                  label: ("Create QR Codes"),
                  color: Colors.red,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateQrCodes()),
                    );
                  }),
              SizedBox(
                height: 10,
              ),
              buildFilledButton(
                  label: "Read QR Codes",
                  color: Colors.red,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReadQrCodes()),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
