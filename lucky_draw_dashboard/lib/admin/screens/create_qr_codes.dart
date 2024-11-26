import 'package:flutter/material.dart';
import 'package:lucky_draw_dashboard/admin/screens/read_qr_codes.dart';
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
  final TextEditingController _timeController = TextEditingController();

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
    _changeQRCode();
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

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
    );

    if (picked != null) {
      setState(() {
        // Format the time as "HH:mm" (24-hour format)
        _timeController.text =
            '${picked.format(context)} (${picked.hour}:${picked.minute.toString().padLeft(2, '0')})';
      });
    }
  }

  Future<void> _submitQrCode() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Extract the time in the parenthesis for Firestore
      final timeInParenthesis =
          _timeController.text.split('(')[1].split(')')[0];

      await firestoreService.addQrCode(
        _qrController.text, // QR data
        _prizeController.text, // Prize
        _dateController.text, // Date from date picker
        timeInParenthesis, // Extracted time in 24-hour format
      );

      // Clear inputs after successful submission
      _changeQRCode();
      _dateController.clear();
      _prizeController.clear();
      _timeController.clear();

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
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          "Create New QR Codes",
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: const Icon(Icons.list),
              color: Colors.white,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReadQrCodes(),
                  ),
                );
              },
            ),
          ),
        ],
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
                    maxLength: 50,
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
                  child: TextField(
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.cancel_outlined),
                        onPressed: () {
                          _timeController.clear();
                        },
                      ),
                      labelText: 'Expired Time',
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    controller: _timeController,
                    readOnly: true,
                    onTap: _selectTime,
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
