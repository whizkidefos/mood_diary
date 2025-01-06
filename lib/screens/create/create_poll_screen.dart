import 'package:flutter/material.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({super.key});

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  Duration _duration = const Duration(days: 1);
  bool _allowMultipleChoices = false;
  bool _showResultsInstantly = true;

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Poll'),
        actions: [
          TextButton(
            onPressed: _createPoll,
            child: const Text('Post'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                hintText: 'Ask your question...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a question';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildOptionsList(),
            const SizedBox(height: 8),
            if (_optionControllers.length < 8)
              OutlinedButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add),
                label: const Text('Add Option'),
              ),
            const SizedBox(height: 24),
            _buildPollSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsList() {
    return Column(
      children: List.generate(
        _optionControllers.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text('${index + 1}'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _optionControllers[index],
                  decoration: InputDecoration(
                    hintText: 'Option ${index + 1}',
                    border: const OutlineInputBorder(),
                    suffixIcon: index >= 2
                        ? IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _removeOption(index),
                          )
                        : null,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter an option';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPollSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Poll Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Duration>(
              value: _duration,
              decoration: const InputDecoration(
                labelText: 'Poll Duration',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: const Duration(hours: 24),
                  child: const Text('1 day'),
                ),
                DropdownMenuItem(
                  value: const Duration(days: 3),
                  child: const Text('3 days'),
                ),
                DropdownMenuItem(
                  value: const Duration(days: 7),
                  child: const Text('1 week'),
                ),
                DropdownMenuItem(
                  value: const Duration(days: 30),
                  child: const Text('1 month'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _duration = value);
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Allow Multiple Choices'),
              subtitle: Text(
                'Users can select multiple options',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: _allowMultipleChoices,
              onChanged: (value) {
                setState(() => _allowMultipleChoices = value);
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Show Results Instantly'),
              subtitle: Text(
                'Users can see results before voting',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: _showResultsInstantly,
              onChanged: (value) {
                setState(() => _showResultsInstantly = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createPoll() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement poll creation
      Navigator.pop(context);
    }
  }
}
