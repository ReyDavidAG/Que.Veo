import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/domain/entities/actor_details.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentations/providers/movies/actor_details_repository.dart';
import 'package:cinemapedia/presentations/screens/loaders/full_screen_loader.dart';
import 'package:cinemapedia/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActorScreen extends ConsumerStatefulWidget {
  static const String routeName = 'actor_screen';
  final String actorId;
  const ActorScreen({super.key, required this.actorId});

  @override
  ActorScreenState createState() => ActorScreenState();
}

class ActorScreenState extends ConsumerState<ActorScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(actorDetailsProvider.notifier).loadActorDetails(widget.actorId);
    ref.read(actorMoviesProvider.notifier).loadActorMovies(widget.actorId);
  }

  @override
  Widget build(BuildContext context) {
    final actor = ref.watch(actorDetailsProvider)[widget.actorId];
    final actorMovies = ref.watch(actorMoviesProvider)[widget.actorId];

    return Scaffold(
      body: actor == null ? FullScreenLoader() : _ActorView(actor: actor, actorMovies: actorMovies),
    );
  }
}

class _ActorView extends StatelessWidget {
  final ActorDetails actor;
  final List<Movie>? actorMovies;
  const _ActorView({required this.actor, this.actorMovies});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        _ActorSliverAppBar(actor: actor),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: 1,
            (context, index) => _ActorDetailsSection(actor: actor, actorMovies: actorMovies),
          ),
        ),
      ],
    );
  }
}

class _ActorSliverAppBar extends StatelessWidget {
  final ActorDetails actor;
  const _ActorSliverAppBar({required this.actor});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.6,
      foregroundColor: Colors.white,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16, end: 16),
        title: Text(
          actor.name,
          style: const TextStyle(fontSize: 20, color: Colors.white),
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (actor.profilePath.isNotEmpty)
              Image.network(actor.profilePath, fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress != null) return const SizedBox();
                return FadeIn(child: child);
              })
            else
              Container(color: Colors.black),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  stops: [0.0, 0.3],
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.0, 0.2, 0.5],
                  colors: [Colors.black, Colors.black54, Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActorDetailsSection extends StatelessWidget {
  final ActorDetails actor;
  final List<Movie>? actorMovies;
  const _ActorDetailsSection({required this.actor, this.actorMovies});

  String _formatDate(DateTime? d) {
    if (d == null) return 'Desconocida';
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String _age(DateTime? birth) {
    if (birth == null) return '';
    final now = DateTime.now();
    int years = now.year - birth.year;
    if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
      years--;
    }
    return '$years años';
  }

  String _genderLabel(int g) {
    switch (g) {
      case 1:
        return 'Femenino';
      case 2:
        return 'Masculino';
      case 3:
        return 'No binario';
      default:
        return 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Color(0xFF0E1427), Color(0xFF121A34)],
          stops: [0.0, 0.35, 0.95],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: actor.profilePath.isNotEmpty
                      ? Image.network(actor.profilePath, height: 160, width: 120, fit: BoxFit.cover)
                      : Container(
                          height: 160,
                          width: 120,
                          alignment: Alignment.center,
                          color: Colors.grey.shade800,
                          child: Icon(Icons.person, size: 48, color: cs.primary),
                        ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 48) * 0.60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(actor.name,
                          style: text.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            icon: Icons.badge_outlined,
                            label: actor.knownForDepartment.isEmpty
                                ? 'Sin departamento'
                                : actor.knownForDepartment,
                          ),
                          _InfoChip(
                            icon: Icons.cake_outlined,
                            label:
                                '${_formatDate(actor.birthday)} ${actor.birthday != null ? '(${_age(actor.birthday)})' : ''}',
                          ),
                          if (actor.placeOfBirth != null && actor.placeOfBirth!.isNotEmpty)
                            _InfoChip(icon: Icons.place_outlined, label: actor.placeOfBirth!),
                          _InfoChip(icon: Icons.people_outline, label: _genderLabel(actor.gender)),
                          _InfoChip(
                              icon: Icons.trending_up,
                              label: 'Popularidad: ${actor.popularity.toStringAsFixed(1)}'),
                          if (actor.imdbId?.isNotEmpty ?? false)
                            _InfoChip(
                                icon: Icons.movie_filter_outlined, label: 'IMDB: ${actor.imdbId}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (actor.alsoKnownAs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('También conocido(a) como',
                        style: text.titleMedium
                            ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: actor.alsoKnownAs
                            .map((aka) => Chip(
                                  label: Text(aka, overflow: TextOverflow.ellipsis),
                                  labelStyle: const TextStyle(color: Colors.white),
                                  backgroundColor: Colors.blueGrey,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(color: Colors.white70),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            if (actorMovies != null && actorMovies!.isNotEmpty)
              MovieHorizontalListview(
                movies: actorMovies!,
                title: 'Películas de ${actor.name}',
                subtitle: '${actorMovies!.length} películas',
              ),
            const SizedBox(height: 12),
            Text('Biografía',
                style:
                    text.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 60, maxHeight: 220),
              child: SingleChildScrollView(
                child: Text(
                  actor.biography.isEmpty ? 'Sin biografía disponible' : actor.biography,
                  style: const TextStyle(color: Colors.white70, height: 1.35),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxWidth = MediaQuery.of(context).size.width * 0.55;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: cs.primary.withAlpha(28),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.primary.withAlpha(90), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: cs.onPrimary.withAlpha(230)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: cs.onPrimary.withAlpha(230),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
