import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.buttonText,
    required this.isLoading,
    this.onPressed,
  });

  final String buttonText;
  final bool isLoading;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          // Maintain primary color even when disabled (loading)
          disabledBackgroundColor: theme.colorScheme.primary,
          disabledForegroundColor: theme.colorScheme.onPrimary,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: Center(
                  child: CupertinoActivityIndicator(
                    radius: 10,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
