import 'package:cinemapedia/presentations/providers/movies/initial_loading_provider.dart';
import 'package:cinemapedia/presentations/providers/movies/movie_provider.dart';
import 'package:cinemapedia/presentations/providers/movies/movies_slideshow_provider.dart';
import 'package:cinemapedia/presentations/screens/loaders/full_screen_loader.dart';
import 'package:cinemapedia/presentations/widgets/movies/movie_horizontal_listview.dart';
import 'package:cinemapedia/presentations/widgets/movies/movies_slideshow.dart';
import 'package:cinemapedia/presentations/widgets/movies/top_ten_movies_listview.dart';
import 'package:cinemapedia/presentations/widgets/shared/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends ConsumerState<HomeView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
    ref.read(popularMoviesProvider.notifier).loadNextPage();
    ref.read(upcomingMoviesProvider.notifier).loadNextPage();
    ref.read(topRatedMoviesProvider.notifier).loadNextPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialLoading = ref.watch(initialLoadingProvider);
    if (initialLoading) return FullScreenLoader();

    final nowPlayingMovies = ref.watch(nowPlayingMoviesProvider);
    final popularMovies = ref.watch(popularMoviesProvider);
    final upcomingMovies = ref.watch(upcomingMoviesProvider);
    final topRatedMovies = ref.watch(topRatedMoviesProvider);
    final moviesSlideshow = ref.watch(moviesSlideshowProvider);

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Color(0xFF0E1427), Color(0xFF121A34)],
              stops: [0.0, 0.85, 0.95],
            ),
          ),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: MoviesSlideshow(movies: moviesSlideshow),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, _) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          MovieHorizontalListview(
                            movies: nowPlayingMovies,
                            title: 'En cines',
                            loadNextPage: () =>
                                ref.read(nowPlayingMoviesProvider.notifier).loadNextPage(),
                          ),
                          TopTenMoviesListview(
                            movies: popularMovies,
                            title: 'Top 10 hoy',
                            subtitle: 'Más vistas',
                          ),
                          MovieHorizontalListview(
                            movies: upcomingMovies,
                            title: 'Próximamente',
                            loadNextPage: () =>
                                ref.read(upcomingMoviesProvider.notifier).loadNextPage(),
                          ),
                          MovieHorizontalListview(
                            movies: topRatedMovies,
                            title: 'Mejor valoradas',
                            loadNextPage: () =>
                                ref.read(topRatedMoviesProvider.notifier).loadNextPage(),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                  childCount: 1,
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _GlassOverlayAppBar(),
        ),
      ],
    );
  }
}

class _GlassOverlayAppBar extends StatelessWidget {
  const _GlassOverlayAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withAlpha(200),
            Colors.black.withAlpha(80),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, .6, 1],
        ),
      ),
      alignment: Alignment.center,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: CustomAppbar(),
      ),
    );
  }
}
