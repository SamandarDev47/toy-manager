class Wedding {
  String? id;
  String eventName;
  String location;
  String weddingType;
  String date;
  String timeOfDay;
  List<String> singers;
  List<String> femaleSingers;
  List<String> musicians;
  String host;
  String owner;
  String note;

  /// 🔥 Yangi maydonlar
  String status; // "kutilmoqda", "bugun", "bajarilgan"
  DateTime? completedAt; // bajarilgan to‘y vaqti (auto-delete uchun)

  /// 🆕 Qo‘shimcha maydonlar
  String? time; // to‘y vaqti
  String? phone; // telefon raqami
  String? description; // qo‘shimcha izoh

  Wedding({
    this.id,
    required this.eventName,
    required this.location,
    required this.weddingType,
    required this.date,
    required this.timeOfDay,
    required this.singers,
    required this.femaleSingers,
    required this.musicians,
    required this.host,
    required this.owner,
    required this.note,
    this.status = "kutilmoqda",
    this.completedAt,
    this.time,
    this.phone,
    this.description,
  });

  /// 🔹 Firebase'dan o‘qish
  factory Wedding.fromMap(Map<dynamic, dynamic> map, String id) {
    return Wedding(
      id: id,
      eventName: map['eventName'] ?? '',
      location: map['location'] ?? '',
      weddingType: map['weddingType'] ?? '',
      date: map['date'] ?? '',
      timeOfDay: map['timeOfDay'] ?? '',
      singers: List<String>.from(map['singers'] ?? []),
      femaleSingers: List<String>.from(map['femaleSingers'] ?? []),
      musicians: List<String>.from(map['musicians'] ?? []),
      host: map['host'] ?? '',
      owner: map['owner'] ?? '',
      note: map['note'] ?? '',
      status: map['status'] ?? 'kutilmoqda',
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'])
          : null,
      time: map['time'],
      phone: map['phone'],
      description: map['description'],
    );
  }

  /// 🔹 Firebase'ga yozish
  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'location': location,
      'weddingType': weddingType,
      'date': date,
      'timeOfDay': timeOfDay,
      'singers': singers,
      'femaleSingers': femaleSingers,
      'musicians': musicians,
      'host': host,
      'owner': owner,
      'note': note,
      'status': status,
      'completedAt': completedAt?.toIso8601String(),
      'time': time,
      'phone': phone,
      'description': description,
    };
  }

  /// 🔹 copyWith
  Wedding copyWith({
    String? id,
    String? eventName,
    String? location,
    String? weddingType,
    String? date,
    String? timeOfDay,
    List<String>? singers,
    List<String>? femaleSingers,
    List<String>? musicians,
    String? host,
    String? owner,
    String? note,
    String? status,
    DateTime? completedAt,
    String? time,
    String? phone,
    String? description,
  }) {
    return Wedding(
      id: id ?? this.id,
      eventName: eventName ?? this.eventName,
      location: location ?? this.location,
      weddingType: weddingType ?? this.weddingType,
      date: date ?? this.date,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      singers: singers ?? this.singers,
      femaleSingers: femaleSingers ?? this.femaleSingers,
      musicians: musicians ?? this.musicians,
      host: host ?? this.host,
      owner: owner ?? this.owner,
      note: note ?? this.note,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      time: time ?? this.time,
      phone: phone ?? this.phone,
      description: description ?? this.description,
    );
  }

  /// 🔹 Sana asosida statusni avtomatik yangilash
  void updateStatus() {
    try {
      final now = DateTime.now();
      final eventDate = DateTime.tryParse(date);

      if (eventDate == null) {
        status = "noma’lum";
        return;
      }

      final today = DateTime(now.year, now.month, now.day);
      final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);

      if (eventDay.isAfter(today)) {
        status = "kutilmoqda"; // hali bo‘lmagan
      } else if (eventDay.isAtSameMomentAs(today)) {
        status = "bugun"; // bugun to‘y bor
      } else {
        status = "bajarilgan"; // o‘tgan to‘y
        completedAt ??= DateTime.now();
      }
    } catch (e) {
      status = "noma’lum";
    }
  }

  /// 🔹 24 soat o‘tgan "bajarilgan" to‘ylarni o‘chirish kerakligini tekshirish
  bool shouldDelete() {
    if (status != "bajarilgan" || completedAt == null) return false;
    final diff = DateTime.now().difference(completedAt!);
    return diff.inHours >= 24;
  }
}
