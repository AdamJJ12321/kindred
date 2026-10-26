import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyRepository {
  FamilyRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchPublicFamilies() => _firestore.collection('families').where('visibility', isEqualTo: 'public').snapshots();
  Future<DocumentReference<Map<String, dynamic>>> createFamily({required String ownerId, required String name, String description = ''}) => _firestore.collection('families').add({'name': name, 'description': description, 'visibility': 'public', 'ownerId': ownerId});
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMembers(String familyId) => _firestore.collection('families').doc(familyId).collection('members').where('status', isEqualTo: 'active').snapshots();
}
