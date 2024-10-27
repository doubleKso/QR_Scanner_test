import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/user_controller.dart';
import '../models/user_model.dart';

class AppUserPage extends StatelessWidget {
  final AppUserController controller = Get.put(AppUserController());

  AppUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage App Users"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              var newUser =
                  AppUser(id: "1", name: "User 1", email: "user1@example.com");
              controller.createUser(newUser);
            },
            child: const Text("Create User"),
          ),
          Obx(
            () => Expanded(
              child: ListView.builder(
                itemCount: controller.appUsers.length,
                itemBuilder: (context, index) {
                  final user = controller.appUsers[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            var updatedUser = AppUser(
                                id: user.id,
                                name: "Updated User",
                                email: "updated@example.com");
                            controller.editUser(user.id, updatedUser);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            controller.deleteUser(user.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
