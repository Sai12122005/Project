import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/theme_provider.dart';
import '../quiz/quiz_page.dart';
import '../chat/chat_page.dart';
import '../results/results_page.dart';
import '../settings/settings_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  static const routeName = '/';

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _animatedButton({required IconData icon, required String label, required VoidCallback onTap, Color? color}) {
    return _BounceButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [Icon(icon), const SizedBox(width: 12), Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))]),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                ScaleTransition(
                  scale: _scale,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ]),
                          boxShadow: [
                            BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 20),
                          ],
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, size: 60, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(t.t('appName'), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                _animatedButton(
                  icon: Icons.quiz_outlined,
                  label: t.t('startQuiz'),
                  color: isDark ? Colors.indigo.shade900 : Colors.indigo.shade100,
                  onTap: () => Navigator.of(context).pushNamed(QuizPage.routeName),
                ),
                const SizedBox(height: 12),
                _animatedButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: t.t('aiTutorChat'),
                  color: isDark ? Colors.green.shade900 : Colors.green.shade100,
                  onTap: () => Navigator.of(context).pushNamed(ChatPage.routeName),
                ),
                const SizedBox(height: 12),
                _animatedButton(
                  icon: Icons.emoji_events_outlined,
                  label: t.t('results'),
                  color: isDark ? Colors.orange.shade900 : Colors.orange.shade100,
                  onTap: () => Navigator.of(context).pushNamed(ResultsPage.routeName),
                ),
                const SizedBox(height: 12),
                _animatedButton(
                  icon: Icons.settings_outlined,
                  label: t.t('settings'),
                  color: isDark ? Colors.purple.shade900 : Colors.purple.shade100,
                  onTap: () => Navigator.of(context).pushNamed(SettingsPage.routeName),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    tooltip: t.t('theme'),
                    onPressed: () {
                      final mode = Theme.of(context).brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
                      ref.read(themeModeProvider.notifier).setThemeMode(mode);
                    },
                    icon: const Icon(Icons.brightness_6_rounded),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BounceButton extends StatefulWidget {
  const _BounceButton({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<_BounceButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 120), lowerBound: 0.0, upperBound: 0.06);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails d) => _controller.forward();
  void _onTapUp(TapUpDetails d) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (d) {
        _onTapUp(d);
        widget.onTap();
      },
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1 - _controller.value;
          return Transform.scale(scale: scale, child: child);
        },
        child: widget.child,
      ),
    );
  }
}
