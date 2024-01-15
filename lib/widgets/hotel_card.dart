import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app/screens/hotel_option_screen.dart';

class HotelCard extends StatefulWidget {
  const HotelCard(
      {super.key,
      required this.hotelData,
      required this.city,
      required this.checkInDate,
      required this.checkOutDate});

  final Map<String, dynamic> hotelData;
  final String city;
  final String checkInDate;
  final String checkOutDate;

  @override
  State<HotelCard> createState() {
    return _HotelCardState();
  }
}

class _HotelCardState extends State<HotelCard> {
  bool _isChecking = false;

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

  void _checkAvailability(String hotelId, String hotelName) async {
    setState(() {
      _isChecking = true;
    });
    String token = await _getAccessToken();
    String auth = 'Bearer $token';
    final headers = {'Authorization': auth};
    final Uri url = Uri.parse(
        'https://test.api.amadeus.com/v3/shopping/hotel-offers?hotelIds=$hotelId&checkInDate=${widget.checkInDate}&checkOutDate=${widget.checkOutDate}');
    final response = await http.get(url, headers: headers);
    final parsedResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => HotelOptionScreen(
            offers: parsedResponse['data'][0]['offers'],
            hotelName: hotelName,
            city: widget.city,
            checkInDate: widget.checkInDate,
            checkOutDate: widget.checkOutDate,
          ),
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text(
            'Hotel niedostępny w twoich datach',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Text(
            'Wybierz inny hotel lub zmień daty',
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
    }
    setState(() {
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Card(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    widget.hotelData['name'].toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    onPressed: _isChecking
                        ? null
                        : () => _checkAvailability(
                            widget.hotelData['hotelId'].toString(),
                            widget.hotelData['name'].toString()),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    child: _isChecking
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : Text(
                            'Sprawdz dostępność od ${widget.checkInDate} do ${widget.checkOutDate}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
