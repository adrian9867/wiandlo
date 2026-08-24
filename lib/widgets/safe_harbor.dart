import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

/// Global audio helper using the single player instance.
/// Safe Harbor and guided tracks share this player so they
/// naturally interrupt each other rather than layering.
class QuickAudio {
  static final AudioPlayer _player = AudioPlayer();

  static AudioPlayer get player => _player;

  static Future<void> playAsset(String path) async {
    try {
      debugPrint('QuickAudio: loading $path');

      if (_player.playing) {
        await _player.stop();
      }

      await _player.setAsset(path);

      debugPrint('QuickAudio: asset loaded');

      await _player.play();

      debugPrint('QuickAudio: playback started');
    } catch (e, stack) {
      debugPrint('QuickAudio ERROR: $e');
      debugPrint('$stack');
      rethrow;
    }
  }

  static Future<void> playSafeHarbor() async {
  try {
    await playAsset('assets/audio/safe_harbor.mp3');
  } catch (e) {
    debugPrint('Safe Harbor audio unavailable: $e');
    rethrow;
  }
}
  static Future<void> stop() async => _player.stop();
}

/// A quiet, living anchor available on every screen.
/// Deep cyan, slow pulse, never flashy — but always visible.
class SafeHarbor extends StatefulWidget {
  const SafeHarbor({super.key, this.bottom = 24, this.right = 24});

  final double bottom;
  final double right;

  @override
  State<SafeHarbor> createState() => _SafeHarborState();
}

class _SafeHarborState extends State<SafeHarbor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _pressed = false;
  bool _grounding = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

 Future<void> _onTap() async {
  setState(() {
    _grounding = true;
  });

  try {
    await QuickAudio.playSafeHarbor();

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() => _grounding = false);
    }
  } catch (_) {
    if (mounted) {
      setState(() {
        _grounding = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Safe Harbor audio not available yet'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: widget.bottom,
      right: widget.right,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) {
              final breathe = 0.5 + (_pulse.value * 0.5);
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A3A4D).withValues(
                    alpha: _grounding
                        ? 0.9
                        : (_pressed ? 0.65 : 0.38 + 0.28 * breathe),
                  ),
                  border: Border.all(
                    color: const Color(0xFF3A6A8A).withValues(
                      alpha: _grounding
                          ? 1.0
                          : (_pressed ? 0.6 : 0.28 + 0.26 * breathe),
                    ),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2A5A7A).withValues(
                        alpha: _grounding ? 0.55 : 0.2 + 0.14 * breathe,
                      ),
                      blurRadius: 22,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _grounding ? 10 : 7,
                    height: _grounding ? 10 : 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6FB6D6).withValues(
                        alpha: _grounding ? 1.0 : 0.85,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6FB6D6).withValues(
                            alpha: _grounding ? 0.6 : 0.3,
                          ),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}