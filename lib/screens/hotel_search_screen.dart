import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app/constants/date_formatter.dart';
import 'package:travel_app/screens/hotel_selection_screen.dart';

class HotelSearchScreen extends StatefulWidget {
  const HotelSearchScreen({super.key});

  @override
  State<HotelSearchScreen> createState() {
    return _HotelSearchScreenState();
  }
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  final _cityController = TextEditingController();
  final FocusNode _cityFocus = FocusNode();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  List<dynamic> _hotels = [];
  bool _isSubmitting = false;

  void _checkInDatePicker() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final future = DateTime(now.year + 1, now.month, now.day);
    final pickedDate = await showDatePicker(
        context: context, initialDate: now, firstDate: now, lastDate: future);
    setState(() {
      _checkInDate = pickedDate;
    });
  }

  void _checkOutDatePicker() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final future = DateTime(now.year + 1, now.month, now.day);
    final pickedDate = await showDatePicker(
        context: context, initialDate: now, firstDate: now, lastDate: future);
    setState(() {
      _checkOutDate = pickedDate;
    });
  }

  void _clearForm() {
    FocusScope.of(context).unfocus();
    setState(() {
      _cityController.text = '';
      _checkInDate = null;
      _checkOutDate = null;
    });
  }

  void _submitForm() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
    });
    if (_cityController.text.trim().length != 3) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text(
            'Bład w polu miasto',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Text(
            'Miasto musi mieć długość trzech znaków',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isSubmitting = false;
                });
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
      return;
    }
    if (_checkInDate == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text(
            'Bład w polu od',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Text(
            'Nie wybrałeś daty zameldowania',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isSubmitting = false;
                });
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
      return;
    }
    if (_checkInDate == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text(
            'Bład w polu do',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Text(
            'Nie wybrałeś daty wymeldowania',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isSubmitting = false;
                });
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
      return;
    }
    if (_checkInDate!.isAfter(_checkOutDate!)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text(
            'Bład w formularzu',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Text(
            'Data wymeldowania nie może być wcześniejsza niż data zameldowania',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isSubmitting = false;
                });
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
      return;
    }
    _hotels = await _searchHotels();
    setState(() {
      _isSubmitting = false;
    });
    _navigateNextScreen(_hotels);
  }

  void _navigateNextScreen(List<dynamic> data) {
    if (_hotels.isEmpty) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => HotelSelectionScreen(
          hotels: _hotels,
          city: _cityController.text.toUpperCase(),
          checkInDate: _checkInDate.toString().toString().substring(0, 10),
          checkOutDate: _checkOutDate.toString().toString().substring(0, 10),
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

  Future<List<dynamic>> _searchHotels() async {
    String token = await _getAccessToken();
    String auth = 'Bearer $token';
    final headers = {'Authorization': auth};
    const String baseUrl =
        'https://test.api.amadeus.com/v1/reference-data/locations/hotels/by-city';
    String generatedUrl =
        '$baseUrl?cityCode=${_cityController.text.toUpperCase()}';
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
          title: const Text('Brak hoteli'),
          content: Text(
            'Nie znaleziono hoteli z podanymi parametrami',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
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
    _cityController.dispose();
    _cityFocus.dispose();
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
            'Wyszukiwarka hoteli',
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
                  color: Theme.of(context).colorScheme.background,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            focusNode: _cityFocus,
                            controller: _cityController,
                            maxLength: 3,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.characters,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Miasto',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      'Od: ',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                                    Text(
                                      _checkInDate == null
                                          ? '(wymagane)'
                                          : formatter.format(_checkInDate!),
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
                                      onPressed: _checkInDatePicker,
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
                                      'Do: ',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                                    Text(
                                      _checkOutDate == null
                                          ? '(wymagane)'
                                          : formatter.format(_checkOutDate!),
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
                                      onPressed: _checkOutDatePicker,
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed:
                                          _isSubmitting ? null : _clearForm,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                      ),
                                      child: _isSubmitting
                                          ? const SizedBox(
                                              height: 16,
                                              width: 16,
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : const Text('Wyczyść'),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed:
                                          _isSubmitting ? null : _submitForm,
                                      child: _isSubmitting
                                          ? const SizedBox(
                                              height: 16,
                                              width: 16,
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : const Text('Szukaj'),
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
      ),
    );
  }
}
