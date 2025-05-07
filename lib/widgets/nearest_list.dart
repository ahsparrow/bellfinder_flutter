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
          return ListView.builder(
            itemCount: widget.viewModel.nearest.length,
            itemBuilder: (BuildContext context, int index) {
              final tower = widget.viewModel.nearest[index];
              return GestureDetector(
                onTap: () async {
                  widget.viewModel.stopLocationUpdates();
                  await Navigator.push(
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
                  widget.viewModel.startLocationUpdates();
                },
                onLongPress: () => widget.showTowerOnMap(
                    context, widget.viewModel.getTower(tower.towerId)),
                child: Card(
                  margin: EdgeInsets.all(2),
                  child: ListTile(
                    title: Text(tower.place),
                    subtitle: Text('${tower.dedication}, ${tower.county}'),
                    leading: CircleAvatar(
                      backgroundColor: Color(bellColour(tower.bells)),
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
