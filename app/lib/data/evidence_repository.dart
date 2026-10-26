import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class EvidenceUploadProgress {
  const EvidenceUploadProgress({required this.bytesTransferred, required this.totalBytes, required this.fileName});
  final int bytesTransferred;
  final int totalBytes;
  final String fileName;
  double get fraction => totalBytes == 0 ? 0 : bytesTransferred / totalBytes;
}

class EvidenceRepository {
  EvidenceRepository({FirebaseStorage? storage, FirebaseFirestore? firestore})
      : _storage = storage ?? FirebaseStorage.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;

  Future<void> uploadEvidence({
    required String storyId,
    required String uploadedBy,
    required PlatformFile file,
    required String kind,
    String? caption,
    void Function(EvidenceUploadProgress progress)? onProgress,
    int maxAttempts = 3,
  }) async {
    final bytes = file.bytes;
    if (bytes == null) throw StateError('File bytes are unavailable. Select the file again.');
    final path = 'stories/$storyId/evidence/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    Object? lastError;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final task = _storage.ref(path).putData(bytes, SettableMetadata(contentType: file.extension));
        final subscription = task.snapshotEvents.listen((snapshot) {
          onProgress?.call(EvidenceUploadProgress(bytesTransferred: snapshot.bytesTransferred, totalBytes: snapshot.totalBytes, fileName: file.name));
        });
        await task;
        await subscription.cancel();
        await _firestore.collection('stories').doc(storyId).collection('evidence').add({
          'kind': kind,
          'storagePath': path,
          'mimeType': file.extension ?? 'application/octet-stream',
          'fileName': file.name,
          if (caption != null && caption.isNotEmpty) 'caption': caption,
          'uploadedBy': uploadedBy,
        });
        return;
      } catch (error) {
        lastError = error;
        if (attempt + 1 < maxAttempts) await Future<void>.delayed(const Duration(milliseconds: 400));
      }
    }
    throw StateError('Upload failed after $maxAttempts attempts: $lastError');
  }
}
