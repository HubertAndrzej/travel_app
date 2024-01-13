import 'package:flutter/material.dart';

class FlightTicket extends StatefulWidget {
  const FlightTicket({super.key});

  @override
  State<FlightTicket> createState() {
    return _FlightTicketState();
  }
}

class _FlightTicketState extends State<FlightTicket> {
  @override
  Widget build(BuildContext context) {
    return const Text('Flights');
  }
}
