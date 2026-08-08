import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/presentations/providers/movies/movie_provider.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:go_router/go_router.dart';

// --- IMPORTACIONES AÑADIDAS ---
import 'dart:ui'; // Para ImageFilter
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemapedia/domain/entities/genre.dart';
import 'package:cinemapedia/presentations/providers/genre/genre_provider.dart';
// -----------------------------

class MoviesByGenreScreen extends ConsumerStatefulWidget {
  static const String routeName = 'movies-by-genre-screen';
  final String genreId;
  final String genreName;

  const MoviesByGenreScreen({super.key, required this.genreId, required this.genreName});

  @override
  MoviesByGenreScreenState createState() => MoviesByGenreScreenState();
}

class MoviesByGenreScreenState extends ConsumerState<MoviesByGenreScreen> {
  final ScrollController scrollController = ScrollController();
  bool isInitialLoadDone = false;

  @override
  void initState() {
    super.initState();
    ref.read(moviesByGenreProvider(widget.genreId).notifier).loadNextPage().then((_) {
      if (mounted) {
        setState(() {
          isInitialLoadDone = true;
        });
      }
    });

    scrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (scrollController.position.pixels + 200 >= scrollController.position.maxScrollExtent) {
      ref.read(moviesByGenreProvider(widget.genreId).notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final moviesByGenre = ref.watch(moviesByGenreProvider(widget.genreId));

    // --- LÓGICA AÑADIDA PARA OBTENER IMAGEN DE GÉNERO ---
    final allGenres = ref.watch(genreProvider);
    Genre? genre;
    try {
      genre = allGenres.firstWhere((g) => g.id.toString() == widget.genreId);
    } catch (e) {
      genre = null; // No encontrado
    }
    final imageUrl = genre?.imageUrl;
    // ----------------------------------------------------

    return Stack(
      children: [
        // --- FONDO ACTUALIZADO ---
        imageUrl != null ? _DynamicBackground(imageUrl: imageUrl) : const _StaticBackground(),
        // -------------------------

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(widget.genreName,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () {
                context.pop();
              },
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: _buildBody(moviesByGenre),
        ),
      ],
    );
  }

  Widget _buildBody(List<Movie> movies) {
    if (movies.isEmpty) {
      if (isInitialLoadDone) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.movie_filter_outlined, color: Colors.white54, size: 60),
              const SizedBox(height: 10),
              Text(
                'No movies found in\n"${widget.genreName}"',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 18),
              ),
            ],
          ),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GridView.builder(
        controller: scrollController,
        itemCount: movies.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2 / 3,
        ),
        itemBuilder: (context, index) {
          final movie = movies[index];
          // --- MEJORA DE UI ---
          return FadeInUp(
            delay: Duration(milliseconds: index * 20),
            duration: const Duration(milliseconds: 300),
            child: _MovieCard(movie: movie),
          );
        },
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final Movie movie;
  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/home/1/movie/${movie.id}');
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        // --- ARREGLO DE BUG DE CARGA ---
        child: CachedNetworkImage(
          imageUrl: movie.posterPath,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.black.withOpacity(0.2),
            child: const Icon(
              Icons.movie_creation_outlined,
              color: Colors.white38,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}

// --- WIDGETS DE FONDO AÑADIDOS ---

class _StaticBackground extends StatelessWidget {
  const _StaticBackground();

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
    );
  }
}

class _DynamicBackground extends StatelessWidget {
  final String imageUrl;
  const _DynamicBackground({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Imagen desenfocada
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            // Fallback por si la imagen de pexels falla
            errorWidget: (context, url, error) => const _StaticBackground(),
          ),
        ),
        // 2. Capa oscura para legibilidad
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.black.withOpacity(0.9),
                const Color(0xFF0E1427).withOpacity(0.95),
                const Color(0xFF121A34),
              ],
              stops: const [0.0, 0.3, 0.7, 0.95],
            ),
          ),
        ),
      ],
    );
  }
}
