class UserProfile {
  final String id;
  final String name;
  final String? photoUrl;
  final String status;
  final List<String> interests;
  final int moodStreakDays;
  final Map<String, dynamic> achievements;

  UserProfile({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.status,
    required this.interests,
    required this.moodStreakDays,
    required this.achievements,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'status': status,
      'interests': interests,
      'moodStreakDays': moodStreakDays,
      'achievements': achievements,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      photoUrl: map['photoUrl'],
      status: map['status'],
      interests: List<String>.from(map['interests']),
      moodStreakDays: map['moodStreakDays'],
      achievements: Map<String, dynamic>.from(map['achievements']),
    );
  }
}

class CommunityPost {
  final String id;
  final String userId;
  final String content;
  final DateTime timestamp;
  final List<String> likes;
  final List<Comment> comments;
  final String? imageUrl;
  final String mood;
  final List<String> tags;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.comments,
    this.imageUrl,
    required this.mood,
    required this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'comments': comments.map((c) => c.toMap()).toList(),
      'imageUrl': imageUrl,
      'mood': mood,
      'tags': tags,
    };
  }

  factory CommunityPost.fromMap(Map<String, dynamic> map) {
    return CommunityPost(
      id: map['id'],
      userId: map['userId'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
      likes: List<String>.from(map['likes']),
      comments:
          (map['comments'] as List).map((c) => Comment.fromMap(c)).toList(),
      imageUrl: map['imageUrl'],
      mood: map['mood'],
      tags: List<String>.from(map['tags']),
    );
  }
}

class Comment {
  final String id;
  final String userId;
  final String content;
  final DateTime timestamp;
  final List<String> likes;

  Comment({
    required this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
    required this.likes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      userId: map['userId'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
      likes: List<String>.from(map['likes']),
    );
  }
}
