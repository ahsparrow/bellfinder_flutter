import 'package:flutter/material.dart';

import '../viewmodels/home_viewmodel.dart';
import '../widgets/map.dart';
import '../widgets/towers_list.dart';
import '../widgets/visits_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
            title: const Text('BellFinder'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            bottom: TabBar(
              tabs: [
                Tab(text: 'Towers'),
                Tab(text: 'Visits'),
                Tab(text: 'Nearby'),
                Tab(text: 'Map'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
            ]),
        body: TabBarView(
          children: [
            TowerListWidget(viewModel: viewModel),
            VisitsListWidget(viewModel: viewModel),
            Center(child: Text('Nearby')),
            MapWidget(viewModel: viewModel),
          ],
        ),
      ),
    );
  }
}
