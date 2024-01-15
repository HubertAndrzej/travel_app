import 'package:flutter/material.dart';

class HotelCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
