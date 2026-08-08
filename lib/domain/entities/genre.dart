import 'package:flutter/material.dart';

class GenreResponse {
  final List<Genre> genres;

  GenreResponse({
    required this.genres,
  });

  factory GenreResponse.fromJson(Map<String, dynamic> json) => GenreResponse(
        genres: List<Genre>.from(json["genres"].map((x) => Genre.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "genres": List<dynamic>.from(genres.map((x) => x.toJson())),
      };
}

class Genre {
  final int id;
  final String name;

  Genre({
    required this.id,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) => Genre(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };

  Color get color {
    switch (id) {
      case 28:
        return Colors.red.shade700;
      case 12:
        return Colors.deepOrange.shade600;
      case 16:
        return Colors.blue.shade400;
      case 35:
        return Colors.yellow.shade800;
      case 80:
        return Colors.blueGrey.shade800;
      case 99:
        return Colors.green.shade700;
      case 18:
        return Colors.purple.shade600;
      case 10751:
        return Colors.pink.shade300;
      case 14:
        return Colors.deepPurpleAccent.shade200;
      case 36:
        return Colors.brown.shade600;
      case 27:
        return Colors.black87;
      case 10402:
        return Colors.teal.shade400;
      case 9648:
        return Colors.indigo.shade700;
      case 10749:
        return Colors.redAccent.shade200;
      case 878:
        return Colors.cyan.shade600;
      case 10770:
        return Colors.grey.shade700;
      case 53:
        return Colors.lime.shade900;
      case 10752:
        return Colors.red.shade900;
      case 37:
        return Colors.amber.shade900;
      default:
        return Colors.grey.shade500;
    }
  }

  IconData get icon {
    switch (id) {
      case 28:
        return Icons.flash_on;
      case 12:
        return Icons.explore;
      case 16:
        return Icons.brush;
      case 35:
        return Icons.sentiment_very_satisfied;
      case 80:
        return Icons.gavel;
      case 99:
        return Icons.camera_roll;
      case 18:
        return Icons.theater_comedy;
      case 10751:
        return Icons.family_restroom;
      case 14:
        return Icons.auto_stories;
      case 36:
        return Icons.account_balance;
      case 27:
        return Icons.bug_report;
      case 10402:
        return Icons.music_note;
      case 9648:
        return Icons.help_outline;
      case 10749:
        return Icons.favorite;
      case 878:
        return Icons.rocket_launch;
      case 10770:
        return Icons.tv;
      case 53:
        return Icons.hourglass_top;
      case 10752:
        return Icons.shield;
      case 37:
        return Icons.landscape;
      default:
        return Icons.movie;
    }
  }

  String get imageUrl {
    switch (id) {
      case 28:
        return 'https://hips.hearstapps.com/es.h-cdn.co/fotoes/images/noticias-cine/bad-boys-3/4-trama-bad-boys/138084844-1-esl-ES/4-trama-bad-boys.jpg';
      case 12:
        return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTcqt5BGOPhbuxlgqbPEVQ_KB1yzB3j6uWCBQ&s';
      case 16:
        return 'https://www.sopitas.com/wp-content/uploads/2016/03/movies.jpg';
      case 35:
        return 'https://larepublica.cronosmedia.glr.pe/original/2023/08/21/64e417e7c4e9cb42b66ba1cd.jpg'; //comedia
      case 80:
        return 'https://occ-0-8407-2219.1.nflxso.net/dnm/api/v6/6AYY37jfdO6hpXcMjf9Yu5cnmO0/AAAABccNpwznngy08YRwEWr-dqkf_E1DzQD49WWgs_FxS-c75_p-0F9pqWY4xVzXyO8tm2lIfkjDnHCdV8855y2zkH8OD6XtkpeD-69f.jpg?r=830';
      case 99:
        return 'https://beam-images.warnermediacdn.com/BEAM_LWM_DELIVERABLES/ddebe436-b6ee-4c27-a6da-d2c03df5fb18/eb7677d3-6781-4910-baf9-ba316fed0feb?host=wbd-images.prod-vod.h264.io&partner=beamcom';
      case 18:
        return 'https://www.cinepremiere.com.mx/wp-content/uploads/2021/08/pride-and-prejudice-1200-1200-675-675-crop-000000-900x506.jpeg';
      case 10751:
        return 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhcDcnUUhdSED1M8gwx7842jMl_nzbMxXTjDoCpsuiWdqyAveux8jltaV1jN-iKGj7A1_w7Lm4-tVPZYqAHlAn4-_Jd0DYvQ-hUgxO5vN2Ncr64fp4joplOUIymBXIuDEzLFHkJTXqQiHoT_8dKCfKFXHXjyZZ5ZmEbwVUsnu1x-OvpTD19hBc9gS1yuCpZ/s3840/2Nti3gYAX513wvhp8IiLL6ZDyOm.jpg';
      case 14:
        return 'https://media.revistagq.com/photos/5eb13e411c7a78d7f484ced3/16:9/w_2560%2Cc_limit/harry-potter.png';
      case 36:
        return 'https://img.asmedia.epimg.net/resizer/v2/DF3MAI5W5BDFBLDGUFU7R33Y34.jpg?auth=3ae2a5d937cb56150ab103c454f5912908d969e922ac22dec5fd85f2d3241e86&width=360&height=203&smart=true';
      case 27:
        return 'https://s.yimg.com/ny/api/res/1.2/ucQr.wDzIBywMibesYZijQ--/YXBwaWQ9aGlnaGxhbmRlcjt3PTEyNDI7aD02MjI7Y2Y9d2VicA--/https://media.zenfs.com/es/tomatazos_56/598d06c2b0d6cb62c4c9671259b59671';
      case 10402:
        return 'https://riodoce.mx/wp-content/uploads/2024/07/WhatsApp-Image-2024-06-23-at-2.16.09-PM.jpeg';
      case 9648:
        return 'https://resizing.flixster.com/7iXpicBfvLFUUTSzqpao72x7PCI=/fit-in/352x330/v2/https://resizing.flixster.com/-XZAfHZM39UwaGJIFWKAE8fS0ak=/v3/t/assets/p29883583_k_v9_ac.jpg';
      case 10749:
        return 'https://wpapi.larepublica.net/wp-content/webp-express/webp-images/doc-root/wp-content/uploads/2025/07/Pelicula-amores-materiales-1024x536.jpg.webp';
      case 878:
        return 'https://m.media-amazon.com/images/S/pv-target-images/16627900db04b76fae3b64266ca161511422059cd24062fb5d900971003a0b70.jpg';
      case 10770:
        return 'https://www.xtrafondos.com/wallpapers/la-pelicula-de-bob-esponja-1135.jpg';
      case 53:
        return 'https://es.web.img3.acsta.net/img/f2/d1/f2d146d60482315da6da3529a5fabfa6.jpg';
      case 10752:
        return 'https://images.ecestaticos.com/sly8T6DB_rFH6wuvh6mqK1_Dn9o=/9x13:2271x1517/1440x1080/filters:fill(white):format(jpg)/f.elconfidencial.com%2Foriginal%2F5d0%2Ff62%2Fcfc%2F5d0f62cfc8b6501b53d245919c43ac21.jpg';
      case 37:
        return 'https://www.ecartelera.com/images/sets/4400/4496.jpg';
      default:
        return 'https://images.pexels.com/photos/7991579/pexels-photo-7991579.jpeg';
    }
  }
}
