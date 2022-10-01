// ignore_for_file: unused_import

import 'package:chat/allCostants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class HomeProvider {
  final FirebaseFirestore firebaseFirestore;
  HomeProvider({
    required this.firebaseFirestore,
  });

  Future<void> updateDataFirestore(
      String collectionPath, String path, Map<String, String> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(path)
        .update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getStreamFirestore(
      String collectionPath, int limit, String? textSearch) {
    if (textSearch?.isNotEmpty == true) {
      return firebaseFirestore
          .collection(collectionPath)
          .limit(limit)
          .where(FirestoreConstants.nickname, isEqualTo: textSearch)
          .snapshots();
    } else {
      return firebaseFirestore
          .collection(collectionPath)
          .limit(limit)
          .snapshots();
    }
  }
}
