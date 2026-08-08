import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopTenMoviesListview extends StatefulWidget {
  final List<Movie> movies;
  final String? title;
  final String? subtitle;

  const TopTenMoviesListview({
    super.key,
    required this.movies,
    this.title,
    this.subtitle,
  });

  @override
  State<TopTenMoviesListview> createState() => _TopTenMoviesListviewState();
}

class _TopTenMoviesListviewState extends State<TopTenMoviesListview> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Movie> get _top10 {
    if (widget.movies.length <= 10) return widget.movies;
    return widget.movies.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hasHeader = widget.title != null || widget.subtitle != null;

    return SizedBox(
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasHeader) _TopTenHeader(title: widget.title, subtitle: widget.subtitle),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _top10.length,
              itemBuilder: (context, index) {
                final movie = _top10[index];
                final rank = index + 1;
                return FadeInLeft(
                  delay: Duration(milliseconds: 50 * index),
                  child: _TopTenSlide(movie: movie, rank: rank),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _TopTenHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const _TopTenHeader({this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (title != null) _MetalDigit(digit: title!, size: 35, strokeWidth: 3.5),
          const Spacer(),
          if (subtitle != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                border: Border.all(color: onPrimary.withAlpha(89), width: 1),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withAlpha(36),
                    Colors.white.withAlpha(12),
                  ],
                ),
              ),
              child: Text(
                subtitle!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white.withAlpha(230),
                      fontWeight: FontWeight.w700,
                      letterSpacing: .2,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopTenSlide extends StatelessWidget {
  final Movie movie;
  final int rank;

  const _TopTenSlide({required this.movie, required this.rank});

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    final bool twoDigits = rank >= 10;

    return InkWell(
      onTap: () => context.push('/home/0/movie/${movie.id}'),
      child: Container(
        width: 226,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: twoDigits ? -10 : 20,
              top: 8,
              bottom: -16,
              child: _RankNumber(rank: rank),
            ),
            Positioned.fill(
              left: 70,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(140),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: Image.network(
                    movie.posterPath,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[800],
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[900],
                      alignment: Alignment.center,
                      child: Icon(Icons.broken_image, color: onPrimary.withAlpha(153)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankNumber extends StatelessWidget {
  final int rank;

  const _RankNumber({
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    if (rank >= 10) {
      return Align(
        alignment: Alignment.bottomLeft,
        child: _TwoDigitNumber(
          first: '1',
          second: '0',
          size: 120,
          strokeWidth: 4,
        ),
      );
    }
    return Align(
      alignment: Alignment.bottomLeft,
      child: _MetalDigit(
        digit: '$rank',
        size: 120,
        strokeWidth: 4,
      ),
    );
  }
}

class _TwoDigitNumber extends StatelessWidget {
  final String first;
  final String second;
  final double size;
  final double strokeWidth;

  const _TwoDigitNumber({
    required this.first,
    required this.second,
    required this.size,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final double oneSize = size;
    final double zeroSize = size * 0.96;
    final double zeroRightShift = size * 0.30;
    final double zeroUpShift = size * 0.02;

    return SizedBox(
      width: size - zeroRightShift,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: _MetalDigit(
              digit: first,
              size: oneSize,
              strokeWidth: strokeWidth,
            ),
          ),
          Positioned(
            left: zeroRightShift,
            bottom: zeroUpShift,
            child: _MetalDigit(
              digit: second,
              size: zeroSize,
              strokeWidth: strokeWidth,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetalDigit extends StatelessWidget {
  final String digit;
  final double size;
  final double strokeWidth;

  const _MetalDigit({
    required this.digit,
    required this.size,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final Rect rect = Rect.fromLTWH(0, 0, size, size);

    final Paint metallicStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF7F7F8),
          Color(0xFFE6E9EE),
          Color(0xFFBCC3CC),
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(rect);

    final Paint sideHighlightStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.55
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFFFFFFFF).withAlpha(160),
          const Color(0xFFFFFFFF).withAlpha(0),
        ],
        stops: const [0.0, 0.35],
      ).createShader(rect);

    return Align(
      alignment: Alignment.bottomLeft,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              bottom: 0,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                child: Text(
                  digit,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: size,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: -2,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Text(
                digit,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: size,
                  fontWeight: FontWeight.w900,
                  foreground: metallicStroke,
                  height: 1.0,
                  letterSpacing: -2,
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Text(
                digit,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: size,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  letterSpacing: -2,
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Text(
                digit,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: size,
                  fontWeight: FontWeight.w900,
                  foreground: sideHighlightStroke,
                  height: 1.0,
                  letterSpacing: -2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
