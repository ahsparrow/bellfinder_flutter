import 'package:flutter/material.dart';

import '../viewmodels/tower_viewmodel.dart';

class TowerScreen extends StatelessWidget {
  const TowerScreen({super.key, required this.viewModel});

  final TowerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BellFinder'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          print(viewModel.tower);
          return Text("Tower screen");
        },
      ),
    );
  }
}
