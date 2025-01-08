import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/backup_service.dart';

class BackupDialog extends StatefulWidget {
  final String chatId;

  const BackupDialog({
    super.key,
    required this.chatId,
  });

  @override
  State<BackupDialog> createState() => _BackupDialogState();
}

class _BackupDialogState extends State<BackupDialog> {
  final _backupService = BackupService();
  List<String>? _backups;
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _error;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final backups = await _backupService.listBackups(widget.chatId);
      if (mounted) {
        setState(() {
          _backups = backups;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load backups: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createBackup() async {
    try {
      setState(() {
        _isProcessing = true;
        _error = null;
        _progress = 0.0;
      });

      await _backupService.createBackup(widget.chatId);
      await _loadBackups();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to create backup: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _progress = 0.0;
        });
      }
    }
  }

  Future<void> _restoreBackup(String backupPath) async {
    try {
      setState(() {
        _isProcessing = true;
        _error = null;
        _progress = 0.0;
      });

      await _backupService.restoreBackup(backupPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restored successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to restore backup: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _progress = 0.0;
        });
      }
    }
  }

  Future<void> _deleteBackup(String backupPath) async {
    try {
      setState(() {
        _isProcessing = true;
        _error = null;
      });

      await _backupService.deleteBackup(backupPath);
      await _loadBackups();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to delete backup: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String _formatBackupName(String path) {
    final filename = path.split('/').last;
    final dateStr = filename.split('_')[1].split('.').first;
    final date = DateTime.parse(
        '${dateStr.substring(0, 8)} ${dateStr.substring(8)}');
    return DateFormat('MMM d, y HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Backups',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_isProcessing)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: LinearProgressIndicator(value: _progress),
              ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_backups?.isEmpty ?? true)
              const Center(
                child: Text('No backups available'),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _backups!.length,
                  itemBuilder: (context, index) {
                    final backup = _backups![index];
                    return ListTile(
                      title: Text(_formatBackupName(backup)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.restore),
                            onPressed: _isProcessing
                                ? null
                                : () => showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Restore Backup'),
                                        content: const Text(
                                          'Are you sure you want to restore this backup? '
                                          'This will replace all current messages.',
                                        ),
                                        actions: [
                                          TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                          TextButton(
                                            child: const Text('Restore'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _restoreBackup(backup);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: _isProcessing
                                ? null
                                : () => showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Backup'),
                                        content: const Text(
                                          'Are you sure you want to delete this backup? '
                                          'This action cannot be undone.',
                                        ),
                                        actions: [
                                          TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                          TextButton(
                                            child: const Text('Delete'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _deleteBackup(backup);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessing ? null : _createBackup,
              child: const Text('Create New Backup'),
            ),
          ],
        ),
      ),
    );
  }
}
