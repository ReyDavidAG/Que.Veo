import 'package:cinemapedia/domain/datasources/actors_datasource.dart';
import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/repositories/actors_repository.dart';

class ActorsRepositoryImpl implements ActorsRepository {
  final ActorsDatasource actorsDatasource;

  ActorsRepositoryImpl(this.actorsDatasource);

  @override
  Future<List<Actor>> getActorsByMovieId(String movieId) {
    return actorsDatasource.getActorsByMovieId(movieId);
  }
}
