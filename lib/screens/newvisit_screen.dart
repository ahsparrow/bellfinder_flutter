import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../viewmodels/newvisit_viewmodel.dart';
import '../util.dart';

class NewVisitScreen extends StatelessWidget {
  const NewVisitScreen({super.key, required this.viewModel});

  final NewVisitViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add visit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
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
        ListTile(
          title: Text(
            widget.viewModel.place,
            style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2),
          ),
          subtitle: Text(widget.viewModel.dedication),
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Color(bellColour(widget.viewModel.bells)),
            child: Text(
              "${widget.viewModel.bells}",
              style:
                  DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2),
            ),
          ),
        ),

        // Date
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            readOnly: true,
            controller: _dateController,
            onTap: () => _pickDate(context),
            decoration: const InputDecoration(
              labelText: "Date",
              border: OutlineInputBorder(),
            ),
          ),
        ),

        // Notes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            minLines: 5,
            maxLines: 5,
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: "Notes",
              border: OutlineInputBorder(),
            ),
          ),
        ),

        // Quarter
        CheckboxListTile(
          title: const Text("Quarter"),
          onChanged: (value) {
            setState(() {
              _quarter = value ?? false;
            });
          },
          value: _quarter,
          controlAffinity: ListTileControlAffinity.leading,
        ),

        // Peal
        CheckboxListTile(
          title: const Text("Peal"),
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
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8),
              child: FilledButton(
                onPressed: () {
                  widget.viewModel.insert(
                    date: DateFormat('dd/MM/yyyy').parse(_dateController.text),
                    notes: _noteController.text,
                    peal: _peal,
                    quarter: _quarter,
                  );
                  Navigator.pop(context);
                },
                child: const Text("Add visit"),
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
