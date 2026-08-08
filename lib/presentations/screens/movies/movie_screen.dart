import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/domain/entities/movie_videos.dart';
// Importamos la entidad con un alias 'wp' para evitar conflictos
import 'package:cinemapedia/domain/entities/watch_providers.dart' as wp;
import 'package:cinemapedia/presentations/providers/favorites_localstorage/favorites_provider.dart';
import 'package:cinemapedia/presentations/providers/favorites_localstorage/is_favorite_movie_provider.dart';
import 'package:cinemapedia/presentations/providers/movie_videos/movie_videos_provider.dart';
import 'package:cinemapedia/presentations/providers/movies/actors_repository.dart';
import 'package:cinemapedia/presentations/providers/movies/movie_info_provider.dart';
import 'package:cinemapedia/presentations/providers/movies/movie_provider.dart';
import 'package:cinemapedia/presentations/providers/movies/watch_providers_provider.dart';
import 'package:cinemapedia/presentations/screens/loaders/full_screen_loader.dart';
import 'package:cinemapedia/presentations/widgets/actors/actor_horizontal_list_view.dart';
import 'package:cinemapedia/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Ocultamos 'ProviderRef' de Riverpod para usar el de nuestra entidad
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ProviderRef;
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MovieScreen extends ConsumerStatefulWidget {
  static const String routeName = 'movie_screen';
  final String movieId;
  const MovieScreen({super.key, required this.movieId});

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {
  @override
  void initState() {
    super.initState();

    ref.read(movieMapProvider.notifier).loadMovie(widget.movieId);
    ref.read(similarMoviesProvider(widget.movieId).notifier).loadNextPage();
    ref.read(actorsProvider.notifier).loadActors(widget.movieId);
    ref.read(movieVideosProvider.notifier).loadMovieVideos(widget.movieId);
    ref.read(watchProvidersProvider.notifier).loadWatchProviders(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    final Movie? movie = ref.watch(movieMapProvider)[widget.movieId];
    final similarMovies = ref.watch(similarMoviesProvider(widget.movieId));
    final actorsByMovie = ref.watch(actorsProvider)[widget.movieId] ?? [];
    final movieVideosMap = ref.watch(movieVideosProvider);
    final movieVideos = movieVideosMap[widget.movieId]?.results ?? [];
    final watchProvidersMap = ref.watch(watchProvidersProvider);
    // Usamos el alias 'wp'
    final wp.WatchProviders watchProviders =
        watchProvidersMap[widget.movieId] ?? wp.WatchProviders(results: {});

    return Scaffold(
      body: _MovieView(
          movie: movie,
          similarMovies: similarMovies,
          actors: actorsByMovie,
          movieVideos: movieVideos,
          watchProviders: watchProviders,
          loadSimilarMovies: () {
            ref.read(similarMoviesProvider(widget.movieId).notifier).loadNextPage();
          }),
    );
  }
}

class _MovieView extends StatelessWidget {
  final Movie? movie;
  final List<Movie> similarMovies;
  final Function loadSimilarMovies;
  final List<Actor> actors;
  final List<Video> movieVideos;
  // Usamos el alias 'wp'
  final wp.WatchProviders watchProviders;

  const _MovieView(
      {required this.movie,
      required this.similarMovies,
      required this.loadSimilarMovies,
      required this.actors,
      required this.movieVideos,
      required this.watchProviders});

  @override
  Widget build(BuildContext context) {
    if (movie == null) {
      return FullScreenLoader();
    }

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        _CustomSliverAppBar(movie: movie!),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: 1,
            (context, index) => _MovieDetailsSection(
                movie: movie!,
                similarMovies: similarMovies,
                loadSimilarMovies: loadSimilarMovies,
                videos: movieVideos,
                watchProviders: watchProviders,
                actors: actors),
          ),
        ),
      ],
    );
  }
}

class _CustomSliverAppBar extends ConsumerWidget {
  final Movie movie;
  const _CustomSliverAppBar({required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteInMemoryProvider(movie.id));

    Future<void> toggleFavorite() async {
      await ref.read(favoriteMoviesProvider.notifier).toggleFavoriteMovie(movie);
      ref.invalidate(isFavoriteMovieProvider(movie.id));
    }

    final size = MediaQuery.of(context).size;
    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () => SharePlus.instance.share(
            ShareParams(
              text: 'https://www.themoviedb.org/movie/${movie.id} — ${movie.title}',
            ),
          ),
          icon: const Icon(Icons.ios_share),
          color: Colors.white,
          tooltip: 'Compartir',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: AnimatedHeartButton(isFavorite: isFavorite, onTap: toggleFavorite),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
          title: Text(
            movie.title,
            style: const TextStyle(fontSize: 20, color: Colors.white),
            textAlign: TextAlign.start,
          ),
          background: DoubleTapToFavorite(
            isFavorite: isFavorite,
            onToggle: toggleFavorite,
            child: Stack(
            children: [
              SizedBox.expand(
                child: Image.network(
                  movie.posterPath,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress != null) return const SizedBox();
                    return FadeIn(child: child);
                  },
                ),
              ),
              _CustomGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.3],
                colors: [
                  Colors.black87,
                  Colors.transparent,
                ],
              ),
              _CustomGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0.0, 0.2, 0.5],
                colors: [
                  Colors.black,
                  Colors.black54,
                  Colors.transparent,
                ],
              ),

              //shadow to icon favorite
              _CustomGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [0.0, 0.4],
                colors: [
                  Colors.black87,
                  Colors.transparent,
                ],
              ),
            ],
          )),
        ),
    );
  }
}

class _MovieDetailsSection extends StatelessWidget {
  final Movie movie;
  final List<Movie> similarMovies;
  final Function loadSimilarMovies;
  final List<Actor> actors;
  final List<Video> videos;
  // Usamos el alias 'wp'
  final wp.WatchProviders watchProviders;

  const _MovieDetailsSection(
      {required this.movie,
      required this.similarMovies,
      required this.loadSimilarMovies,
      required this.actors,
      required this.videos,
      required this.watchProviders});

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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        movie.posterPath,
                        height: 150,
                      ),
                    ),
                    const SizedBox(width: 10),
                    //Title and info
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 40) * 0.70,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            height: 100,
                            child: SingleChildScrollView(
                              child: Text(
                                movie.overview.isEmpty
                                    ? 'Sin descripción disponible'
                                    : movie.overview,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
            // Videos (trailers)
            if (videos.isNotEmpty) _MovieVideosListView(videos: videos),

            //Genres
            if (movie.genres != null && movie.genres!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: movie.genres!
                        .map((genre) => InkWell(
                              onTap: () {
                                context.push('/home/0/genre/${genre.id}/${genre.name}');
                              },
                              child: Chip(
                                label: Text(genre.name),
                                backgroundColor: genre.color,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: genre.color),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                labelStyle: const TextStyle(color: Colors.white),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),

            // Watch Providers
            if (watchProviders.results.isNotEmpty)
              _NewWatchProvidersDisplay(watchProviders: watchProviders),

            ActorHorizontalListView(actors: actors),

            MovieHorizontalListview(
              movies: similarMovies,
              title: 'Películas Similares',
              loadNextPage: () => loadSimilarMovies(),
            )
          ],
        ),
      ),
    );
  }
}

class _CustomGradient extends StatelessWidget {
  final List<double> stops;
  final Alignment begin;
  final Alignment end;
  final List<Color> colors;

  const _CustomGradient(
      {required this.stops, required this.begin, required this.end, required this.colors});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            stops: stops,
            colors: colors,
          ),
        ),
      ),
    );
  }
}

class _MovieVideosListView extends StatelessWidget {
  final List<Video> videos;
  const _MovieVideosListView({required this.videos});

  @override
  Widget build(BuildContext context) {
    final youtubeVideos = videos.where((video) => video.site == 'YouTube').toList();

    if (youtubeVideos.isEmpty) {
      return const SizedBox(height: 10);
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: youtubeVideos.length,
        itemBuilder: (context, index) {
          final video = youtubeVideos[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 300,
                  height: 150,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (context, animation, __) => FadeTransition(
                            opacity: animation,
                            child: _FullScreenVideoPlayer(videoKey: video.key),
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Image.network(
                          'https://img.youtube.com/vi/${video.key}/0.jpg',
                          fit: BoxFit.cover,
                          width: 300,
                          height: 150,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 300,
                            height: 150,
                            color: Colors.black26,
                            child: const Icon(Icons.broken_image, color: Colors.white54),
                          ),
                        ),
                        const Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Icon(Icons.play_circle_fill, size: 64, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 300,
                  child: Text(
                    video.name,
                    style: const TextStyle(color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FullScreenVideoPlayer extends StatefulWidget {
  final String videoKey;
  const _FullScreenVideoPlayer({required this.videoKey});

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoKey,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        forceHD: true,
        mute: false,
        hideControls: false,
        disableDragSeek: false,
        showLiveFullscreenButton: false,
      ),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.redAccent,
              onEnded: (data) {
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          Positioned(
            top: 25,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30.0),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET PRINCIPAL DE 'DÓNDE VER' ---
class _NewWatchProvidersDisplay extends StatelessWidget {
  final wp.WatchProviders watchProviders;
  const _NewWatchProvidersDisplay({required this.watchProviders});

  @override
  Widget build(BuildContext context) {
    // 1. Detección automática de país, con fallback a 'US'
    final countryCode = Localizations.localeOf(context).countryCode ?? 'US';
    final options = watchProviders.forCountry(countryCode) ?? watchProviders.results['US'];

    if (options == null) return const SizedBox.shrink();

    // 2. Agrupamos proveedores en listas para las tabs
    final streamProviders = [
      ...options.byType(wp.ProviderType.flatrate),
      ...options.byType(wp.ProviderType.ads)
    ];
    final rentProviders = options.byType(wp.ProviderType.rent);
    final buyProviders = options.byType(wp.ProviderType.buy);

    final List<Widget> tabs = [];
    final List<Widget> tabViews = [];

    // 3. Creamos las tabs dinámicamente
    if (streamProviders.isNotEmpty) {
      tabs.add(const Tab(text: 'Streaming'));
      tabViews.add(_ProviderGrid(providers: streamProviders, link: options.link));
    }
    if (rentProviders.isNotEmpty) {
      tabs.add(const Tab(text: 'Rentar'));
      tabViews.add(_ProviderGrid(providers: rentProviders, link: options.link));
    }
    if (buyProviders.isNotEmpty) {
      tabs.add(const Tab(text: 'Comprar'));
      tabViews.add(_ProviderGrid(providers: buyProviders, link: options.link));
    }

    if (tabs.isEmpty) return const SizedBox.shrink();

    // 4. Usamos DefaultTabController para manejar el estado de las tabs
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Dónde ver',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          TabBar(
            tabs: tabs,
            isScrollable: false,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
          ),
          SizedBox(
            height: 120, // Altura para el contenido de las tabs
            child: TabBarView(
              children: tabViews,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// --- WIDGET SECUNDARIO PARA EL CONTENIDO DE LAS TABS ---
class _ProviderGrid extends StatelessWidget {
  final List<wp.ProviderRef> providers;
  final String link;
  const _ProviderGrid({required this.providers, required this.link});

  @override
  Widget build(BuildContext context) {
    if (providers.isEmpty) {
      return const Center(
        child: Text('No disponible', style: TextStyle(color: Colors.white54)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: providers.map((p) => _ProviderChip(provider: p, deepLinkUrl: link)).toList(),
        ),
      ),
    );
  }
}

// --- WIDGET PARA MOSTRAR CADA LOGO + NOMBRE (VERSIÓN MEJORADA) ---
class _ProviderChip extends StatelessWidget {
  final wp.ProviderRef provider;
  final String? deepLinkUrl;
  const _ProviderChip({required this.provider, this.deepLinkUrl});

  void _open() {
    final url = deepLinkUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _open,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF121A34),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                provider.logoUrl(size: wp.WatchLogoSize.w45),
                width: 30,
                height: 30,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 30, color: Colors.white54),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              provider.providerName,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
