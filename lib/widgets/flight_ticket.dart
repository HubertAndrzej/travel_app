import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FlightTicket extends StatefulWidget {
  const FlightTicket({super.key});

  @override
  State<FlightTicket> createState() {
    return _FlightTicketState();
  }
}

class _FlightTicketState extends State<FlightTicket> {
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
    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return const Text('Flights');
  }
}
