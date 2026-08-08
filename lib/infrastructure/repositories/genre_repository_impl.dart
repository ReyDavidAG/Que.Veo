import 'package:cinemapedia/domain/datasources/genre_datasource.dart';
import 'package:cinemapedia/domain/entities/genre.dart';
import 'package:cinemapedia/repositories/genre_repository.dart';

class GenreRepositoryImpl implements GenreRepository {
  final GenreDataSource dataSource;
  GenreRepositoryImpl(this.dataSource);
  @override
  Future<GenreResponse> getGenres() {
    return dataSource.getGenres();
  }
}
