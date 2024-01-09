import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PassengerInfo extends StatefulWidget {
  const PassengerInfo({
    super.key,
    required this.origin,
    required this.destination,
    required this.date,
    required this.currency,
    required this.total,
  });

  final String origin;
  final String destination;
  final String date;
  final String currency;
  final String total;

  @override
  State<PassengerInfo> createState() {
    return _PassengerInfoState();
  }
}

class _PassengerInfoState extends State<PassengerInfo> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';

  void _payForSelectedOption() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context);
      String? userEmail =
          FirebaseAuth.instance.currentUser!.email ?? 'No Email';
      double amount = double.parse(widget.total) * 100;
      await _initPayment(
        email: userEmail,
        currency: widget.currency,
        total: amount.toString(),
      );
    }
  }

  Future<void> _initPayment({
    required String email,
    required String currency,
    required String total,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://us-central1-travel-app-93e16.cloudfunctions.net/stripePaymentIntentRequest'),
        body: {
          'email': email,
          'currency': currency,
          'total': total,
        },
      );
      final jsonResponse = jsonDecode(response.body);
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: jsonResponse['paymentIntent'],
          merchantDisplayName: 'go4travel',
          customerId: jsonResponse['customer'],
          customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment is successful'),
        ),
      );
    } catch (error) {
      if (error is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occured ${error.error.localizedMessage}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occured $error'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 48, 16, keyboardSpace + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Podsumowanie',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Form(
            key: _formKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      label: Text('Pełne imię i nazwisko pasażera'),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Pole nie może być puste.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredName = value!;
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  _formKey.currentState!.reset();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                ),
                child: const Text('Wyczyść'),
              ),
              ElevatedButton(
                onPressed: _payForSelectedOption,
                child: Text('Zapłać ${widget.currency} ${widget.total}'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
