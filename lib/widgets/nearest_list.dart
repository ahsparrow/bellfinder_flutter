import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../screens/tower_screen.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/tower_viewmodel.dart';
import '../util.dart';

class NearestListWidget extends StatefulWidget {
  const NearestListWidget(
      {super.key, required this.viewModel, required this.showTowerOnMap});

  final HomeViewModel viewModel;
  final Function(BuildContext, Tower) showTowerOnMap;

  @override
  State<NearestListWidget> createState() => NearestListWidgetState();
}

class NearestListWidgetState extends State<NearestListWidget> {
  @override
  initState() {
    super.initState();
    widget.viewModel.startLocationUpdates();
  }

  @override
  dispose() {
    widget.viewModel.stopLocationUpdates();
    super.dispose();
  }

  @override
  Widget build(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          var nearest = widget.viewModel.getNearest();
          if (nearest.isEmpty) {
            return Center(
              child: Text(
                "Waiting for location...",
                textAlign: TextAlign.center,
                style: TextTheme.of(context).bodyLarge,
              ),
            );
          } else {
            return ListView.builder(
              itemCount: nearest.length,
              itemBuilder: (BuildContext context, int index) {
                final nearby = nearest[index];
                final tower = nearby.tower;
                return towerCard(context, tower, nearby.dist);
              },
            );
          }
        },
      ),
    );
  }

  Card towerCard(BuildContext context, Tower tower, double distance) {
    return Card(
      margin: const EdgeInsets.all(2),
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                tower.place,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text("${(distance / 1609).toStringAsFixed(1)} mi"),
          ],
        ),
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                '${tower.dedication}, ${tower.county}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text("${HomeViewModel.weightCwt(tower.weight).round()} cwt"),
          ],
        ),
        leading: Stack(
          alignment: Alignment.topRight,
          children: [
            ...[
              CircleAvatar(
                backgroundColor: Color(
                  bellColour(tower.bells, tower.unringable),
                ),
                child: Text('${tower.bells}'),
              )
            ],
            ...((widget.viewModel.hasVisit(tower.towerId))
                ? [
                    Icon(
                      Icons.verified,
                      size: IconTheme.of(context).size! * 0.75,
                    ),
                  ]
                : []),
          ],
        ),
        leadingAndTrailingTextStyle: TextTheme.of(context).titleLarge,
        visualDensity:
            const VisualDensity(vertical: VisualDensity.minimumDensity),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TowerScreen(
                viewModel: TowerViewModel(
                  database: context.read<AppDatabase>(),
                  towerId: tower.towerId,
                ),
              ),
            ),
          );

          if (result == "map" && context.mounted) {
            await widget.showTowerOnMap(context, tower);
          }
        },
        onLongPress: () async {
          await widget.showTowerOnMap(context, tower);
        },
      ),
    );
  }
}
