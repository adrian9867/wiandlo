import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// ── Sound Environments ────────────────────────────────────────────
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
  SoundEnvironment(
    id: 'silence',
    label: 'Silence',
    description: 'just you',
    emoji: '◦',
  ),
  SoundEnvironment(
    id: 'temple',
    label: 'Temple',
    description: 'bells, morning air',
    emoji: '🔔',
    assetPath: 'assets/audio/temple.mp3',
  ),
  SoundEnvironment(
    id: 'nightroad',
    label: 'Night Road',
    description: 'distant traffic, wind',
    emoji: '🌙',
    assetPath: 'assets/audio/nightroad.mp3',
  ),
  SoundEnvironment(
    id: 'rain',
    label: 'Rain',
    description: 'soft, continuous',
    emoji: '🌧',
    assetPath: 'assets/audio/rain.mp3',
  ),
  SoundEnvironment(
    id: 'market',
    label: 'Market',
    description: 'alive, present',
    emoji: '🏮',
    assetPath: 'assets/audio/market.mp3',
  ),
  SoundEnvironment(
    id: 'forest',
    label: 'Forest',
    description: 'birds, leaves',
    emoji: '🌿',
    assetPath: 'assets/audio/forest.mp3',
  ),
];

// ── Breath Cycle ──────────────────────────────────────────────────
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

// ── Screen ────────────────────────────────────────────────────────
class GroundSessionScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const GroundSessionScreen({super.key, required this.onComplete});

  @override
  State<GroundSessionScreen> createState() => _GroundSessionScreenState();
}

class _GroundSessionScreenState extends State<GroundSessionScreen>
    with TickerProviderStateMixin {

  // Session state
  bool _sessionStarted = false;
  int _sessionSeconds = 0;
  int _selectedDuration = 10; // minutes
  Timer? _sessionTimer;

  // Breath state
  _BreathPhase _phase = _BreathPhase.inhale;
  int _phaseSeconds = 0;
  late AnimationController _breathController;
  late Animation<double> _breathScale;

  // Sound
  SoundEnvironment _selectedEnv = kSoundEnvironments[0]; // silence default
  bool _soundPickerOpen = false;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _kBreathDurations[_BreathPhase.inhale]!),
    );
    _breathScale = Tween<double>(begin: 0.62, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  // ── Session control ───────────────────────────────────────────
  void _startSession() {
    setState(() {
      _sessionStarted = true;
    });
    _runBreathPhase(_phase);
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _sessionSeconds++;
        _phaseSeconds++;
        final phaseDuration = _kBreathDurations[_phase]!;
        if (_phaseSeconds >= phaseDuration) {
          _phaseSeconds = 0;
          _advancePhase();
        }
        if (_sessionSeconds >= _selectedDuration * 60) {
          t.cancel();
          _endSession();
        }
      });
    });
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
    // hold phases: controller stays at current value
  }

  void _endSession() {
    _sessionTimer?.cancel();
    Navigator.of(context).pop();
    widget.onComplete();
  }

  // ── Helpers ───────────────────────────────────────────────────
  String get _timeRemaining {
    final remaining = (_selectedDuration * 60) - _sessionSeconds;
    final m = (remaining ~/ 60).toString().padLeft(2, '0');
    final s = (remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _sessionProgress =>
      _sessionSeconds / (_selectedDuration * 60);

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.78),
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: _sessionStarted ? _buildPlayer() : _buildPrepScreen(),
          ),

          // Back button (prep screen only)
          if (!_sessionStarted)
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
                      color: AppColors.ground.withValues(alpha: 0.4),
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),

          // Sound picker overlay
          if (_soundPickerOpen) _buildSoundPicker(),
        ],
      ),
    );
  }

  // ── Prep Screen ───────────────────────────────────────────────
  Widget _buildPrepScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // Title
          Text(
            'GROUND',
            style: AppTextStyles.trackLabel(
              size: 11,
              color: AppColors.ground.withValues(alpha: 0.5),
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

          // Duration selector
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
                          ? AppColors.ground.withValues(alpha: 0.7)
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

          // Sound environment picker button
          GestureDetector(
            onTap: () => setState(() => _soundPickerOpen = true),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
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

          // Begin button
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
                'begin',
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
    );
  }

  // ── Active Session Player ─────────────────────────────────────
  Widget _buildPlayer() {
    return Column(
      children: [
        // ── Progress bar (hairline at top)
        LinearProgressIndicator(
          value: _sessionProgress,
          backgroundColor: Colors.white.withValues(alpha: 0.04),
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.ground.withValues(alpha: 0.4),
          ),
          minHeight: 1,
        ),

        // ── Top row: sound env emoji + timer + end button
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sound env indicator — tap to change
              GestureDetector(
                onTap: () => setState(() => _soundPickerOpen = true),
                child: Text(
                  _selectedEnv.emoji,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Text(
                _timeRemaining,
                style: AppTextStyles.ui(
                  size: 13,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
              // End session
              GestureDetector(
                onTap: _endSession,
                child: Text(
                  'end',
                  style: AppTextStyles.ui(
                    size: 11,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(flex: 3),

        // ── Breathing orb
        AnimatedBuilder(
          animation: _breathController,
          builder: (_, __) {
            return Transform.scale(
              scale: _breathScale.value,
              child: _buildOrb(),
            );
          },
        ),

        const SizedBox(height: 40),

        // ── Breath label
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            _kBreathLabels[_phase]!,
            key: ValueKey(_phase),
            style: AppTextStyles.ui(
              size: 13,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ),

        const Spacer(flex: 4),
      ],
    );
  }

  Widget _buildOrb() {
  const double d = 200;
  return Container(
    width: d,
    height: d,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.ground.withValues(alpha: 0.05),
      border: Border.all(
        color: AppColors.ground.withValues(alpha: 0.25),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.ground.withValues(alpha: 0.10),
          blurRadius: 40,
          spreadRadius: 6,
        ),
      ],
    ),
    child: Center(
      child: Container(
        width: d * 0.42,
        height: d * 0.42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.ground.withValues(alpha: 0.18),
          boxShadow: [
            BoxShadow(
              color: AppColors.ground.withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: 3,
            ),
          ],
        ),
      ),
    ),
  );
}


  // ── Sound Picker Bottom Sheet ──────────────────────────────────
  Widget _buildSoundPicker() {
    return GestureDetector(
      onTap: () => setState(() => _soundPickerOpen = false),
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // prevent dismiss on inner tap
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0A110A),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
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
                        setState(() {
                          _selectedEnv = env;
                          _soundPickerOpen = false;
                          // TODO: play env.assetPath when audio integrated
                        });
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
                            Text(
                              env.emoji,
                              style: const TextStyle(fontSize: 18),
                            ),
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
          ),
        ),
      ),
    );
  }
}
