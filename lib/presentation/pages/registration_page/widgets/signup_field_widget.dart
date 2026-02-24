import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assesment/presentation/bloc/password_visibility_bloc.dart';
import 'package:flutter_assesment/utils/constants.dart';
import 'package:flutter_assesment/utils/validations.dart';
import 'package:flutter_assesment/widgets/custom_button_widget.dart';
import 'package:flutter_assesment/widgets/custom_text_form_fields_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_assesment/presentation/bloc/registration/registration_bloc.dart';
 import 'package:flutter_assesment/utils/alerts_and_navigators.dart';
import 'package:flutter_assesment/presentation/pages/home_page/home_page.dart';

// ignore: must_be_immutable
class SignUpFieldWidget extends StatefulWidget {
  const SignUpFieldWidget({super.key});

  @override
  State<SignUpFieldWidget> createState() => _SignUpFieldWidgetState();
}

class _SignUpFieldWidgetState extends State<SignUpFieldWidget> {
  late TextEditingController fullnameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    fullnameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _register(BuildContext context) {
    if (!formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      customSnackbar(context, 'Passwords do not match');
      return;
    }

    context.read<RegistrationBloc>().add(
      UserRegistrationEvent(
        fullName: fullnameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegistrationBloc, RegistrationState>(
      listener: (context, state) {
        if (state is UserRegistrationSuccessState) {
          customSnackbar(context, state.message);
          Future.delayed(const Duration(milliseconds: 600)).then((_) {
            nextScreenRemoveUntil(context, const HomePage());
          });
        } else if (state is UserRegistrationErrorState) {
          customSnackbar(context, state.errorMessage);
        }
      },
      builder: (context, state) {
        final isLoading = state is UserRegistrationLoadingState;
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
                  BlocBuilder<PasswordVisibilityBloc, PasswordVisibilityState>(
                    builder: (context, signUpState) {
                      return CustomTxtFormField(
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
                        obscureText: signUpState.isPasswordHidden,
                        suffix: GestureDetector(
                          onTap: () {
                            context.read<PasswordVisibilityBloc>().add(TogglePasswordVisibilityEvent());
                          },
                          child: Icon(
                            signUpState.isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                            size: 20,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      );
                    },
                  ),
                  kHeight(20),

                  // Confirm passowrd field
                  BlocBuilder<PasswordVisibilityBloc, PasswordVisibilityState>(
                    builder: (context, signUpState) {
                      return CustomTxtFormField(
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
                        obscureText: signUpState.isConfirmPasswordHidden,
                        suffix: GestureDetector(
                          onTap: () {
                            context.read<PasswordVisibilityBloc>().add(ToggleConfirmPasswordVisibilityEvent());
                          },
                          child: Icon(
                            signUpState.isConfirmPasswordHidden ? Icons.visibility_off : Icons.visibility,
                            size: 20,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      );
                    },
                  ),
                  kHeight(25),

                  // Register button
                  CustomButton(
                    buttonText: 'Register',
                    isLoading: isLoading,
                    onPressed: isLoading ? null : () => _register(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
