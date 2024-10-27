import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:math'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lucky Draw QR Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QRViewExample(),
    );
  }
}

class QRCodeController extends GetxController {
  final Set<String> usedQRs = {}; 
  final RxString result = ''.obs; 
  final RxBool isWinner = false.obs; 
  final Random random = Random(); 
  QRViewController? qrViewController;

  void handleQRResult(Barcode scanData) {
    String qrCodeData = scanData.code!;
    if (usedQRs.contains(qrCodeData)) {
      result.value = "QR Code Already Used!";
    } else {
      isWinner.value = _performLuckyDraw();
      usedQRs.add(qrCodeData);
      result.value = isWinner.value ? "Congratulations! You won the lucky draw!" : "Thank you!";
    }
    qrViewController?.pauseCamera(); 
    showMessage(result.value); 
  }

  bool _performLuckyDraw() {
    return random.nextBool();
  }

  void showMessage(String message) {
    Get.dialog(
      AlertDialog(
        title: const Text("Result"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Get.back();
              qrViewController?.resumeCamera();
            },
          ),
        ],
      ),
    );
  }

  void setQRViewController(QRViewController controller) {
    qrViewController = controller;
  }
}

class QRViewExample extends StatelessWidget {
  const QRViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    final QRCodeController qrCodeController = Get.put(QRCodeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lucky Draw QR Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: GlobalKey(debugLabel: 'QR'),
              onQRViewCreated: (QRViewController controller) {
                qrCodeController.setQRViewController(controller);
                controller.scannedDataStream.listen((scanData) {
                  qrCodeController.handleQRResult(scanData);
                });
              },
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Obx(() => Text(
                  qrCodeController.result.isEmpty ? 'Place QR Code within frame to scan' : 'Data: ${qrCodeController.result.value}')),
            ),
          ),
        ],
      ),
    );
  }
}
