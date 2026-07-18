import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../routes/app_router.dart';
import '../routes/app_routes.dart';
import 'theme/app_theme.dart';

/// Root widget of the application.
///
/// Wires together theming and routing. Keep this thin — feature logic lives
/// under `features/`.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
