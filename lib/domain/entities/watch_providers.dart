class WatchProviders {
  final Map<String, CountryWatchOptions> results;
  WatchProviders({required this.results});

  factory WatchProviders.fromJson(Map<String, dynamic> json) {
    final results = <String, CountryWatchOptions>{};
    final map = json['results'] as Map<String, dynamic>? ?? {};
    map.forEach((k, v) => results[k] = CountryWatchOptions.fromJson(v));
    return WatchProviders(results: results);
  }

  CountryWatchOptions? forCountry(String iso3166) => results[iso3166.toUpperCase()];
}

class CountryWatchOptions {
  final String link;
  final List<ProviderRefData> flatrate;
  final List<ProviderRefData> rent;
  final List<ProviderRefData> buy;
  final List<ProviderRefData> ads;

  CountryWatchOptions({
    required this.link,
    required this.flatrate,
    required this.rent,
    required this.buy,
    required this.ads,
  });

  factory CountryWatchOptions.fromJson(Map<String, dynamic> json) {
    List<ProviderRefData> list(String key) {
      final arr = json[key] as List<dynamic>? ?? const [];
      return arr.map((e) => ProviderRefData.fromJson(e)).toList()
        ..sort((a, b) => (a.displayPriority).compareTo(b.displayPriority));
    }

    return CountryWatchOptions(
      link: json['link'] as String? ?? '',
      flatrate: list('flatrate'),
      rent: list('rent'),
      buy: list('buy'),
      ads: list('ads'),
    );
  }

  List<ProviderRefData> byType(ProviderType type) {
    switch (type) {
      case ProviderType.flatrate:
        return flatrate;
      case ProviderType.rent:
        return rent;
      case ProviderType.buy:
        return buy;
      case ProviderType.ads:
        return ads;
    }
  }
}

class ProviderRefData {
  final String logoPath;
  final int providerId;
  final String providerName;
  final int displayPriority;

  ProviderRefData({
    required this.logoPath,
    required this.providerId,
    required this.providerName,
    required this.displayPriority,
  });

  factory ProviderRefData.fromJson(Map<String, dynamic> json) => ProviderRefData(
        logoPath: json['logo_path'] as String? ?? '',
        providerId: (json['provider_id'] as num).toInt(),
        providerName: json['provider_name'] as String? ?? '',
        displayPriority: (json['display_priority'] as num?)?.toInt() ?? 999,
      );

  String logoUrl({WatchLogoSize size = WatchLogoSize.w92}) {
    final s = switch (size) {
      WatchLogoSize.w45 => 'w45',
      WatchLogoSize.w92 => 'w92',
      WatchLogoSize.w154 => 'w154'
    };
    return 'https://image.tmdb.org/t/p/$s$logoPath';
  }
}

enum ProviderType { flatrate, rent, buy, ads }

enum WatchLogoSize { w45, w92, w154 }
