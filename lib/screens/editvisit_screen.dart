import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/editvisit_viewmodel.dart';

class EditVisitScreen extends StatefulWidget {
  const EditVisitScreen({super.key, required this.viewModel});

  final EditVisitViewModel viewModel;

  @override
  State<EditVisitScreen> createState() => EditVisitScreenState();
}

class EditVisitScreenState extends State<EditVisitScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _quarter = false;
  bool _peal = false;

  @override
  void dispose() {
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit visit'),
        actions: [
          TextButton(
            child: Text("Save"),
            onPressed: () {
              context.pop();
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) => builder(context),
      ),
    );
  }

  Widget builder(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        _dateController.text = (widget.viewModel.date != null)
            ? DateFormat("dd/MM/yyyy").format(widget.viewModel.date!)
            : "";
        _noteController.text = widget.viewModel.notes;
        _peal = widget.viewModel.peal;
        _quarter = widget.viewModel.quarter;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.inversePrimary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.viewModel.place,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    widget.viewModel.dedication,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),

            // Notes
            Padding(
              padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
              child: TextField(
                readOnly: true,
                controller: _dateController,
                onTap: () => _pickDate(context),
                decoration: InputDecoration(
                  labelText: "Date",
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            // Quarter
            Padding(
              padding: EdgeInsets.all(8),
              child: TextField(
                minLines: 5,
                maxLines: 5,
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: "Notes",
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            // Peal
            CheckboxListTile(
              title: Text("Quarter"),
              onChanged: (value) {
                setState(() {
                  _quarter = value ?? false;
                });
              },
              value: _quarter,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: Text("Peal"),
              onChanged: (value) {
                setState(() {
                  _peal = value ?? false;
                });
              },
              value: _peal,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1950, 1, 1),
      lastDate: DateTime.now(),
      initialDate:
          DateFormat("dd/MM/yyyy").tryParseStrict(_dateController.text),
    );

    if (date != null) {
      _dateController.text = DateFormat("dd/MM/yyyy").format(date);
    }
  }
}
