import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/storage/app_preferences.dart';
import 'package:cinemapedia/config/theme/app_spacing.dart';
import 'package:cinemapedia/config/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Three-slide first-launch tour. Shown once; completion persists in
/// [AppPreferences.onboardingDone]. Returns to `/home/0` when done.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = <_Slide>[
    _Slide(
      icon: Icons.movie_filter_outlined,
      title: 'Descubre qué ver',
      body: 'Estrenos, populares y mejor valoradas. Sin catálogo interminable.',
    ),
    _Slide(
      icon: Icons.favorite_border,
      title: 'Guarda lo que quieres ver',
      body: 'Toca el corazón en cualquier película. Doble-tap en el poster también.',
    ),
    _Slide(
      icon: Icons.search,
      title: 'Encuentra por título, actor o director',
      body: 'La búsqueda está en la barra superior. Te mostramos resultados al instante.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await AppPreferences.instance.setOnboardingDone();
    if (!mounted) return;
    context.go('/home/0');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.paper,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            _DotsIndicator(count: _slides.length, current: _page),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _page == _slides.length - 1 ? _finish : () => _controller.nextPage(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOut,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.accentInk,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    ),
                  ),
                  child: Text(_page == _slides.length - 1 ? 'Empezar' : 'Siguiente'),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final String title;
  final String body;
  const _Slide({required this.icon, required this.title, required this.body});
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeIn(
            duration: const Duration(milliseconds: 240),
            child: Icon(slide.icon, size: 96, color: colors.accent),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(color: colors.text),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;
  const _DotsIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? colors.accent : colors.iconMuted,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
