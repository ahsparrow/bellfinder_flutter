import 'package:flutter/material.dart';

import '../home_viewmodel.dart';

class TowerListWidget extends StatelessWidget {
  const TowerListWidget({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return ListView.builder(
          itemCount: viewModel.towers.length,
          itemBuilder: (BuildContext context, int index) {
            return Text(viewModel.towers[index].place);
          },
        );
      },
    );
  }
}
