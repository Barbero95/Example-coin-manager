import 'package:aramark_excel/models/entry.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class NewInput extends StatefulWidget {
  final String barcodeScanRes;
  final Entry? entry;
  const NewInput({Key? key, required this.barcodeScanRes, this.entry})
      : super(key: key);

  @override
  State<NewInput> createState() => _NewInputState();
}

class _NewInputState extends State<NewInput> {
  final TextEditingController _textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _saveTextButton;

  @override
  void initState() {
    if (widget.entry != null) {
      _textEditingController.text = widget.entry?.value.toString() ?? "0.0";
      _textEditingController.selection = TextSelection(
          baseOffset: 0, extentOffset: _textEditingController.text.length);
      _saveTextButton = "Update";
    } else {
      _saveTextButton = "Save";
    }
    super.initState();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Box<Entry> box = Hive.box<Entry>('entries');
      if (widget.entry != null) {
        widget.entry!.value = double.parse(
            _textEditingController.text.trim().replaceAll(",", "."));
        box.put(widget.entry!.code, widget.entry!);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Updated!")));
        Navigator.of(context).pop();
      } else {
        Entry entry = Entry(
            code: widget.barcodeScanRes,
            value: double.parse(
                _textEditingController.text.trim().replaceAll(",", ".")));
        box.put(entry.code, entry);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Saved!")));
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(
                label: Text("Code:"),
                enabled: false,
              ),
              style: const TextStyle(color: Colors.grey),
              initialValue: widget.barcodeScanRes,
              validator: (String? value) {
                if (value == null ||
                    value.trim().isEmpty ||
                    double.tryParse(value.trim().replaceAll(",", "."))
                        is! double) {
                  return "Invalid number!";
                }
                return null;
              },
              onFieldSubmitted: (value) => _save(),
            ),
            const SizedBox(
              height: 10,
            ),
            Form(
              key: _formKey,
              child: TextFormField(
                autofocus: true,
                controller: _textEditingController,
                decoration: const InputDecoration(
                    hintText: "0.0", label: Text("Money")),
                keyboardType: TextInputType.number,
                validator: (String? value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      double.tryParse(value.trim().replaceAll(",", "."))
                          is! double) {
                    return "Invalid number!";
                  }
                  return null;
                },
                onFieldSubmitted: (value) => _save(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () => _save(),
          child: Text(
            _saveTextButton,
            style: const TextStyle(
                color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
