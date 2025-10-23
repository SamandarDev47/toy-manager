import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/wedding.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('weddings');
  final DatabaseReference _historyRef = FirebaseDatabase.instance.ref('history');
  final DatabaseReference _tokensRef = FirebaseDatabase.instance.ref('userTokens');
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> saveUserToken() async {
    final token = await _messaging.getToken();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (token == null || uid == null) return;
    await _tokensRef.child(uid).set({
      'token': token,
      'uid': uid,
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> addWedding(Wedding wedding) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final now = DateTime.now().millisecondsSinceEpoch;
    final newRef = _dbRef.push();
    final clean = wedding.copyWith(
      id: newRef.key,
      date: Wedding.normalizeDateString(wedding.date),
      status: 'active',
      createdAt: now,
      updatedAt: now,
      createdBy: uid,
    );
    await newRef.set(clean.toMap());
  }

  Future<void> updateWedding(Wedding wedding) async {
    if (wedding.id == null) return;
    final clean = wedding.copyWith(
      date: Wedding.normalizeDateString(wedding.date),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _dbRef.child(wedding.id!).update(clean.toMap());
  }

  Future<void> deleteWedding(String id) async => _dbRef.child(id).remove();

  Stream<List<Wedding>> getWeddings() {
    return _dbRef.onValue.map((event) {
      final list = _parseWeddingList(event.snapshot.value);
      list.sort((a, b) {
        final da = a.dateTime ?? DateTime(2100);
        final db = b.dateTime ?? DateTime(2100);
        return da.compareTo(db);
      });
      return list.where((w) => !w.isPast).toList();
    });
  }

  Stream<List<Wedding>> getHistory() {
    return _historyRef.onValue.map((event) {
      final list = _parseWeddingList(event.snapshot.value);
      list.sort((a, b) {
        final da = a.dateTime ?? DateTime(1900);
        final db = b.dateTime ?? DateTime(1900);
        return db.compareTo(da);
      });
      return list;
    });
  }

  Future<void> archivePastWeddings() async {
    final snapshot = await _dbRef.get();
    final list = _parseWeddingList(snapshot.value);
    for (final wedding in list) {
      if (wedding.id != null && wedding.isPast) {
        await moveToHistory(wedding);
      }
    }
  }

  Future<void> moveToHistory(Wedding wedding) async {
    if (wedding.id == null) return;
    final archived = wedding.copyWith(
      status: 'archived',
      completedAt: DateTime.now(),
      archivedAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _historyRef.child(wedding.id!).set(archived.toMap());
    await _dbRef.child(wedding.id!).remove();
  }

  List<Wedding> _parseWeddingList(dynamic value) {
    if (value == null) return <Wedding>[];
    if (value is Map) {
      return value.entries
          .where((entry) => entry.value is Map)
          .map((entry) => Wedding.fromMap(Map<dynamic, dynamic>.from(entry.value as Map), entry.key.toString()))
          .toList();
    }
    if (value is List) {
      final list = <Wedding>[];
      for (var i = 0; i < value.length; i++) {
        final item = value[i];
        if (item is Map) list.add(Wedding.fromMap(Map<dynamic, dynamic>.from(item), i.toString()));
      }
      return list;
    }
    return <Wedding>[];
  }
}
