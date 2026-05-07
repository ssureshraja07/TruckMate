import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class VoicePlayerWidget extends StatefulWidget {
  final String voiceUrl;
  const VoicePlayerWidget({super.key, required this.voiceUrl});

  @override
  State<VoicePlayerWidget> createState() => _VoicePlayerWidgetState();
}

class _VoicePlayerWidgetState extends State<VoicePlayerWidget> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(UrlSource(widget.voiceUrl));
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFF1a1a2e),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Voice note",
            style: TextStyle(fontSize: 10, color: Colors.black45),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
