import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatAnalyticsService {
  final _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getDetailedChatStats(String chatId) async {
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    final stats = {
      'messageCount': messages.size,
      'mediaCount': 0,
      'voiceMessageCount': 0,
      'responseTime': Duration.zero,
      'mostActiveHours': <int, int>{},
      'messagesByDate': <String, int>{},
      'messageTypes': <String, int>{},
      'participantStats': <String, Map<String, dynamic>>{},
      'wordFrequency': <String, int>{},
      'averageMessageLength': 0,
      'longestMessage': '',
      'totalWords': 0,
    };

    DateTime? lastMessageTime;
    String? lastSenderId;
    int totalCharacters = 0;

    for (final doc in messages.docs) {
      final message = doc.data();
      final timestamp = (message['timestamp'] as Timestamp).toDate();
      final senderId = message['senderId'] as String;
      final type = message['type'] as String;
      final text = message['text'] as String? ?? '';

      // Count message types
      stats['messageTypes'][type] = (stats['messageTypes'][type] ?? 0) + 1;

      // Count media and voice messages
      if (type == 'media') stats['mediaCount']++;
      if (type == 'voice') stats['voiceMessageCount']++;

      // Track activity by hour
      final hour = timestamp.hour;
      stats['mostActiveHours'][hour] =
          (stats['mostActiveHours'][hour] ?? 0) + 1;

      // Track messages by date
      final date = DateFormat('yyyy-MM-dd').format(timestamp);
      stats['messagesByDate'][date] = (stats['messagesByDate'][date] ?? 0) + 1;

      // Calculate response times
      if (lastMessageTime != null && lastSenderId != senderId) {
        final responseTime = timestamp.difference(lastMessageTime);
        stats['responseTime'] += responseTime;
      }
      lastMessageTime = timestamp;
      lastSenderId = senderId;

      // Track participant statistics
      if (!stats['participantStats'].containsKey(senderId)) {
        stats['participantStats'][senderId] = {
          'messageCount': 0,
          'wordCount': 0,
          'characterCount': 0,
          'mediaCount': 0,
        };
      }
      stats['participantStats'][senderId]['messageCount']++;
      if (type == 'media') {
        stats['participantStats'][senderId]['mediaCount']++;
      }

      // Analyze text content
      if (text.isNotEmpty) {
        final words = text.split(' ');
        stats['totalWords'] += words.length;
        stats['participantStats'][senderId]['wordCount'] += words.length;
        stats['participantStats'][senderId]['characterCount'] += text.length;
        totalCharacters += text.length;

        for (final word in words) {
          if (word.length > 3) {
            // Ignore short words
            stats['wordFrequency'][word.toLowerCase()] =
                (stats['wordFrequency'][word.toLowerCase()] ?? 0) + 1;
          }
        }

        if (text.length > (stats['longestMessage'] as String).length) {
          stats['longestMessage'] = text;
        }
      }
    }

    // Calculate averages
    if (messages.size > 0) {
      stats['averageMessageLength'] = totalCharacters / messages.size;
    }

    // Sort word frequency
    final sortedWords = Map.fromEntries(
        (stats['wordFrequency'] as Map<String, int>).entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)));
    stats['wordFrequency'] = Map.fromEntries(sortedWords.entries.take(50));

    return stats;
  }

  Stream<Map<String, dynamic>> getRealtimeStats(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .snapshots()
        .map((snapshot) {
      final stats = {
        'messageCount': snapshot.size,
        'lastActivity': snapshot.docs.isNotEmpty
            ? (snapshot.docs.first.data()['timestamp'] as Timestamp).toDate()
            : null,
        'activeToday': 0,
        'activeThisWeek': 0,
      };

      final now = DateTime.now();
      for (final doc in snapshot.docs) {
        final timestamp = (doc.data()['timestamp'] as Timestamp).toDate();
        if (timestamp.isAfter(now.subtract(const Duration(days: 1)))) {
          stats['activeToday'] = (stats['activeToday'] as int) + 1;
        }
        if (timestamp.isAfter(now.subtract(const Duration(days: 7)))) {
          stats['activeThisWeek'] = (stats['activeThisWeek'] as int) + 1;
        }
      }

      return stats;
    });
  }

  Future<void> generateReport(String chatId) async {
    final stats = await getDetailedChatStats(chatId);
    final report = {
      'generatedAt': FieldValue.serverTimestamp(),
      'stats': stats,
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('reports')
        .add(report);
  }
}

// lib/widgets/chat_stats_view.dart
class ChatStatsView extends StatefulWidget {
  final String chatId;

  const ChatStatsView({
    super.key,
    required this.chatId,
  });

  @override
  State<ChatStatsView> createState() => _ChatStatsViewState();
}

class _ChatStatsViewState extends State<ChatStatsView> {
  final _analyticsService = ChatAnalyticsService();
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _analyticsService.getDetailedChatStats(widget.chatId);
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading statistics')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stats == null) {
      return const Center(child: Text('No statistics available'));
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat Statistics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Activity'),
              Tab(text: 'Content'),
              Tab(text: 'Participants'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(),
            _buildActivityTab(),
            _buildContentTab(),
            _buildParticipantsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          'Messages',
          [
            _buildStatItem('Total Messages', _stats!['messageCount']),
            _buildStatItem('Media Messages', _stats!['mediaCount']),
            _buildStatItem('Voice Messages', _stats!['voiceMessageCount']),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          'Response Time',
          [
            _buildStatItem(
              'Average Response',
              '${(_stats!['responseTime'] as Duration).inMinutes} minutes',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityTab() {
    final hourlyData = (_stats!['mostActiveHours'] as Map<int, int>)
        .entries
        .map((e) => {'hour': e.key, 'count': e.value})
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: hourlyData
                  .map((e) => e['count'] as num)
                  .reduce(max)
                  .toDouble(),
              barGroups: hourlyData
                  .map((data) => BarChartGroupData(
                        x: data['hour'] as int,
                        barRods: [
                          BarChartRodData(
                            toY: (data['count'] as num).toDouble(),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentTab() {
    final wordFrequency = _stats!['wordFrequency'] as Map<String, int>;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          'Content Analysis',
          [
            _buildStatItem('Total Words', _stats!['totalWords']),
            _buildStatItem(
              'Average Message Length',
              '${_stats!['averageMessageLength'].toStringAsFixed(1)} characters',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Most Used Words',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: wordFrequency.entries
                      .take(20)
                      .map((e) => Chip(
                            label: Text(e.key),
                            avatar: CircleAvatar(
                              child: Text(
                                e.value.toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsTab() {
    final participantStats =
        _stats!['participantStats'] as Map<String, dynamic>;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: participantStats.entries.map((entry) {
        final stats = entry.value as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Participant ${entry.key}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildStatItem('Messages', stats['messageCount']),
                _buildStatItem('Words', stats['wordCount']),
                _buildStatItem('Media Shared', stats['mediaCount']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
