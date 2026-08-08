import 'package:cinemapedia/domain/datasources/actor_details_datasource.dart';
import 'package:cinemapedia/domain/entities/actor_details.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/repositories/actor_details_repository.dart';

class ActorDetailsRepositoryImpl implements ActorDetailsRepository {
  final ActorDetailsDataSource actorDetailsDataSource;
  ActorDetailsRepositoryImpl(this.actorDetailsDataSource);
  @override
  Future<ActorDetails> getActorDetails(String actorId) {
    return actorDetailsDataSource.getActorDetails(actorId);
  }

  @override
  Future<List<Movie>> getActorMovies(String actorId) {
    return actorDetailsDataSource.getActorMovies(actorId);
  }
}
