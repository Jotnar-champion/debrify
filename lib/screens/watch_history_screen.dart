import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/formatters.dart';

/// Screen showing full watch history with timestamps.
class WatchHistoryScreen extends StatefulWidget {
  const WatchHistoryScreen({super.key});

  @override
  State<WatchHistoryScreen> createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends State<WatchHistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await StorageService.getWatchHistory();
    if (mounted) {
      setState(() {
        _history = history;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        title: const Text('Clear Watch History?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: const Text(
          'This will remove all watch history entries. This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await StorageService.clearWatchHistory();
      _load();
    }
  }

  Future<void> _removeEntry(int index) async {
    await StorageService.removeWatchHistoryEntry(index);
    _load();
  }

  String _timeAgo(int? ms) {
    if (ms == null) return '';
    final now = DateTime.now();
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _providerLabel(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'realdebrid':
      case 'real-debrid':
        return 'Real-Debrid';
      case 'torbox':
        return 'Torbox';
      case 'pikpak':
        return 'PikPak';
      default:
        return 'Real-Debrid';
    }
  }

  Color _providerColor(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'torbox':
        return const Color(0xFF10B981);
      case 'pikpak':
        return const Color(0xFFFFAA00);
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Watch History'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear All',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF6366F1), strokeWidth: 2.5))
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history,
                          size: 64, color: Colors.white.withOpacity(0.15)),
                      const SizedBox(height: 16),
                      Text('No watch history yet',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Items you play will appear here',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 13)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  separatorBuilder: (_, __) => Divider(
                    color: Colors.white.withOpacity(0.06),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final entry = _history[index];
                    final title =
                        (entry['title'] as String?) ?? 'Unknown';
                    final provider = entry['provider'] as String?;
                    final watchedAt = entry['watchedAt'] as int?;
                    final kind = entry['kind'] as String?;

                    return Dismissible(
                      key: ValueKey('history_${index}_${entry['watchedAt']}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red.withOpacity(0.2),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      onDismissed: (_) => _removeEntry(index),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _providerColor(provider).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            kind == 'collection'
                                ? Icons.folder_rounded
                                : Icons.play_circle_outline,
                            color: _providerColor(provider),
                            size: 22,
                          ),
                        ),
                        title: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              _providerLabel(provider),
                              style: TextStyle(
                                color: _providerColor(provider)
                                    .withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (kind != null) ...[
                              Text(' · ',
                                  style: TextStyle(
                                      color:
                                          Colors.white.withOpacity(0.3))),
                              Text(
                                kind == 'collection'
                                    ? 'Series'
                                    : 'Movie',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12),
                              ),
                            ],
                            Text(' · ',
                                style: TextStyle(
                                    color:
                                        Colors.white.withOpacity(0.3))),
                            Text(
                              _timeAgo(watchedAt),
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.close,
                              size: 18,
                              color: Colors.white.withOpacity(0.3)),
                          onPressed: () => _removeEntry(index),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
