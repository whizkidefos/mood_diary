class MoodEntry {
  final String mood;
  final DateTime date;
  final String? note;
  final String? gratitude;
  final String? id;

  MoodEntry({
    required this.mood,
    required this.date,
    this.note,
    this.gratitude,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'mood': mood,
      'date': date.toIso8601String(),
      'note': note,
      'gratitude': gratitude,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map, String id) {
    return MoodEntry(
      mood: map['mood'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      gratitude: map['gratitude'],
      id: id,
    );
  }
}
