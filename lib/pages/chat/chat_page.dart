import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/app_user.dart';
import '../../models/chat_message.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../theme/app_theme.dart';

class ChatPage extends StatefulWidget {
  final bool active;
  const ChatPage({super.key, this.active = true});

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
  void didUpdateWidget(covariant ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.active && _me != null) _service.setTyping(_me!, false);
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
    if (me == null || !widget.active) return;
    _service.setTyping(me, true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () => _service.setTyping(me, false));
  }

  void _jumpBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = _me?.uid ?? '';
    return Scaffold(
      backgroundColor: AppTheme.pageBg(context),
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Guruh chat'),
          Text('To‘y jamoasi', style: TextStyle(fontSize: 12, color: AppTheme.subtext(context), fontWeight: FontWeight.w600)),
        ]),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.pageGradientOf(context)),
        child: Column(children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _service.messages(),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                if (widget.active && _me != null && messages.isNotEmpty) {
                  _service.markAsRead(messages);
                }
                WidgetsBinding.instance.addPostFrameCallback((_) => _jumpBottom());
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (messages.isEmpty) {
                  return const Center(child: Text('Hali xabar yo‘q. Birinchi bo‘lib yozing 👋'));
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  itemCount: messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == messages.length) return _TypingFooter(service: _service, currentUid: uid);
                    final msg = messages[index];
                    return _MessageBubble(
                      message: msg,
                      isMe: msg.senderId == uid,
                      onReply: () => setState(() => _replyTo = msg),
                      onEdit: msg.senderId == uid && !msg.deleted ? () { _controller.text = msg.text; setState(() => _editing = msg); } : null,
                      onDelete: msg.senderId == uid && !msg.deleted ? () => _service.deleteMessage(msg.id) : null,
                      onSeen: msg.senderId == uid ? () { _showSeen(context, msg); } : null,
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
              decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.line(context))),
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
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Row(children: [
                Expanded(child: TextField(controller: _controller, minLines: 1, maxLines: 5, onChanged: _onTyping, decoration: const InputDecoration(hintText: 'Xabar yozing...'))),
                const SizedBox(width: 8),
                FilledButton(onPressed: _send, style: FilledButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(16), minimumSize: const Size(52, 52)), child: const Icon(Icons.send_rounded)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _showSeen(BuildContext context, ChatMessage message) async {
    final names = await _service.seenNames(message);
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kimlar ko‘rgan?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              if (names.isEmpty)
                Text('Hali boshqa foydalanuvchilar ko‘rmagan.', style: TextStyle(color: AppTheme.subtext(context)))
              else ...[
                Text('${names.length} ta foydalanuvchi ko‘rgan.', style: TextStyle(color: AppTheme.subtext(context))),
                const SizedBox(height: 10),
                ...names.map(
                  (name) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary.withOpacity(.12),
                      child: Text(name.trim().isEmpty ? 'U' : name.trim()[0].toUpperCase(), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900)),
                    ),
                    title: Text(name, style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w800)),
                    subtitle: const Text('Ko‘rgan'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingFooter extends StatelessWidget {
  final ChatService service;
  final String currentUid;
  const _TypingFooter({required this.service, required this.currentUid});

  @override
  Widget build(BuildContext context) {
    if (currentUid.isEmpty) return const SizedBox(height: 8);
    return StreamBuilder<List<String>>(
      stream: service.typingUsers(currentUid),
      builder: (context, snapshot) {
        final names = snapshot.data ?? [];
        if (names.isEmpty) return const SizedBox(height: 8);
        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 4, top: 4, bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.line(context))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _TypingDots(color: AppTheme.primary),
                const SizedBox(width: 8),
                Text('${names.join(', ')} typing...', style: TextStyle(color: AppTheme.subtext(context), fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _TypingDots extends StatefulWidget {
  final Color color;
  const _TypingDots({required this.color});
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Row(children: List.generate(3, (i) {
        final v = ((_c.value * 3 - i).clamp(0.0, 1.0));
        return Container(margin: const EdgeInsets.symmetric(horizontal: 2), width: 6, height: 6 + (v * 4), decoration: BoxDecoration(color: widget.color.withOpacity(.45 + v * .55), borderRadius: BorderRadius.circular(9)));
      })),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final VoidCallback onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSeen;
  const _MessageBubble({required this.message, required this.isMe, required this.onReply, this.onEdit, this.onDelete, this.onSeen});

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
            color: isMe ? AppTheme.primary : AppTheme.card(context),
            border: Border.all(color: isMe ? Colors.transparent : AppTheme.line(context)),
            borderRadius: BorderRadius.only(topLeft: const Radius.circular(18), topRight: const Radius.circular(18), bottomLeft: Radius.circular(isMe ? 18 : 4), bottomRight: Radius.circular(isMe ? 4 : 18)),
            boxShadow: AppTheme.isDark(context) ? null : [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (!isMe) Text('${message.senderName} • ${message.senderRole}', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 12)),
            if (message.replyToText != null)
              Container(width: double.infinity, margin: const EdgeInsets.only(top: 6, bottom: 8), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: (isMe ? Colors.white : AppTheme.primary).withOpacity(.14), borderRadius: BorderRadius.circular(12)), child: Text('${message.replyToSenderName ?? ''}: ${message.replyToText}', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: isMe ? Colors.white70 : AppTheme.subtext(context), fontSize: 12))),
            Text(message.text, style: TextStyle(color: isMe ? Colors.white : AppTheme.text(context), fontSize: 15, fontStyle: message.deleted ? FontStyle.italic : FontStyle.normal)),
            const SizedBox(height: 6),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text('${message.edited ? 'tahrirlandi • ' : ''}$time', style: TextStyle(color: isMe ? Colors.white70 : AppTheme.subtext(context), fontSize: 11)),
              if (isMe) ...[
                const SizedBox(width: 5),
                Icon(message.readBy.entries.any((entry) => entry.value == true && entry.key != message.senderId) ? Icons.done_all : Icons.done, size: 16, color: message.readBy.entries.any((entry) => entry.value == true && entry.key != message.senderId) ? Colors.lightBlueAccent : Colors.white70),
              ],
            ]),
          ]),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.reply), title: const Text('Javob berish'), onTap: () { Navigator.pop(context); onReply(); }),
        if (onSeen != null) ListTile(leading: const Icon(Icons.visibility_outlined), title: const Text('Kimlar ko‘rgan?'), onTap: () { Navigator.pop(context); onSeen!(); }),
        if (onEdit != null) ListTile(leading: const Icon(Icons.edit), title: const Text('Tahrirlash'), onTap: () { Navigator.pop(context); onEdit!(); }),
        if (onDelete != null) ListTile(leading: const Icon(Icons.delete_outline, color: Colors.red), title: const Text('O‘chirish'), onTap: () { Navigator.pop(context); onDelete!(); }),
      ])),
    );
  }
}
