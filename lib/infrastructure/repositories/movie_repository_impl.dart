import 'package:cinemapedia/domain/datasources/movies_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/repositories/movies_repository.dart';

class MovieRepositoryImpl extends MoviesRepository {
  final MoviesDatasource moviesDatasource;

  MovieRepositoryImpl(this.moviesDatasource);

  @override
  Future<List<Movie>> getNowPlayingMovies({int page = 1}) {
    return moviesDatasource.getNowPlayingMovies(page: page);
  }

  @override
  Future<List<Movie>> getPopularMovies({int page = 1}) {
    return moviesDatasource.getPopularMovies(page: page);
  }

  @override
  Future<List<Movie>> getUpcomingMovies({int page = 1}) {
    return moviesDatasource.getUpcomingMovies(page: page);
  }

  @override
  Future<List<Movie>> getTopRatedMovies({int page = 1}) {
    return moviesDatasource.getTopRatedMovies(page: page);
  }

  @override
  Future<Movie> getMovieById(String id) {
    return moviesDatasource.getMovieById(id);
  }

  @override
  Future<List<Movie>> getSimilarMovies(String id, {int page = 1}) {
    return moviesDatasource.getSimilarMoviesById(id: id, page: page);
  }

  @override
  Future<List<Movie>> searchMovies(String query) {
    return moviesDatasource.searchMovies(query);
  }

  @override
  Future<List<Movie>> getMoviesByGenre({required String genreId, int page = 1}) {
    return moviesDatasource.getMoviesByGenre(genreId: genreId, page: page);
  }
}
