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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 40, 0, 30),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SignUpFieldWidget(),
                Positioned(
                  bottom: 0,
                  child: SignUpWidgets.signInNavigate(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
