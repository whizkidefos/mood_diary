import 'package:flutter/material.dart';
import 'games/memory_game.dart';
import 'games/color_patterns.dart';
import 'games/word_search.dart';
import 'exercise_details.dart';
import 'journal_entry.dart';
import 'music_player.dart';
import 'meditation_details.dart';
import 'art_therapy.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  int _selectedCategory = 0;
  bool _isBreathing = false;
  int _breathCount = 0;
  final int _breathTarget = 4;

  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.sports_handball,
      'label': 'Exercise',
      'color': Colors.orange,
      'description': 'Physical activities to boost your mood and energy',
      'tip': 'Start with small, achievable goals',
    },
    {
      'icon': Icons.self_improvement,
      'label': 'Breathing',
      'color': Colors.blue,
      'description': 'Breathing exercises for stress relief',
      'tip': 'Take deep breaths throughout the day',
    },
    {
      'icon': Icons.edit_note,
      'label': 'Journal',
      'color': Colors.purple,
      'description': 'Express your thoughts and feelings',
      'tip': 'Write freely without judgment',
    },
    {
      'icon': Icons.games,
      'label': 'Games',
      'color': Colors.green,
      'description': 'Fun activities to keep your mind engaged',
      'tip': 'Take breaks between activities',
    },
    {
      'icon': Icons.self_improvement,
      'label': 'Meditation',
      'color': Colors.deepPurple,
      'description': 'Guided sessions for inner peace',
      'tip': 'Find a quiet space to practice',
    },
    {
      'icon': Icons.palette,
      'label': 'Art Therapy',
      'color': Colors.pink,
      'description': 'Express yourself through creativity',
      'tip': 'Focus on the process, not the result',
    },
    {
      'icon': Icons.music_note,
      'label': 'Music',
      'color': Colors.teal,
      'description': 'Calming sounds and melodies',
      'tip': 'Use headphones for best experience',
    },
    {
      'icon': Icons.sports_handball,
      'label': 'Exercise',
      'color': Colors.orange,
    },
    {
      'icon': Icons.self_improvement,
      'label': 'Breathing',
      'color': Colors.blue,
    },
    {
      'icon': Icons.edit_note,
      'label': 'Journal',
      'color': Colors.purple,
    },
    {
      'icon': Icons.games,
      'label': 'Games',
      'color': Colors.green,
    },
    {
      'icon': Icons.self_improvement,
      'label': 'Meditation',
      'color': Colors.deepPurple,
    },
    {
      'icon': Icons.palette,
      'label': 'Art Therapy',
      'color': Colors.pink,
    },
    {
      'icon': Icons.music_note,
      'label': 'Music',
      'color': Colors.teal,
    },
  ];

  final List<Map<String, dynamic>> _exercises = [
    {
      'title': 'Walking',
      'duration': '20 mins',
      'description': 'Take a mindful walk outside',
      'icon': Icons.directions_walk,
      'instructions':
          'Start with a slow pace, focus on your breathing, and observe your surroundings.',
    },
    {
      'title': 'Stretching',
      'duration': '10 mins',
      'description': 'Basic full-body stretches',
      'icon': Icons.accessibility_new,
      'instructions':
          'Gentle stretches for your neck, shoulders, back, and legs.',
    },
    {
      'title': 'Yoga',
      'duration': '15 mins',
      'description': 'Simple yoga poses for beginners',
      'icon': Icons.self_improvement,
      'instructions':
          'Basic poses including mountain pose, child\'s pose, and downward dog.',
    },
  ];

  final List<Map<String, dynamic>> _meditations = [
    {
      'title': 'Body Scan',
      'duration': '10 mins',
      'description': 'Progressive relaxation meditation',
      'icon': Icons.spa,
    },
    {
      'title': 'Mindful Breathing',
      'duration': '5 mins',
      'description': 'Focus on your breath',
      'icon': Icons.air,
    },
    {
      'title': 'Loving Kindness',
      'duration': '15 mins',
      'description': 'Develop compassion and empathy',
      'icon': Icons.favorite,
    },
  ];

  final List<Map<String, dynamic>> _artTherapy = [
    {
      'title': 'Mandala Drawing',
      'description': 'Create patterns for relaxation',
      'icon': Icons.brush,
    },
    {
      'title': 'Color Emotions',
      'description': 'Express feelings through colors',
      'icon': Icons.palette,
    },
    {
      'title': 'Free Sketching',
      'description': 'Draw whatever comes to mind',
      'icon': Icons.edit,
    },
  ];

  final List<Map<String, dynamic>> _musicTherapy = [
    {
      'title': 'Nature Sounds',
      'duration': '30 mins',
      'description': 'Calming forest and ocean sounds',
      'icon': Icons.forest,
    },
    {
      'title': 'Relaxing Piano',
      'duration': '20 mins',
      'description': 'Soft piano melodies',
      'icon': Icons.piano,
    },
    {
      'title': 'Meditation Bells',
      'duration': '15 mins',
      'description': 'Tibetan singing bowls',
      'icon': Icons.music_note,
    },
  ];

  final List<String> _journalPrompts = [
    'What made you smile today?',
    'Write about a challenge you overcame recently.',
    'List three things you\'re grateful for.',
    'What\'s something you\'re looking forward to?',
    'Describe your ideal day.',
    'What\'s one thing you\'d like to improve about yourself?',
    'Write about someone who inspires you.',
  ];

  void _startBreathingExercise() {
    setState(() {
      _isBreathing = true;
      _breathCount = 0;
    });
    _runBreathingCycle();
  }

  Future<void> _runBreathingCycle() async {
    if (!_isBreathing) return;

    setState(() => _breathCount++);

    if (_breathCount > _breathTarget) {
      setState(() => _isBreathing = false);
      return;
    }

    await Future.delayed(const Duration(seconds: 4)); // Inhale
    if (!_isBreathing) return;

    await Future.delayed(const Duration(seconds: 4)); // Hold
    if (!_isBreathing) return;

    await Future.delayed(const Duration(seconds: 4)); // Exhale
    if (!_isBreathing) return;

    _runBreathingCycle();
  }

  Widget _buildCategoryHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryHeader('Daily Exercises', _categories[0]['color']),
        Expanded(
          child: ListView.builder(
            itemCount: _exercises.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final exercise = _exercises[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _categories[0]['color'],
                    child: Icon(exercise['icon'], color: Colors.white),
                  ),
                  title: Text(exercise['title']),
                  subtitle: Text(exercise['description']),
                  trailing: Text(exercise['duration']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ExerciseDetails(exercise: exercise),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBreathingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isBreathing) ...[
            AnimatedContainer(
              duration: const Duration(seconds: 4),
              width: _breathCount % 3 == 1 ? 200 : 100,
              height: _breathCount % 3 == 1 ? 200 : 100,
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: _categories[1]['color'],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _breathCount % 3 == 0
                      ? 'Inhale'
                      : _breathCount % 3 == 1
                          ? 'Hold'
                          : 'Exhale',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ] else ...[
            Text(
              'Box Breathing',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(
              'Inhale for 4 seconds\nHold for 4 seconds\nExhale for 4 seconds',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _startBreathingExercise,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Breathing Exercise'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJournalContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _journalPrompts.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prompt ${index + 1}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _journalPrompts[index],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JournalEntry(
                              prompt: _journalPrompts[index],
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Write'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGamesContent() {
    final games = [
      {
        'title': 'Memory Cards',
        'description': 'Test and improve your memory',
        'icon': Icons.grid_view,
        'screen': const MemoryGame(),
      },
      {
        'title': 'Color Patterns',
        'description': 'Follow the sequence',
        'icon': Icons.palette,
        'screen': const ColorPatterns(),
      },
      {
        'title': 'Word Search',
        'description': 'Find hidden positive words',
        'icon': Icons.search,
        'screen': const WordSearch(),
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return Card(
          child: InkWell(
            onTap: game['screen'] != null
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => game['screen'] as Widget,
                      ),
                    )
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    game['icon'] as IconData,
                    size: 48,
                    color: _categories[3]['color'],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    game['title'] as String,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    game['description'] as String,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMeditationContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _meditations.length,
      itemBuilder: (context, index) {
        final meditation = _meditations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _categories[4]['color'],
              child: Icon(meditation['icon'], color: Colors.white),
            ),
            title: Text(meditation['title']),
            subtitle: Text(meditation['description']),
            trailing: Text(meditation['duration']),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MeditationDetails(
                  meditation: meditation,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArtTherapyContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _artTherapy.length,
      itemBuilder: (context, index) {
        final art = _artTherapy[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _categories[5]['color'],
              child: Icon(art['icon'], color: Colors.white),
            ),
            title: Text(art['title']),
            subtitle: Text(art['description']),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArtTherapy(
                  activity: art,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMusicContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _musicTherapy.length,
      itemBuilder: (context, index) {
        final music = _musicTherapy[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _categories[6]['color'],
              child: Icon(music['icon'], color: Colors.white),
            ),
            title: Text(music['title']),
            subtitle: Text(music['description']),
            trailing: Text(music['duration']),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MusicPlayer(
                  track: music,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Activities',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == index;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCategory = index),
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? category['color']
                                        : category['color'].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    category['icon'],
                                    color: isSelected
                                        ? Colors.white
                                        : category['color'],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category['label'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? category['color']
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_selectedCategory >= 0)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _categories[_selectedCategory]['description'],
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 16,
                                color: _categories[_selectedCategory]['color'],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Tip: ${_categories[_selectedCategory]['tip']}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: _categories[_selectedCategory]
                                            ['color'],
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedCategory,
              children: [
                _buildExerciseContent(),
                _buildBreathingContent(),
                _buildJournalContent(),
                _buildGamesContent(),
                _buildMeditationContent(),
                _buildArtTherapyContent(),
                _buildMusicContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
