import 'package:flutter/material.dart';

class FlightSelectionScreen extends StatelessWidget {
  const FlightSelectionScreen({super.key, required this.flights});

  final List<dynamic> flights;

  @override
  Widget build(BuildContext context) {
    return const Text('Flights!');
  }
}
