import 'package:flutter/material.dart';
import 'package:travel_app/widgets/flight_card.dart';

class FlightSelectionScreen extends StatelessWidget {
  const FlightSelectionScreen(
      {super.key,
      required this.flights,
      required this.origin,
      required this.destination,
      required this.date});

  final List<dynamic> flights;
  final String origin;
  final String destination;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          'Wybór opcji',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: flights.length,
        itemBuilder: (BuildContext context, int index) {
          return FlightCard(flightData: flights[index]);
        },
      ),
    );
  }
}
