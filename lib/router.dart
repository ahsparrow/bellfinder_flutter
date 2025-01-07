import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'viewmodels/home_viewmodel.dart';
import 'screens/tower_screen.dart';
import 'viewmodels/tower_viewmodel.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return HomeScreen(viewModel: HomeViewModel(database: context.read()));
      },
    ),
    GoRoute(
      path: '/towers/:towerId',
      builder: (context, state) {
        return TowerScreen(
          viewModel: TowerViewModel(
            towerId: int.parse(state.pathParameters['towerId']!),
            database: context.read(),
          ),
        );
      },
    )
  ],
);
