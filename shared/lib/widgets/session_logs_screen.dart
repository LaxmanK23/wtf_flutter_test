import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models.dart';
import '../services/session_service.dart';

class SessionLogsScreen extends ConsumerStatefulWidget {
  final VoidCallback
  onSchedulePressed; // Callback for "Schedule your first call" CTA
  const SessionLogsScreen({super.key, required this.onSchedulePressed});

  @override
  ConsumerState<SessionLogsScreen> createState() => _SessionLogsScreenState();
}

class _SessionLogsScreenState extends ConsumerState<SessionLogsScreen> {
  String _selectedFilter = 'All'; // Chips: All, Last 7 days, This Month

  List<SessionLog> _filterAndSortLogs(List<SessionLog> logs) {
    final now = DateTime.now();

    // 1. Filter by chip selection
    var filtered = logs.where((log) {
      if (_selectedFilter == 'Last 7 days') {
        return log.startedAt.isAfter(now.subtract(const Duration(days: 7)));
      } else if (_selectedFilter == 'This Month') {
        return log.startedAt.year == now.year &&
            log.startedAt.month == now.month;
      }
      return true; // 'All'
    }).toList();

    // 2. Acceptance Criteria: Sorting by latest first
    filtered.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return filtered;
  }

  void _showDetailModal(BuildContext context, SessionLog log) {
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(log.startedAt);
    final durationMin = (log.durationSec / 60).toStringAsFixed(1);

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Session Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text('Date: $dateStr'),
            Text('Duration: $durationMin minutes'),
            Text(
              'Rating: ${log.rating != null ? "${log.rating} / 5 Stars" : "Not rated"}',
            ),
            const Divider(height: 24),
            Text(
              'Member Notes: ${log.memberNotes?.isNotEmpty == true ? log.memberNotes : "None"}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Trainer Notes: ${log.trainerNotes?.isNotEmpty == true ? log.trainerNotes : "None"}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            // Bonus Export: Share text summary using SharePlus
            // Export Summary Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1769E0),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.share),
              label: const Text('Export Summary'),
              onPressed: () {
                final summary =
                    'Fitness Coaching Session Summary\n'
                    'Date: $dateStr\n'
                    'Duration: $durationMin mins\n'
                    'Rating: ${log.rating ?? "N/A"}/5\n'
                    'Trainer Notes: ${log.trainerNotes ?? "None"}';

                // Correct SharePlus syntax matching the latest package version
                SharePlus.instance.share(ShareParams(text: summary));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allLogs = ref.watch(sessionServiceProvider);
    final logs = _filterAndSortLogs(allLogs);

    return Scaffold(
      appBar: AppBar(title: const Text('Session Logs & Insights')),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['All', 'Last 7 days', 'This Month'].map((filter) {
                return ChoiceChip(
                  label: Text(filter),
                  selected: _selectedFilter == filter,
                  onSelected: (val) => setState(() => _selectedFilter = filter),
                  selectedColor: const Color(0xFF1769E0).withValues(alpha: 0.2),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // Log List or Empty State
          Expanded(
            child: logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No session logs found.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        // Required Acceptance Copy with widget. prefix for callback
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1769E0),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: widget.onSchedulePressed,
                          child: const Text('Schedule your first call'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final dateStr = DateFormat(
                        'MMM d, h:mm a',
                      ).format(log.startedAt);
                      final durationMin = (log.durationSec / 60)
                          .toStringAsFixed(1);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          onTap: () => _showDetailModal(context, log),
                          leading: const Icon(
                            Icons.check_circle,
                            color: Color(0xFF12876A),
                          ),
                          title: Text(
                            dateStr,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Duration: $durationMin mins'),
                          trailing: log.rating != null
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${log.rating}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'No Rating',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
