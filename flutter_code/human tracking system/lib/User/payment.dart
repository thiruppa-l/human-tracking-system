import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RazorpayPayment {
  static void openPayment(BuildContext context, double rate, {required Function onSuccess, required Function onFailure}) {
    final _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
      debugPrint('Payment Success: ${response.paymentId}');
      onSuccess(); // Call the onSuccess callback
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
      debugPrint('Payment Error: ${response.code} - ${response.message}');
      onFailure(); // Call the onFailure callback
    });
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) {
      debugPrint('External Wallet: ${response.walletName}');
    });

    final options = {
      'key': 'rzp_test_CqeHnHeUxTbGut',
      'amount': (rate * 100).toInt(), // Convert rate to paise
      'name': 'Parking Fee',
      'description': 'Parking slot reservation fee',
      'prefill': {'contact': 'USER_PHONE_NUMBER', 'email': 'USER_EMAIL'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

}
