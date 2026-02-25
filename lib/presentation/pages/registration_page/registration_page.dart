import 'package:flutter/material.dart';
import 'package:flutter_assesment/presentation/pages/registration_page/widgets/signup_field_widget.dart';
import 'package:flutter_assesment/presentation/pages/registration_page/widgets/signup_widget.dart';
 

import 'package:flutter_assesment/widgets/custom_appbar_widget.dart';
 
class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: CustomAppbar.show(context, true, 'Register'),
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(minHeight: mediaHeight),
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(), // Spacer for alignment
              const SignUpFieldWidget(),
              SignUpWidgets.signInNavigate(context),
            ],
          ),
        ),
      ),
    );
  }
}
