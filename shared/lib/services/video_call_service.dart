import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'schedule_service.dart'; // To get tokenServerUrl

// Holds the active call state for the UI to consume
class CallState {
  final bool isJoining;
  final bool isConnected;
  final bool isReconnecting;
  final HMSVideoTrack? localVideoTrack;
  final HMSVideoTrack? remoteVideoTrack;
  final String? remotePeerName;
  final DateTime? joinedAt;

  CallState({
    this.isJoining = false,
    this.isConnected = false,
    this.isReconnecting = false,
    this.localVideoTrack,
    this.remoteVideoTrack,
    this.remotePeerName,
    this.joinedAt,
  });

  CallState copyWith({
    bool? isJoining,
    bool? isConnected,
    bool? isReconnecting,
    HMSVideoTrack? localVideoTrack,
    HMSVideoTrack? remoteVideoTrack,
    String? remotePeerName,
    DateTime? joinedAt,
  }) {
    return CallState(
      isJoining: isJoining ?? this.isJoining,
      isConnected: isConnected ?? this.isConnected,
      isReconnecting: isReconnecting ?? this.isReconnecting,
      localVideoTrack: localVideoTrack ?? this.localVideoTrack,
      remoteVideoTrack: remoteVideoTrack ?? this.remoteVideoTrack,
      remotePeerName: remotePeerName ?? this.remotePeerName,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

final videoCallProvider = NotifierProvider<VideoCallNotifier, CallState>(
  () => VideoCallNotifier(),
);

class VideoCallNotifier extends Notifier<CallState>
    implements HMSUpdateListener {
  late HMSSDK _hmsSDK;

  @override
  CallState build() {
    _initSDK();
    return CallState();
  }

  Future<void> _initSDK() async {
    _hmsSDK = HMSSDK();
    await _hmsSDK.build();
    _hmsSDK.addUpdateListener(listener: this);
  }

  Future<void> requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  Future<void> joinRoom({
    required String roomId,
    required String userId,
    required String role,
  }) async {
    state = state.copyWith(isJoining: true);
    await requestPermissions();

    try {
      // Fetch token from our local Node.js server
      final url = Uri.parse(
        '$tokenServerUrl/token?roomId=$roomId&userId=$userId&role=$role',
      );
      final response = await http.get(url);
      if (response.statusCode != 200) throw Exception('Failed to get token');

      final token = jsonDecode(response.body)['token'];

      final config = HMSConfig(authToken: token, userName: userId);

      await _hmsSDK.join(config: config);
    } catch (e) {
      debugPrint('Error joining room: $e');
      state = state.copyWith(isJoining: false);
    }
  }

  Future<void> leaveRoom() async {
    await _hmsSDK.leave();
    state = CallState(); // Reset state
  }

  Future<void> toggleMic() async {
    await _hmsSDK.toggleMicMuteState();
  }

  Future<void> toggleVideo() async {
    await _hmsSDK.toggleCameraMuteState();
  }

  void switchCamera() {
    _hmsSDK.switchCamera();
  }

  // --- HMSUpdateListener Callbacks ---

  @override
  void onJoin({required HMSRoom room}) {
    state = state.copyWith(
      isJoining: false,
      isConnected: true,
      joinedAt: DateTime.now(),
    );
  }

  @override
  void onTrackUpdate({
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer,
  }) {
    if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
      if (trackUpdate == HMSTrackUpdate.trackAdded) {
        if (peer.isLocal) {
          state = state.copyWith(localVideoTrack: track as HMSVideoTrack);
        } else {
          state = state.copyWith(
            remoteVideoTrack: track as HMSVideoTrack,
            remotePeerName: peer.name,
          );
        }
      } else if (trackUpdate == HMSTrackUpdate.trackRemoved) {
        if (!peer.isLocal) {
          state = CallState(
            isConnected: true,
            joinedAt: state.joinedAt,
            localVideoTrack: state.localVideoTrack,
          );
        }
      }
    }
  }

  @override
  void onReconnecting() {
    state = state.copyWith(isReconnecting: true);
  }

  @override
  void onReconnected() {
    state = state.copyWith(isReconnecting: false);
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    if (update == HMSPeerUpdate.peerLeft) {
      if (!peer.isLocal) {
        state = CallState(
          isConnected: true,
          joinedAt: state.joinedAt,
          localVideoTrack: state.localVideoTrack,
        );
      }
    }
  }

  // --- REQUIRED OVERRIDES FOR LATEST HMSSDK ---

  @override
  void onPeerListUpdate({
    required List<HMSPeer> addedPeers,
    required List<HMSPeer> removedPeers,
  }) {}

  @override
  void onRemovedFromRoom({
    required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer,
  }) {}

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}

  @override
  void onAudioDeviceChanged({
    HMSAudioDevice? currentAudioDevice,
    List<HMSAudioDevice>? availableAudioDevice,
  }) {}

  @override
  void onChangeTrackStateRequest({
    required HMSTrackChangeRequest hmsTrackChangeRequest,
  }) {}

  @override
  void onHMSError({required HMSException error}) {}

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}
}
