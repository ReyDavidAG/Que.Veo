import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/theme/theme_context.dart';
import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActorHorizontalListView extends StatefulWidget {
  final List<Actor> actors;
  final String? title;
  final String? subtitle;
  final VoidCallback? loadNextPage;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final String Function(Actor)? routePath;

  const ActorHorizontalListView({
    super.key,
    required this.actors,
    this.title,
    this.subtitle,
    this.loadNextPage,
    this.height,
    this.padding,
    this.routePath,
  });

  @override
  State<ActorHorizontalListView> createState() => _ActorHorizontalListViewState();
}

class _ActorHorizontalListViewState extends State<ActorHorizontalListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (widget.loadNextPage == null) return;
      final position = _scrollController.position;
      if ((position.pixels + 200) >= position.maxScrollExtent) {
        widget.loadNextPage!.call();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onTapActor(BuildContext context, Actor actor) {
    final path = widget.routePath != null ? widget.routePath!(actor) : '/home/0/actor/${actor.id}';
    context.push(path);
  }

  @override
  Widget build(BuildContext context) {
    final totalHeight = widget.height ?? 200.0;
    return SizedBox(
      height: totalHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null || widget.subtitle != null)
            _ActorsHeader(title: widget.title, subtitle: widget.subtitle),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.actors.length,
              physics: const BouncingScrollPhysics(),
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final actor = widget.actors[index];
                return FadeInRight(
                  child: _ActorPillCard(
                    actor: actor,
                    onTap: () => _onTapActor(context, actor),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActorPillCard extends StatelessWidget {
  final Actor actor;
  final VoidCallback? onTap;

  const _ActorPillCard({required this.actor, this.onTap});

  bool get _hasPhoto => (actor.profilePath != null && actor.profilePath!.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;

    return Semantics(
      label:
          'Actor: ${actor.name}${actor.character != null ? ", personaje: ${actor.character}" : ""}',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 140,
          child: Column(
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.accent.withAlpha(25),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _hasPhoto
                      ? Image.network(
                          actor.profilePath!,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.medium,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return FadeIn(child: child);
                            return const _ActorImagePlaceholder();
                          },
                          errorBuilder: (_, __, ___) => const _ActorImageFallback(),
                        )
                      : const _ActorImageFallback(),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                actor.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.text,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              if (actor.character != null && actor.character!.trim().isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.accent.withAlpha(25),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: colors.accent.withAlpha(120), width: 0.8),
                    ),
                    child: Text(
                      actor.character!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.text,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActorImagePlaceholder extends StatelessWidget {
  const _ActorImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surfaceRaised,
      alignment: Alignment.center,
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _ActorImageFallback extends StatelessWidget {
  const _ActorImageFallback();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.accent.withAlpha(40),
            colors.accent.withAlpha(32),
            colors.surface.withAlpha(28),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.person, size: 48, color: colors.iconMuted),
    );
  }
}

class _ActorsHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const _ActorsHeader({this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: colors.text,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (title != null) Text(title!, style: titleStyle),
          const Spacer(),
          if (subtitle != null)
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.accent,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                side: BorderSide(color: colors.accent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                subtitle!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
