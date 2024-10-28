import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DetailPage extends StatelessWidget {
  final String documentId;

  const DetailPage({super.key, required this.documentId});

  Future<Map<String, dynamic>?> _fetchDocumentDetail() async {
    // print(documentId);
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('QrCodes') // Use your collection name
          .doc(documentId)
          .get();
      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>?;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching document details: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: SelectableText(
        "QR Code ID: " + documentId,
        style: TextStyle(fontSize: 15),
      )),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchDocumentDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.grey,
              color: Colors.red,
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
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
                    color: Colors.red[50],
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20.0), // Rounded corners
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                          16.0), // Inner padding for the card
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            QrImageView(
                              data: data['data'],
                              version: QrVersions.auto,
                              embeddedImage: const AssetImage(
                                  'assets/images/AxraWithBackground.jpg'),
                              embeddedImageStyle: const QrEmbeddedImageStyle(
                                  size: Size(30, 30)),
                              size: 200,
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(height: 20),
                            const Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Winner: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold), // Bold text
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                data['winner'] != null ? data['winner'] : '-',
                              ),
                            ),

                            // const SizedBox(height: 20),
                            const Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Created Date: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold), // Bold text
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                DateFormat.yMMMMEEEEd().format(createdDate),
                              ),
                            ),
                            const SizedBox(height: 10), // Spacing
                            const Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Prize: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold), // Bold text
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(data['prize']),
                            ),
                            const SizedBox(height: 10), // Spacing
                            const Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Expired Date: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold), // Bold text
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                DateFormat.yMMMMEEEEd().format(expiredDate),
                              ),
                            ),
                            const SizedBox(height: 10), // Spacing
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                data['scannedDate'] != null
                                    ? "Scanned Date: "
                                    : 'Scanned Date: -',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold), // Bold text
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                data['scannedDate'] != null
                                    ? DateFormat.yMMMMEEEEd()
                                        .format(data['scannedDate'].toDate())
                                    : '-',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
            ),
          );
        },
      ),
    );
  }
}
