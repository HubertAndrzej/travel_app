import 'package:flutter/material.dart';
import 'package:travel_app/widgets/passenger_info.dart';

class FlightCard extends StatelessWidget {
  const FlightCard(
      {super.key,
      required this.flightData,
      required this.origin,
      required this.destination,
      required this.date});

  final Map<String, dynamic> flightData;
  final String origin;
  final String destination;
  final String date;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> itineraries = flightData['itineraries'];
    final Map<String, dynamic> price = flightData['price'];

    Widget buildSegmentWidget(List<dynamic> segments) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < segments.length; i++)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Linia: ${segments[i]['carrierCode']}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Numer: ${segments[i]['number']}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Od: ${segments[i]['departure']['iataCode']}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Do: ${segments[i]['arrival']['iataCode']}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Wylot: ${segments[i]['departure']['at'].substring(0, 10)} ${segments[i]['departure']['at'].substring(11, 16)}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Przylot: ${segments[i]['arrival']['at'].substring(0, 10)} ${segments[i]['arrival']['at'].substring(11, 16)}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    }

    List<String> forwardFlightDetails() {
      List<String> flightDetails = [];
      for (var i = 0; i < itineraries.length; i++) {
        List<dynamic> segments = itineraries[i]['segments'];
        for (int j = 0; j < segments.length; j++) {
          String singleFlight = '';
          singleFlight += segments[j]['carrierCode'];
          singleFlight += ' ';
          singleFlight += segments[j]['number'];
          singleFlight += '   ';
          singleFlight += segments[j]['departure']['iataCode'];
          singleFlight += ' - ';
          singleFlight += segments[j]['arrival']['iataCode'];
          singleFlight += '\n';
          singleFlight += segments[j]['departure']['at'].substring(0, 10);
          singleFlight += ' ';
          singleFlight += segments[j]['departure']['at'].substring(11, 16);
          singleFlight += ' - ';
          singleFlight += segments[j]['arrival']['at'].substring(0, 10);
          singleFlight += ' ';
          singleFlight += segments[j]['arrival']['at'].substring(11, 16);
          flightDetails.add(singleFlight);
        }
      }
      return flightDetails;
    }

    void openPassengerNameInfo() {
      showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) {
          return PassengerInfo(
            origin: origin,
            destination: destination,
            date: date,
            currency: flightData['price']['currency'],
            total: flightData['price']['total'],
            segments: forwardFlightDetails(),
          );
        },
      );
    }

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
                'Oferta ${flightData['id']}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Loty:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            for (int i = 0; i < itineraries.length; i++)
              buildSegmentWidget(itineraries[i]['segments']),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Cena:  ${price['currency']} ${price['total']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: openPassengerNameInfo,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    child: Text(
                      'Wybierz',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
  }
}
