import 'package:flutter/material.dart';
import 'package:travel_app/constants/date_formatter.dart';
import 'package:travel_app/constants/travel_classes.dart';

class FlightSearchScreen extends StatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  State<FlightSearchScreen> createState() {
    return _FlightSearchScreenState();
  }
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  final _departureController = TextEditingController();
  final _arrivalController = TextEditingController();
  DateTime? _departureDate;
  DateTime? _arrivalDate;
  String _travelClassDropdown = 'Dowolna';

  void _departureDatePicker() async {
    final now = DateTime.now();
    final future = DateTime(now.year + 1, now.month, now.day);
    final pickedDate = await showDatePicker(
        context: context, initialDate: now, firstDate: now, lastDate: future);
    setState(() {
      _departureDate = pickedDate;
    });
  }

  void _arrivalDatePicker() async {
    final now = DateTime.now();
    final future = DateTime(now.year + 1, now.month, now.day);
    final pickedDate = await showDatePicker(
        context: context, initialDate: now, firstDate: now, lastDate: future);
    setState(() {
      _arrivalDate = pickedDate;
    });
  }

  void _clearForm() {
    setState(() {
      _departureController.text = '';
      _arrivalController.text = '';
      _departureDate = null;
      _arrivalDate = null;
      _travelClassDropdown = 'Dowolna';
    });
  }

  @override
  void dispose() {
    _departureController.dispose();
    _arrivalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          'Wyszukaj lot...',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 110,
                child: const CircleAvatar(
                  backgroundImage: AssetImage('assets/icons/logo.ico'),
                  radius: 50,
                ),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _departureController,
                                maxLength: 3,
                                keyboardType: TextInputType.text,
                                textCapitalization:
                                    TextCapitalization.characters,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Skąd',
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 60,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _arrivalController,
                                maxLength: 3,
                                keyboardType: TextInputType.text,
                                textCapitalization:
                                    TextCapitalization.characters,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Dokąd',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    'Wylot: ',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  Text(
                                    _departureDate == null
                                        ? '(wymagany)'
                                        : formatter.format(_departureDate!),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  IconButton(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    onPressed: _departureDatePicker,
                                    icon: const Icon(Icons.calendar_month),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Powrót: ',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  Text(
                                    _arrivalDate == null
                                        ? '(opcjonalny)'
                                        : formatter.format(_arrivalDate!),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  IconButton(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    onPressed: _arrivalDatePicker,
                                    icon: const Icon(Icons.calendar_month),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Klasa: ',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            ),
                            const SizedBox(width: 10),
                            DropdownButton(
                              dropdownColor:
                                  Theme.of(context).colorScheme.background,
                              value: _travelClassDropdown,
                              onChanged: (value) {
                                setState(() {
                                  _travelClassDropdown = value!;
                                });
                              },
                              items:
                                  travelClasses.map<DropdownMenuItem>((value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: _clearForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                    ),
                                    child: const Text('Wyczyść'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    child: const Text('Szukaj'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
