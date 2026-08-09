import 'package:cinemapedia/config/storage/app_preferences.dart';
import 'package:cinemapedia/config/theme/app_spacing.dart';
import 'package:cinemapedia/config/theme/theme_context.dart';
import 'package:cinemapedia/config/theme/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings: theme mode (live), recent searches clear, app version.
/// The language toggle is a placeholder until i18n is real.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final themeMode = ref.watch(themeModeProvider);
    final version = '1.0.0'; // placeholder until pubspec.yaml is wired

    return Scaffold(
      backgroundColor: colors.paper,
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: colors.paper,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const _SectionTitle('Apariencia'),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('Sistema')),
              ButtonSegment(value: ThemeMode.light, label: Text('Claro')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro')),
            ],
            selected: {themeMode},
            onSelectionChanged: (selection) {
              ref.read(themeModeProvider.notifier).set(selection.first);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionTitle('Idioma'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.language, color: colors.icon),
            title: const Text('Español (México)'),
            subtitle: Text(
              'Próximamente: más idiomas.',
              style: textTheme.bodySmall?.copyWith(color: colors.textHint),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionTitle('Datos'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.history, color: colors.icon),
            title: const Text('Borrar historial de búsqueda'),
            onTap: () async {
              await AppPreferences.instance.setRecentSearches(const <String>[]);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Historial borrado')),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl3),
          Center(
            child: Text(
              'cinemapedia · $version',
              style: textTheme.bodySmall?.copyWith(color: colors.textHint),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: context.colors.textMuted,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
