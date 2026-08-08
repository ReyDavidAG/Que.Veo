import 'dart:async';

import 'package:animate_do/animate_do.dart';
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

  @override
  TextStyle? get searchFieldStyle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);

    final appBar = AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.black,
      shadowColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: theme.textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return theme.copyWith(
      appBarTheme: appBar,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: theme.colorScheme.copyWith(surface: Colors.black),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: Colors.white.withAlpha(26),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.white.withAlpha(170),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withAlpha(60), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withAlpha(60), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white, width: 1.2),
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

          if (loading) {
            return const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
              icon: const Icon(Icons.close_rounded, color: Colors.white),
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
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
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
          ? const _IdleHint()
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Color(0xFF0E1427), Color(0xFF121A34)],
          stops: [0.0, 0.35, 0.95],
        ),
      ),
      child: child,
    );
  }
}

class _IdleHint extends StatelessWidget {
  const _IdleHint();

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 250),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 52, color: onPrimary.withAlpha(170)),
            const SizedBox(height: 12),
            Text(
              'Busca por título, actor o director',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: onPrimary.withAlpha(200),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
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
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

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
                      color: onPrimary.withAlpha(200),
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
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withAlpha(20),
          border: Border.all(color: Colors.white.withAlpha(40), width: 1),
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
                                color: onPrimary.withAlpha(180),
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
                        child: Icon(Icons.broken_image, color: onPrimary.withAlpha(170)),
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
                              color: onPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .2,
                            ),
                      ),
                      Row(
                        children: [
                          Text(
                            _year(movie),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: onPrimary.withAlpha(180),
                                ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.star_half_rounded,
                              color: Colors.amber.withAlpha(230), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: onPrimary,
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
