import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/app_user.dart';
import '../models/chat_message.dart';

class ChatService {
  final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref('chats/main/messages');
  final DatabaseReference _typingRef = FirebaseDatabase.instance.ref('chats/main/typing');
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');

  Stream<List<ChatMessage>> messages() {
    return _messagesRef.orderByChild('createdAt').limitToLast(250).onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <ChatMessage>[];
      final list = value.entries
          .where((e) => e.value is Map)
          .map((e) => ChatMessage.fromMap(Map<dynamic, dynamic>.from(e.value as Map), e.key.toString()))
          .toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  Future<void> sendMessage({required String text, required AppUser sender, ChatMessage? replyTo}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final ref = _messagesRef.push();
    final msg = ChatMessage(
      id: ref.key!,
      senderId: sender.uid,
      senderName: sender.fullName,
      senderPhone: sender.phone,
      senderRole: sender.role,
      text: trimmed,
      createdAt: now,
      updatedAt: now,
      replyToId: replyTo?.id,
      replyToText: replyTo?.text,
      replyToSenderName: replyTo?.senderName,
      readBy: {sender.uid: true},
    );
    await ref.set(msg.toMap());
  }

  Future<void> editMessage(String id, String newText) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _messagesRef.child(id).update({
      'text': newText.trim(),
      'edited': true,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deleteMessage(String id) async {
    await _messagesRef.child(id).remove();
  }

  Future<void> markAsRead(List<ChatMessage> messages) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final updates = <String, Object?>{};
    for (final msg in messages) {
      if (msg.senderId != uid && msg.readBy[uid] != true) {
        updates['${msg.id}/readBy/$uid'] = true;
      }
    }
    if (updates.isNotEmpty) await _messagesRef.update(updates);
  }

  Stream<int> unreadCount() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(0);
    return messages().map((items) => items.where((m) => m.senderId != uid && m.readBy[uid] != true && !m.deleted).length);
  }


  Future<List<String>> seenNames(ChatMessage message) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null || message.senderId != currentUid) return <String>[];

    final seenUids = message.readBy.entries
        .where((entry) => entry.value == true && entry.key != currentUid)
        .map((entry) => entry.key)
        .toSet()
        .toList();

    if (seenUids.isEmpty) return <String>[];

    final names = <String>[];
    for (final uid in seenUids) {
      final snap = await _usersRef.child(uid).get();
      if (snap.value is Map) {
        final user = AppUser.fromMap(Map<dynamic, dynamic>.from(snap.value as Map), uid);
        names.add(user.fullName);
      } else {
        names.add('Foydalanuvchi');
      }
    }
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }

  Future<void> setTyping(AppUser user, bool typing) async {
    if (typing) {
      await _typingRef.child(user.uid).set({
        'name': user.fullName,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      await _typingRef.child(user.uid).remove();
    }
  }

  Stream<List<String>> typingUsers(String currentUid) {
    return _typingRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <String>[];
      final now = DateTime.now().millisecondsSinceEpoch;
      final names = <String>[];
      value.forEach((key, val) {
        if (key.toString() == currentUid || val is! Map) return;
        final updatedAt = int.tryParse((val['updatedAt'] ?? '').toString()) ?? 0;
        if (now - updatedAt < 6000) names.add((val['name'] ?? 'Kimdir').toString());
      });
      return names;
    });
  }
}
