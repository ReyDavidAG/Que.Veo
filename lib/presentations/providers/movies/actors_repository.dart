import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/presentations/providers/movies/actors_respository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final actorsProvider = StateNotifierProvider<ActorsNotifier, Map<String, List<Actor>>>((ref) {
  final getActorsByMovieId = ref.watch(actorsRepositoryProvider).getActorsByMovieId;
  return ActorsNotifier((movieId) => getActorsByMovieId(movieId));
});

typedef ActorCallback = Future<List<Actor>> Function(String movieId);

class ActorsNotifier extends StateNotifier<Map<String, List<Actor>>> {
  final ActorCallback getActorsByMovieId;
  ActorsNotifier(this.getActorsByMovieId) : super({});

  Future<void> loadActors(String movieId) async {
    if (state[movieId] != null) return;
    final actors = await getActorsByMovieId(movieId);

    state = {...state, movieId: actors};
  }
}
