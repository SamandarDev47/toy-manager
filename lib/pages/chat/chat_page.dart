import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/app_user.dart';
import '../../models/chat_message.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../theme/app_theme.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _service = ChatService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  AppUser? _me;
  ChatMessage? _replyTo;
  ChatMessage? _editing;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    AuthService.instance.getCurrentProfile().then((value) {
      if (mounted) setState(() => _me = value);
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    if (_me != null) _service.setTyping(_me!, false);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final me = _me;
    if (me == null || _controller.text.trim().isEmpty) return;
    final text = _controller.text;
    _controller.clear();
    if (_editing != null) {
      await _service.editMessage(_editing!.id, text);
      setState(() => _editing = null);
    } else {
      await _service.sendMessage(text: text, sender: me, replyTo: _replyTo);
      setState(() => _replyTo = null);
    }
    await _service.setTyping(me, false);
    _jumpBottom();
  }

  void _onTyping(String _) {
    final me = _me;
    if (me == null) return;
    _service.setTyping(me, true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () => _service.setTyping(me, false));
  }

  void _jumpBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = _me?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Guruh chat'),
            if (uid.isNotEmpty)
              StreamBuilder<List<String>>(
                stream: _service.typingUsers(uid),
                builder: (context, snap) {
                  final names = snap.data ?? [];
                  return Text(names.isEmpty ? 'To‘y jamoasi' : '${names.join(', ')} yozmoqda...', style: const TextStyle(fontSize: 12, color: AppTheme.muted));
                },
              ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: Column(
          children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _service.messages(),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                if (_me != null && messages.isNotEmpty) _service.markAsRead(messages);
                WidgetsBinding.instance.addPostFrameCallback((_) => _jumpBottom());
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (messages.isEmpty) {
                  return const Center(child: Text('Hali xabar yo‘q. Birinchi bo‘lib yozing 👋'));
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _MessageBubble(
                      message: msg,
                      isMe: msg.senderId == uid,
                      onReply: () => setState(() => _replyTo = msg),
                      onEdit: msg.senderId == uid && !msg.deleted ? () {
                        _controller.text = msg.text;
                        setState(() => _editing = msg);
                      } : null,
                      onDelete: msg.senderId == uid && !msg.deleted ? () => _service.deleteMessage(msg.id) : null,
                    );
                  },
                );
              },
            ),
          ),
          if (_replyTo != null || _editing != null)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.stroke), boxShadow: AppTheme.smallShadow),
              child: Row(children: [
                Icon(_editing != null ? Icons.edit : Icons.reply, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(_editing != null ? 'Xabarni tahrirlash' : '${_replyTo!.senderName}: ${_replyTo!.text}', maxLines: 1, overflow: TextOverflow.ellipsis)),
                IconButton(onPressed: () => setState(() { _replyTo = null; _editing = null; _controller.clear(); }), icon: const Icon(Icons.close)),
              ]),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 96),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      onChanged: _onTyping,
                      decoration: const InputDecoration(hintText: 'Xabar yozing...'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _send,
                    style: FilledButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(16)),
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final VoidCallback onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _MessageBubble({required this.message, required this.isMe, required this.onReply, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final time = message.createdAt == 0 ? '' : DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(message.createdAt));
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMenu(context),
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .78),
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? AppTheme.primary : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe) Text('${message.senderName} • ${message.senderRole}', style: TextStyle(color: isMe ? Colors.white70 : AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 12)),
              if (message.replyToText != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 6, bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: (isMe ? Colors.white : AppTheme.primary).withOpacity(.14), borderRadius: BorderRadius.circular(12)),
                  child: Text('${message.replyToSenderName ?? ''}: ${message.replyToText}', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: isMe ? Colors.white70 : AppTheme.muted, fontSize: 12)),
                ),
              Text(message.text, style: TextStyle(color: isMe ? Colors.white : AppTheme.ink, fontSize: 15, fontStyle: message.deleted ? FontStyle.italic : FontStyle.normal)),
              const SizedBox(height: 6),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text('${message.edited ? 'tahrirlandi • ' : ''}$time', style: TextStyle(color: isMe ? Colors.white70 : AppTheme.muted, fontSize: 11)),
                if (isMe) ...[
                  const SizedBox(width: 5),
                  Icon(message.readBy.length > 1 ? Icons.done_all : Icons.done, size: 16, color: message.readBy.length > 1 ? Colors.lightBlueAccent : Colors.white70),
                ],
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.reply), title: const Text('Javob berish'), onTap: () { Navigator.pop(context); onReply(); }),
          if (onEdit != null) ListTile(leading: const Icon(Icons.edit), title: const Text('Tahrirlash'), onTap: () { Navigator.pop(context); onEdit!(); }),
          if (onDelete != null) ListTile(leading: const Icon(Icons.delete_outline, color: Colors.red), title: const Text('O‘chirish'), onTap: () { Navigator.pop(context); onDelete!(); }),
        ]),
      ),
    );
  }
}
