import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';
import 'home_viewmodel.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return HomeScreen(viewModel: HomeViewModel(database: context.read()));
      },
    ),
  ],
);
