import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoCallScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const VideoCallScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMicMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Remote video
          Container(
            color: Colors.grey[900],
            child: const Center(
              child: Icon(
                Icons.person,
                size: 120,
                color: Colors.white54,
              ),
            ),
          ),

          // Local video preview
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () => setState(() => _isMinimized = !_isMinimized),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isMinimized ? 100 : 120,
                height: _isMinimized ? 150 : 180,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ),

          // Call info and controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '00:00',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCallButton(
                        icon: _isMicMuted ? Icons.mic_off : Icons.mic,
                        label: _isMicMuted ? 'Unmute' : 'Mute',
                        onPressed: () =>
                            setState(() => _isMicMuted = !_isMicMuted),
                      ),
                      _buildCallButton(
                        icon:
                            _isCameraOff ? Icons.videocam_off : Icons.videocam,
                        label: _isCameraOff ? 'Start Video' : 'Stop Video',
                        onPressed: () =>
                            setState(() => _isCameraOff = !_isCameraOff),
                      ),
                      _buildCallButton(
                        icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                        label: _isSpeakerOn ? 'Speaker' : 'Earpiece',
                        onPressed: () =>
                            setState(() => _isSpeakerOn = !_isSpeakerOn),
                      ),
                      _buildCallButton(
                        icon: Icons.call_end,
                        color: Colors.red,
                        label: 'End',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: label,
          backgroundColor: color ?? Colors.white24,
          onPressed: onPressed,
          child: Icon(icon),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
