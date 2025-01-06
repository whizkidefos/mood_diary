import 'package:flutter/material.dart';
import 'package:mood_diary/models/social_event_models.dart';

class PollWidget extends StatefulWidget {
  final Poll poll;
  final Function(int, bool) onVote;

  const PollWidget({
    super.key,
    required this.poll,
    required this.onVote,
  });

  @override
  State<PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _progressAnimations;
  List<bool> _selectedOptions = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _initializeAnimations();
    _controller.forward();
  }

  void _initializeAnimations() {
    _selectedOptions = List.filled(widget.poll.options.length, false);
    _progressAnimations = widget.poll.options.map((option) {
      final totalVotes =
          widget.poll.options.fold(0, (sum, opt) => sum + opt.votes.length);

      final percentage =
          totalVotes == 0 ? 0.0 : option.votes.length / totalVotes;

      return Tween<double>(
        begin: 0,
        end: percentage,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalVotes =
        widget.poll.options.fold(0, (sum, option) => sum + option.votes.length);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.poll.question,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  '${widget.poll.expiresAt.difference(DateTime.now()).inHours}h left',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(widget.poll.options.length, (index) {
              final option = widget.poll.options[index];
              final percentage = totalVotes == 0
                  ? 0.0
                  : option.votes.length / totalVotes * 100;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (widget.poll.isMultiChoice) {
                        _selectedOptions[index] = !_selectedOptions[index];
                      } else {
                        _selectedOptions.fillRange(
                            0, _selectedOptions.length, false);
                        _selectedOptions[index] = true;
                      }
                    });
                    widget.onVote(index, _selectedOptions[index]);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedOptions[index]
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (widget.poll.isMultiChoice)
                              Checkbox(
                                value: _selectedOptions[index],
                                onChanged: (value) {
                                  setState(
                                      () => _selectedOptions[index] = value!);
                                  widget.onVote(index, value!);
                                },
                              )
                            else
                              Radio<bool>(
                                value: true,
                                groupValue: _selectedOptions[index],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOptions.fillRange(
                                        0, _selectedOptions.length, false);
                                    _selectedOptions[index] = true;
                                  });
                                  widget.onVote(index, true);
                                },
                              ),
                            Expanded(
                              child: Text(option.text),
                            ),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _progressAnimations[index],
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              value: _progressAnimations[index].value,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation(
                                Theme.of(context).colorScheme.primary,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${option.votes.length} votes',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Text(
              'Total votes: $totalVotes',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
