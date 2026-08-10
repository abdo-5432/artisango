import 'package:in_app_review/in_app_review.dart';
import 'package:flutter/material.dart';

class RateAppService {
  static final InAppReview _inAppReview = InAppReview.instance;

  static Future<void> requestReview(BuildContext context) async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
    } else {
      // Fallback for debug / devices without Play Store
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Enjoying ArtisanGo?'),
            content: const Text('Please rate us on the Play Store!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // You can open the Play Store link here if needed
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text('Rate Now'),
              ),
            ],
          ),
        );
      }
    }
  }
}
