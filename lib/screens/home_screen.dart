import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/widgets/hotel_reservation.dart';
import 'package:travel_app/widgets/new_booking.dart';

import '../widgets/flight_ticket.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const NewBooking(),
    const FlightTicket(),
    const HotelReservation(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          'go4travel',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        actions: [
          Row(
            children: [
              Text(
                'Wyloguj się',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                icon: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
            ),
            label: 'Nowa podróż',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.airplane_ticket,
            ),
            label: 'Kupione loty',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.hotel,
            ),
            label: 'Zamówione hotele',
          ),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onBackground,
      ),
    );
  }
}
