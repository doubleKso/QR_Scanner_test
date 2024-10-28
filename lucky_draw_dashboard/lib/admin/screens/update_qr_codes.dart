import 'package:flutter/material.dart';
import 'package:lucky_draw_dashboard/admin/services/firestore_service.dart';
import 'package:lucky_draw_dashboard/widgets/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UpdateQrCodes extends StatefulWidget {
  final String qrCodeId; // Pass the QR code ID to this page

  const UpdateQrCodes({super.key, required this.qrCodeId});

  @override
  State<UpdateQrCodes> createState() => _UpdateQrCodePageState();
}

class _UpdateQrCodePageState extends State<UpdateQrCodes> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController _qrController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _prizeController = TextEditingController();
  // final TextEditingController _statusController = TextEditingController();
  // final TextEditingController _scannedDateController = TextEditingController();
  String? errorMessage;
  bool isLoading = true; // Track loading state
  String qrData = ""; // Store QR code data

  @override
  void initState() {
    super.initState();
    _loadQrCodeData(); // Load data on initialization
  }

  Future<void> _loadQrCodeData() async {
    try {
      // Fetch QR code data using the ID
      final qrDataMap = await firestoreService.getQrCodeById(widget.qrCodeId);
      setState(() {
        _qrController.text = qrDataMap['data'];
        _prizeController.text = qrDataMap['prize'];
        _dateController.text =
            qrDataMap['expiredDate'].toDate().toString().split(" ")[0];
        qrData = _qrController.text; // Set the QR code data for displaying
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false; // Set loading to false after fetching
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toString().split(" ")[0];
      });
    }
  }

  Future<void> _updateQrCode() async {
    setState(() {
      isLoading = true;
    });

    try {
      await firestoreService.updateQrCode(
        _qrController.text,
        _prizeController.text,
        _dateController.text,
        widget.qrCodeId, // Pass the ID to the update method
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("QR code updated successfully!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ));

      await Future.delayed(const Duration(seconds: 1));

      Navigator.pushReplacementNamed(context, '/readQRCodes');
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("$errorMessage"),
        backgroundColor: Colors.red,
        duration: const Duration(milliseconds: 500),
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.33,
            child: Column(
              children: [
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      embeddedImage: const AssetImage(
                          'assets/images/AxraWithBackground.jpg'),
                      embeddedImageStyle:
                          const QrEmbeddedImageStyle(size: Size(30, 30)),
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                Visibility(
                  visible: false,
                  child: TextField(
                    readOnly: true,
                    controller: _qrController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: TextField(
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.cancel_outlined),
                        onPressed: () {
                          _prizeController.clear();
                        },
                      ),
                      labelText: 'Prize',
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    controller: _prizeController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: TextField(
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.cancel_outlined),
                        onPressed: () {
                          _dateController.clear();
                        },
                      ),
                      labelText: 'Expired Date',
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    controller: _dateController,
                    readOnly: true,
                    onTap: _selectDate,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: buildFilledButton(
                    label: "Update QR Code",
                    color: Colors.red,
                    onPressed: isLoading ? null : _updateQrCode,
                  ),
                ),
                if (isLoading)
                  const CircularProgressIndicator(
                    backgroundColor: Colors.grey,
                    color: Colors.redAccent,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
