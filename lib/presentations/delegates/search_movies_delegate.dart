import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/storage/app_preferences.dart';
import 'package:cinemapedia/config/theme/theme_context.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef SearchMoviesCallback = Future<List<Movie>> Function(String query);

class SearchMoviesDelegate extends SearchDelegate<Movie?> {
  final SearchMoviesCallback searchMovies;
  List<Movie> previousResults;
  StreamController<List<Movie>> debounceMovies = StreamController<List<Movie>>.broadcast();
  StreamController<bool> isLoadingStream = StreamController<bool>.broadcast();
  Timer? _debounceTimer;

  SearchMoviesDelegate({required this.searchMovies, required this.previousResults});

  void cleanStreams() {
    _debounceTimer?.cancel();
    debounceMovies.close();
    isLoadingStream.close();
  }

  void _onQueryChanged(String query) {
    isLoadingStream.add(true);
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final movies = await searchMovies(query);
      previousResults = movies;
      debounceMovies.add(movies);
      isLoadingStream.add(false);
    });
  }

  @override
  String get searchFieldLabel => 'Buscar películas';

  @override
  TextInputType get keyboardType => TextInputType.text;

  // searchFieldStyle is left at default — the AppBarTheme's titleTextStyle +
  // inputDecorationTheme.hintStyle drive the look.

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final isDark = theme.brightness == Brightness.dark;

    final appBar = AppBarTheme(
      backgroundColor: isDark ? Colors.black : colors.paper,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: isDark ? Colors.black : colors.paper,
      shadowColor: isDark ? Colors.black : colors.paper,
      iconTheme: IconThemeData(color: colors.icon),
      titleTextStyle: theme.textTheme.titleMedium?.copyWith(
        color: colors.text,
        fontWeight: FontWeight.w700,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );

    return theme.copyWith(
      appBarTheme: appBar,
      scaffoldBackgroundColor: isDark ? Colors.black : colors.paper,
      colorScheme: theme.colorScheme.copyWith(surface: isDark ? Colors.black : colors.paper),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: colors.surface,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: colors.textHint),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.accent, width: 1.2),
        ),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      StreamBuilder<bool>(
        initialData: false,
        stream: isLoadingStream.stream,
        builder: (context, snapshot) {
          final loading = snapshot.data ?? false;
          final colors = context.colors;

          if (loading) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                  ),
                ),
              ),
            );
          }

          if (query.isEmpty) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => query = '',
              icon: Icon(Icons.close_rounded, color: colors.icon),
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              splashRadius: 18,
              visualDensity: VisualDensity.compact,
              tooltip: 'Limpiar',
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return FadeInLeft(
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: context.colors.icon,
        ),
        onPressed: () => {cleanStreams(), close(context, null)},
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _GradientScaffold(
      child: _ResultsList(
        previousResults: previousResults,
        onSelect: (movie) => close(context, movie),
        debounceMovies: debounceMovies,
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _onQueryChanged(query);
    return _GradientScaffold(
      child: query.trim().isEmpty
          ? _IdleHint(
              onSelect: (suggestion) {
                query = suggestion;
                _onQueryChanged(query);
                showSuggestions(context);
              },
            )
          : _ResultsList(
              previousResults: previousResults,
              onSelect: (movie) {
                cleanStreams();
                close(context, movie);
              },
              debounceMovies: debounceMovies,
            ),
    );
  }
}

class _GradientScaffold extends StatelessWidget {
  final Widget child;
  const _GradientScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: context.colors.heroGradient,
          stops: const [0.0, 0.35, 0.95],
        ),
      ),
      child: child,
    );
  }
}

class _IdleHint extends StatelessWidget {
  final ValueChanged<String> onSelect;
  const _IdleHint({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final recents = AppPreferences.instance.recentSearches;
    return Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 250),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_rounded, size: 52, color: colors.iconMuted),
              const SizedBox(height: 12),
              Text(
                'Busca por título, actor o director',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (recents.isNotEmpty) ...[
                const SizedBox(height: 32),
                Text(
                  'Búsquedas recientes',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.colors.textHint,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: recents
                      .map(
                        (q) => ActionChip(
                          label: Text(q),
                          onPressed: () => onSelect(q),
                          backgroundColor: context.colors.surface,
                          labelStyle: TextStyle(color: context.colors.text),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: context.colors.rule),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final ValueChanged<Movie> onSelect;
  final StreamController<List<Movie>> debounceMovies;
  final List<Movie> previousResults;

  const _ResultsList({
    required this.onSelect,
    required this.debounceMovies,
    required this.previousResults,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return StreamBuilder<List<Movie>>(
      initialData: previousResults,
      stream: debounceMovies.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: FadeIn(
              child: Text(
                'Sin resultados',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.text,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          );
        }

        final movies = snapshot.data!;
        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          itemCount: movies.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) => ZoomIn(
            duration: Duration(milliseconds: 140 + (i % 6) * 12),
            child: _MovieResultTile(
              movie: movies[i],
              onTap: () => onSelect(movies[i]),
            ),
          ),
        );
      },
    );
  }
}

class _MovieResultTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const _MovieResultTile({
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colors.surface,
          border: Border.all(color: colors.outlineVariant, width: 1),
        ),
        child: SizedBox(
          height: 76,
          child: Row(
            children: [
              ClipRRect(
                child: Stack(
                  children: [
                    Image.network(
                      movie.posterPath,
                      width: 160,
                      height: 76,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress != null) {
                          SizedBox(
                            width: 76,
                            height: 104,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: colors.accent,
                              ),
                            ),
                          );
                        }
                        return ZoomIn(child: child);
                      },
                      errorBuilder: (_, __, ___) => Container(
                        width: 76,
                        height: 104,
                        color: Colors.black26,
                        alignment: Alignment.center,
                        child: Icon(Icons.broken_image, color: colors.iconMuted),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withAlpha(80),
                              Colors.black.withAlpha(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: colors.text,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .2,
                            ),
                      ),
                      Row(
                        children: [
                          Text(
                            _year(movie),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colors.textMuted,
                                ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.star_half_rounded,
                              color: colors.rating, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: colors.text,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _year(Movie m) {
    try {
      final dynamic rd = (m as dynamic).releaseDate;
      if (rd is DateTime) return rd.year.toString();
      if (rd is String && rd.isNotEmpty) {
        final y = RegExp(r'(\d{4})').firstMatch(rd)?.group(1);
        if (y != null) return y;
      }
    } catch (_) {}
    return '';
  }
}
