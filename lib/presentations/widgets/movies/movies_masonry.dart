import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentations/widgets/movies/movie_poster_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MovieMasonry extends StatefulWidget {
  final List<Movie> movies;
  final Future<List<Movie>> Function()? loadNextPage;
  final void Function(Movie movie)? onMovieLongPress;

  const MovieMasonry({
    super.key,
    required this.movies,
    this.loadNextPage,
    this.onMovieLongPress,
  });

  @override
  State<MovieMasonry> createState() => _MovieMasonryState();
}

class _MovieMasonryState extends State<MovieMasonry> {
  bool isLastPage = false;
  bool isLoading = false;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      // if(widget.loadNextPage == null) return;

      // Si el scroll está al final o cerca de unos 200px, aquí llamar el loadNextPage
      if (scrollController.position.pixels + 200 >= scrollController.position.maxScrollExtent) {
        loadNextPageMovies();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void loadNextPageMovies() async {
    if (isLoading || isLastPage) return;
    if (widget.loadNextPage == null) return;

    isLoading = true;
    final movies = await widget.loadNextPage!();
    isLoading = false;

    if (movies.isEmpty) {
      isLastPage = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: MasonryGridView.count(
        controller: scrollController,
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: widget.movies.length,
        itemBuilder: (context, index) {
          final movie = widget.movies[index];
          final tile = MoviePosterLink(
            movie: movie,
            onLongPress: widget.onMovieLongPress == null
                ? null
                : () => widget.onMovieLongPress!(movie),
          );

          if (index == 1) {
            return Column(
              children: [
                const SizedBox(height: 30),
                tile,
              ],
            );
          }

          return tile;
        },
      ),
    );
  }
}
