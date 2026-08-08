import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String movieDbKey = dotenv.env['THE_MOVIE_DB_KEY'] ?? 'No key found';
  static String movieDbAccessToken = dotenv.env['THE_MOVIE_DB_ACCESS_TOKEN'] ?? 'No token found';
}
