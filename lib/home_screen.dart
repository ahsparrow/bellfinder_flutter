import 'package:flutter/material.dart';

import 'home_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => Column(
        children: [
          Text(viewModel.visits.length.toString()),
          TextButton(
            child: Text("Press me"),
            onPressed: () => viewModel.insertVisit(),
          )
        ],
      ),
    );
  }
}
