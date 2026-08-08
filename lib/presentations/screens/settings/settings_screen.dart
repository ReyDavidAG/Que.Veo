import 'package:cinemapedia/config/storage/app_preferences.dart';
import 'package:cinemapedia/config/theme/app_colors.dart';
import 'package:cinemapedia/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Settings: theme mode (cosmetic until a light theme ships), recent searches
/// clear, app version. The language toggle is a placeholder until i18n is real.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _themeMode = 'dark';

  @override
  void initState() {
    super.initState();
    _themeMode = AppPreferences.instance.themeMode;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final version = '1.0.0'; // placeholder until pubspec.yaml is wired

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: AppColors.paper,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _SectionTitle('Apariencia'),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'system', label: Text('Sistema')),
              ButtonSegment(value: 'light', label: Text('Claro')),
              ButtonSegment(value: 'dark', label: Text('Oscuro')),
            ],
            selected: {_themeMode},
            onSelectionChanged: (selection) async {
              setState(() => _themeMode = selection.first);
              await AppPreferences.instance.setThemeMode(selection.first);
            },
          ),
          const SizedBox(height: AppSpacing.xs2),
          Text(
            'El modo claro llega en una versión futura.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textHint),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle('Idioma'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language, color: AppColors.icon),
            title: const Text('Español (México)'),
            subtitle: Text(
              'Próximamente: más idiomas.',
              style: textTheme.bodySmall?.copyWith(color: AppColors.textHint),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle('Datos'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history, color: AppColors.icon),
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
              style: textTheme.bodySmall?.copyWith(color: AppColors.textHint),
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
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
