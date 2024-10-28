import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucky_draw_dashboard/admin/screens/detail_page.dart';
import 'package:lucky_draw_dashboard/admin/screens/update_qr_codes.dart';
import 'package:lucky_draw_dashboard/admin/services/firestore_service.dart';

class ReadQrCodes extends StatefulWidget {
  const ReadQrCodes({super.key});

  @override
  State<ReadQrCodes> createState() => _ReadQrCodesState();
}

class _ReadQrCodesState extends State<ReadQrCodes> {
  final CollectionReference qrCodes =
      FirebaseFirestore.instance.collection('QrCodes');
  List<Map<String, dynamic>> _data = [];

  bool isLoading = true;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _fetchQrCodes();
  }

  Future<void> _fetchQrCodes() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Fetch the data
      List<Map<String, dynamic>> fetchedData =
          await _firestoreService.fetchQrCodes();

      setState(() {
        _data = fetchedData;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching QR codes: $error")),
      );
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
        ),
        body: Container(
          padding: const EdgeInsets.all(25.0),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.grey,
                    color: Colors.redAccent,
                  ),
                )
              : _data.isEmpty
                  ? const Center(
                      child: Text(
                        "No Data Available",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: const [
                            DataColumn(
                              label: Text(
                                "No",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14), // Bold and larger font size
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
                            DataColumn(
                              label: Text(
                                "Winner",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ],
                          rows: _data.map((item) {
                            return DataRow(cells: [
                              DataCell(Center(
                                  child: Text(
                                      (_data.indexOf(item) + 1).toString()))),
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
                              DataCell(Text(
                                item['availability'] == true
                                    ? "Available"
                                    : (item['availability'] == false
                                        ? "Expired or Scanned"
                                        : "N/A"),
                                style: TextStyle(
                                  color: item['availability'] == true
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              )),
                              DataCell(
                                item['expiredDate'] != null
                                    ? Text(DateFormat.yMMMMEEEEd()
                                        .format(item['expiredDate'].toDate()))
                                    : const Center(child: Text('None')),
                              ),
                              DataCell(
                                item['scannedDate'] != null
                                    ? Text(DateFormat.yMMMMEEEEd()
                                        .format(item['scannedDate'].toDate()))
                                    : const Center(child: Text("-")),
                              ),
                              DataCell(
                                item['timestamp'] != null
                                    ? Text(DateFormat.yMMMMEEEEd()
                                        .format(item['timestamp'].toDate()))
                                    : const Center(child: Text('None')),
                              ),
                              DataCell(
                                item['winner'] != null
                                    ? Text(item['winner'])
                                    : const Center(child: Text("-")),
                              ),
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
                                                  UpdateQrCodes(
                                                      qrCodeId: item['id']),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.delete_forever_outlined,
                                            color: Colors.redAccent),
                                        onPressed: () async {
                                          try {
                                            await _firestoreService
                                                .deleteQrCode(item["id"]);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  backgroundColor: Colors.green,
                                                  duration:
                                                      Duration(seconds: 1),
                                                  content: Text(
                                                      "QR code deleted successfully.")),
                                            );
                                            _fetchQrCodes(); // Refresh the list
                                          } catch (e) {
                                            // Show an error message if deletion fails
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  backgroundColor: Colors.red,
                                                  duration:
                                                      Duration(seconds: 1),
                                                  content: Text(
                                                      "Error deleting QR code: $e")),
                                            );
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
                    ),
        ),
      ),
    );
  }
}
