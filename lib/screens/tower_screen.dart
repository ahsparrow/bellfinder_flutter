import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text('Get directions'),
              ),
              PopupMenuItem(
                value: 2,
                child: Text('Add visit'),
              ),
            ],
            onSelected: (val) async {
              if (val == 1) {
                final tower = viewModel.tower;
                if (tower != null) {
                  final uri = Uri.parse(
                      "geo:${tower.latitude},${tower.longitude}?z=8&q=${tower.latitude},${tower.longitude}(${Uri.encodeFull(tower.dedication)})");
                  await launchUrl(uri);
                }
              }
            },
          ),
        ],
      ),
      body: _body(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final tower = viewModel.tower;

        if (tower == null) {
          // Empty widget
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
                  spacer,
                  TableRow(
                    children: [
                      SizedBox.shrink(),
                      Row(
                        children: [
                          FilledButton.tonal(
                            onPressed: () => _launchUrl(tower.towerId),
                            child: Text("Open Dove's Guide"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _launchUrl(int towerId) async {
    await launchUrl(
        Uri.parse("https://dove.cccbr.org.uk/detail.php?TowerBase=$towerId"));
  }
}
