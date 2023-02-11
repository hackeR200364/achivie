import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../shared_preferences.dart';

class AllTaskProvider extends ChangeNotifier {
  CollectionReference users = FirebaseFirestore.instance.collection("users");

  late Stream<QuerySnapshot<Map<String, dynamic>>> firestore;
  int? inboxCount, completedCount, pendingCount;
  void firestoreFromProviderFunc({
    required String type,
    required String status,
  }) async {
    String email = await StorageServices.getUserEmail();

    final firestoreFromProvider = FirebaseFirestore.instance
        .collection("users")
        .doc(email)
        .collection("tasks")
        .where(Keys.taskType, isEqualTo: type)
        .where(Keys.taskStatus, isEqualTo: status)
        .snapshots();

    final firestoreAllFromProvider = FirebaseFirestore.instance
        .collection("users")
        .doc(email)
        .collection("tasks")
        .where(Keys.taskType, isEqualTo: type)
        .snapshots();

    firestore =
        (status == "INBOX") ? firestoreAllFromProvider : firestoreFromProvider;
    if (status == "INBOX") {
      inboxCount = await firestore.length;
      notifyListeners();
    } else {
      completedCount = await firestore.length;
      pendingCount = await firestore.length;
      notifyListeners();
    }
  }
}
