import 'package:cinemapedia/presentations/providers/movies/movie_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final initialLoadingProvider = Provider<bool>((ref) {
  final step1 = ref.watch(nowPlayingMoviesProvider);
  final step2 = ref.watch(popularMoviesProvider);
  final step3 = ref.watch(upcomingMoviesProvider);
  final step4 = ref.watch(topRatedMoviesProvider);

  if (step1.isEmpty || step2.isEmpty || step3.isEmpty || step4.isEmpty) {
    return true;
  }

  return false;
});
