import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/safe_harbor.dart';

// ── Enums & Data ─────────────────────────────────────────────────

enum SessionMode { free, guided }

enum _BreathPhase { inhale, holdIn, exhale, holdOut }

const Map<_BreathPhase, int> _kBreathDurations = {
  _BreathPhase.inhale: 4,
  _BreathPhase.holdIn: 4,
  _BreathPhase.exhale: 6,
  _BreathPhase.holdOut: 2,
};

const Map<_BreathPhase, String> _kBreathLabels = {
  _BreathPhase.inhale: 'breathe in',
  _BreathPhase.holdIn: 'hold',
  _BreathPhase.exhale: 'breathe out',
  _BreathPhase.holdOut: 'rest',
};

class GuidedTrack {
  final String id;
  final String title;
  final String subtitle;
  final int durationMinutes;
  final String? assetPath;

  const GuidedTrack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    this.assetPath,
  });
}

const List<GuidedTrack> kGuidedTracks = [
  GuidedTrack(id: '01', title: 'Arrival', subtitle: 'returning to the body', durationMinutes: 5, assetPath: 'assets/audio/G01_phase01.mp3'),
  GuidedTrack(id: '02', title: 'The Space Between', subtitle: 'noticing the gap', durationMinutes: 8, assetPath: 'assets/audio/G01_phase02.mp3'),
  GuidedTrack(id: '03', title: 'Dissolving Edges', subtitle: 'where do you end', durationMinutes: 10),
  GuidedTrack(id: '04', title: 'The Weight of Silence', subtitle: 'listening beneath thought', durationMinutes: 7),
  GuidedTrack(id: '05', title: 'Root Frequency', subtitle: 'grounding in sensation', durationMinutes: 12),
  GuidedTrack(id: '06', title: 'Floating Attention', subtitle: 'awareness without anchor', durationMinutes: 9),
  GuidedTrack(id: '07', title: 'The Hollow Bell', subtitle: 'sound and disappearance', durationMinutes: 6),
  GuidedTrack(id: '08', title: 'Inverted Seeing', subtitle: 'looking from behind the eyes', durationMinutes: 11),
  GuidedTrack(id: '09', title: 'Time Unwound', subtitle: 'presence outside duration', durationMinutes: 8),
  GuidedTrack(id: '10', title: 'The Last Threshold', subtitle: 'resting in uncertainty', durationMinutes: 15),
];

class SoundEnvironment {
  final String id;
  final String label;
  final String description;
  final String emoji;
  final String? assetPath;

  const SoundEnvironment({
    required this.id,
    required this.label,
    required this.description,
    required this.emoji,
    this.assetPath,
  });
}

const List<SoundEnvironment> kSoundEnvironments = [
  SoundEnvironment(id: 'silence', label: 'Silence', description: 'just you', emoji: '◦'),
  SoundEnvironment(id: 'temple', label: 'Temple', description: 'bells, morning air', emoji: '🔔', assetPath: 'assets/audio/temple.mp3'),
  SoundEnvironment(id: 'nightroad', label: 'Night Road', description: 'distant traffic, wind', emoji: '🌙', assetPath: 'assets/audio/nightroad.mp3'),
  SoundEnvironment(id: 'rain', label: 'Rain', description: 'soft, continuous', emoji: '🌧', assetPath: 'assets/audio/rain.mp3'),
  SoundEnvironment(id: 'market', label: 'Market', description: 'alive, present', emoji: '🏮', assetPath: 'assets/audio/market.mp3'),
  SoundEnvironment(id: 'forest', label: 'Forest', description: 'birds, leaves', emoji: '🌿', assetPath: 'assets/audio/forest.mp3'),
];

// ── Breath Core Widget ───────────────────────────────────────────

class _BreathCore extends StatelessWidget {
  final Animation<double> breathController;
  final Animation<double> scaleAnimation;
  final _BreathPhase phase;
  final Color accentColor;

  const _BreathCore({
    required this.breathController,
    required this.scaleAnimation,
    required this.phase,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: breathController,
          builder: (_, __) {
            final t = breathController.value;
            return Transform.scale(
              scale: scaleAnimation.value,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.08 + t * 0.08),
                      blurRadius: 50,
                      spreadRadius: 12,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: 0.12 + t * 0.1),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.3),
                          blurRadius: 24,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withValues(alpha: 0.5 + t * 0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 48),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: Text(
            _kBreathLabels[phase]!,
            key: ValueKey(phase),
            style: AppTextStyles.ui(
              size: 13,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Main Screen ──────────────────────────────────────────────────

class GroundSessionScreen extends StatefulWidget {
  final SessionMode mode;
  final GuidedTrack? selectedTrack;
  final VoidCallback onComplete;

  const GroundSessionScreen({
    super.key,
    required this.mode,
    this.selectedTrack,
    required this.onComplete,
  });

  @override
  State<GroundSessionScreen> createState() => _GroundSessionScreenState();
}

class _GroundSessionScreenState extends State<GroundSessionScreen>
    with TickerProviderStateMixin {
  // Navigation / selection state
  bool _showTrackList = false;
  GuidedTrack? _activeTrack;
  int _maxUnlockedTrack = 1;

  // Free mode state
  int _selectedDuration = 10;
  SoundEnvironment _selectedEnv = kSoundEnvironments[0];

 bool _sessionStarted = false;
bool _isPaused = false;

int _sessionSeconds = 0;
int _totalSessionSeconds = 0;
int _totalSecondsForProgress = 0;

Duration _audioPosition = Duration.zero;
Duration _audioDuration = Duration.zero;
StreamSubscription<Duration>? _positionSub;
Timer? _sessionTimer;

  // Breath state
  _BreathPhase _phase = _BreathPhase.inhale;
  int _phaseSeconds = 0;
  late AnimationController _breathController;
  late Animation<double> _breathScale;

  // Audio state
  bool _autoAdvance = true;
  StreamSubscription<PlayerState>? _playerSub;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _kBreathDurations[_BreathPhase.inhale]!),
    );
    _breathScale = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    if (widget.mode == SessionMode.guided && widget.selectedTrack == null) {
      _showTrackList = true;
      _loadTrackProgress();
    } else if (widget.mode == SessionMode.guided && widget.selectedTrack != null) {
      _activeTrack = widget.selectedTrack;
      _totalSessionSeconds = _activeTrack!.durationMinutes * 60;
    } else {
      _totalSessionSeconds = _selectedDuration * 60;
    }
  }

  Future<void> _loadTrackProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final max = prefs.getInt('ground_max_unlocked_track') ?? 1;
    if (!mounted) return;
    setState(() => _maxUnlockedTrack = max);
  }

  Future<void> _unlockNextTrack() async {
    if (widget.mode != SessionMode.guided || _activeTrack == null) return;
    final currentIndex = kGuidedTracks.indexWhere((t) => t.id == _activeTrack!.id);
    if (currentIndex >= 0 && currentIndex == _maxUnlockedTrack && currentIndex < kGuidedTracks.length - 1) {
      final prefs = await SharedPreferences.getInstance();
      final newMax = currentIndex + 1;
      await prefs.setInt('ground_max_unlocked_track', newMax);
    }
  }

  void _selectTrack(GuidedTrack track) {
  setState(() {
    _activeTrack = track;
    _sessionSeconds = 0;
    _audioPosition = Duration.zero;
    _audioDuration = Duration.zero;
    _showTrackList = false;
    _totalSessionSeconds = track.durationMinutes * 60;
    _totalSecondsForProgress = track.durationMinutes * 60;
  });
}

 void _startSession() {
  setState(() {
    _sessionStarted = true;
    _isPaused = false;
  });

  _runBreathPhase(_phase);

  if (widget.mode == SessionMode.guided) {
    _playTrackAudio();
  } else {
    _startSessionTimer();
  }
}

void _startSessionTimer() {
  _sessionTimer?.cancel();

  _sessionTimer = Timer.periodic(
    const Duration(seconds: 1),
    (t) {
      if (!mounted || _isPaused) return;

      setState(() {
        _sessionSeconds++;
        _phaseSeconds++;

        final phaseDuration = _kBreathDurations[_phase]!;

        if (_phaseSeconds >= phaseDuration) {
          _phaseSeconds = 0;
          _advancePhase();
        }

        if (_sessionSeconds >= _totalSessionSeconds) {
          t.cancel();
          _endSession();
        }
      });
    },
  );
}

Future<void> _togglePause() async {
  final player = QuickAudio.player;

  if (_isPaused) {
    setState(() => _isPaused = false);

    _runBreathPhase(_phase);

    if (widget.mode == SessionMode.guided) {
      await player.play();
    } else {
      _startSessionTimer();
    }
  } else {
    setState(() => _isPaused = true);

    if (widget.mode == SessionMode.guided) {
      await player.pause();
    } else {
      _sessionTimer?.cancel();
    }

    _breathController.stop();
  }
}
  // ── Audio playback for guided transmissions ───────────────────────
Future<void> _playTrackAudio() async {
  final path = _activeTrack?.assetPath;
  if (path == null) return;

  try {
    final player = QuickAudio.player;

    _playerSub?.cancel();
    _positionSub?.cancel();

    _playerSub = player.playerStateStream.listen((state) {
      if (!mounted) return;

      if (state.processingState == ProcessingState.completed) {
        _handleAudioCompleted();
      }
    });

    _positionSub = player.positionStream.listen((position) {
      if (!mounted) return;

      setState(() {
        _audioPosition = position;
        _sessionSeconds = position.inSeconds;
      });
    });

    if (player.playing) {
      await player.stop();
    }

    await player.setAsset(path);

    final duration = player.duration ?? Duration.zero;

    if (mounted) {
      setState(() {
        _audioDuration = duration;
        _totalSessionSeconds = duration.inSeconds;
        _totalSecondsForProgress = duration.inSeconds;
        _audioPosition = Duration.zero;
        _sessionSeconds = 0;
      });
    }

    await player.play();
  } catch (e, stack) {
    debugPrint('GROUND AUDIO ERROR: $e');
    debugPrint('$stack');
  }
}

  void _handleAudioCompleted() {
    _sessionTimer?.cancel();
    if (widget.mode == SessionMode.guided && _autoAdvance) {
      final current = _activeTrack;
      if (current != null) {
        final idx = kGuidedTracks.indexWhere((t) => t.id == current.id);
        final nextIdx = idx + 1;
        if (nextIdx < kGuidedTracks.length &&
            nextIdx <= _maxUnlockedTrack &&
            kGuidedTracks[nextIdx].assetPath != null) {
          final next = kGuidedTracks[nextIdx];
          setState(() {
            _activeTrack = next;
            _sessionSeconds = 0;
            _totalSecondsForProgress = next.durationMinutes * 60;
            _totalSessionSeconds = next.durationMinutes * 60;
            _phase = _BreathPhase.inhale;
            _phaseSeconds = 0;
          });
          _runBreathPhase(_phase);
          _playTrackAudio();
          
          return;
        }
      }
    }
    _endSession();
  }

  Future<void> _endSession() async {
    _sessionTimer?.cancel();
    _playerSub?.cancel();
    await QuickAudio.stop();
    await _unlockNextTrack();
    _resetForNextSession();
    if (!mounted) return;
    widget.onComplete();
  }

  void _advancePhase() {
    final phases = _BreathPhase.values;
    final next = phases[(_phase.index + 1) % phases.length];
    setState(() => _phase = next);
    _runBreathPhase(next);
  }

  void _runBreathPhase(_BreathPhase phase) {
    final dur = Duration(seconds: _kBreathDurations[phase]!);
    _breathController.duration = dur;
    if (phase == _BreathPhase.inhale) {
      _breathController.forward(from: 0);
    } else if (phase == _BreathPhase.exhale) {
      _breathController.reverse(from: 1);
    }
  }

  void _resetForNextSession() {
    _sessionStarted = false;
    _sessionSeconds = 0;
    _showTrackList = false;
  }

  String get _timeRemaining {
    final remaining = _totalSessionSeconds - _sessionSeconds;
    final m = (remaining ~/ 60).toString().padLeft(2, '0');
    final s = (remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

String get _formatElapsedTime {
  final m = (_sessionSeconds ~/ 60)
      .toString()
      .padLeft(2, '0');

  final s = (_sessionSeconds % 60)
      .toString()
      .padLeft(2, '0');

  return '$m:$s';
}
  double get _sessionProgress {
  if (_audioDuration.inMilliseconds <= 0) return 0.0;

  return (_audioPosition.inMilliseconds /
          _audioDuration.inMilliseconds)
      .clamp(0.0, 1.0);
}
  @override
void dispose() {
  _sessionTimer?.cancel();
  _playerSub?.cancel();
  _positionSub?.cancel();
  _breathController.dispose();
  super.dispose();
}

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_showTrackList) return _buildTrackListScreen();
    if (!_sessionStarted) {
      return widget.mode == SessionMode.free
          ? _buildFreePrepScreen()
          : _buildGuidedPrepScreen();
    }
    return _buildActiveSession();
  }

  // ── Track List (Guided) ───────────────────────────────────────

  Widget _buildTrackListScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF060A06),
      body:      Stack(
       children: [
       SafeArea(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   // Top bar
                   SizedBox(
                     height: 44,
                     child: Stack(
                       alignment: Alignment.center,
                       children: [
                         Align(
                           alignment: Alignment.centerLeft,
                           child: GestureDetector(
                             onTap: () => Navigator.of(context).pop(),
                             child: Padding(
                               padding: const EdgeInsets.symmetric(
                                 horizontal: AppSpacing.md,
                               ),
                               child: Icon(
                                 Icons.arrow_back_ios,
                                 color: AppColors.ground.withValues(alpha: 0.35),
                                 size: 16,
                               ),
                             ),
                           ),
                         ),
                         Text(
                           'TRANSMISSIONS',
                           style: AppTextStyles.trackLabel(
                             size: 11,
                             color: AppColors.ground.withValues(alpha: 0.4),
                           ),
                         ),
                       ],
                     ),
                   ),
                   const SizedBox(height: 24),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 24),
                     child: Text(
                       'choose a signal',
                       style: AppTextStyles.ui(
                         size: 20,
                         color: Colors.white.withValues(alpha: 0.8),
                       ),
                     ),
                   ),
                   const SizedBox(height: 8),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 24),
                     child: Text(
                       'listen in order. each unlocks the next.',
                       style: AppTextStyles.ui(
                         size: 10,
                         color: Colors.white.withValues(alpha: 0.25),
                       ),
                     ),
                   ),
                   const SizedBox(height: 24),
                   Expanded(
                     child: ListView.builder(
                       padding: const EdgeInsets.symmetric(horizontal: 24),
                       itemCount: kGuidedTracks.length,
                       itemBuilder: (_, index) {
                         final track = kGuidedTracks[index];
                         final unlocked = index <= _maxUnlockedTrack;
                         final listened = index < _maxUnlockedTrack;

                         return GestureDetector(
                           onTap: unlocked ? () => _selectTrack(track) : null,
                           child: Container(
                             margin: const EdgeInsets.only(bottom: 8),
                             padding: const EdgeInsets.symmetric(
                               horizontal: 20,
                               vertical: 18,
                             ),
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(12),
                               border: Border.all(
                                 color: unlocked
                                     ? listened
                                         ? AppColors.ground.withValues(alpha: 0.15)
                                         : AppColors.ground.withValues(alpha: 0.35)
                                     : Colors.white.withValues(alpha: 0.06),
                               ),
                               color: unlocked
                                   ? listened
                                       ? AppColors.ground.withValues(alpha: 0.03)
                                       : AppColors.ground.withValues(alpha: 0.06)
                                   : Colors.transparent,
                             ),
                             child: Row(
                               children: [
                                 Text(
                                   track.id,
                                   style: AppTextStyles.ui(
                                     size: 10,
                                     color: unlocked
                                         ? AppColors.ground.withValues(alpha: 0.5)
                                         : Colors.white.withValues(alpha: 0.12),
                                   ),
                                 ),
                                 const SizedBox(width: 16),
                                 Expanded(
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Text(
                                         track.title,
                                         style: AppTextStyles.ui(
                                           size: 13,
                                           color: unlocked
                                               ? Colors.white.withValues(alpha: 0.8)
                                               : Colors.white.withValues(alpha: 0.2),
                                         ),
                                       ),
                                       const SizedBox(height: 4),
                                       Text(
                                         track.subtitle,
                                         style: AppTextStyles.ui(
                                           size: 10,
                                           color: Colors.white.withValues(
                                             alpha: unlocked ? 0.3 : 0.12,
                                           ),
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                                 Text(
                                   '${track.durationMinutes}m',
                                   style: AppTextStyles.ui(
                                     size: 10,
                                     color: Colors.white.withValues(
                                       alpha: unlocked ? 0.25 : 0.1,
                                     ),
                                   ),
                                 ),
                                 const SizedBox(width: 12),
                                 if (!unlocked)
                                   Icon(
                                     Icons.lock_outline,
                                     size: 12,
                                     color: Colors.white.withValues(alpha: 0.12),
                                   )
                                 else if (listened)
                                   Container(
                                     width: 6,
                                     height: 6,
                                     decoration: BoxDecoration(
                                       shape: BoxShape.circle,
                                       color: AppColors.ground.withValues(alpha: 0.4),
                                     ),
                                   ),
                               ],
                             ),
                           ),
                         );
                       },
                     ),
                   ),
                 ],
               ),
             ),
       const SafeHarbor(),
     ],
     )
    );
  }

  // ── Guided Prep ───────────────────────────────────────────────

  Widget _buildGuidedPrepScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF060A06),
      body:      Stack(
       children: [
       SafeArea(
               child: Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 32),
                 child: Column(
                   children: [
                     const Spacer(flex: 2),
                     Text(
                       'TRANSMISSION',
                       style: AppTextStyles.trackLabel(
                         size: 11,
                         color: AppColors.ground.withValues(alpha: 0.4),
                       ),
                     ),
                     const SizedBox(height: 16),
                     Text(
                       _activeTrack?.title ?? '',
                       textAlign: TextAlign.center,
                       style: AppTextStyles.ui(
                         size: 24,
                         color: Colors.white.withValues(alpha: 0.85),
                       ),
                     ),
                     const SizedBox(height: 8),
                     Text(
                       _activeTrack?.subtitle ?? '',
                       textAlign: TextAlign.center,
                       style: AppTextStyles.ui(
                         size: 12,
                         color: Colors.white.withValues(alpha: 0.3),
                       ),
                     ),
                     const Spacer(flex: 2),
                     Text(
                       '${_activeTrack?.durationMinutes ?? 0} minutes',
                       style: AppTextStyles.ui(
                         size: 11,
                         color: Colors.white.withValues(alpha: 0.2),
                       ),
                     ),
                     const Spacer(),
                     GestureDetector(
                       onTap: () =>
                           setState(() => _autoAdvance = !_autoAdvance),
                       child: Container(
                         margin: const EdgeInsets.only(bottom: 10),
                         padding: const EdgeInsets.symmetric(
                           horizontal: 20,
                           vertical: 12,
                         ),
                         decoration: BoxDecoration(
                           border: Border.all(
                             color: _autoAdvance
                                 ? AppColors.ground.withValues(alpha: 0.35)
                                 : Colors.white.withValues(alpha: 0.08),
                           ),
                           borderRadius: BorderRadius.circular(40),
                           color: _autoAdvance
                               ? AppColors.ground.withValues(alpha: 0.05)
                               : Colors.transparent,
                         ),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Text(
                               _autoAdvance ? 'auto continue' : 'stop after',
                               style: AppTextStyles.ui(
                                 size: 11,
                                 color: _autoAdvance
                                     ? AppColors.ground.withValues(alpha: 0.8)
                                     : Colors.white.withValues(alpha: 0.35),
                               ),
                             ),
                             const SizedBox(width: 10),
                             AnimatedContainer(
                               duration: const Duration(milliseconds: 250),
                               width: 34,
                               height: 18,
                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(10),
                                 color: _autoAdvance
                                     ? AppColors.ground.withValues(alpha: 0.6)
                                     : Colors.white.withValues(alpha: 0.12),
                               ),
                               child: Align(
                                 alignment: _autoAdvance
                                     ? Alignment.centerRight
                                     : Alignment.centerLeft,
                                 child: Padding(
                                   padding: EdgeInsets.symmetric(
                                     horizontal: 3,
                                     vertical: 3,
                                   ),
                                   child: Container(
                                     width: 12,
                                     height: 12,
                                     decoration: BoxDecoration(
                                       shape: BoxShape.circle,
                                       color: _autoAdvance
                                           ? AppColors.ground
                                           : Colors.white.withValues(
                                               alpha: 0.4,
                                             ),
                                     ),
                                   ),
                                 ),
                               ),
                             ),
                           ],
                         ),
                       ),
                     ),
                     GestureDetector(
                       onTap: _startSession,
                       child: Container(
                         width: double.infinity,
                         padding: const EdgeInsets.symmetric(vertical: 18),
                         decoration: BoxDecoration(
                           border: Border.all(
                             color: AppColors.ground.withValues(alpha: 0.4),
                           ),
                           borderRadius: BorderRadius.circular(16),
                           color: AppColors.ground.withValues(alpha: 0.06),
                         ),
                         child: Text(
                           'begin transmission',
                           textAlign: TextAlign.center,
                           style: AppTextStyles.ui(
                             size: 14,
                             color: AppColors.ground.withValues(alpha: 0.85),
                           ),
                         ),
                       ),
                     ),
                     const Spacer(flex: 2),
                   ],
                 ),
               ),
             ),
       const SafeHarbor(),
     ],
     )
    );
  }

  // ── Free Prep ─────────────────────────────────────────────────

  Widget _buildFreePrepScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF060A06),
      body:      Stack(
       children: [
       SafeArea(
               child: Stack(
                 children: [
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 32),
                     child: Column(
                       children: [
                         const Spacer(flex: 2),
                         Text(
                           'GROUND',
                           style: AppTextStyles.trackLabel(
                             size: 11,
                             color: AppColors.ground.withValues(alpha: 0.4),
                           ),
                         ),
                         const SizedBox(height: 12),
                         Text(
                           'quiet the noise',
                           style: AppTextStyles.ui(
                             size: 22,
                             color: Colors.white.withValues(alpha: 0.85),
                           ),
                         ),
                         const Spacer(flex: 2),

                         // Duration
                         Text(
                           'session length',
                           style: AppTextStyles.ui(
                             size: 10,
                             color: Colors.white.withValues(alpha: 0.3),
                           ),
                         ),
                         const SizedBox(height: 16),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [5, 10, 15, 20].map((min) {
                             final selected = _selectedDuration == min;
                             return GestureDetector(
                               onTap: () => setState(() => _selectedDuration = min),
                               child: AnimatedContainer(
                                 duration: const Duration(milliseconds: 200),
                                 margin: const EdgeInsets.symmetric(horizontal: 6),
                                 padding: const EdgeInsets.symmetric(
                                   horizontal: 18,
                                   vertical: 10,
                                 ),
                                 decoration: BoxDecoration(
                                   border: Border.all(
                                     color: selected
                                         ? AppColors.ground.withValues(alpha: 0.6)
                                         : Colors.white.withValues(alpha: 0.08),
                                   ),
                                   borderRadius: BorderRadius.circular(40),
                                   color: selected
                                       ? AppColors.ground.withValues(alpha: 0.08)
                                       : Colors.transparent,
                                 ),
                                 child: Text(
                                   '${min}m',
                                   style: AppTextStyles.ui(
                                     size: 12,
                                     color: selected
                                         ? AppColors.ground.withValues(alpha: 0.9)
                                         : Colors.white.withValues(alpha: 0.3),
                                   ),
                                 ),
                               ),
                             );
                           }).toList(),
                         ),
                         const Spacer(),

                         // Sound env
                         GestureDetector(
                           onTap: () => _showSoundPicker(),
                           child: Container(
                             padding: const EdgeInsets.symmetric(
                               horizontal: 20,
                               vertical: 14,
                             ),
                             decoration: BoxDecoration(
                               border: Border.all(
                                 color: Colors.white.withValues(alpha: 0.08),
                               ),
                               borderRadius: BorderRadius.circular(12),
                             ),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Row(
                                   children: [
                                     Text(
                                       _selectedEnv.emoji,
                                       style: const TextStyle(fontSize: 16),
                                     ),
                                     const SizedBox(width: 12),
                                     Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Text(
                                           _selectedEnv.label,
                                           style: AppTextStyles.ui(
                                             size: 12,
                                             color: Colors.white.withValues(alpha: 0.7),
                                           ),
                                         ),
                                         Text(
                                           _selectedEnv.description,
                                           style: AppTextStyles.ui(
                                             size: 9,
                                             color: Colors.white.withValues(alpha: 0.3),
                                           ),
                                         ),
                                       ],
                                     ),
                                   ],
                                 ),
                                 Icon(
                                   Icons.unfold_more,
                                   color: Colors.white.withValues(alpha: 0.2),
                                   size: 16,
                                 ),
                               ],
                             ),
                           ),
                         ),
                         const Spacer(),

                         // Begin
                         GestureDetector(
                           onTap: () {
                             setState(() => _totalSessionSeconds = _selectedDuration * 60);
                             _startSession();
                           },
                           child: Container(
                             width: double.infinity,
                             padding: const EdgeInsets.symmetric(vertical: 18),
                             decoration: BoxDecoration(
                               border: Border.all(
                                 color: AppColors.ground.withValues(alpha: 0.4),
                               ),
                               borderRadius: BorderRadius.circular(16),
                               color: AppColors.ground.withValues(alpha: 0.06),
                             ),
                             child: Text(
                               'begin attunement',
                               textAlign: TextAlign.center,
                               style: AppTextStyles.ui(
                                 size: 14,
                                 color: AppColors.ground.withValues(alpha: 0.85),
                               ),
                             ),
                           ),
                         ),
                         const Spacer(flex: 2),
                       ],
                     ),
                   ),

                   // Back
                   Positioned(
                     top: 0,
                     left: 0,
                     child: SafeArea(
                       child: GestureDetector(
                         onTap: () => Navigator.of(context).pop(),
                         child: Padding(
                           padding: const EdgeInsets.all(AppSpacing.md),
                           child: Icon(
                             Icons.arrow_back_ios,
                             color: AppColors.ground.withValues(alpha: 0.35),
                             size: 16,
                           ),
                         ),
                       ),
                     ),
                   ),
                 ],
               ),
             ),
       const SafeHarbor(),
     ],
     )
    );
  }
  Future<void> _skipBackward() async {
  final player = QuickAudio.player;

  if (widget.mode != SessionMode.guided) return;

  final target = player.position - const Duration(seconds: 10);

  await player.seek(
    target < Duration.zero ? Duration.zero : target,
  );
}

Future<void> _seekAudio(double seconds) async {
  final player = QuickAudio.player;

  if (widget.mode != SessionMode.guided) return;

  final target = Duration(milliseconds: (seconds * 1000).round());

  await player.seek(target);
}
  // ── Active Session (Shared) ───────────────────────────────────

  Widget _buildActiveSession() {
  final durationSeconds = _audioDuration.inSeconds.toDouble();
  final positionSeconds = _audioPosition.inSeconds
      .clamp(0, _audioDuration.inSeconds)
      .toDouble();

  return Scaffold(
    backgroundColor: Colors.black.withValues(alpha: 0.85),
    body: Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              // ── Top metadata ─────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.mode == SessionMode.free)
                      GestureDetector(
                        onTap: _showSoundPicker,
                        child: Text(
                          _selectedEnv.emoji,
                          style: const TextStyle(fontSize: 14),
                        ),
                      )
                    else
                      Text(
                        _activeTrack?.id ?? '',
                        style: AppTextStyles.ui(
                          size: 10,
                          color: AppColors.ground.withValues(alpha: 0.4),
                        ),
                      ),

                    Text(
                      _timeRemaining,
                      style: AppTextStyles.ui(
                        size: 13,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),

                    GestureDetector(
                      onTap: _endSession,
                      child: Text(
                        'end',
                        style: AppTextStyles.ui(
                          size: 11,
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (widget.mode == SessionMode.guided &&
                  _activeTrack != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _activeTrack!.title,
                    style: AppTextStyles.ui(
                      size: 11,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),

              // ── Breathing area ────────────────────────────
              const Spacer(flex: 3),

              _BreathCore(
                breathController: _breathController,
                scaleAnimation: _breathScale,
                phase: _phase,
                accentColor: AppColors.ground,
              ),

              const Spacer(flex: 2),

              // ── Playback area ─────────────────────────────
              if (widget.mode == SessionMode.guided)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Spotify-like seek bar
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 5,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                          activeTrackColor:
                              AppColors.ground.withValues(alpha: 0.75),
                          inactiveTrackColor:
                              Colors.white.withValues(alpha: 0.08),
                          thumbColor: AppColors.ground,
                        ),
                        child: Slider(
                          min: 0,
                          max: durationSeconds > 0
                              ? durationSeconds
                              : 1,
                          value: positionSeconds,
                          onChanged: durationSeconds > 0
                              ? _seekAudio
                              : null,
                        ),
                      ),

                      // elapsed / total
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_audioPosition),
                              style: AppTextStyles.ui(
                                size: 9,
                                color: Colors.white.withValues(alpha: 0.22),
                              ),
                            ),
                            Text(
                              _formatDuration(_audioDuration),
                              style: AppTextStyles.ui(
                                size: 9,
                                color: Colors.white.withValues(alpha: 0.22),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // playback controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _skipBackward,
                            child: SizedBox(
                              width: 54,
                              height: 54,
                              child: Center(
                                child: Icon(
                                  Icons.replay_10,
                                  size: 26,
                                  color: Colors.white.withValues(alpha: 0.55),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 18),

                          GestureDetector(
                            onTap: _togglePause,
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.ground
                                      .withValues(alpha: 0.35),
                                ),
                                color: AppColors.ground
                                    .withValues(alpha: 0.08),
                              ),
                              child: Icon(
                                _isPaused
                                    ? Icons.play_arrow
                                    : Icons.pause,
                                size: 25,
                                color: AppColors.ground
                                    .withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),

        const SafeHarbor(),
      ],
    ),
  );
}
String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes
      .remainder(60)
      .toString()
      .padLeft(2, '0');

  final seconds = duration.inSeconds
      .remainder(60)
      .toString()
      .padLeft(2, '0');

  return '$minutes:$seconds';
}
  // ── Sound Picker ──────────────────────────────────────────────

  void _showSoundPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0A110A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'sound environment',
              style: AppTextStyles.ui(
                size: 10,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 16),
            ...kSoundEnvironments.map((env) {
              final selected = _selectedEnv.id == env.id;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedEnv = env);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: selected
                        ? AppColors.ground.withValues(alpha: 0.08)
                        : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? AppColors.ground.withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(env.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            env.label,
                            style: AppTextStyles.ui(
                              size: 13,
                              color: Colors.white.withValues(
                                alpha: selected ? 0.85 : 0.5,
                              ),
                            ),
                          ),
                          Text(
                            env.description,
                            style: AppTextStyles.ui(
                              size: 9,
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                        ],
                      ),
                      if (env.assetPath == null) ...[
                        const Spacer(),
                        Text(
                          'coming soon',
                          style: AppTextStyles.ui(
                            size: 8,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}