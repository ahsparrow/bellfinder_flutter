import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            final tower = viewModel.towers[index];
            return GestureDetector(
              onTap: () => context.push('/towers/${tower.towerId}'),
              child: Card(
                margin: EdgeInsets.all(2),
                child: ListTile(
                  title: Text(tower.place),
                  subtitle: Text('${tower.dedication}, ${tower.county}'),
                  leading: Text('${tower.bells}'),
                  leadingAndTrailingTextStyle: TextTheme.of(context).titleLarge,
                  dense: true,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
