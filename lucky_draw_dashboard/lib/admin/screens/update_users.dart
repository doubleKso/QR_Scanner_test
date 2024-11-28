import 'package:flutter/material.dart';
import 'package:lucky_draw_dashboard/admin/services/firestore_service.dart';
import 'package:lucky_draw_dashboard/widgets/widgets.dart';

class UpdateUsers extends StatefulWidget {
  final String userId;
  const UpdateUsers({super.key, required this.userId});

  @override
  State<UpdateUsers> createState() => _UpdateUsersState();
}

class _UpdateUsersState extends State<UpdateUsers> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  // final TextEditingController _userPhoneController = TextEditingController();
  // final TextEditingController _timeController = TextEditingController();
  String? errorMessage;
  bool isLoading = true; // Track loading state
  String qrData = "";

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load data on initialization
  }

  Future<void> _loadUserData() async {
    try {
      // Fetch QR code data using the ID
      final userDataMap = await firestoreService.getUserById(widget.userId);
      setState(() {
        _usernameController.text = userDataMap['username'];
        _userEmailController.text = userDataMap['email'];
        // _userPhoneController.text = userDataMap['phone'];
        // _timeController.text =
        //     '${TimeOfDay(hour: expiredDateTime.hour, minute: expiredDateTime.minute).format(context)} (${expiredDateTime.hour.toString().padLeft(2, '0')}:${expiredDateTime.minute.toString().padLeft(2, '0')})';
        // qrData = _qrController.text;
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

  Future<void> _updateUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      await firestoreService.updateUser(
        _usernameController.text,
        _userEmailController.text,
        // _userPhoneController.text,
        widget.userId, // Pass the ID to the update method
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("User updated successfully!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ));

      await Future.delayed(const Duration(seconds: 1));

      // Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("$errorMessage"),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
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
          "Users",
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.33,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: TextField(
                    readOnly: true,
                    maxLength: 50,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.cancel_outlined),
                        onPressed: () {
                          _usernameController.clear();
                        },
                      ),
                      labelText: 'Email',
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    controller: _userEmailController,
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
                          _usernameController.clear();
                        },
                      ),
                      labelText: 'Username',
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    controller: _usernameController,
                  ),
                ),
                //  Padding(
                //     padding: const EdgeInsets.symmetric(vertical: 10.0),
                //     child: TextField(
                //       maxLength: 50,
                //       decoration: InputDecoration(
                //         suffixIcon: IconButton(
                //           icon: const Icon(Icons.cancel_outlined),
                //           onPressed: () {
                //             _usernameController.clear();
                //           },
                //         ),
                //         labelText: 'phone',
                //         enabledBorder: const OutlineInputBorder(
                //           borderSide: BorderSide(color: Colors.black),
                //         ),
                //         focusedBorder: const OutlineInputBorder(
                //           borderSide: BorderSide(color: Colors.black),
                //         ),
                //       ),
                //       controller: _userPhoneController,
                //     ),
                //   ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: buildFilledButton(
                    label: "Update QR Code",
                    color: Colors.red,
                    onPressed: isLoading ? null : _updateUser,
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
