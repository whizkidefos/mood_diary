class TrackingEntry {
  final String id;
  final DateTime date;
  final int waterIntake; // in glasses
  final int steps;
  final double sleepHours;
  final bool tookMedication;
  final int healthyMeals;
  final String? notes;

  TrackingEntry({
    required this.id,
    required this.date,
    required this.waterIntake,
    required this.steps,
    required this.sleepHours,
    required this.tookMedication,
    required this.healthyMeals,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'waterIntake': waterIntake,
      'steps': steps,
      'sleepHours': sleepHours,
      'tookMedication': tookMedication,
      'healthyMeals': healthyMeals,
      'notes': notes,
    };
  }

  factory TrackingEntry.fromMap(Map<String, dynamic> map, String id) {
    return TrackingEntry(
      id: id,
      date: DateTime.parse(map['date']),
      waterIntake: map['waterIntake'] ?? 0,
      steps: map['steps'] ?? 0,
      sleepHours: (map['sleepHours'] ?? 0).toDouble(),
      tookMedication: map['tookMedication'] ?? false,
      healthyMeals: map['healthyMeals'] ?? 0,
      notes: map['notes'],
    );
  }
}
