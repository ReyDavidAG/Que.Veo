import 'package:cinemapedia/domain/entities/actor_details.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentations/providers/movies/actor_details_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final actorDetailsProvider =
    StateNotifierProvider<ActorDetailsNotifier, Map<String, ActorDetails>>((ref) {
  final getActorDetails = ref.watch(actorDetailsRepositoryProvider).getActorDetails;
  return ActorDetailsNotifier((actorId) => getActorDetails(actorId));
});

final actorMoviesProvider =
    StateNotifierProvider<ActorMoviesNotifier, Map<String, List<Movie>>>((ref) {
  final getActorMovies = ref.watch(actorDetailsRepositoryProvider).getActorMovies;
  return ActorMoviesNotifier((actorId) => getActorMovies(actorId));
});

typedef ActorDetailsCallback = Future<ActorDetails> Function(String actorId);
typedef ActorMoviesCallback = Future<List<Movie>> Function(String actorId);

class ActorDetailsNotifier extends StateNotifier<Map<String, ActorDetails>> {
  final ActorDetailsCallback getActorDetails;
  ActorDetailsNotifier(this.getActorDetails) : super({});

  Future<void> loadActorDetails(String actorId) async {
    if (state[actorId] != null) return;
    final actorDetails = await getActorDetails(actorId);

    state = {...state, actorId: actorDetails};
  }
}

class ActorMoviesNotifier extends StateNotifier<Map<String, List<Movie>>> {
  final ActorMoviesCallback getActorMovies;
  ActorMoviesNotifier(this.getActorMovies) : super({});

  Future<void> loadActorMovies(String actorId) async {
    if (state[actorId] != null) return;
    final actorMovies = await getActorMovies(actorId);

    state = {...state, actorId: actorMovies};
  }
}
