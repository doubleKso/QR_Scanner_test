import 'package:get/get.dart';

import '../models/user_model.dart';

class AppUserController extends GetxController {
  var appUsers = <AppUser>[].obs;

  void createUser(AppUser appUser) {
    appUsers.add(appUser);
  }

  void editUser(String id, AppUser updatedUser) {
    int index = appUsers.indexWhere((user) => user.id == id);
    if (index != -1) {
      appUsers[index] = updatedUser;
    }
  }

  void deleteUser(String id) {
    appUsers.removeWhere((user) => user.id == id);
  }
}
