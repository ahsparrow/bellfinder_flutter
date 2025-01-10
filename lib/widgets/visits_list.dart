import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../viewmodels/home_viewmodel.dart';

class VisitsListWidget extends StatelessWidget {
  const VisitsListWidget({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return ListView.builder(
          itemCount: viewModel.visits.length,
          itemBuilder: (BuildContext context, int index) {
            final visit = viewModel.visits[index];
            return GestureDetector(
              onTap: () => context.push('/visits/${visit.visitId}'),
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
                      Text('${visit.dedication}, ${visit.county}'),
                      Spacer(),
                      Text((visit.peal)
                          ? "P"
                          : (visit.quarter)
                              ? "Q"
                              : ""),
                    ],
                  ),
                  leading: Text('${visit.bells}'),
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
