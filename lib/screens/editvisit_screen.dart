import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../viewmodels/editvisit_viewmodel.dart';

class EditVisitScreen extends StatelessWidget {
  const EditVisitScreen({super.key, required this.viewModel});

  final EditVisitViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit visit'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          // Use UniqueKey so state gets regenerated on change
          return EditForm(key: UniqueKey(), viewModel: viewModel);
        },
      ),
    );
  }
}

class EditForm extends StatefulWidget {
  const EditForm({super.key, required this.viewModel});

  final EditVisitViewModel viewModel;

  @override
  State<EditForm> createState() => EditFormState();
}

class EditFormState extends State<EditForm> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _quarter = false;
  bool _peal = false;

  @override
  initState() {
    _dateController.value = TextEditingValue(
      text: (widget.viewModel.date != null)
          ? DateFormat("dd/MM/yyyy").format(widget.viewModel.date!)
          : "",
    );
    _noteController.value = TextEditingValue(
      text: widget.viewModel.notes,
    );
    _quarter = widget.viewModel.quarter;
    _peal = widget.viewModel.peal;

    super.initState();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

        Row(
          children: [
            Spacer(),

            // Delete button
            Padding(
              padding: EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () async {
                  if (await _confirmDelete() && context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Text("Delete"),
              ),
            ),

            // Save button
            Padding(
              padding: EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () {
                  widget.viewModel.update(
                    date: DateFormat('dd/MM/yyyy').parse(_dateController.text),
                    notes: _noteController.text,
                    peal: _peal,
                    quarter: _quarter,
                  );
                  Navigator.pop(context);
                },
                child: Text("Save"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<bool> _confirmDelete() async {
    switch (await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(title: const Text('Are you sure?'), actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 1),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 2),
            child: Text('Yes'),
          ),
        ]);
      },
    )) {
      case 2:
        widget.viewModel.delete();
        return true;
      default:
        return false;
    }
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
