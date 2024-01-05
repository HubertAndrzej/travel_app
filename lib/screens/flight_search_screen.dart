import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app/constants/date_formatter.dart';
import 'package:travel_app/constants/travel_classes.dart';
import 'package:travel_app/screens/home_screen.dart';

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
  DateTime? _returnDate;
  String _travelClassDropdown = 'Dowolna';
  List<dynamic> _flights = [];

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
      _returnDate = pickedDate;
    });
  }

  void _clearForm() {
    setState(() {
      _departureController.text = '';
      _arrivalController.text = '';
      _departureDate = null;
      _returnDate = null;
      _travelClassDropdown = 'Dowolna';
    });
  }

  void _submitForm() async {
    if (_departureController.text.trim().length != 3) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Bład w polu skąd'),
          content: const Text('Miejsce wylotu musi mieć długość trzech znaków'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
      return;
    }
    if (_arrivalController.text.trim().length != 3) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Bład w polu dokąd'),
          content:
              const Text('Miejsce przylotu musi mieć długość trzech znaków'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
      return;
    }
    if (_departureDate == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Bład w polu wylot'),
          content: const Text('Nie wybrałeś daty wylotu'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
      return;
    }
    if (_returnDate != null && _departureDate!.isAfter(_returnDate!)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Bład w polu skąd'),
          content: const Text(
              'Data powrotu nie może być wcześniejsza niż data wylotu'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
      return;
    }
    _flights = await _searchFlights();
    _navigateNextScreen(_flights);
  }

  void _navigateNextScreen(List<dynamic> data) {
    if (_flights.isEmpty) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const HomeScreen(),
      ),
    );
  }

  Future<String> _getAccessToken() async {
    var url =
        Uri.parse('https://test.api.amadeus.com/v1/security/oauth2/token');
    var client = http.Client();
    var response = await client.post(url, body: {
      'grant_type': 'client_credentials',
      'client_id': 'YWcVCukFQNqVOVGYAGIkO4ShJrWWtwS2',
      'client_secret': 'LffYAS4rnxG3FrCu'
    });

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var accessToken = jsonResponse['access_token'];
      return accessToken;
    }

    return '';
  }

  Future<List<dynamic>> _searchFlights() async {
    String token = await _getAccessToken();
    String auth = 'Bearer $token';
    final headers = {'Authorization': auth};
    const String baseUrl =
        'https://test.api.amadeus.com/v2/shopping/flight-offers';

    String generatedUrl =
        '$baseUrl?originLocationCode=${_departureController.text.toUpperCase()}&destinationLocationCode=${_arrivalController.text.toUpperCase()}&departureDate=${_departureDate.toString().substring(0, 10)}';
    if (_returnDate != null) {
      generatedUrl += '&returnDate=${_returnDate.toString().substring(0, 10)}';
    }
    generatedUrl += '&adults=1';
    if (_travelClassDropdown == 'Dowolna') {
      generatedUrl += '';
    } else if (_travelClassDropdown == 'Premium Economy') {
      generatedUrl += '&travelClass=PREMIUM_ECONOMY';
    } else {
      generatedUrl += '&travelClass=${_travelClassDropdown.toUpperCase()}';
    }
    final Uri url = Uri.parse(generatedUrl);

    final response = await http.get(url, headers: headers);

    final parsedResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return parsedResponse['data'];
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Brak lotów'),
          content: const Text('Nie znaleziono lotów z podanymi parametrami'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
      return List<dynamic>.empty();
    }
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
                                    _returnDate == null
                                        ? '(opcjonalny)'
                                        : formatter.format(_returnDate!),
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
                                  Theme.of(context).colorScheme.primary,
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
                                      fontSize: 14,
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
                                    onPressed: _submitForm,
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
