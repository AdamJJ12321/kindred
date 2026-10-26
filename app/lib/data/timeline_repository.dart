import 'package:cloud_firestore/cloud_firestore.dart';

class TimelineRepository {
  TimelineRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchEvents() => _firestore.collection('timelineEvents').orderBy('date.start').snapshots();
}
