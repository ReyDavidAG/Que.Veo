import 'package:cinemapedia/domain/entities/genre.dart';

abstract class GenreDataSource {
  Future<GenreResponse> getGenres();
}
