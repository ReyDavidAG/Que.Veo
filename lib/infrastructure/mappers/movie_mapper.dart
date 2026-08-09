import 'package:cinemapedia/config/database/database.dart';
import 'package:cinemapedia/domain/entities/genre.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/actor_credits_response.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/movie_details.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/movie_moviedb.dart';

class MovieMapper {
  static Movie movieDBToEntity(MovieMovieDB movieMovieDB) => Movie(
        adult: movieMovieDB.adult,
        backdropPath: movieMovieDB.backdropPath != ''
            ? 'https://image.tmdb.org/t/p/w500${movieMovieDB.backdropPath}'
            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRoWcWg0E8pSjBNi0TtiZsqu8uD2PAr_K11DA&s',
        genreIds: movieMovieDB.genreIds.map((e) => e.toString()).toList(),
        id: movieMovieDB.id,
        originalLanguage: movieMovieDB.originalLanguage,
        originalTitle: movieMovieDB.originalTitle,
        overview: movieMovieDB.overview,
        popularity: movieMovieDB.popularity,
        posterPath: movieMovieDB.posterPath != ''
            ? 'https://image.tmdb.org/t/p/w500${movieMovieDB.posterPath}'
            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRoWcWg0E8pSjBNi0TtiZsqu8uD2PAr_K11DA&s',
        releaseDate: movieMovieDB.releaseDate,
        title: movieMovieDB.title,
        video: movieMovieDB.video,
        voteAverage: movieMovieDB.voteAverage,
        voteCount: movieMovieDB.voteCount,
      );

  static Movie movieDetailsToEntity(MovieDetails movieDetails) => Movie(
        adult: movieDetails.adult,
        backdropPath: movieDetails.backdropPath != '' && movieDetails.backdropPath != null
            ? 'https://image.tmdb.org/t/p/w500${movieDetails.backdropPath}'
            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRoWcWg0E8pSjBNi0TtiZsqu8uD2PAr_K11DA&s',
        genreIds: movieDetails.genres.map((e) => e.name.toString()).toList(),
        genres: movieDetails.genres.map((e) => Genre(id: e.id, name: e.name)).toList(),
        id: movieDetails.id,
        originalLanguage: movieDetails.originalLanguage,
        originalTitle: movieDetails.originalTitle,
        overview: movieDetails.overview,
        popularity: movieDetails.popularity,
        posterPath: movieDetails.posterPath != '' && movieDetails.posterPath != null
            ? 'https://image.tmdb.org/t/p/w500${movieDetails.posterPath}'
            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRoWcWg0E8pSjBNi0TtiZsqu8uD2PAr_K11DA&s',
        releaseDate: movieDetails.releaseDate,
        title: movieDetails.title,
        video: false,
        voteAverage: movieDetails.voteAverage,
        voteCount: movieDetails.voteCount,
      );

  static Movie castToEntity(CastM cast) => Movie(
        id: cast.id,
        adult: cast.adult,
        backdropPath: cast.backdropPath != null && cast.backdropPath != ''
            ? 'https://image.tmdb.org/t/p/w500${cast.backdropPath}'
            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRoWcWg0E8pSjBNi0TtiZsqu8uD2PAr_K11DA&s',
        genreIds: cast.genreIds != null ? cast.genreIds!.map((e) => e.toString()).toList() : [],
        originalLanguage: cast.originalLanguage,
        originalTitle: cast.originalTitle,
        overview: cast.overview,
        popularity: cast.popularity ?? 0,
        posterPath: cast.posterPath != '' && cast.posterPath != null
            ? 'https://image.tmdb.org/t/p/w500${cast.posterPath}'
            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRoWcWg0E8pSjBNi0TtiZsqu8uD2PAr_K11DA&s',
        releaseDate: null,
        title: cast.title,
        video: cast.video ?? false,
        voteAverage: cast.voteAverage ?? 0,
        voteCount: cast.voteCount ?? 0,
      );

  static Movie favoriteDBToEntity(FavoriteMovy favoriteMovy) => Movie(
        id: favoriteMovy.movieId,
        adult: false,
        backdropPath: favoriteMovy.backdropPath,
        genreIds: [],
        originalLanguage: '',
        originalTitle: favoriteMovy.originalTitle,
        overview: '',
        popularity: 0,
        posterPath: favoriteMovy.posterPath.startsWith('https://')
            ? favoriteMovy.posterPath
            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRoWcWg0E8pSjBNi0TtiZsqu8uD2PAr_K11DA&s',
        releaseDate: null,
        title: favoriteMovy.title,
        video: false,
        voteAverage: favoriteMovy.voteAverage,
        voteCount: 0,
      );
}
