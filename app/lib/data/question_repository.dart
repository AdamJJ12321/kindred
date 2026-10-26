import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionRepository {
  QuestionRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchRecentQuestions() => _firestore.collection('dailyQuestions').orderBy('activeDate', descending: true).limit(7).snapshots();
}
