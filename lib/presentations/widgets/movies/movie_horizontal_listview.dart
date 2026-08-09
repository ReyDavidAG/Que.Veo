import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/config/theme/theme_context.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MovieHorizontalListview extends StatefulWidget {
  final List<Movie> movies;
  final String? title;
  final String? subtitle;
  final VoidCallback? loadNextPage;

  const MovieHorizontalListview({
    super.key,
    required this.movies,
    this.title,
    this.subtitle,
    this.loadNextPage,
  });

  @override
  State<MovieHorizontalListview> createState() => _MovieHorizontalListviewState();
}

class _MovieHorizontalListviewState extends State<MovieHorizontalListview> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (widget.loadNextPage == null) return;

      if ((scrollController.position.pixels + 200) >= scrollController.position.maxScrollExtent) {
        widget.loadNextPage!();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null || widget.subtitle != null)
            _Title(
              title: widget.title,
              subtitle: widget.subtitle,
            ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.movies.length,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final movie = widget.movies[index];
                return FadeInRight(
                  child: _Slide(movie: movie),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final Movie movie;

  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final colors = context.colors;

    return InkWell(
      onTap: () {
        context.push('/home/0/movie/${movie.id}');
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con borde y sombra
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.network(
                movie.posterPath,
                height: 220,
                width: 150,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return FadeIn(child: child);
                  return Container(
                    height: 220,
                    width: 150,
                    decoration: BoxDecoration(
                      color: colors.surfaceRaised,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(color: colors.accent),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Título
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textStyles.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 4),
            // Rating y popularidad
            Row(
              children: [
                Icon(Icons.star_half_rounded, color: colors.rating, size: 16),
                const SizedBox(width: 4),
                Text(
                  movie.voteAverage.toString(),
                  style: textStyles.labelSmall?.copyWith(color: colors.rating),
                ),
                const Spacer(),
                Text(
                  HumanFormats.number(movie.popularity),
                  style: textStyles.labelSmall?.copyWith(color: colors.textMuted),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const _Title({this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final colors = context.colors;

    final textStyle = textStyles.titleMedium?.copyWith(
      color: colors.text,
      fontWeight: FontWeight.w600,
      overflow: TextOverflow.ellipsis,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (title != null)
              Text(
                title!,
                style: textStyle,
              ),
            const SizedBox(width: 8),
            if (subtitle != null)
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  side: BorderSide(color: colors.accent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: Text(
                  subtitle!,
                  style: textStyles.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.text,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
