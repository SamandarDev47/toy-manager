import 'package:intl/intl.dart';

class Wedding {
  String? id;
  String eventName;
  String location;
  String weddingType;
  String starterType;
  String date;
  String timeOfDay;
  List<String> singers;
  List<String> femaleSingers;
  List<String> musicians;
  String host;
  String owner;
  String note;
  String status;
  DateTime? completedAt;
  String? time;
  String? phone;
  String? description;
  int createdAt;
  int updatedAt;
  String? createdBy;
  String? archivedAt;

  Wedding({
    this.id,
    required this.eventName,
    required this.location,
    required this.weddingType,
    required this.starterType,
    required this.date,
    required this.timeOfDay,
    required this.singers,
    required this.femaleSingers,
    required this.musicians,
    required this.host,
    required this.owner,
    required this.note,
    this.status = 'active',
    this.completedAt,
    this.time,
    this.phone,
    this.description,
    int? createdAt,
    int? updatedAt,
    this.createdBy,
    this.archivedAt,
  })  : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

  factory Wedding.fromMap(Map<dynamic, dynamic> map, String id) {
    return Wedding(
      id: id,
      eventName: (map['eventName'] ?? '').toString(),
      location: (map['location'] ?? '').toString(),
      weddingType: (map['weddingType'] ?? '').toString(),
      starterType: (map['starterType'] ?? '').toString(),
      date: (map['date'] ?? '').toString(),
      timeOfDay: (map['timeOfDay'] ?? '').toString(),
      singers: _stringList(map['singers']),
      femaleSingers: _stringList(map['femaleSingers']),
      musicians: _stringList(map['musicians']),
      host: (map['host'] ?? '').toString(),
      owner: (map['owner'] ?? '').toString(),
      note: (map['note'] ?? '').toString(),
      status: (map['status'] ?? 'active').toString(),
      completedAt: map['completedAt'] != null ? DateTime.tryParse(map['completedAt'].toString()) : null,
      time: map['time']?.toString(),
      phone: map['phone']?.toString(),
      description: map['description']?.toString(),
      createdAt: _asInt(map['createdAt']),
      updatedAt: _asInt(map['updatedAt']),
      createdBy: map['createdBy']?.toString(),
      archivedAt: map['archivedAt']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'location': location,
      'weddingType': weddingType,
      'starterType': starterType,
      'date': normalizeDateString(date),
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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
      'archivedAt': archivedAt,
    };
  }

  DateTime? get dateTime => parseDate(date);

  bool get isPast {
    final d = dateTime;
    if (d == null) return false;
    final today = DateTime.now();
    final current = DateTime(today.year, today.month, today.day);
    final event = DateTime(d.year, d.month, d.day);
    return event.isBefore(current);
  }

  bool get isToday {
    final d = dateTime;
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  String get displayDate {
    final d = dateTime;
    return d == null ? date : DateFormat('dd.MM.yyyy').format(d);
  }

  Wedding copyWith({
    String? id,
    String? eventName,
    String? location,
    String? weddingType,
    String? starterType,
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
    int? createdAt,
    int? updatedAt,
    String? createdBy,
    String? archivedAt,
  }) {
    return Wedding(
      id: id ?? this.id,
      eventName: eventName ?? this.eventName,
      location: location ?? this.location,
      weddingType: weddingType ?? this.weddingType,
      starterType: starterType ?? this.starterType,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  static DateTime? parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final raw = value.trim();
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;

    for (final pattern in ['dd-MM-yyyy', 'dd.MM.yyyy', 'dd/MM/yyyy', 'yyyy-MM-dd']) {
      try {
        return DateFormat(pattern).parseStrict(raw);
      } catch (_) {}
    }
    return null;
  }

  static String normalizeDateString(String value) {
    final d = parseDate(value);
    if (d == null) return value;
    return DateFormat('yyyy-MM-dd').format(d);
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    if (value is Map) return value.values.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    return <String>[];
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
