import 'package:flutter/material.dart';

import 'home_viewmodel.dart';
import 'widgets/map.dart';
import 'widgets/towers_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('BellFinder'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Towers'),
                Tab(text: 'Visits'),
                Tab(text: 'Nearby'),
                Tab(text: 'Map'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              TowerListWidget(viewModel: viewModel),
              Center(child: Text('Visits')),
              Center(child: Text('Nearby')),
              MapWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
