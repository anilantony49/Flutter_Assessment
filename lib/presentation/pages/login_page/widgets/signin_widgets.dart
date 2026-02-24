import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assesment/presentation/pages/registration_page/registration_page.dart';
import 'package:flutter_assesment/utils/alerts_and_navigators.dart';

class SignInWidgets {
  static InkWell signUpNavigate(BuildContext context) {
    return InkWell(
      onTap: () => nextScreen(context, const RegistrationPage()),
      child: FadeInUp(
        delay: const Duration(milliseconds: 700),
        duration: const Duration(milliseconds: 1000),
        child: Text.rich(
          textAlign: TextAlign.center,
          TextSpan(
            children: [
              TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              TextSpan(
                text: 'Register.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
