import 'package:flutter/material.dart';
import 'package:lucky_draw_dashboard/admin/services/firestore_service.dart';
import 'package:lucky_draw_dashboard/widgets/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

class CreateQrCodes extends StatefulWidget {
  const CreateQrCodes({super.key});

  @override
  State<CreateQrCodes> createState() => _CreateQrCodesState();
}

class _CreateQrCodesState extends State<CreateQrCodes> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController _qrController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _prizeController = TextEditingController();
  String? errorMessage;
  var uuid = const Uuid();
  bool isLoading = false; // New variable to track loading state

  String qrData = "";

  void _changeQRCode() {
    setState(() {
      String newUuid = uuid.v4(); // Generate a new UUID
      _qrController.text = newUuid;
      qrData = _qrController.text;
    });
  }

  @override
  void initState() {
    super.initState();
    _changeQRCode(); // Generate the initial UUID when the widget is created
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

  Future<void> _submitQrCode() async {
    setState(() {
      isLoading = true;
    });

    try {
      await firestoreService.addQrCode(
        _qrController.text,
        _prizeController.text,
        _dateController.text,
      );

      _changeQRCode();
      _dateController.clear();
      _prizeController.clear();

      setState(() {
        errorMessage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("QR code added successfully!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ));
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("$errorMessage"),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 500),
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
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          "Create New QR Codes",
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width *
                0.33, // One-third of the screen width
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
                    label: "Add QR Code",
                    color: Colors.red,
                    onPressed: isLoading ? null : _submitQrCode,
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
