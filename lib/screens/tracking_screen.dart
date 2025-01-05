import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tracking_entry.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _waterController = TextEditingController(text: '0');
  final _stepsController = TextEditingController(text: '0');
  final _sleepController = TextEditingController(text: '0.0');
  final _mealsController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  bool _tookMedication = false;

  @override
  void dispose() {
    _waterController.dispose();
    _stepsController.dispose();
    _sleepController.dispose();
    _mealsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveTracking() async {
    try {
      final entry = TrackingEntry(
        id: DateTime.now().toIso8601String(),
        date: DateTime.now(),
        waterIntake: int.tryParse(_waterController.text) ?? 0,
        steps: int.tryParse(_stepsController.text) ?? 0,
        sleepHours: double.tryParse(_sleepController.text) ?? 0.0,
        tookMedication: _tookMedication,
        healthyMeals: int.tryParse(_mealsController.text) ?? 0,
        notes: _notesController.text,
      );

      await FirebaseFirestore.instance
          .collection('tracking_entries')
          .add(entry.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tracking data saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTracking,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tracking_entries')
            .orderBy('date', descending: true)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTrackingCard(
                  title: 'Water Intake',
                  icon: Icons.water_drop,
                  color: Colors.blue,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _waterController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Glasses of water',
                            suffix: Text('glasses'),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          final current =
                              int.tryParse(_waterController.text) ?? 0;
                          _waterController.text = (current + 1).toString();
                        },
                      ),
                    ],
                  ),
                ),
                _buildTrackingCard(
                  title: 'Step Count',
                  icon: Icons.directions_walk,
                  color: Colors.green,
                  child: TextField(
                    controller: _stepsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Number of steps',
                      suffix: Text('steps'),
                    ),
                  ),
                ),
                _buildTrackingCard(
                  title: 'Sleep',
                  icon: Icons.bedtime,
                  color: Colors.indigo,
                  child: TextField(
                    controller: _sleepController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Hours of sleep',
                      suffix: Text('hours'),
                    ),
                  ),
                ),
                _buildTrackingCard(
                  title: 'Medication',
                  icon: Icons.medication,
                  color: Colors.red,
                  child: SwitchListTile(
                    title: const Text('Took medication today?'),
                    value: _tookMedication,
                    onChanged: (value) =>
                        setState(() => _tookMedication = value),
                  ),
                ),
                _buildTrackingCard(
                  title: 'Healthy Meals',
                  icon: Icons.restaurant,
                  color: Colors.orange,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _mealsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Number of healthy meals',
                            suffix: Text('meals'),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          final current =
                              int.tryParse(_mealsController.text) ?? 0;
                          _mealsController.text = (current + 1).toString();
                        },
                      ),
                    ],
                  ),
                ),
                _buildTrackingCard(
                  title: 'Notes',
                  icon: Icons.note,
                  color: Colors.purple,
                  child: TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Add any notes about your day',
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: FilledButton.icon(
                    onPressed: _saveTracking,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Today\'s Tracking'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrackingCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
