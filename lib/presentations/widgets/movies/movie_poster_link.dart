import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoviePosterLink extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onLongPress;

  const MoviePosterLink({super.key, required this.movie, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/0/movie/${movie.id}'),
      onLongPress: onLongPress,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(movie.posterPath),
      ),
    );
  }
}
