import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assesment/presentation/pages/registration_page/registration_page.dart';
import 'package:flutter_assesment/utils/alerts_and_navigators.dart';

class SignInWidgets {
  static Widget signUpNavigate(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: TextButton(
        onPressed: () => nextScreen(context, const RegistrationPage()),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: 'Register',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
