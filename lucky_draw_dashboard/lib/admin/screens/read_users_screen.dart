import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:lucky_draw_dashboard/admin/screens/update_users.dart';
import 'package:lucky_draw_dashboard/admin/services/firestore_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('Users');
  List<Map<String, dynamic>> _data = [];

  bool isLoading = true;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Fetch the data
      List<Map<String, dynamic>> fetchedData =
          await _firestoreService.fetchUsers();

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
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   foregroundColor: Colors.red, // Change color if needed
        //   title: const Text(
        //     "Users",
        //     style: TextStyle(fontSize: 15),
        //   ),
        // ),
        body: Container(
          padding: const EdgeInsets.all(25.0),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      backgroundColor: Colors.grey,
                      color: Colors.redAccent // Adjust color
                      ),
                )
              : _data.isEmpty
                  ? const Center(
                      child: Text(
                        "No User Data Available",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columnSpacing: 40.0, // Adjust spacing
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
                                "Username",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Email",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            // DataColumn(
                            //   label: Text(
                            //     "Role",
                            //     style: TextStyle(
                            //         fontWeight: FontWeight.bold, fontSize: 14),
                            //   ),
                            // ),
                            // DataColumn(
                            //   label: Text(
                            //     "Created Date",
                            //     style: TextStyle(
                            //         fontWeight: FontWeight.bold, fontSize: 14),
                            //   ),
                            // ),
                            DataColumn(
                              label: Text(
                                "Actions",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ],
                          rows: _data.map((user) {
                            return DataRow(cells: [
                              // DataCell(Text(user['id'] ?? 'N/A')),
                              DataCell(Center(
                                  child: Text(
                                      (_data.indexOf(user) + 1).toString()))),
                              DataCell(Text(user['username'] ?? 'N/A')),
                              DataCell(Text(user['email'] ?? 'N/A')),
                              // DataCell(Text(user['role'] ?? 'N/A')),
                              // DataCell(
                              //   user['createdDate'] != null
                              //       ? Text(DateFormat.yMMMMEEEEd()
                              //           .format(user['createdDate']?.toDate()))
                              //       : const Center(child: Text('N/A')),
                              // ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          color: Colors.redAccent),
                                      onPressed: () {
                                        // Navigate to edit user page
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => UpdateUsers(
                                                userId: user['id']!),
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
                                              .deleteUser(user["id"]!);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                backgroundColor: Colors.green,
                                                duration: Duration(seconds: 1),
                                                content: Text(
                                                    "User deleted successfully.")),
                                          );
                                          _fetchUsers(); // Refresh the list
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 1),
                                                content: Text(
                                                    "Error deleting user: $e")),
                                          );
                                        }
                                      },
                                    ),
                                  ],
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
