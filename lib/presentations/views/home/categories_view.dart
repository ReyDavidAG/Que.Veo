import 'package:cinemapedia/config/theme/theme_context.dart';
import 'package:cinemapedia/domain/entities/genre.dart';
import 'package:cinemapedia/presentations/providers/genre/genre_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// PAQUETES AÑADIDOS
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';

class CategoriesView extends ConsumerStatefulWidget {
  const CategoriesView({super.key});

  @override
  CategoriesViewState createState() => CategoriesViewState();
}

class CategoriesViewState extends ConsumerState<CategoriesView> {
  @override
  void initState() {
    super.initState();
    ref.read(genreProvider.notifier).loadGenres();
  }

  @override
  Widget build(BuildContext context) {
    final genres = ref.watch(genreProvider);
    final colors = context.colors;
    final heroGradient = colors.heroGradient;

    if (genres.isEmpty) {
      return Scaffold(
        backgroundColor: colors.paper,
        body: const Center(
            child: CircularProgressIndicator(
          strokeWidth: 2,
        )),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: heroGradient,
                stops: const [0.0, 0.2, 0.85],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 50), // Más espacio para la barra de estado
                const Text(
                  'Categorías',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: genres.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 25,
                      crossAxisSpacing: 25,
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (context, index) {
                      final genre = genres[index];

                      // --- MEJORA DE DISEÑO ---
                      // Animación escalonada para cada tarjeta
                      return FadeInUp(
                        delay: Duration(milliseconds: index * 40),
                        duration: const Duration(milliseconds: 300),
                        child: _CategoryCard(genre: genre),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Genre genre;

  const _CategoryCard({required this.genre});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;

    return Container(
      // 1. Sombra ("sombreado") para la tarjeta
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          // Color de fondo en caso de que la imagen falle
          color: genre.color,
          child: InkWell(
            onTap: () {
              context.push('/home/1/genre/${genre.id}/${genre.name}');
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // --- ARREGLO DEL BUG DE CARGA ---
                // Reemplazamos Image.network por CachedNetworkImage
                CachedNetworkImage(
                  imageUrl: genre.imageUrl,
                  fit: BoxFit.cover,
                  // Widget de carga (lo que se ve mientras descarga)
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  // Fallback: si la imagen falla, muestra el diseño anterior
                  errorWidget: (context, url, error) =>
                      _FallbackCard(genre: genre, textStyles: textStyles),
                ),

                // --- Layer 2: Gradiente (sombra para legibilidad) ---
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                        Colors.black,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),

                // --- Layer 3: Contenido (Icono y Texto) ---
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icono en la esquina superior
                      Icon(
                        genre.icon,
                        color: Colors.white,
                        size: 35,
                        shadows: [
                          Shadow(color: Colors.black.withOpacity(0.7), blurRadius: 10),
                        ],
                      ),
                      // Texto en la parte inferior
                      Text(
                        genre.name,
                        style: textStyles.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black.withOpacity(0.9), blurRadius: 10)],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget de Fallback (para el errorBuilder de CachedNetworkImage)
class _FallbackCard extends StatelessWidget {
  const _FallbackCard({
    required this.genre,
    required this.textStyles,
  });

  final Genre genre;
  final TextTheme textStyles;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(genre.icon, color: Colors.white, size: 40),
        const SizedBox(height: 10),
        Text(
          genre.name,
          style: textStyles.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
