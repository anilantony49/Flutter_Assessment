import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assesment/utils/constants.dart';
import 'package:flutter_assesment/utils/validations.dart';
import 'package:flutter_assesment/widgets/custom_button_widget.dart';
import 'package:flutter_assesment/widgets/custom_text_form_fields_widget.dart';
 

// ignore: must_be_immutable
class SignUpFieldWidget extends StatefulWidget {
  const SignUpFieldWidget({super.key});

  @override
  State<SignUpFieldWidget> createState() => _SignUpFieldWidgetState();
}

class _SignUpFieldWidgetState extends State<SignUpFieldWidget> {
  late TextEditingController fullnameController = TextEditingController();

  late TextEditingController emailController = TextEditingController();

  late TextEditingController passwordController = TextEditingController();

  late TextEditingController confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    fullnameController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullnameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Future<void> _register(BuildContext context) async {
  //   final authProvider = context.read<RegisterAuthProvider>();
  //   if (!formKey.currentState!.validate()) return;

  //   if (passwordController.text != confirmPasswordController.text) {
  //     customSnackbar(context, 'Passwords do not match');
  //     return;
  //   }
  //   final success = await authProvider.register(
  //     email: emailController.text.trim(),
  //     password: passwordController.text.trim(),
  //   );

  //   if (success) {
  //     customSnackbar(context, 'Account created successfully!');
  //     await Future.delayed(const Duration(milliseconds: 600));
  //     nextScreenRemoveUntil(context, const HomePage());
  //   } else {
  //     customSnackbar(
  //       context,
  //       authProvider.errorMessage ??
  //           'Unable to create account. Please try again.',
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // final authProvider = context.watch<RegisterAuthProvider>();
    return FadeInDown(
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 1000),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create an account',
                    style: TextStyle(
                      fontSize: 20,
                      fontVariations: fontWeightW700,
                    ),
                  ),
                  kHeight(10),
                  const Text(
                    "Please enter you information and create your account.",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              kHeight(25),
              // Full name field
              CustomTxtFormField(
                hintText: 'Full name',
                controller: fullnameController,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Name is required';
                  }
                  if (val.length < 2) {
                    return 'Please enter a valid name';
                  }
                  return null;
                },
              ),
              kHeight(20),

              // Email address field
              CustomTxtFormField(
                hintText: 'Email address',
                controller: emailController,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(emailRegexPattern).hasMatch(val)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              kHeight(20),

              // Password field
              CustomTxtFormField(
                hintText: 'Password',
                controller: passwordController,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Password is required';
                  }
                  if (!RegExp(passowrdRegexPattern).hasMatch(val)) {
                    return 'Passwords should be 8 characters, at least one number and one special character';
                  }
                  return null;
                },
                // obscureText: authProvider.isPasswordHidden,
                // suffix: GestureDetector(
                //   onTap: authProvider.togglePasswordVisibility,
                //   child: Icon(
                //     authProvider.isPasswordHidden
                //         ? Icons.visibility_off
                //         : Icons.visibility,
                //     size: 20,
                //     color: Theme.of(context).colorScheme.secondary,
                //   ),
                // ),
              ),
              kHeight(20),

              // Confirm passowrd field
              CustomTxtFormField(
                hintText: 'Confirm password',
                controller: confirmPasswordController,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Password is required';
                  }
                  if (!RegExp(passowrdRegexPattern).hasMatch(val)) {
                    return 'Passwords should be 8 characters, at least one number and one special character';
                  }
                  return null;
                },
                // obscureText: authProvider.isConfirmPasswordHidden,
                // suffix: GestureDetector(
                //   onTap: authProvider.toggleConfirmPasswordVisibility,
                //   child: Icon(
                //     authProvider.isConfirmPasswordHidden
                //         ? Icons.visibility_off
                //         : Icons.visibility,
                //     size: 20,
                //     color: Theme.of(context).colorScheme.secondary,
                //   ),
                // ),
              ),
              kHeight(25),

              // Register button
              // CustomButton(
              //   buttonText: 'Register',
              //   isLoading: authProvider.isLoading,
              //   onPressed:
              //       authProvider.isLoading ? null : () => _register(context),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
