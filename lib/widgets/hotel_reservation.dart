import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app/models/hotel.dart';

class HotelReservation extends StatefulWidget {
  const HotelReservation({super.key});

  @override
  State<HotelReservation> createState() {
    return _HotelReservationState();
  }
}

class _HotelReservationState extends State<HotelReservation> {
  List<Hotel> _hotels = [];
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookedHotels();
  }

  void _loadBookedHotels() async {
    User user = FirebaseAuth.instance.currentUser!;

    final url = Uri.https(
        'travel-app-93e16-default-rtdb.europe-west1.firebasedatabase.app',
        'users/${user.uid}/hotels.json');
    final response = await http.get(url);
    if (response.body == 'null') {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<Hotel> loadedItems = [];
    for (final item in listData.entries) {
      loadedItems.add(
        Hotel(
          host: item.value['host'],
          city: item.value['city'],
          hotelName: item.value['hotelName'],
          checkInDate: item.value['checkInDate'],
          checkOutDate: item.value['checkOutDate'],
          roomType: item.value['roomType'],
          currency: item.value['currency'],
          total: item.value['total'],
          confirmation: item.value['confirmation'],
        ),
      );
    }
    setState(() {
      _hotels = loadedItems;
      _isLoading = false;
    });
  }

  void _displayHotelInfo(Hotel hotel) {
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
              'Imię gościa: ${hotel.host}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Numer rezerwacji: ${hotel.confirmation}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Miasto: ${hotel.city}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nazwa hotelu:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 16,
              ),
            ),
            Text(
              hotel.hotelName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Typ pokoju: ${hotel.roomType}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Od ${hotel.checkInDate} do ${hotel.checkOutDate}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cena:  ${hotel.currency} ${hotel.total}',
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
        'Nie zamówiłeś jeszcze żadnych hoteli',
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
    if (_hotels.isNotEmpty) {
      content = ListView.builder(
        itemCount: _hotels.length,
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
                      'W ${_hotels[index].city} od ${_hotels[index].checkInDate} do ${_hotels[index].checkOutDate} dla ${_hotels[index].host}',
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
                          onPressed: () => _displayHotelInfo(_hotels[index]),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.primaryContainer,
                            ),
                          ),
                          child: Text(
                            'Wiecej informacji',
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
