import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/safe_harbor.dart';

const List<String> kInquiryQuestions = [
  'What are you avoiding feeling right now?',
  'Who is aware of these thoughts?',
  'What would it mean to let go completely?',
  'Where in your body do you feel most alive?',
  'What are you pretending not to know?',
  'If no one could see you, who would you be?',
  'What is trying to emerge through you today?',
  'What are you holding that is not yours?',
  'What would silence say if it could speak?',
  'Who is the one watching the one who asks?',
];

class DailyInquiryScreen extends StatefulWidget {
  const DailyInquiryScreen({super.key});

  @override
  State<DailyInquiryScreen> createState() => _DailyInquiryScreenState();
}

class _DailyInquiryScreenState extends State<DailyInquiryScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _reflections = [];
  bool _saved = false;

  String get _todayQuestion {
    final n = DateTime.now();
    final day = n.day + n.month * 31 + n.year * 365;
    return kInquiryQuestions[day % kInquiryQuestions.length];
  }

  @override
  void initState() {
    super.initState();
    _loadReflections();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadReflections() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('wiandlo_reflections') ?? [];
    setState(() {
      _reflections = raw
          .map((r) => jsonDecode(r) as Map<String, dynamic>)
          .toList();
      _reflections.sort(
        (a, b) => DateTime.parse(b['date']).compareTo(
          DateTime.parse(a['date']),
        ),
      );
    });

    final today = DateTime.now();
    for (final r in _reflections) {
      final d = DateTime.parse(r['date']);
      if (d.year == today.year &&
          d.month == today.month &&
          d.day == today.day &&
          r['question'] == _todayQuestion) {
        _controller.text = r['answer'];
        setState(() => _saved = true);
        break;
      }
    }
  }

  Future<void> _saveReflection() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('wiandlo_reflections') ?? [];
    final today = DateTime.now();

    raw.removeWhere((r) {
      final m = jsonDecode(r) as Map<String, dynamic>;
      final d = DateTime.parse(m['date']);
      return d.year == today.year &&
          d.month == today.month &&
          d.day == today.day &&
          m['question'] == _todayQuestion;
    });

    raw.add(jsonEncode({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'date': DateTime.now().toIso8601String(),
      'question': _todayQuestion,
      'answer': text,
    }));

    await prefs.setStringList('wiandlo_reflections', raw);
    setState(() => _saved = true);
    await _loadReflections();
    if (mounted) FocusScope.of(context).unfocus();
  }

  String _formatDate(String iso) {
    final d = DateTime.parse(iso);
    return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                              color: AppColors.open.withValues(alpha: 0.35),
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'OPEN',
                        style: AppTextStyles.trackLabel(
                          size: 11,
                          color: AppColors.open.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          _formatDate(DateTime.now().toIso8601String()),
                          style: AppTextStyles.ui(
                            size: 10,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          _todayQuestion,
                          style: AppTextStyles.ui(
                            size: 22,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.open.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                          ),
                          child: TextField(
                            controller: _controller,
                            maxLines: 6,
                            minLines: 3,
                            style: AppTextStyles.ui(
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            decoration: InputDecoration(
                              hintText: 'write what arises...',
                              hintStyle: AppTextStyles.ui(
                                size: 13,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onChanged: (_) {
                              if (_saved) setState(() => _saved = false);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: _saveReflection,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _saved
                                    ? AppColors.open.withValues(alpha: 0.3)
                                    : AppColors.open.withValues(alpha: 0.5),
                              ),
                              borderRadius: BorderRadius.circular(40),
                              color: _saved
                                  ? AppColors.open.withValues(alpha: 0.05)
                                  : AppColors.open.withValues(alpha: 0.1),
                            ),
                            child: Text(
                              _saved ? 'recorded' : 'record reflection',
                              style: AppTextStyles.ui(
                                size: 12,
                                color: _saved
                                    ? AppColors.open.withValues(alpha: 0.5)
                                    : AppColors.open.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 56),
                        if (_reflections.isNotEmpty) ...[
                          Text(
                            'past reflections',
                            style: AppTextStyles.ui(
                              size: 10,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ..._reflections.map((r) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.06),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white.withValues(alpha: 0.02),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDate(r['date']),
                                    style: AppTextStyles.ui(
                                      size: 9,
                                      color: AppColors.open.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    r['question'],
                                    style: AppTextStyles.ui(
                                      size: 11,
                                      color: Colors.white.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    r['answer'],
                                    style: AppTextStyles.ui(
                                      size: 13,
                                      color: Colors.white.withValues(
                                        alpha: 0.65,
                                      ),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 40),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SafeHarbor(),
        ],
      ),
    );
  }
}