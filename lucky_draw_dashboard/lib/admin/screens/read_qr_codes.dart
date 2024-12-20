import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucky_draw_dashboard/admin/screens/create_qr_codes.dart';
import 'package:lucky_draw_dashboard/admin/screens/detail_page.dart';
import 'package:lucky_draw_dashboard/admin/screens/update_qr_codes.dart';
import 'package:lucky_draw_dashboard/admin/services/firestore_service.dart';
import 'package:excel/excel.dart';
import 'dart:html' as html;
import 'dart:convert';

class ReadQrCodes extends StatefulWidget {
  const ReadQrCodes({super.key});

  @override
  State<ReadQrCodes> createState() => _ReadQrCodesState();
}

class _ReadQrCodesState extends State<ReadQrCodes> {
  final CollectionReference qrCodes =
      FirebaseFirestore.instance.collection('QrCodes');
  // List<Map<String, dynamic>> _data = [];

  bool isLoading = true;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // _fetchQrCodes();
  }

  // Future<void> _fetchQrCodes() async {
  //   try {
  //     setState(() {
  //       isLoading = true;
  //     });

  //     List<Map<String, dynamic>> fetchedData =
  //         await _firestoreService.fetchQrCodes();

  //     for (var item in fetchedData) {
  //       if (item['winner'] != null) {
  //         final winnerId = item['winner'];
  //         final winnerData = await _firestoreService.getUserById(winnerId);
  //         item['winner'] = winnerData['username'] ?? 'Unknown';
  //       }
  //     }

  //     setState(() {
  //       _data = fetchedData;
  //       isLoading = false;
  //     });
  //   } catch (error) {
  //     setState(() {
  //       isLoading = false;
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error fetching QR codes: $error")),
  //     );
  //   }
  // }

  Future<void> exportData() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preparing to download..."),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 1),
        ),
      );
      final qrCodesList = await _firestoreService.fetchQrCodes();
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['QR Codes'];
      excel.delete('Sheet1');

      sheetObject.appendRow([
        TextCellValue('ID'),
        TextCellValue('Expired Date'),
        TextCellValue('Scanned Date'),
        TextCellValue('Prize'),
        TextCellValue('Winner'),
        TextCellValue('Created at')
      ]);

      for (var qrCode in qrCodesList) {
        final expiredDate = qrCode['expiredDate'];
        final scannedDate = qrCode['scannedDate'];
        final timestamp = qrCode['timestamp'];

        Map<String, dynamic> user = {};
        if (qrCode['winner'] != null) {
          try {
            user = await _firestoreService.getUserById(qrCode['winner']);
            if (user.isEmpty) {
              user['username'] = 'Unknown';
              user['email'] = '';
            } else {
              user['email'] = '(' + user['email'] + ')';
            }
          } catch (e) {
            user['username'] = 'Unknown';
            user['email'] = '';
            print("Error fetching user: $e");
          }
        } else {
          user['username'] = '-';
          user['email'] = '';
        }
        sheetObject.appendRow([
          TextCellValue(qrCode['id']?.toString() ?? ''),
          TextCellValue(expiredDate != null && expiredDate is Timestamp
              ? DateFormat.yMMMMEEEEd().add_jm().format(expiredDate.toDate())
              : 'None'),
          TextCellValue(scannedDate != null && scannedDate is Timestamp
              ? DateFormat.yMMMMEEEEd().add_jm().format(scannedDate.toDate())
              : '-'),
          TextCellValue(qrCode['prize']?.toString() ?? ''),
          TextCellValue(user['username'] + user['email']),
          TextCellValue(timestamp != null && timestamp is Timestamp
              ? DateFormat.yMMMMEEEEd().add_jm().format(timestamp.toDate())
              : 'None'),
        ]);
      }

      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        final base64Excel = base64Encode(fileBytes);
        html.AnchorElement(
            href:
                'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,$base64Excel')
          ..setAttribute(
              'download', 'QR Codes ${DateTime.now().toString()}.xlsx')
          ..click();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Download started."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stacktrace) {
      print("Error during export: $e");
      print("Stacktrace: $stacktrace");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text(
            "Qr Codes",
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.save_alt_outlined),
                color: Colors.white,
                onPressed: exportData,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.add_outlined),
                color: Colors.white,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateQrCodes(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _firestoreService.fetchQrCodesAsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.grey,
                  color: Colors.redAccent,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "No Data Available",
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            final data = snapshot.data!;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const [
                    DataColumn(
                      label: Text(
                        "No",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Detail",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Prize",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Status",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Expired Date",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Scanned Date",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Created",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    // DataColumn(
                    //   label: Text(
                    //     "Winner",
                    //     style: TextStyle(
                    //         fontWeight: FontWeight.bold, fontSize: 14),
                    //   ),
                    // ),
                    DataColumn(
                      label: Text(
                        "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                  rows: data.map((item) {
                    return DataRow(cells: [
                      DataCell(Center(
                          child: Text((data.indexOf(item) + 1).toString()))),
                      DataCell(
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailPage(documentId: item['id']),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.green),
                          ),
                          child: Text(
                            '${item['data']}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(item['prize'] ?? 'N/A')),
                      DataCell(
                        Text(
                          item['winner'] != null
                              ? "Scanned"
                              : (item['expiredDate'] != null &&
                                      item['expiredDate']
                                          .toDate()
                                          .isBefore(DateTime.now())
                                  ? "Expired"
                                  : "Available"),
                          style: TextStyle(
                            color: item['winner'] != null
                                ? Colors.blue
                                : (item['expiredDate'] != null &&
                                        item['expiredDate']
                                            .toDate()
                                            .isBefore(DateTime.now())
                                    ? Colors.red
                                    : Colors.green),
                          ),
                        ),
                      ),

                      DataCell(
                        item['expiredDate'] != null
                            ? Text(DateFormat.yMMMMEEEEd()
                                .add_jm()
                                .format(item['expiredDate'].toDate()))
                            : const Center(child: Text('None')),
                      ),
                      DataCell(
                        item['scannedDate'] != null
                            ? Text(DateFormat.yMMMMEEEEd()
                                .add_jm()
                                .format(item['scannedDate'].toDate()))
                            : const Center(child: Text("-")),
                      ),
                      DataCell(
                        item['timestamp'] != null
                            ? Text(DateFormat.yMMMMEEEEd()
                                .add_jm()
                                .format(item['timestamp'].toDate()))
                            : const Center(child: Text('None')),
                      ),
                      // DataCell(
                      //   item['winner'] != null
                      //       ? Text(item['winner'])
                      //       : const Center(child: Text("-")),
                      // ),
                      DataCell(
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: Colors.redAccent),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UpdateQrCodes(qrCodeId: item['id']),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_forever_outlined,
                                    color: Colors.redAccent),
                                onPressed: () async {
                                  final shouldDelete = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Delete QR Code"),
                                        content: const Text(
                                            "Are you sure you want to delete this QR code?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text("Delete",
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (shouldDelete == true) {
                                    try {
                                      await _firestoreService
                                          .deleteQrCode(item["id"]);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.green,
                                          duration: Duration(seconds: 1),
                                          content: Text(
                                              "QR code deleted successfully."),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          duration: const Duration(seconds: 1),
                                          content: Text(
                                              "Error deleting QR code: $e"),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
