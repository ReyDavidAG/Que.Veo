import 'package:cinemapedia/infrastructure/datasources/genre_moviedb_datasource.dart';
import 'package:cinemapedia/infrastructure/repositories/genre_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final genreProviderRepository = Provider<GenreRepositoryImpl>((ref) {
  return GenreRepositoryImpl(GenreMovieDBDataSource());
});
