import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assesment/utils/constants.dart';
import 'package:flutter_assesment/utils/validations.dart';
import 'package:flutter_assesment/widgets/custom_button_widget.dart';
import 'package:flutter_assesment/widgets/custom_text_form_fields_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_assesment/presentation/bloc/registration/registration_bloc.dart';
import 'package:flutter_assesment/utils/alerts_and_navigators.dart';
import 'package:flutter_assesment/presentation/pages/home_page/home_page.dart';
import 'package:flutter_assesment/presentation/bloc/password_visibility/password_visibility_bloc.dart';

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
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create an account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Join us and start managing your tasks efficiently.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Full name field
                  CustomTxtFormField(
                    hintText: 'Full name',
                    controller: fullnameController,
                    validator: AppValidators.validateFullName,
                  ),

                  const SizedBox(height: 16),

                  // Email address field
                  CustomTxtFormField(
                    hintText: 'Email address',
                    controller: emailController,
                    validator: AppValidators.validateEmail,
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  BlocBuilder<PasswordVisibilityBloc, PasswordVisibilityState>(
                    builder: (context, signUpState) {
                      return CustomTxtFormField(
                        hintText: 'Password',
                        controller: passwordController,
                        validator: AppValidators.validatePassword,
                        obscureText: signUpState.isPasswordHidden,
                        suffix: IconButton(
                          onPressed: () {
                            context.read<PasswordVisibilityBloc>().add(
                              TogglePasswordVisibilityEvent(),
                            );
                          },
                          icon: Icon(
                            signUpState.isPasswordHidden
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Confirm password field
                  BlocBuilder<PasswordVisibilityBloc, PasswordVisibilityState>(
                    builder: (context, signUpState) {
                      return CustomTxtFormField(
                        hintText: 'Confirm password',
                        controller: confirmPasswordController,
                        validator: (val) {
                          if (val != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return AppValidators.validatePassword(val);
                        },
                        obscureText: signUpState.isConfirmPasswordHidden,
                        suffix: IconButton(
                          onPressed: () {
                            context.read<PasswordVisibilityBloc>().add(
                              ToggleConfirmPasswordVisibilityEvent(),
                            );
                          },
                          icon: Icon(
                            signUpState.isConfirmPasswordHidden
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

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
