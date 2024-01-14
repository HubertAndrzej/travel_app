class Flight {
  Flight({
    required this.passenger,
    required this.origin,
    required this.destination,
    required this.date,
    required this.currency,
    required this.total,
    required this.pnr,
    required this.segments,
  });

  String passenger;
  String origin;
  String destination;
  String date;
  String currency;
  String total;
  String pnr;
  List<String> segments;
}
