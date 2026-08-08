import 'package:cinemapedia/presentations/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
    initialLocation: '/home/0',
    errorBuilder: (context, state) {
      final String error = state.error?.message ?? 'Unknown error';
      return _ErrorScreen(error: error, statusCode: 404);
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home/0'),
      GoRoute(
          path: '/home/:page',
          name: HomeScreen.routeName,
          builder: (context, state) {
            final pageIndex = int.tryParse(state.pathParameters['page'] ?? '0') ?? 0;
            return HomeScreen(
              pageIndex: pageIndex,
            );
          },
          routes: [
            GoRoute(
              path: '/movie/:id',
              name: MovieScreen.routeName,
              builder: (context, state) {
                final movieId = state.pathParameters['id'] ?? 'no-id';
                return MovieScreen(movieId: movieId);
              },
            ),
            GoRoute(
              path: '/actor/:id',
              name: ActorScreen.routeName,
              builder: (context, state) {
                final actorId = state.pathParameters['id'] ?? 'no-id';
                return ActorScreen(actorId: actorId);
              },
            ),
            GoRoute(
              path: '/genre/:id/:name',
              name: MoviesByGenreScreen.routeName,
              builder: (context, state) {
                final genreId = state.pathParameters['id'] ?? 'no-id';
                final genreName = state.pathParameters['name'] ?? 'no-name';
                return MoviesByGenreScreen(
                  genreId: genreId,
                  genreName: genreName,
                );
              },
            ),
          ]),
    ]);

// ShellRoute(
//     builder: (context, state, child) {
//       return HomeScreen(
//         child: child,
//       );
//     },
//     routes: [
//       GoRoute(
//         path: '/',
//         name: 'home_view',
//         builder: (context, state) => const HomeView(),
//       ),
//       GoRoute(
//         path: '/favorites',
//         name: 'favorites_view',
//         builder: (context, state) => const FavoritesView(),
//       ),
//       GoRoute(
//         path: '/categories',
//         name: 'categories_view',
//         builder: (context, state) => const CategoriesView(),
//       ),
//     ])

class _ErrorScreen extends StatelessWidget {
  final String error;
  final int statusCode;

  const _ErrorScreen({required this.error, required this.statusCode});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Error $statusCode'),
        ),
        body: Center(
          child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(21),
                child: Text('Ha ocurrido un error: $error',
                    maxLines: 3, overflow: TextOverflow.ellipsis),
              ),
              ElevatedButton(
                onPressed: () {
                  context.go('/home/0');
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
