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
          final tower = viewModel.tower;
          if (tower == null) {
            return SizedBox.shrink();
          } else {
            const spacer = TableRow(
              children: [
                SizedBox(height: 8),
                SizedBox(height: 8),
              ],
            );

            return DefaultTextStyle.merge(
              style: Theme.of(context).textTheme.headlineSmall,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Table(
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Text('Place:'),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tower.place),
                            Text(
                              tower.dedication,
                              textScaler: TextScaler.linear(0.75),
                            ),
                          ],
                        ),
                      ],
                    ),
                    spacer,
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Text('County:'),
                        ),
                        Text(tower.county),
                      ],
                    ),
                    spacer,
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Text('Bells:'),
                        ),
                        Text(tower.bells.toString()),
                      ],
                    ),
                    spacer,
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Text('Tenor:'),
                        ),
                        Text(viewModel.weightString),
                      ],
                    ),
                    spacer,
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Text('Practice:'),
                        ),
                        Text(tower.practice),
                      ],
                    ),
                    spacer,
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Text('First visit:'),
                        ),
                        // TBD - Add value
                        Text(''),
                      ],
                    ),
                    spacer,
                    TableRow(
                      children: [
                        SizedBox.shrink(),
                        Text("Open Dove's Guide"),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
