import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../routes/app_routes.dart';

/// Landing screen of the app. Replace the body with your real home UI.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Hearts2SpaceU 👋'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.memberList),
              child: const Text('Members'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.schedule),
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
