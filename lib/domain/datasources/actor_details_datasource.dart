import 'package:cinemapedia/domain/entities/actor_details.dart';
import 'package:cinemapedia/domain/entities/movie.dart';

abstract class ActorDetailsDataSource {
  Future<ActorDetails> getActorDetails(String actorId);
  Future<List<Movie>> getActorMovies(String actorId);
}
