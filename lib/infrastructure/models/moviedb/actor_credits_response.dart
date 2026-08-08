class CastMovie {
  final List<CastM> cast;
  final List<dynamic> crew;
  final int id;

  CastMovie({
    required this.cast,
    required this.crew,
    required this.id,
  });

  factory CastMovie.fromJson(Map<String, dynamic> json) => CastMovie(
        cast: List<CastM>.from(json["cast"].map((x) => CastM.fromJson(x))),
        crew: List<dynamic>.from(json["crew"].map((x) => x)),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "cast": List<dynamic>.from(cast.map((x) => x.toJson())),
        "crew": List<dynamic>.from(crew.map((x) => x)),
        "id": id,
      };
}

class CastM {
  final bool adult;
  final String? backdropPath;
  final List<int>? genreIds;
  final int id;
  final String originalLanguage;
  final String originalTitle;
  final String overview;
  final double? popularity;
  final String? posterPath;
  final String title;
  final bool? video;
  final double? voteAverage;
  final int? voteCount;
  final String character;
  final String creditId;
  final int order;

  CastM({
    required this.adult,
    required this.backdropPath,
    required this.genreIds,
    required this.id,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
    required this.character,
    required this.creditId,
    required this.order,
  });

  factory CastM.fromJson(Map<String, dynamic> json) => CastM(
        adult: json["adult"],
        backdropPath: json["backdrop_path"],
        genreIds:
            json["genre_ids"] != null ? List<int>.from(json["genre_ids"].map((x) => x)) : null,
        id: json["id"],
        originalLanguage: json["original_language"],
        originalTitle: json["original_title"],
        overview: json["overview"],
        popularity: json["popularity"]?.toDouble(),
        posterPath: json["poster_path"],
        title: json["title"],
        video: json["video"],
        voteAverage: json["vote_average"]?.toDouble(),
        voteCount: json["vote_count"],
        character: json["character"],
        creditId: json["credit_id"],
        order: json["order"],
      );

  Map<String, dynamic> toJson() => {
        "adult": adult,
        "backdrop_path": backdropPath,
        "genre_ids": genreIds != null ? List<dynamic>.from(genreIds!.map((x) => x)) : null,
        "id": id,
        "original_language": originalLanguage,
        "original_title": originalTitle,
        "overview": overview,
        "popularity": popularity,
        "poster_path": posterPath,
        "title": title,
        "video": video,
        "vote_average": voteAverage,
        "vote_count": voteCount,
        "character": character,
        "credit_id": creditId,
        "order": order,
      };
}
