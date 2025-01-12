import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/newvisit_viewmodel.dart';

class NewVisitScreen extends StatelessWidget {
  const NewVisitScreen({super.key, required this.viewModel});

  final NewVisitViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new visit'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          // Use UniqueKey so state gets regenerate on change
          return NewVisitForm(key: UniqueKey(), viewModel: viewModel);
        },
      ),
    );
  }
}

class NewVisitForm extends StatefulWidget {
  const NewVisitForm({super.key, required this.viewModel});

  final NewVisitViewModel viewModel;

  @override
  State<NewVisitForm> createState() => NewVisitFormState();
}

class NewVisitFormState extends State<NewVisitForm> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _quarter = false;
  bool _peal = false;

  @override
  void initState() {
    super.initState();
    _dateController.value = TextEditingValue(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()),
    );
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
            Padding(
              padding: EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () {
                  widget.viewModel.insert(
                    date: DateFormat('dd/MM/yyyy').parse(_dateController.text),
                    notes: _noteController.text,
                    peal: _peal,
                    quarter: _quarter,
                  );
                  context.pop();
                },
                child: Text("Save"),
              ),
            ),
          ],
        ),
      ],
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
