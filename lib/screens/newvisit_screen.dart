import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/newvisit_viewmodel.dart';

class NewVisitScreen extends StatefulWidget {
  const NewVisitScreen({super.key, required this.viewModel});

  final NewVisitViewModel viewModel;

  @override
  State<NewVisitScreen> createState() => NewVisitScreenState();
}

class NewVisitScreenState extends State<NewVisitScreen> {
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
        title: const Text('Add new visit'),
        actions: [
          TextButton(
            child: Text("Save"),
            onPressed: () {
              widget.viewModel.insert(
                  date: DateFormat("dd/MM/yyyy").parse(_dateController.text),
                  notes: _noteController.text,
                  quarter: _quarter,
                  peal: _peal);
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
        _dateController.text = DateFormat("dd/MM/yyyy").format(DateTime.now());
        _noteController.text = "";
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
