import 'package:flutter/material.dart';
import 'package:travel_app/widgets/hotel_card.dart';

class HotelSelectionScreen extends StatelessWidget {
  const HotelSelectionScreen(
      {super.key,
      required this.hotels,
      required this.city,
      required this.checkInDate,
      required this.checkOutDate});

  final List<dynamic> hotels;
  final String city;
  final String checkInDate;
  final String checkOutDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          'Wybierz hotel',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: hotels.length,
        itemBuilder: (BuildContext context, int index) {
          return HotelCard(
            hotelData: hotels[index],
            city: city,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
          );
        },
      ),
    );
  }
}
