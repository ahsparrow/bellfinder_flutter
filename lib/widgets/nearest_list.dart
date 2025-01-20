import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../screens/tower_screen.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/tower_viewmodel.dart';

class NearestListWidget extends StatefulWidget {
  const NearestListWidget({super.key, required this.viewModel});

  final HomeViewModel viewModel;

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
    return ListenableBuilder(
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
              child: Card(
                margin: EdgeInsets.all(2),
                child: ListTile(
                  title: Text(tower.place),
                  subtitle: Text('${tower.dedication}, ${tower.county}'),
                  leading: Text('${tower.bells}'),
                  leadingAndTrailingTextStyle: TextTheme.of(context).titleLarge,
                  visualDensity:
                      VisualDensity(vertical: VisualDensity.minimumDensity),
                  trailing: (widget.viewModel.hasVisit(tower.towerId))
                      ? Icon(Icons.done)
                      : null,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
