import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucky_draw_dashboard/widgets/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:html' as html;

class DetailPage extends StatelessWidget {
  final String documentId;
  final ScreenshotController _screenshotController = ScreenshotController();
  DetailPage({super.key, required this.documentId});

  Stream<Map<String, dynamic>?> _getDocumentStream() async* {
    try {
      await for (DocumentSnapshot docSnapshot in FirebaseFirestore.instance
          .collection('QrCodes')
          .doc(documentId)
          .snapshots()) {
        if (!docSnapshot.exists) {
          yield null;
        } else {
          Map<String, dynamic> data =
              docSnapshot.data() as Map<String, dynamic>;
          if (data['winner'] != null) {
            String winnerId = data['winner'];
            DocumentSnapshot winnerSnapshot = await FirebaseFirestore.instance
                .collection('Users')
                .doc(winnerId)
                .get();

            data['winner'] = winnerSnapshot.exists
                ? winnerSnapshot['username'] ?? 'Unknown'
                : 'Unknown';
          } else {
            data['winner'] = '-';
          }

          yield data;
        }
      }
    } catch (e) {
      print("Error fetching document details: $e");
      yield null;
    }
  }

  void _downloadImage(Uint8List imageBytes) {
    final base64Image = 'data:image/png;base64,${base64Encode(imageBytes)}';
    final anchor = html.AnchorElement(href: base64Image)
      ..target = 'blank'
      ..download = "QR Code:" + '$documentId'
      ..click();
    anchor.remove();
  }

  void _captureAndDownloadImage() {
    _screenshotController.capture().then((Uint8List? imageBytes) {
      if (imageBytes != null) {
        _downloadImage(imageBytes);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SelectableText(
          "QR Code ID: $documentId",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 25),
            child: buildOutlinedButton(
                label: "Save QR Code",
                color: Colors.green,
                onPressed: _captureAndDownloadImage),
          )
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _getDocumentStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.grey,
                color: Colors.red,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No data"));
          }

          final data = snapshot.data!;
          DateTime createdDate = data['timestamp'].toDate();
          DateTime expiredDate = data['expiredDate'].toDate();

          return Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.33,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Card(
                  elevation: 4.0,
                  color: Colors.red.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Screenshot(
                            controller: _screenshotController,
                            child: QrImageView(
                              data: data['data'],
                              version: QrVersions.auto,
                              embeddedImage: const AssetImage(
                                  'assets/images/AxraWithBackground.jpg'),
                              embeddedImageStyle: const QrEmbeddedImageStyle(
                                  size: Size(30, 30)),
                              size: 200,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Winner: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                data['winner'] ?? '-',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              )),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Created Date: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              DateFormat.yMMMMEEEEd()
                                  .add_jm()
                                  .format(createdDate),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Prize: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(data['prize']),
                          ),
                          const SizedBox(height: 10),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Expired Date: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              DateFormat.yMMMMEEEEd()
                                  .add_jm()
                                  .format(expiredDate),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              data['scannedDate'] != null
                                  ? "Scanned Date: "
                                  : 'Scanned Date: -',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              data['scannedDate'] != null
                                  ? DateFormat.yMMMMEEEEd()
                                      .add_jm()
                                      .format(data['scannedDate'].toDate())
                                  : '-',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
