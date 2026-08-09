import 'package:cinemapedia/presentations/views/home/categories_view.dart';
import 'package:cinemapedia/presentations/views/home/favorites_view.dart';
import 'package:cinemapedia/presentations/views/home/home_view.dart';
import 'package:cinemapedia/presentations/widgets/shared/custom_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = 'home_screen';
  final int pageIndex;

  const HomeScreen({super.key, required this.pageIndex});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showBottomBar = true;
  bool _lastWasReverse = false;

  bool _handleScroll(UserScrollNotification notif) {
    final dir = notif.direction;
    if (dir == ScrollDirection.reverse && !_lastWasReverse) {
      _lastWasReverse = true;
      if (_showBottomBar) setState(() => _showBottomBar = false);
    } else if (dir == ScrollDirection.forward && _lastWasReverse) {
      _lastWasReverse = false;
      if (!_showBottomBar) setState(() => _showBottomBar = true);
    }
    return false;
  }

  final viewWidgets = const <Widget>[
    HomeView(),
    CategoriesView(),
    FavoritesView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: NotificationListener<UserScrollNotification>(
        onNotification: _handleScroll,
        child: IndexedStack(
          index: widget.pageIndex,
          children: viewWidgets,
        ),
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        offset: _showBottomBar ? Offset.zero : const Offset(0, 1),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          opacity: _showBottomBar ? 1 : 0,
          child: CustomBottomNavigation(currentIndex: widget.pageIndex),
        ),
      ),
    );
  }
}
