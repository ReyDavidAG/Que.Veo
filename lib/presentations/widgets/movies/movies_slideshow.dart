import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoviesSlideshow extends StatefulWidget {
  final List<Movie> movies;

  const MoviesSlideshow({super.key, required this.movies});

  @override
  State<MoviesSlideshow> createState() => _MoviesSlideshowState();
}

class _MoviesSlideshowState extends State<MoviesSlideshow> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    final movies = widget.movies;

    return Stack(
      children: [
        Positioned.fill(
          child: _BlurredBackground(
            key: ValueKey(movies[_currentIndex].id),
            imageUrl: movies[_currentIndex].posterPath,
          ),
        ),
        // Pass-through overlays: taps fall through to the InkWell on each slide.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: _TopShade(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            width: double.infinity,
            child: Swiper(
              viewportFraction: 1,
              scale: 1,
              autoplay: true,
              autoplayDelay: 8000,
              duration: 900,
              onIndexChanged: (index) {
                setState(() => _currentIndex = index);
              },
              pagination: null,
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return _Slide(movie: movie);
              },
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: _BottomOverlayContent(
              movie: widget.movies[_currentIndex],
              currentIndex: _currentIndex,
              total: widget.movies.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _Slide extends StatelessWidget {
  final Movie movie;
  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(0),
      boxShadow: const [
        BoxShadow(
          color: Colors.black45,
          blurRadius: 10,
          offset: Offset(0, 20),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(0),
      child: InkWell(
        onTap: () => context.push('/home/0/movie/${movie.id}'),
        child: DecoratedBox(
          decoration: decoration,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Image.network(
              movie.posterPath,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return FadeIn(child: child);
                return const DecoratedBox(decoration: BoxDecoration(color: Colors.black12));
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BlurredBackground extends StatelessWidget {
  final String imageUrl;
  const _BlurredBackground({required super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        color: Colors.black.withAlpha(30),
        colorBlendMode: BlendMode.darken,
      ),
    );
  }
}

class _TopShade extends StatelessWidget {
  const _TopShade();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha(200), // fuerte arriba
            Colors.black.withAlpha(0), // se desvanece
          ],
        ),
      ),
    );
  }
}

class _BottomOverlayContent extends StatelessWidget {
  final Movie movie;
  final int currentIndex;
  final int total;

  const _BottomOverlayContent({
    required this.movie,
    required this.currentIndex,
    required this.total,
  });

  String _yearFromMovie(Movie m) {
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

  String _ratingText(Movie m) {
    try {
      final dynamic va = (m as dynamic).voteAverage;
      if (va != null) {
        final num n = (va is num) ? va : num.tryParse(va.toString()) ?? 0;
        return n.toStringAsFixed(1);
      }
    } catch (_) {}
    return '—';
  }

  String _overview(Movie m) {
    try {
      final dynamic ov = (m as dynamic).overview;
      if (ov is String && ov.trim().isNotEmpty) return ov.trim();
    } catch (_) {}
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final year = _yearFromMovie(movie);
    final rating = _ratingText(movie);
    final overview = _overview(movie);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha(0),
            Colors.black.withAlpha(160),
            Colors.black.withAlpha(210),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              _Chip(
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text(
                      rating,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (year.isNotEmpty)
                _Chip(
                  child: Text(
                    year,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (overview.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                overview,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      height: 1.35,
                    ),
              ),
            ),
          const SizedBox(height: 12),
          _DotsIndicator(
            length: total,
            index: currentIndex,
            activeColor: Colors.white,
            inactiveColor: Colors.white.withAlpha(150),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final Widget child;
  const _Chip({required this.child});

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(60),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: onPrimary.withAlpha(80)),
      ),
      child: child,
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int length;
  final int index;
  final Color activeColor;
  final Color inactiveColor;

  const _DotsIndicator({
    required this.length,
    required this.index,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final bool active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}
