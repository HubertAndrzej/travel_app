import 'package:flutter/material.dart';

class PassengerInfo extends StatefulWidget {
  const PassengerInfo(
      {super.key,
      required this.origin,
      required this.destination,
      required this.date});

  final String origin;
  final String destination;
  final String date;

  @override
  State<PassengerInfo> createState() {
    return _PassengerInfoState();
  }
}

class _PassengerInfoState extends State<PassengerInfo> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';

  void _payForSelectedOption() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => Text(
            _enteredName.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 48, 16, keyboardSpace + 16),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  label: Text('Pełne imię i nazwisko'),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Pole nie może być puste.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                _formKey.currentState!.reset();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: const Text('Wyczyść'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _payForSelectedOption,
              child: const Text('Zapłać'),
            ),
          ],
        ),
      ),
    );
  }
}
