class Environment {
  static const movieDbKey = String.fromEnvironment('THE_MOVIE_DB_KEY');
  static const movieDbAccessToken =
      String.fromEnvironment('THE_MOVIE_DB_ACCESS_TOKEN');

  static bool get isConfigured =>
      movieDbKey.isNotEmpty && movieDbAccessToken.isNotEmpty;
}
