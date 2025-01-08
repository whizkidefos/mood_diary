import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood_entry.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _gratitudeController = TextEditingController();

  final Map<String, Map<String, dynamic>> moods = {
    'Excellent': {
      'icon': Icons.sentiment_very_satisfied,
      'color': Colors.green,
      'description': 'Feeling amazing!'
    },
    'Indifferent': {
      'icon': Icons.sentiment_neutral_outlined,
      'color': Colors.blueGrey,
      'description': 'Just going with the flow'
    },
    'Good': {
      'icon': Icons.sentiment_satisfied,
      'color': Colors.lightGreen,
      'description': 'Having a good day'
    },
    'Just Fine': {
      'icon': Icons.sentiment_neutral,
      'color': Colors.amber,
      'description': 'Feeling okay'
    },
    'Bad': {
      'icon': Icons.sentiment_dissatisfied,
      'color': Colors.orange,
      'description': 'Not feeling great'
    },
    'Terrible': {
      'icon': Icons.sentiment_very_dissatisfied,
      'color': Colors.red,
      'description': 'Having a rough day'
    },
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _noteController.dispose();
    _gratitudeController.dispose();
    super.dispose();
  }

  Future<void> _saveMoodEntry(String mood) async {
    try {
      final entry = MoodEntry(
        mood: mood,
        date: DateTime.now(),
        note: _noteController.text,
        gratitude: _gratitudeController.text,
      );

      await FirebaseFirestore.instance
          .collection('mood_entries')
          .add(entry.toMap());

      _noteController.clear();
      _gratitudeController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mood saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving mood: $e')),
        );
      }
    }
  }

  void _showMoodDialog(String mood) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(moods[mood]!['icon'] as IconData),
            const SizedBox(width: 8),
            Text('Record $mood Mood'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'How are you feeling?',
                  hintText: 'Write about your day...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _gratitudeController,
                decoration: const InputDecoration(
                  labelText: 'Gratitude',
                  hintText: 'What are you grateful for today?',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _saveMoodEntry(mood);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodStats(List<MoodEntry> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final moodCounts = <String, int>{};
    for (var entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...moodCounts.entries.map((e) {
              final percentage =
                  (e.value / entries.length * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(moods[e.key]!['icon'] as IconData,
                            color: moods[e.key]!['color'] as Color),
                        const SizedBox(width: 8),
                        Text('${e.key}: $percentage%'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: e.value / entries.length,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(
                        moods[e.key]!['color'] as Color,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(List<MoodEntry> entries) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: daysInMonth,
              itemBuilder: (context, index) {
                final day = index + 1;
                final entry = entries.firstWhere(
                  (e) => e.date.day == day && e.date.month == now.month,
                  orElse: () => MoodEntry(mood: '', date: DateTime.now()),
                );

                return Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: entry.mood.isNotEmpty
                        ? (moods[entry.mood]!['color'] as Color)
                            .withOpacity(0.7)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        color:
                            entry.mood.isNotEmpty ? Colors.white : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: moods.length,
      itemBuilder: (context, index) {
        final mood = moods.entries.elementAt(index);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.5, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _controller,
            curve: Interval(
              index * 0.1,
              0.5 + index * 0.1,
              curve: Curves.easeOut,
            ),
          )),
          child: _buildMoodCard(mood.key, mood.value),
        );
      },
    );
  }

  Widget _buildMoodCard(String mood, Map<String, dynamic> moodData) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _showMoodDialog(mood),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                (moodData['color'] as Color).withOpacity(0.7),
                moodData['color'] as Color,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                moodData['icon'] as IconData,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                mood,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                moodData['description'] as String,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodHistory(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No mood entries yet')),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = entries[index];
          final moodData = moods[entry.mood]!;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: moodData['color'] as Color,
                  child: Icon(
                    moodData['icon'] as IconData,
                    color: Colors.white,
                  ),
                ),
                title: Text(entry.mood),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (entry.note != null && entry.note!.isNotEmpty)
                      Text('Note: ${entry.note}'),
                    if (entry.gratitude != null && entry.gratitude!.isNotEmpty)
                      Text('Grateful for: ${entry.gratitude}'),
                  ],
                ),
                trailing: Text(
                  '${entry.date.hour}:${entry.date.minute.toString().padLeft(2, '0')}',
                ),
              ),
            ),
          );
        },
        childCount: entries.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('mood_entries')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data?.docs.map((doc) {
                return MoodEntry.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                );
              }).toList() ??
              [];

          return CustomScrollView(
            slivers: [
              const SliverAppBar.medium(
                title: Text('Mood Tracker'),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How are you feeling?',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      _buildMoodGrid(),
                      const SizedBox(height: 24),
                      Text(
                        'Your Moods',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _buildCalendarView(entries),
                      const SizedBox(height: 16),
                      _buildMoodStats(entries),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              _buildMoodHistory(entries),
            ],
          );
        },
      ),
    );
  }
}
