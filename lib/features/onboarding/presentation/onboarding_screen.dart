import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animations/jaiza_motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/jaiza_ornaments.dart';
import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../providers/providers.dart';

class _OnboardPage {
  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

const _pages = [
  _OnboardPage(
    icon: Icons.mosque_outlined,
    title: 'Track Every Salah',
    body:
        'Mark your Fard, Nawafil and Qaza prayers with a tap, and see your '
        'progress build day by day.',
  ),
  _OnboardPage(
    icon: Icons.groups_2_outlined,
    title: 'For Families & Institutes',
    body:
        'Parents can track their children, and madaris can manage teachers, '
        'classes and students — all in one place.',
  ),
  _OnboardPage(
    icon: Icons.notifications_active_outlined,
    title: 'Stay Consistent',
    body:
        'Gentle reminders at the right times help you never miss a prayer and '
        'stay steadfast on your journey.',
  ),
];

/// First-launch onboarding: three animated intro pages. Shown once per
/// install (gated by [OnboardingRepository]); afterwards the splash routes
/// straight past it.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingRepositoryProvider).markComplete();
    if (mounted) context.go('/welcome');
  }

  void _next() {
    if (_index >= _pages.length - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: JaizaMotion.fast,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      body: JaizaBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: AnimatedOpacity(
                  duration: JaizaMotion.fast,
                  opacity: isLast ? 0 : 1,
                  child: TextButton(
                    onPressed: isLast ? null : _finish,
                    child: const Text('Skip'),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, i) =>
                      _OnboardPageView(page: _pages[i]),
                ),
              ),
              const JaizaMosqueSkyline(height: 70),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _pages.length; i++)
                          AnimatedContainer(
                            duration: JaizaMotion.fast,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == _index ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _index
                                  ? scheme.tertiary
                                  : scheme.outline.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: AppTheme.tonalButtonStyle(context).copyWith(
                          backgroundColor: WidgetStatePropertyAll(
                            scheme.tertiary,
                          ),
                          foregroundColor: WidgetStatePropertyAll(
                            scheme.onTertiary,
                          ),
                          minimumSize: const WidgetStatePropertyAll(
                            Size.fromHeight(52),
                          ),
                        ),
                        onPressed: _next,
                        child: Text(
                          isLast ? 'Get Started' : 'Next',
                          style: textTheme.titleMedium?.copyWith(
                            color: scheme.onTertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPageView extends StatelessWidget {
  const _OnboardPageView({required this.page});

  final _OnboardPage page;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.secondaryContainer.withValues(alpha: 0.6),
                  border: Border.all(
                    color: scheme.tertiary.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Icon(page.icon, size: 68, color: scheme.tertiary),
              )
              .animate(key: ValueKey(page.title))
              .scale(
                begin: const Offset(0.6, 0.6),
                end: const Offset(1, 1),
                duration: JaizaMotion.slow,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: JaizaMotion.medium),
          const SizedBox(height: 36),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ).jaizaEnter(delay: JaizaMotion.fast),
          const SizedBox(height: 14),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ).jaizaEnter(delay: JaizaMotion.medium),
        ],
      ),
    );
  }
}
