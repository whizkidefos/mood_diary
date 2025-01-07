import 'package:flutter/material.dart';
import 'package:mood_diary/services/backup_service.dart'; // Adjust the import path as necessary

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

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    try {
      final backups = await _backupService.listBackups(widget.chatId);
      setState(() {
        _backups = backups;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading backups')),
        );
      }
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isProcessing = true);
    try {
      await _backupService.createBackup(widget.chatId);
      await _loadBackups();
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _restoreBackup(String backupUrl) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text(
          'This will replace all current messages. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      await _backupService.restoreBackup(widget.chatId, backupUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restored successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error restoring backup')),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _deleteBackup(String backupName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup'),
        content: const Text('Are you sure you want to delete this backup?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      await _backupService.deleteBackup(widget.chatId, backupName);
      await _loadBackups();
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Backups',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            if (_isLoading || _isProcessing)
              const Center(child: CircularProgressIndicator())
            else if (_backups == null || _backups!.isEmpty)
              const Center(child: Text('No backups found'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _backups!.length,
                  itemBuilder: (context, index) {
                    final backup = _backups![index];
                    return ListTile(
                      title: Text(backup),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.restore),
                            onPressed: () => _restoreBackup(backup),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteBackup(backup),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _createBackup,
                icon: const Icon(Icons.backup),
                label: const Text('Create Backup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
