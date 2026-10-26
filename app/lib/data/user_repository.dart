import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchProfile(String userId) => _firestore.collection('users').doc(userId).snapshots();
  Future<DocumentSnapshot<Map<String, dynamic>>> getProfile(String userId) => _firestore.collection('users').doc(userId).get();
  Future<void> upsertProfile(String userId, Map<String, dynamic> data) => _firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
}
