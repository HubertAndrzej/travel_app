import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app/models/flight.dart';

class FlightTicket extends StatefulWidget {
  const FlightTicket({super.key});

  @override
  State<FlightTicket> createState() {
    return _FlightTicketState();
  }
}

class _FlightTicketState extends State<FlightTicket> {
  List<Flight> _flights = [];
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBoughtFlights();
  }

  void _loadBoughtFlights() async {
    User user = FirebaseAuth.instance.currentUser!;

    final url = Uri.https(
        'travel-app-93e16-default-rtdb.europe-west1.firebasedatabase.app',
        'users/${user.uid}/flights.json');
    final response = await http.get(url);
    if (response.body == 'null') {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<Flight> loadedItems = [];
    for (final item in listData.entries) {
      var array = item.value['segments'];
      loadedItems.add(
        Flight(
          passenger: item.value['passenger'],
          origin: item.value['origin'],
          destination: item.value['destination'],
          date: item.value['date'],
          currency: item.value['currency'],
          total: item.value['total'],
          pnr: item.value['pnr'],
          segments: List<String>.from(array),
        ),
      );
    }
    setState(() {
      _flights = loadedItems;
      _isLoading = false;
    });
  }

  Widget buildSegmentWidget(List<String> segments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < segments.length; i++)
          Column(
            children: [
              Text(
                segments[i],
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
      ],
    );
  }

  void _displayFlightInfo(Flight flight) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Center(
          child: Text(
            'Informacje',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PNR: ${flight.pnr}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Imię pasażera: ${flight.passenger}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loty:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            buildSegmentWidget(flight.segments),
            const SizedBox(height: 8),
            Text(
              'Cena:  ${flight.currency} ${flight.total}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            child: Text(
              'Ok',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text(
        'Nie kupiłeś jeszcze żadnych lotów',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
    if (_isLoading) {
      content = Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      );
    }
    if (_flights.isNotEmpty) {
      content = ListView.builder(
        itemCount: _flights.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Card(
              color: Theme.of(context).colorScheme.onPrimary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Z ${_flights[index].origin} do ${_flights[index].destination} w dniu ${_flights[index].date} dla ${_flights[index].passenger}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () => _displayFlightInfo(_flights[index]),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.primaryContainer,
                            ),
                          ),
                          child: Text(
                            'Więcej informacji',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    return content;
  }
}
