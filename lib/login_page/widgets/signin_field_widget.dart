// ignore_for_file: use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assesment/utils/alerts_and_navigators.dart';
import 'package:flutter_assesment/utils/constants.dart';
import 'package:flutter_assesment/utils/validations.dart';
 

// ignore: must_be_immutable
class SignInFieldWidget extends StatefulWidget {
  const SignInFieldWidget({super.key});

  @override
  State<SignInFieldWidget> createState() => _SignInFieldWidgetState();
}

class _SignInFieldWidgetState extends State<SignInFieldWidget> {
  late TextEditingController emailController = TextEditingController();

  late TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    final authProvider = context.read<LoginAuthProvider>();

    final success = await authProvider.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (success) {
      customSnackbar(context, 'Login successful!');
      await Future.delayed(const Duration(milliseconds: 600));
      nextScreenRemoveUntil(context, const HomePage());
    } else {
      customSnackbar(context, authProvider.errorMessage ?? 'Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<LoginAuthProvider>();
    return FadeInDown(
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 1000),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 40, 40, 30),
        child: Form(
          key: formKey,
          // autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 20,
                        fontVariations: fontWeightW700,
                      ),
                    ),
                    kHeight(10),
                    const Text(
                      "Enter your login details to continue.",
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),

              kHeight(25),

              // Email address field
              CustomTxtFormField(
                hintText: 'Email address',
                controller: emailController,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(emailRegexPattern).hasMatch(val) || val.isEmpty) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),

              kHeight(20),

              /// Password
              CustomTxtFormField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: authProvider.isPasswordHidden,
                suffix: GestureDetector(
                  onTap: authProvider.togglePasswordVisibility,
                  child: Icon(
                    authProvider.isPasswordHidden
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 20,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              kHeight(25),

              /// Sign In Button
              CustomButton(
                buttonText: 'Login',
                isLoading: authProvider.isLoading,
                onPressed:
                    authProvider.isLoading ? null : () => _loginUser(context),
              ),

              kHeight(10),

              /// Forgot Password (Link only – no functionality)
              InkWell(
                onTap: () {
                  // No functionality required
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Forget Password?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
