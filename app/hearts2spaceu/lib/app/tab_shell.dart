import 'package:flutter/material.dart';

import '../features/collection/presentation/pages/collection_page.dart';
import '../features/gallery/presentation/pages/albums_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/more/presentation/pages/more_page.dart';
import '../features/schedule/presentation/pages/schedule_page.dart';
import 'widgets/glass/glass_nav_bar.dart';

/// The app's root screen: five tabs under a floating glass nav bar.
///
/// Replaces Home-as-landing-page. The four capabilities a fan opens repeatedly
/// (Home, Gallery, Schedule, Collection) are one tap from anywhere; the rest
/// live behind More. Detail pages still push on top of the shell as full routes,
/// so the nav bar is out of the way once you are reading one thing.
class TabShell extends StatefulWidget {
  const TabShell({super.key});

  /// The Schedule tab's index, for [TabSwitcher.go]. Only the tabs something
  /// actually jumps to are named.
  static const int scheduleTab = 2;

  @override
  State<TabShell> createState() => _TabShellState();
}

/// Lets a tab's own content switch tabs — Home's "See all" jumping to the
/// Schedule tab rather than pushing a second copy of it on top of the shell.
///
/// An InheritedWidget purely to pass one callback down; it never notifies, so
/// depending on it costs nothing.
class TabSwitcher extends InheritedWidget {
  const TabSwitcher({super.key, required this.select, required super.child});

  final ValueChanged<int> select;

  /// Switches to [index]. A no-op outside a [TabShell] — which is what lets the
  /// tab pages still be pushed as standalone routes.
  static void go(BuildContext context, int index) {
    context.dependOnInheritedWidgetOfExactType<TabSwitcher>()?.select(index);
  }

  @override
  bool updateShouldNotify(TabSwitcher oldWidget) => false;
}

class _TabShellState extends State<TabShell> {
  int _index = 0;

  static const _destinations = [
    NavDestination(icon: Icons.home_rounded, label: 'Home'),
    NavDestination(icon: Icons.photo_library_rounded, label: 'Gallery'),
    NavDestination(icon: Icons.calendar_month_rounded, label: 'Schedule'),
    NavDestination(icon: Icons.favorite_rounded, label: 'My Collection'),
    NavDestination(icon: Icons.more_horiz_rounded, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody: the tabs' content scrolls under the translucent nav bar,
      // which is what makes the blur read as glass rather than as a gray strip.
      extendBody: true,
      body: TabSwitcher(
        select: (index) => setState(() => _index = index),
        child: IndexedStack(
          index: _index,
          children: const [
            HomePage(),
            AlbumsPage(),
            SchedulePage(),
            CollectionPage(),
            MorePage(),
          ],
        ),
      ),
      bottomNavigationBar: GlassNavBar(
        destinations: _destinations,
        currentIndex: _index,
        onSelected: (index) => setState(() => _index = index),
      ),
    );
  }
}
