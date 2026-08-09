import 'package:cinemapedia/config/theme/theme_context.dart';
import 'package:flutter/material.dart';

class FullScreenLoader extends StatelessWidget {
  FullScreenLoader({super.key});

  final listMessages = <String>[
    'Cargando...',
    'Por favor, espere...',
    'Estamos trabajando en ello...',
    'Un momento, por favor...',
    'Casi listo...'
  ];

  Stream<String> get messageStream async* {
    for (final message in listMessages) {
      await Future.delayed(const Duration(seconds: 2));
      yield message;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = Theme.of(context).textTheme;
    final heroGradient = colors.heroGradient;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: heroGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Espere por favor',
              style: textStyles.headlineSmall?.copyWith(
                color: colors.text,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              strokeWidth: 4.0,
              color: colors.accent,
            ),
            const SizedBox(height: 20),
            StreamBuilder<String>(
              stream: messageStream,
              builder: (context, snapshot) {
                final message = snapshot.data ?? 'Cargando...';
                return Text(
                  message,
                  style: textStyles.bodyLarge?.copyWith(
                    color: colors.textMuted,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
