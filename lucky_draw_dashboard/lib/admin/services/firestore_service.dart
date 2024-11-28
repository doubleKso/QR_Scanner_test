import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final CollectionReference qrCodes =
      FirebaseFirestore.instance.collection('QrCodes');
  final CollectionReference users =
      FirebaseFirestore.instance.collection('Users');

  Future<void> addQrCode(String qrData, String prize, String expiredDate,
      String expiredTime) async {
    try {
      if (qrData.isEmpty ||
          prize.isEmpty ||
          expiredDate.isEmpty ||
          expiredTime.isEmpty) {
        throw Exception("QR data, prize, date, and time cannot be empty.");
      }

      final DateTime date = DateTime.parse(expiredDate); // From date picker
      final TimeOfDay time = TimeOfDay(
        hour: int.parse(expiredTime.split(":")[0]),
        minute: int.parse(expiredTime.split(":")[1]),
      ); // From time picker

      final DateTime combinedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      // Add to Firestore
      return qrCodes.doc(qrData).set({
        "availability": true,
        "data": qrData,
        "timestamp": Timestamp.now(),
        "expiredDate":
            Timestamp.fromDate(combinedDateTime), // Use combined DateTime
        "scannedDate": null,
        "prize": prize,
        "winner": null,
      });
    } catch (e) {
      throw Exception("Error adding QR code: $e");
    }
  }

  Future<void> updateQrCode(String qrData, String prize, String expiredDate,
      String expiredTime, String qrCodeId) async {
    try {
      // Validate inputs
      if (qrData.isEmpty ||
          prize.isEmpty ||
          expiredDate.isEmpty ||
          expiredTime.isEmpty) {
        throw Exception("QR data, prize, date, and time cannot be empty.");
      }

      final DateTime date = DateTime.parse(expiredDate);
      final TimeOfDay time = TimeOfDay(
        hour: int.parse(expiredTime.split(":")[0]),
        minute: int.parse(expiredTime.split(":")[1]),
      );

      final DateTime combinedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      // Fetch existing document data
      final docSnapshot = await qrCodes.doc(qrCodeId).get();
      if (!docSnapshot.exists) {
        throw Exception("QR Code document not found.");
      }

      final existingData = docSnapshot.data() as Map<String, dynamic>;

      final updatedData = {
        "availability": existingData["availability"] ?? true,
        "data": qrData,
        "expiredDate": Timestamp.fromDate(combinedDateTime),
        "scannedDate": existingData["scannedDate"],
        "prize": prize,
        "winner": existingData["winner"],
      };

      await qrCodes.doc(qrCodeId).update(updatedData);
    } catch (e) {
      throw Exception("Error updating QR code: $e");
    }
  }

  Future<void> updateUser(String username, String email, String userId) async {
    try {
      // Validate inputs
      if (username.isEmpty ||
          email.isEmpty ||
          // phone.isEmpty ||
          userId.isEmpty) {
        throw Exception("username, email, phone cannot be empty.");
      }
      // Fetch existing document data
      final docSnapshot = await users.doc(userId).get();
      if (!docSnapshot.exists) {
        throw Exception("User document not found.");
      }

      final existingData = docSnapshot.data() as Map<String, dynamic>;

      final updatedData = {
        "username": existingData["username"] ?? true,
        "email": existingData["email"],
      };

      await users.doc(userId).update(updatedData);
    } catch (e) {
      throw Exception("Error updating QR code: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchQrCodes() async {
    try {
      QuerySnapshot querySnapshot =
          await qrCodes.orderBy('timestamp', descending: true).get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("$e");
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> fetchQrCodesAsStream() {
    return qrCodes
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<Map<String, dynamic>> getQrCodeById(String id) async {
    try {
      DocumentSnapshot snapshot = await qrCodes.doc(id).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception("QR code not found");
      }
    } catch (e) {
      throw Exception("Failed to fetch QR code: $e");
    }
  }

  Future<Map<String, dynamic>> getUserById(String id) async {
    try {
      DocumentSnapshot snapshot = await users.doc(id).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception("QR code not found");
      }
    } catch (e) {
      throw Exception("Failed to fetch QR code: $e");
    }
  }

  Future<void> deleteQrCode(String documentId) async {
    try {
      await qrCodes.doc(documentId).delete();
      print("Document with ID: $documentId deleted successfully.");
    } catch (e) {
      print("Error deleting document: $e");
    }
  }

  Future<void> deleteUser(String documentId) async {
    try {
      await users.doc(documentId).delete();
      print("Document with ID: $documentId deleted successfully.");
    } catch (e) {
      print("Error deleting document: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      QuerySnapshot querySnapshot =
          await users.orderBy('timestamp', descending: true).get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching data: $e");
      return [];
    }
  }
}
