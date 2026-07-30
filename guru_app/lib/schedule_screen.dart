import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/models.dart';
import 'package:shared/providers/auth_provider.dart';
import 'package:shared/services/schedule_service.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  int _selectedDayOffset = 0;
  TimeOfDay? _selectedTime;
  final TextEditingController _noteController = TextEditingController();

  // Generate next 3 days
  List<DateTime> get _next3Days {
    final now = DateTime.now();
    return List.generate(3, (i) => now.add(Duration(days: i)));
  }

  // Generate 30-min blocks (e.g., 9:00 AM to 5:00 PM)
  List<TimeOfDay> get _timeSlots {
    return List.generate(16, (i) {
      int hour = 9 + (i ~/ 2);
      int minute = (i % 2) == 0 ? 0 : 30;
      return TimeOfDay(hour: hour, minute: minute);
    });
  }

  void _submitRequest() async {
    if (_selectedTime == null) return;

    final currentUser = ref.read(authProvider)!;
    final selectedDate = _next3Days[_selectedDayOffset];
    final scheduledFor = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    try {
      await ref
          .read(scheduleServiceProvider.notifier)
          .requestCall(
            currentUser.id,
            currentUser.assignedTrainerId!,
            scheduledFor,
            _noteController.text,
          );

      if (!mounted) return;

      // Required Assessment Copy
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Call requested. Waiting for trainer approval.'),
        ),
      );

      // Clear form so user can see it in "My Requests"
      setState(() {
        _selectedTime = null;
        _noteController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the requests from our Riverpod service
    final myRequests = ref
        .watch(scheduleServiceProvider)
        .where((req) => req.memberId == ref.read(authProvider)?.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule a Call')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Select Date',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              final date = _next3Days[index];
              final isSelected = _selectedDayOffset == index;
              return ChoiceChip(
                label: Text(DateFormat('MMM d').format(date)),
                selected: isSelected,
                onSelected: (val) => setState(() {
                  _selectedDayOffset = index;
                  _selectedTime = null; // Reset time on day change
                }),
                selectedColor: const Color(0xFF1769E0).withOpacity(0.2),
              );
            }),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select Time (30-min slots)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _timeSlots.map((time) {
              final isSelected = _selectedTime == time;
              return ChoiceChip(
                label: Text(time.format(context)),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedTime = time),
                selectedColor: const Color(0xFF1769E0).withOpacity(0.2),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Note for Trainer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLength: 140, // Max 140 chars constraint met
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'E.g., Macros review',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFF1769E0,
              ), // Guru App primary color
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: _selectedTime == null ? null : _submitRequest,
            child: const Text('Request Call'),
          ),

          // --- "My Requests" Section ---
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'My Requests',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (myRequests.isEmpty)
            const Text('No requests yet.', style: TextStyle(color: Colors.grey))
          else
            ...myRequests.map((req) {
              final formattedDate = DateFormat(
                'MMM d • h:mm a',
              ).format(req.scheduledFor);

              // Required Assessment Copy
              final statusText = req.status == CallRequestStatus.pending
                  ? 'Pending approval by Aarav'
                  : req.status.name.toUpperCase();

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    req.status == CallRequestStatus.approved
                        ? Icons.check_circle
                        : req.status == CallRequestStatus.declined
                        ? Icons.cancel
                        : Icons.schedule,
                    color: req.status == CallRequestStatus.approved
                        ? const Color(0xFF12876A)
                        : // Success Green
                          req.status == CallRequestStatus.declined
                        ? const Color(0xFFD92D20)
                        : // Error Red
                          Colors.orange, // Warning/Pending
                  ),
                  title: Text(
                    formattedDate,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(statusText),
                ),
              );
            }),
        ],
      ),
    );
  }
}
