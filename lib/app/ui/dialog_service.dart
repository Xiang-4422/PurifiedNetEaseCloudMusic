import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DialogService {
  const DialogService._();

  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Lottie.asset(
          'assets/lottie/empty_status.json',
          width: 750 / 4,
          height: 750 / 4,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
