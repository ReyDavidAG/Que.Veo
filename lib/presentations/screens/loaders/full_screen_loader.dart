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
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1B1B2F), // azul oscuro elegante
            Color(0xFF16213E), // azul profundo
            Color(0xFF0F3460), // azul vibrante
          ],
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
                color: colors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              strokeWidth: 4.0,
              color: colors.primary,
            ),
            const SizedBox(height: 20),
            StreamBuilder<String>(
              stream: messageStream,
              builder: (context, snapshot) {
                final message = snapshot.data ?? 'Cargando...';
                return Text(
                  message,
                  style: textStyles.bodyLarge?.copyWith(
                    color: colors.onPrimary.withOpacity(0.8),
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
