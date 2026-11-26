class SmokingRecord {
  const SmokingRecord({
    required this.id,
    required this.date,
    required this.count,
    required this.target,
    required this.note,
  });

  final int id;
  final String date;
  final int count;
  final int target;
  final String note;

  factory SmokingRecord.fromJson(Map<String, dynamic> json) {
    return SmokingRecord(
      id: (json['id'] as num).toInt(),
      date: json['date'] as String,
      count: (json['count'] as num).toInt(),
      target: (json['target'] as num).toInt(),
      note: (json['note'] ?? '') as String,
    );
  }
}

enum DemoState { normal, slow, error, empty }
