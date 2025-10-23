import 'package:firebase_database/firebase_database.dart';
import '../models/wedding.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('weddings');
  final DatabaseReference _historyRef = FirebaseDatabase.instance.ref().child('history');

  /// === 🟢 To‘y qo‘shish
  Future<void> addWedding(Wedding wedding) async {
    final newRef = _dbRef.push();
    await newRef.set(wedding.toMap());
  }

  /// === 🟡 To‘y yangilash
  Future<void> updateWedding(Wedding wedding) async {
    if (wedding.id == null) return;
    await _dbRef.child(wedding.id!).update(wedding.toMap());
  }

  /// === 🔴 To‘y o‘chirish
  Future<void> deleteWedding(String id) async {
    await _dbRef.child(id).remove();
  }

  /// === 🔁 Real-time oqim — barcha to‘ylar
  Stream<List<Wedding>> getWeddings() {
    return _dbRef.onValue.map((event) {
      final value = event.snapshot.value;

      if (value == null) return <Wedding>[];

      if (value is Map) {
        return value.entries.map((entry) {
          final key = entry.key.toString();
          final val = Map<String, dynamic>.from(entry.value);
          return Wedding.fromMap(val, key);
        }).toList();
      } else if (value is List) {
        final List<Wedding> list = [];
        for (int i = 0; i < value.length; i++) {
          final item = value[i];
          if (item is Map) {
            list.add(Wedding.fromMap(Map<String, dynamic>.from(item), i.toString()));
          }
        }
        return list;
      }

      return <Wedding>[];
    });
  }

  /// === 🟣 To‘yni tarixga o‘tkazish (weddings → history)
  Future<void> moveToHistory(Wedding wedding) async {
    if (wedding.id == null) return;

    // 1️⃣ History bo‘limiga qo‘shamiz
    final newRef = _historyRef.push();
    await newRef.set(wedding.toMap());

    // 2️⃣ Asl weddings dan o‘chiramiz
    await _dbRef.child(wedding.id!).remove();
  }

  /// === 🟤 Tarixdagi to‘ylarni olish (real-time)
  Stream<List<Wedding>> getHistory() {
    return _historyRef.onValue.map((event) {
      final value = event.snapshot.value;

      if (value == null) return <Wedding>[];

      if (value is Map) {
        return value.entries.map((entry) {
          final key = entry.key.toString();
          final val = Map<String, dynamic>.from(entry.value);
          return Wedding.fromMap(val, key);
        }).toList();
      } else if (value is List) {
        final List<Wedding> list = [];
        for (int i = 0; i < value.length; i++) {
          final item = value[i];
          if (item is Map) {
            list.add(Wedding.fromMap(Map<String, dynamic>.from(item), i.toString()));
          }
        }
        return list;
      }

      return <Wedding>[];
    });
  }
}
