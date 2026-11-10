import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
    String sourceNotes = '',
    Map<String, dynamic>? date,
    List<Map<String, dynamic>> locations = const [],
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
      'sourceNotes': sourceNotes,
      if (date != null) 'date': date,
      'locations': locations,
      if (status == 'published') 'publishedAt': now,
    });
  }

  Future<void> updateStory(String storyId, Map<String, dynamic> data) {
    return _firestore.collection('stories').doc(storyId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> publishStory(String storyId) => updateStory(storyId, {
    'status': 'published',
    'publishedAt': FieldValue.serverTimestamp(),
  });

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
    String? storagePath,
    String? mimeType,
    int order = 0,
  }) {
    final data = <String, dynamic>{'kind': kind, 'uploadedBy': uploadedBy};
    data['order'] = order;
    if (fileName?.trim().isNotEmpty == true)
      data['fileName'] = fileName!.trim();
    if (caption?.trim().isNotEmpty == true) data['caption'] = caption!.trim();
    if (sourceNote?.trim().isNotEmpty == true)
      data['sourceNote'] = sourceNote!.trim();
    if (storagePath?.trim().isNotEmpty == true)
      data['storagePath'] = storagePath!.trim();
    if (mimeType?.trim().isNotEmpty == true)
      data['mimeType'] = mimeType!.trim();
    return _firestore
        .collection('stories')
        .doc(storyId)
        .collection('evidence')
        .add(data);
  }

  Future<DocumentReference<Map<String, dynamic>>> uploadEvidence({
    required String storyId,
    required String uploadedBy,
    required String kind,
    required String fileName,
    required List<int> bytes,
    String? mimeType,
    String? caption,
    String? sourceNote,
    int order = 0,
  }) async {
    final path =
        'stories/$storyId/evidence/${DateTime.now().microsecondsSinceEpoch}_$fileName';
    await FirebaseStorage.instance
        .ref(path)
        .putData(
          Uint8List.fromList(bytes),
          SettableMetadata(contentType: mimeType),
        );
    return addEvidence(
      storyId: storyId,
      uploadedBy: uploadedBy,
      kind: kind,
      fileName: fileName,
      caption: caption,
      sourceNote: sourceNote,
      storagePath: path,
      mimeType: mimeType,
      order: order,
    );
  }

  Future<void> updateEvidence(
    String storyId,
    String evidenceId,
    Map<String, dynamic> data,
  ) {
    return _firestore
        .collection('stories')
        .doc(storyId)
        .collection('evidence')
        .doc(evidenceId)
        .update(data);
  }

  Future<void> deleteEvidence(
    String storyId,
    String evidenceId, {
    String? storagePath,
  }) async {
    if (storagePath?.isNotEmpty == true) {
      await FirebaseStorage.instance.ref(storagePath).delete();
    }
    await _firestore
        .collection('stories')
        .doc(storyId)
        .collection('evidence')
        .doc(evidenceId)
        .delete();
  }

  Future<void> reorderEvidence(String storyId, List<String> evidenceIds) async {
    final batch = _firestore.batch();
    for (var i = 0; i < evidenceIds.length; i++) {
      batch.update(
        _firestore
            .collection('stories')
            .doc(storyId)
            .collection('evidence')
            .doc(evidenceIds[i]),
        {'order': i},
      );
    }
    await batch.commit();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchEvidence(String storyId) =>
      _firestore
          .collection('stories')
          .doc(storyId)
          .collection('evidence')
          .orderBy('order')
          .snapshots();
}
