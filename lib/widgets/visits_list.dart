import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../screens/editvisit_screen.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/editvisit_viewmodel.dart';

class VisitsListWidget extends StatelessWidget {
  const VisitsListWidget({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return ListView.builder(
            itemCount: viewModel.visits.length,
            itemBuilder: (BuildContext context, int index) {
              final visit = viewModel.visits[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditVisitScreen(
                        viewModel: EditVisitViewModel(
                          database: context.read<AppDatabase>(),
                          visitId: visit.visitId,
                        ),
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.all(2),
                  child: ListTile(
                    title: Row(
                      children: [
                        Text(visit.place),
                        Spacer(),
                        Text(DateFormat('dd/MM/yyyy').format(visit.date)),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${visit.dedication}, ${visit.county}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Text((visit.peal)
                            ? "P"
                            : (visit.quarter)
                                ? "Q"
                                : ""),
                      ],
                    ),
                    leading: Text('${visit.bells}'),
                    leadingAndTrailingTextStyle:
                        TextTheme.of(context).titleLarge,
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
