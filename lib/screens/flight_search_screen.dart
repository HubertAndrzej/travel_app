import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app/constants/date_formatter.dart';
import 'package:travel_app/constants/travel_classes.dart';
import 'package:travel_app/screens/flight_selection_screen.dart';

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
  final FocusNode _departureFocus = FocusNode();
  final FocusNode _arrivalFocus = FocusNode();
  DateTime? _departureDate;
  DateTime? _returnDate;
  String _travelClassDropdown = 'Dowolna';
  List<dynamic> _flights = [];
  bool _isSubmitting = false;

  void _departureDatePicker() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final future = DateTime(now.year + 1, now.month, now.day);
    final pickedDate = await showDatePicker(
        context: context, initialDate: now, firstDate: now, lastDate: future);
    setState(() {
      _departureDate = pickedDate;
    });
  }

  void _arrivalDatePicker() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final future = DateTime(now.year + 1, now.month, now.day);
    final pickedDate = await showDatePicker(
        context: context, initialDate: now, firstDate: now, lastDate: future);
    setState(() {
      _returnDate = pickedDate;
    });
  }

  void _clearForm() {
    FocusScope.of(context).unfocus();
    setState(() {
      _departureController.text = '';
      _arrivalController.text = '';
      _departureDate = null;
      _returnDate = null;
      _travelClassDropdown = 'Dowolna';
    });
  }

  void _submitForm() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
    });
    if (_departureController.text.trim().length != 3) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.error,
          title: Text(
            'Błąd w polu skąd',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          content: Text(
            'Miejsce wylotu musi mieć długość dokładnie trzech znaków',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isSubmitting = false;
                });
              },
              child: Text(
                'Ok',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
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
          backgroundColor: Theme.of(context).colorScheme.error,
          title: Text(
            'Błąd w polu dokąd',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          content: Text(
            'Miejsce przylotu musi mieć długość dokładnie trzech znaków',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isSubmitting = false;
                });
              },
              child: Text(
                'Ok',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }
    if (_departureController.text == _arrivalController.text) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.error,
          title: Text(
            'Błąd w formularzu',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          content: Text(
            'Miejsce przylotu nie może być takie same jak miejsce wylotu',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isSubmitting = false;
                });
              },
              child: Text(
                'Ok',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
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
          backgroundColor: Theme.of(context).colorScheme.error,
          title: Text(
            'Błąd w polu wylot',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          content: Text(
            'Nie wybrałeś daty wylotu',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isSubmitting = false;
                });
              },
              child: Text(
                'Ok',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
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
          backgroundColor: Theme.of(context).colorScheme.error,
          title: Text(
            'Błąd w formularzu',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          content: Text(
            'Data powrotu nie może być wcześniejsza niż data wylotu',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isSubmitting = false;
                });
              },
              child: Text(
                'Ok',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }
    _flights = await _searchFlights();
    setState(() {
      _isSubmitting = false;
    });
    _navigateNextScreen(_flights);
  }

  void _navigateNextScreen(List<dynamic> data) {
    if (_flights.isEmpty) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => FlightSelectionScreen(
          flights: _flights,
          origin: _departureController.text.toUpperCase(),
          destination: _arrivalController.text.toUpperCase(),
          date: _departureDate.toString().toString().substring(0, 10),
        ),
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
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          title: Text(
            'Brak lotów',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          content: Text(
            'Nie znaleziono lotów z podanymi parametrami',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: Text(
                'Ok',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
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
    _departureFocus.dispose();
    _arrivalFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            'Wyszukiwarka lotów',
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
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  focusNode: _departureFocus,
                                  controller: _departureController,
                                  maxLength: 3,
                                  keyboardType: TextInputType.text,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
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
                                  focusNode: _arrivalFocus,
                                  controller: _arrivalController,
                                  maxLength: 3,
                                  keyboardType: TextInputType.text,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
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
                                            .onSecondaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 60,
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Powrót: ',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                    ),
                                  ],
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
                                      _departureDate == null
                                          ? '(wymagany)'
                                          : formatter.format(_departureDate!),
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                    ),
                                    IconButton(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                      onPressed: _departureDatePicker,
                                      icon: const Icon(Icons.calendar_month),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 60,
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      _returnDate == null
                                          ? '(opcjonalny)'
                                          : formatter.format(_returnDate!),
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                    ),
                                    IconButton(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
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
                              Expanded(
                                child: Text(
                                  'Klasa: ',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: DropdownButton(
                                  dropdownColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  value: _travelClassDropdown,
                                  onChanged: (value) {
                                    setState(() {
                                      _travelClassDropdown = value!;
                                    });
                                  },
                                  items: travelClasses
                                      .map<DropdownMenuItem>((value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: _isSubmitting ? null : _clearForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .errorContainer,
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                      )
                                    : Text(
                                        'Wyczyść',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onErrorContainer,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                onPressed: _isSubmitting ? null : _submitForm,
                                child: _isSubmitting
                                    ? SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      )
                                    : Text(
                                        'Szukaj',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
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
      ),
    );
  }
}
