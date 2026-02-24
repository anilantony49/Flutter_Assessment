import 'package:flutter/material.dart';
import 'package:flutter_assesment/presentation/pages/login_page/widgets/signin_field_widget.dart';
import 'package:flutter_assesment/presentation/pages/login_page/widgets/signin_widgets.dart';
import 'package:flutter_assesment/widgets/custom_appbar_widget.dart';
 
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: CustomAppbar.show(context, false, 'Login'),
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 40, 0, 30),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SignInFieldWidget(),
                Positioned(
                  bottom: 0,
                  child: SignInWidgets.signUpNavigate(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
