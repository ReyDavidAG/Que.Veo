import 'package:cinemapedia/config/constants/environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TMDB configuration is read from compile-time defines', () {
    expect(
      Environment.isConfigured,
      Environment.movieDbKey.isNotEmpty &&
          Environment.movieDbAccessToken.isNotEmpty,
    );
  });
}
