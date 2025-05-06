import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/database.dart';
import '../screens/newvisit_screen.dart';
import '../viewmodels/tower_viewmodel.dart';
import '../viewmodels/newvisit_viewmodel.dart';

class TowerScreen extends StatelessWidget {
  const TowerScreen({super.key, required this.viewModel});

  final TowerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tower'),
      ),
      body: _body(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final tower = viewModel.tower;
          if (tower != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewVisitScreen(
                  viewModel: NewVisitViewModel(
                      database: context.read<AppDatabase>(),
                      towerId: tower.towerId),
                ),
              ),
            );
          }
        },
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
        }

        const spacer =
            TableRow(children: [SizedBox(height: 4), SizedBox(height: 4)]);

        return Column(
          //Tower information header
          children: [
            Text(
              tower.place,
              style:
                  DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2),
            ),
            Text(tower.dedication),

            // Tower details table
            Padding(
              padding:
                  EdgeInsets.only(right: 24, left: 24, top: 24, bottom: 48),
              child: DefaultTextStyle.merge(
                style: DefaultTextStyle.of(context)
                    .style
                    .apply(fontSizeFactor: 1.3),
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
                        Text((viewModel.firstVisit != null)
                            ? DateFormat("d/M/y").format(viewModel.firstVisit!)
                            : ""),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: FittedBox(
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context, "map"),
                      label: Text("Map"),
                      icon: Icon(Icons.map),
                    ),
                    SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () => _launchUrl(tower.towerId),
                      label: Text("Dove's"),
                      icon: Icon(Icons.church_outlined),
                    ),
                    SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(
                            "geo:${tower.latitude},${tower.longitude}?z=8&q=${tower.latitude},${tower.longitude}(${Uri.encodeFull(tower.dedication)})");
                        await launchUrl(uri);
                      },
                      label: Text("Directions"),
                      icon: Icon(Icons.directions_outlined),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(int towerId) async {
    await launchUrl(
        Uri.parse("https://dove.cccbr.org.uk/detail.php?TowerBase=$towerId"));
  }
}
