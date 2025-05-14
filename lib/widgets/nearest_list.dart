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
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          var nearest = widget.viewModel.getNearest();
          return ListView.builder(
            itemCount: nearest.length,
            itemBuilder: (BuildContext context, int index) {
              final nearby = nearest[index];
              final tower = nearby.tower;
              return GestureDetector(
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
                    widget.showTowerOnMap(context, tower);
                  }
                },
                onLongPress: () => widget.showTowerOnMap(context, tower),
                child: Card(
                  margin: EdgeInsets.all(2),
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
                        Text("${(nearby.dist / 1609).toStringAsFixed(1)} mi"),
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
                        Text(
                            "${HomeViewModel.weightCwt(tower.weight).round()} cwt"),
                      ],
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Color(
                        bellColour(tower.bells, tower.unringable),
                      ),
                      child: Text('${tower.bells}'),
                    ),
                    leadingAndTrailingTextStyle:
                        TextTheme.of(context).titleLarge,
                    visualDensity:
                        VisualDensity(vertical: VisualDensity.minimumDensity),
                    trailing: (widget.viewModel.hasVisit(tower.towerId))
                        ? Icon(Icons.beenhere_outlined)
                        : null,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
