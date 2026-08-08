import 'package:cinemapedia/infrastructure/datasources/actor_details_moviedb_datasouce.dart';
import 'package:cinemapedia/infrastructure/reporsitories/actor_details_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final actorDetailsRepositoryProvider = Provider<ActorDetailsRepositoryImpl>((ref) {
  return ActorDetailsRepositoryImpl(ActorDetailsMoviedbDatasouce());
});
