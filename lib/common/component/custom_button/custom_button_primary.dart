import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/common/component/custom_progress_indicator.dart';

class CustomButtonPrimary extends StatelessWidget {
  const CustomButtonPrimary({
    required this.text,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (isLoading || !isEnabled)
          ? null
          : () {
              // Add touch feedback to buttons
              HapticFeedback.mediumImpact();
              onPressed();
            },
      child: isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CustomProgressIndicator(color: Theme.of(context).colorScheme.primary),
            )
          : Text(text, textAlign: TextAlign.center),
    );
  }
}
