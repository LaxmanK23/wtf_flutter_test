import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import '../models.dart';
import '../services/video_call_service.dart';
import '../services/session_service.dart';
import '../providers/auth_provider.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String peerRole; // 'guest' (member) or 'host' (trainer)
  final String memberId;
  final String trainerId;

  const VideoCallScreen({
    super.key,
    required this.roomId,
    required this.peerRole,
    required this.memberId,
    required this.trainerId,
  });

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  bool _isMicMuted = false;
  bool _isVideoOff = false;

  @override
  void initState() {
    super.initState();
    // Join room immediately on load using widget.roomId and widget.peerRole
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(authProvider);
      if (currentUser != null) {
        ref
            .read(videoCallProvider.notifier)
            .joinRoom(
              roomId: widget.roomId,
              userId: currentUser.id,
              role: widget.peerRole,
            );
      }
    });
  }

  void _endCall() async {
    final callState = ref.read(videoCallProvider);
    final startTime = callState.joinedAt ?? DateTime.now();
    final endTime = DateTime.now();

    // 1. Leave 100ms room
    await ref.read(videoCallProvider.notifier).leaveRoom();

    if (!mounted) return;
    Navigator.pop(context); // Close video screen

    // 2. Create Session Log using widget IDs
    final sessionLog = await ref
        .read(sessionServiceProvider.notifier)
        .createLog(
          memberId: widget.memberId,
          trainerId: widget.trainerId,
          startedAt: startTime,
          endedAt: endTime,
        );

    // 3. Show Post-Call Sheet based on role
    final currentUser = ref.read(authProvider);
    if (currentUser != null && mounted) {
      _showPostCallSheet(context, currentUser.role, sessionLog.id);
    }
  }

  void _showPostCallSheet(BuildContext context, UserRole role, String logId) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) => role == UserRole.member
          ? _MemberPostCallSheet(logId: logId)
          : _TrainerPostCallSheet(logId: logId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(videoCallProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Participant Grid
          Column(
            children: [
              Expanded(
                child: callState.localVideoTrack != null
                    ? HMSVideoView(track: callState.localVideoTrack!)
                    : const Center(
                        child: Text(
                          'Connecting Local Camera...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
              const Divider(color: Colors.grey, height: 1),
              Expanded(
                child: callState.remoteVideoTrack != null
                    ? HMSVideoView(track: callState.remoteVideoTrack!)
                    : Center(
                        child: Text(
                          callState.isConnected
                              ? 'Waiting for remote participant...'
                              : 'Connecting...',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
              ),
            ],
          ),

          // Network Reconnection Loader (Resilience requirement)
          if (callState.isReconnecting || callState.isJoining)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // Control Toolbar
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'mic',
                  backgroundColor: Colors.grey.shade800,
                  onPressed: () {
                    setState(() => _isMicMuted = !_isMicMuted);
                    ref.read(videoCallProvider.notifier).toggleMic();
                  },
                  child: Icon(
                    _isMicMuted ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'video',
                  backgroundColor: Colors.grey.shade800,
                  onPressed: () {
                    setState(() => _isVideoOff = !_isVideoOff);
                    ref.read(videoCallProvider.notifier).toggleVideo();
                  },
                  child: Icon(
                    _isVideoOff ? Icons.videocam_off : Icons.videocam,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'flip',
                  backgroundColor: Colors.grey.shade800,
                  onPressed: () =>
                      ref.read(videoCallProvider.notifier).switchCamera(),
                  child: const Icon(Icons.cameraswitch, color: Colors.white),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'end',
                  backgroundColor: Colors.red,
                  onPressed: _endCall,
                  child: const Icon(Icons.call_end, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Post-Call Sheets ---

class _MemberPostCallSheet extends ConsumerStatefulWidget {
  final String logId;
  const _MemberPostCallSheet({required this.logId});

  @override
  ConsumerState<_MemberPostCallSheet> createState() =>
      _MemberPostCallSheetState();
}

class _MemberPostCallSheetState extends ConsumerState<_MemberPostCallSheet> {
  int _rating = 5;
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Rate Your Session',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: () => setState(() => _rating = index + 1),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Optional note...',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1769E0),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref
                  .read(sessionServiceProvider.notifier)
                  .updateMemberFeedback(
                    widget.logId,
                    _rating,
                    _noteController.text,
                  );
              Navigator.pop(context);
            },
            child: const Text('Submit Feedback'),
          ),
        ],
      ),
    );
  }
}

class _TrainerPostCallSheet extends ConsumerStatefulWidget {
  final String logId;
  const _TrainerPostCallSheet({required this.logId});

  @override
  ConsumerState<_TrainerPostCallSheet> createState() =>
      _TrainerPostCallSheetState();
}

class _TrainerPostCallSheetState extends ConsumerState<_TrainerPostCallSheet> {
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Session Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Quick notes for member...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF12876A),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref
                  .read(sessionServiceProvider.notifier)
                  .updateTrainerNotes(widget.logId, _notesController.text);
              Navigator.pop(context);
            },
            child: const Text('Mark as Complete'),
          ),
        ],
      ),
    );
  }
}
