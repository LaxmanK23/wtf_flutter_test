import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/models.dart';
import 'package:shared/services/schedule_service.dart';

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  void _showDeclineModal(
    BuildContext context,
    WidgetRef ref,
    String requestId,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Request'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Reason for declining...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref
                  .read(scheduleServiceProvider.notifier)
                  .declineCall(requestId, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filter for only pending requests
    final pendingRequests = ref
        .watch(scheduleServiceProvider)
        .where((r) => r.status == CallRequestStatus.pending)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Requests')),
      body: pendingRequests.isEmpty
          ? const Center(
              child: Text(
                'No pending requests.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingRequests.length,
              itemBuilder: (context, index) {
                final req = pendingRequests[index];
                final formattedDate = DateFormat(
                  'MMM d, yyyy • h:mm a',
                ).format(req.scheduledFor);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Member ID: ${req.memberId}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Requested for: $formattedDate',
                          style: const TextStyle(color: Color(0xFFE50914)),
                        ),
                        const SizedBox(height: 8),
                        Text('Note: ${req.note.isEmpty ? "None" : req.note}'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    _showDeclineModal(context, ref, req.id),
                                child: const Text('Decline'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                    0xFF12876A,
                                  ), // Required Success Green
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () async {
                                  try {
                                    await ref
                                        .read(scheduleServiceProvider.notifier)
                                        .approveCall(req.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Call Approved!'),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Approve'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
