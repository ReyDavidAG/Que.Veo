import 'package:cinemapedia/domain/entities/genre.dart';

abstract class GenreRepository {
  Future<GenreResponse> getGenres();
}
