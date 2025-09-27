import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:wemaro/providers/video_provider.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  const VideoCallScreen({super.key});

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  @override
  void initState() {
    super.initState();
    // ref.read(videoProvider.notifier).initializeCall(isCaller: );
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoProvider);

    if (!videoState.permissionsGranted) {
      return const Scaffold(body: Center(child: Text('Grant permissions to proceed')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Video Call')),
      body: Stack(
        children: [
          if (videoState.localStreamId != null)
            RTCVideoView(RTCVideoRenderer()..srcObject = videoState.peerConnection!.getLocalStreams().firstWhere((s) => (s?.id ?? "") == videoState.localStreamId)),
          if (videoState.remoteStreamId != null)
            Positioned(
              top: 0,
              right: 0,
              child: RTCVideoView(RTCVideoRenderer()..srcObject = videoState.peerConnection!.getRemoteStreams().firstWhere((s) =>(s?.id ?? "") == videoState.remoteStreamId)),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(videoState.isMuted ? Icons.mic_off : Icons.mic),
                  onPressed: ref.read(videoProvider.notifier).toggleMute,
                ),
                IconButton(
                  icon: Icon(videoState.isVideoEnabled ? Icons.videocam : Icons.videocam_off),
                  onPressed: ref.read(videoProvider.notifier).toggleVideo,
                ),
                IconButton(
                  icon: const Icon(Icons.screen_share),
                  onPressed: ref.read(videoProvider.notifier).shareScreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}