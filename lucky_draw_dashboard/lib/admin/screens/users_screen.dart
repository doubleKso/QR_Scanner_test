import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: SizedBox(
      // decoration: BoxDecoration(color: Colors.grey[50]),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Here"),
          SizedBox(
            height: 10,
          ),
          Text("is"),
          SizedBox(
            height: 10,
          ),
          Text("Users"),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    ));
  }
}
