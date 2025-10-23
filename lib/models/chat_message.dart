class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderPhone;
  final String senderRole;
  final String text;
  final int createdAt;
  final int updatedAt;
  final bool edited;
  final bool deleted;
  final String? replyToId;
  final String? replyToText;
  final String? replyToSenderName;
  final Map<String, bool> readBy;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderPhone,
    required this.senderRole,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.edited = false,
    this.deleted = false,
    this.replyToId,
    this.replyToText,
    this.replyToSenderName,
    this.readBy = const {},
  });

  factory ChatMessage.fromMap(Map<dynamic, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      senderId: (map['senderId'] ?? '').toString(),
      senderName: (map['senderName'] ?? '').toString(),
      senderPhone: (map['senderPhone'] ?? '').toString(),
      senderRole: (map['senderRole'] ?? 'user').toString(),
      text: (map['text'] ?? '').toString(),
      createdAt: _asInt(map['createdAt']),
      updatedAt: _asInt(map['updatedAt']),
      edited: map['edited'] == true,
      deleted: map['deleted'] == true,
      replyToId: map['replyToId']?.toString(),
      replyToText: map['replyToText']?.toString(),
      replyToSenderName: map['replyToSenderName']?.toString(),
      readBy: _readMap(map['readBy']),
    );
  }

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'senderName': senderName,
        'senderPhone': senderPhone,
        'senderRole': senderRole,
        'text': text.trim(),
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'edited': edited,
        'deleted': deleted,
        'replyToId': replyToId,
        'replyToText': replyToText,
        'replyToSenderName': replyToSenderName,
        'readBy': readBy,
      };

  static Map<String, bool> _readMap(dynamic value) {
    if (value is! Map) return {};
    return value.map((key, val) => MapEntry(key.toString(), val == true));
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
