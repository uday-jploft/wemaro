// lib/providers/video_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';

class VideoState {
  final bool isMuted;
  final bool isVideoEnabled;
  final bool permissionsGranted;
  final RTCPeerConnection? peerConnection;
  final String? localStreamId;
  final String? remoteStreamId;

  VideoState({
    this.isMuted = false,
    this.isVideoEnabled = true,
    this.permissionsGranted = false,
    this.peerConnection,
    this.localStreamId,
    this.remoteStreamId,
  });

  VideoState copyWith({
    bool? isMuted,
    bool? isVideoEnabled,
    bool? permissionsGranted,
    RTCPeerConnection? peerConnection,
    String? localStreamId,
    String? remoteStreamId,
  }) {
    return VideoState(
      isMuted: isMuted ?? this.isMuted,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      permissionsGranted: permissionsGranted ?? this.permissionsGranted,
      peerConnection: peerConnection ?? this.peerConnection,
      localStreamId: localStreamId ?? this.localStreamId,
      remoteStreamId: remoteStreamId ?? this.remoteStreamId,
    );
  }
}

class VideoNotifier extends Notifier<VideoState> {
  @override
  VideoState build() => VideoState();

  Future<void> initializeCall({required bool isCaller}) async {
    if (!state.permissionsGranted) {
      await requestPermissions();
    }
    if (state.permissionsGranted && state.peerConnection == null) {
      final pc = await createPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
      });
      state = state.copyWith(peerConnection: pc);

      try {
        final stream = await navigator.mediaDevices.getUserMedia({
          'video': state.isVideoEnabled,
          'audio': !state.isMuted,
        });
        if (stream != null) {
          pc.addStream(stream);
          state = state.copyWith(localStreamId: stream.id);
        }
      } catch (e) {
        // Handle media access error
        print('Error accessing media: $e');
        return;
      }

      pc.onTrack = (event) {
        if (event.streams.isNotEmpty && event.streams[0] != null) {
          state = state.copyWith(remoteStreamId: event.streams[0].id);
        }
      };

      // Signaling with Firebase Realtime Database
      final roomRef = FirebaseDatabase.instance.ref('rooms/test_room');

      pc.onIceCandidate = (candidate) {
        if (candidate != null && candidate.candidate != null) {
          final candidatesRef = isCaller ? roomRef.child('callerCandidates') : roomRef.child('calleeCandidates');
          candidatesRef.push().set(candidate.toMap());
        }
      };

      if (isCaller) {
        try {
          final offer = await pc.createOffer();
          await pc.setLocalDescription(offer);
          await roomRef.child('offer').set({'type': offer.type, 'sdp': offer.sdp});

          roomRef.child('answer').onValue.listen((event) async {
            final data = event.snapshot.value as Map<dynamic, dynamic>?;
            if (data != null && data['sdp'] != null && data['type'] != null) {
              await pc.setRemoteDescription(RTCSessionDescription(data['sdp'] as String, data['type'] as String));
            }
          });

          roomRef.child('calleeCandidates').onChildAdded.listen((event) {
            final data = event.snapshot.value as Map<dynamic, dynamic>?;
            if (data != null && data['candidate'] != null) {
              pc.addCandidate(RTCIceCandidate(
                data['candidate'] as String,
                data['sdpMid'] as String?,
                data['sdpMLineIndex'] as int?,
              ));
            }
          });
        } catch (e) {
          print('Error creating offer: $e');
        }
      } else {
        roomRef.child('offer').onValue.listen((event) async {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null && data['sdp'] != null && data['type'] != null) {
            await pc.setRemoteDescription(RTCSessionDescription(data['sdp'] as String, data['type'] as String));
            try {
              final answer = await pc.createAnswer();
              await pc.setLocalDescription(answer);
              await roomRef.child('answer').set({'type': answer.type, 'sdp': answer.sdp});
            } catch (e) {
              print('Error creating answer: $e');
            }
          }
        });

        roomRef.child('callerCandidates').onChildAdded.listen((event) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null && data['candidate'] != null) {
            pc.addCandidate(RTCIceCandidate(
              data['candidate'] as String,
              data['sdpMid'] as String?,
              data['sdpMLineIndex'] as int?,
            ));
          }
        });
      }
    }
  }

  Future<void> requestPermissions() async {
    final status = await [Permission.camera, Permission.microphone].request();
    if (status[Permission.camera]!.isGranted && status[Permission.microphone]!.isGranted) {
      state = state.copyWith(permissionsGranted: true);
    }
  }

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
    if (state.peerConnection != null && state.localStreamId != null) {
      final stream = state.peerConnection!.getLocalStreams().firstWhere(
            (s) => s?.id == state.localStreamId,
        orElse: () => throw Exception('Local stream not found'),
      );
      final audioTracks = stream?.getAudioTracks();
      if (audioTracks != null && audioTracks.isNotEmpty) {
        audioTracks.forEach((track) => track.enabled = !state.isMuted);
      }
    }
  }

  void toggleVideo() {
    state = state.copyWith(isVideoEnabled: !state.isVideoEnabled);
    if (state.peerConnection != null && state.localStreamId != null) {
      final stream = state.peerConnection!.getLocalStreams().firstWhere(
            (s) => s?.id == state.localStreamId,
        orElse: () => throw Exception('Local stream not found'),
      );
      final videoTracks = stream?.getVideoTracks();
      if (videoTracks != null && videoTracks.isNotEmpty) {
        videoTracks.forEach((track) => track.enabled = state.isVideoEnabled);
      }
    }
  }

  void shareScreen() {
    if (state.peerConnection != null) {
      navigator.mediaDevices.getDisplayMedia({'video': true}).then((stream) {
        if (stream != null) {
          state.peerConnection!.addStream(stream);
        }
      }).catchError((e) {
        print('Screen share failed: $e');
      });
    }
  }
}

final videoProvider = NotifierProvider<VideoNotifier, VideoState>(() => VideoNotifier());