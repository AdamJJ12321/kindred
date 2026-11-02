import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreStoryRepository {
  FirestoreStoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchPublicStories() {
    return _firestore
        .collection('stories')
        .where('visibility', isEqualTo: 'public')
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<DocumentReference<Map<String, dynamic>>> createStory({
    required String creatorId,
    required String title,
    required String description,
    required String storyType,
    required String evidenceType,
    String visibility = 'public',
    String status = 'published',
  }) {
    final now = FieldValue.serverTimestamp();
    return _firestore.collection('stories').add({
      'creatorId': creatorId,
      'title': title,
      'description': description,
      'storyType': storyType,
      'evidenceType': evidenceType,
      'visibility': visibility,
      'status': status,
      'familyIds': <String>[],
      'relatedStoryIds': <String>[],
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<void> setVisibility(String storyId, String visibility) {
    return _firestore.collection('stories').doc(storyId).update({
      'visibility': visibility,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentReference<Map<String, dynamic>>> addEvidence({
    required String storyId,
    required String uploadedBy,
    required String kind,
    String? fileName,
    String? caption,
    String? sourceNote,
  }) {
    final data = <String, dynamic>{'kind': kind, 'uploadedBy': uploadedBy};
    if (fileName?.trim().isNotEmpty == true)
      data['fileName'] = fileName!.trim();
    if (caption?.trim().isNotEmpty == true) data['caption'] = caption!.trim();
    if (sourceNote?.trim().isNotEmpty == true)
      data['sourceNote'] = sourceNote!.trim();
    return _firestore
        .collection('stories')
        .doc(storyId)
        .collection('evidence')
        .add(data);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchEvidence(String storyId) =>
      _firestore
          .collection('stories')
          .doc(storyId)
          .collection('evidence')
          .snapshots();
}
