import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference qrCodes =
      FirebaseFirestore.instance.collection('QrCodes');

  Future<void> addQrCode(String qrData, String prize, String expiredDate) {
    try {
      final DateTime date = DateTime.parse(expiredDate);
      if (qrData.isEmpty || prize.isEmpty || expiredDate.isEmpty) {
        throw Exception("QR data and prize and date cannot be empty.");
      }
      return qrCodes.add({
        // "id": "AA",
        "availability": true,
        "data": qrData,
        "timestamp": Timestamp.now(),
        "expiredDate": Timestamp.fromDate(date),
        "scannedDate": null,
        "prize": prize,
        "winner": null,
      });
    } catch (e) {
      throw Exception("$e");
    }
  }

  Future<void> updateQrCode(
      String qrData, String prize, String expiredDate, String qrCodeId) {
    // String expiredDate, String scannedDate) {
    try {
      final DateTime date = DateTime.parse(expiredDate);
      if (qrData.isEmpty || prize.isEmpty || expiredDate.isEmpty) {
        throw Exception("QR data and prize and date cannot be empty.");
      }
      return qrCodes.doc(qrCodeId).update({
        "availability": true,
        "data": qrData,
        "expiredDate": Timestamp.fromDate(date),
        "scannedDate": null,
        "prize": prize,
        "winner": null,
      });
    } catch (e) {
      throw Exception("$e");
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
      print("Error fetching data: $e");
      return [];
    }
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

  Future<void> deleteQrCode(String documentId) async {
    try {
      await qrCodes.doc(documentId).delete();
      print("Document with ID: $documentId deleted successfully.");
    } catch (e) {
      print("Error deleting document: $e");
    }
  }
}
