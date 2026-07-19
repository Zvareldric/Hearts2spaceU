import 'package:flutter/material.dart';

import '../features/home/presentation/pages/home_page.dart';
import '../features/official_information/presentation/pages/member_detail_page.dart';
import '../features/official_information/presentation/pages/member_list_page.dart';
import 'app_routes.dart';

/// Central place that maps route names to screens.
///
/// Add a `case` per feature route. For heavier navigation needs, this is the
/// natural spot to swap in a package like `go_router` later.
class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case AppRoutes.memberList:
        return MaterialPageRoute(builder: (_) => const MemberListPage());
      case AppRoutes.memberDetail:
        final memberId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => MemberDetailPage(memberId: memberId),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
