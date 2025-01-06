import 'package:cloud_firestore/cloud_firestore.dart';

class Poll {
  final String id;
  final String question;
  final List<PollOption> options;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String createdBy;
  final bool isMultiChoice;

  Poll({
    required this.id,
    required this.question,
    required this.options,
    required this.createdAt,
    required this.expiresAt,
    required this.createdBy,
    this.isMultiChoice = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options.map((opt) => opt.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'createdBy': createdBy,
      'isMultiChoice': isMultiChoice,
    };
  }

  factory Poll.fromMap(Map<String, dynamic> map) {
    return Poll(
      id: map['id'],
      question: map['question'],
      options: (map['options'] as List)
          .map((opt) => PollOption.fromMap(opt))
          .toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'],
      isMultiChoice: map['isMultiChoice'] ?? false,
    );
  }
}

class PollOption {
  final String text;
  final List<String> votes;

  PollOption({
    required this.text,
    required this.votes,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'votes': votes,
    };
  }

  factory PollOption.fromMap(Map<String, dynamic> map) {
    return PollOption(
      text: map['text'],
      votes: List<String>.from(map['votes']),
    );
  }
}

class GroupEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String createdBy;
  final List<String> attendees;
  final List<String> maybeAttending;
  final List<String> notAttending;
  final List<String> tags;
  final String? imageUrl;

  GroupEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.createdBy,
    required this.attendees,
    required this.maybeAttending,
    required this.notAttending,
    required this.tags,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'location': location,
      'createdBy': createdBy,
      'attendees': attendees,
      'maybeAttending': maybeAttending,
      'notAttending': notAttending,
      'tags': tags,
      'imageUrl': imageUrl,
    };
  }

  factory GroupEvent.fromMap(Map<String, dynamic> map) {
    return GroupEvent(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      location: map['location'],
      createdBy: map['createdBy'],
      attendees: List<String>.from(map['attendees']),
      maybeAttending: List<String>.from(map['maybeAttending']),
      notAttending: List<String>.from(map['notAttending']),
      tags: List<String>.from(map['tags']),
      imageUrl: map['imageUrl'],
    );
  }
}
