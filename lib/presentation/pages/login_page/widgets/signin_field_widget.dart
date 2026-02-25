// ignore_for_file: use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assesment/presentation/bloc/user_sign_in/sign_in_bloc.dart';
import 'package:flutter_assesment/utils/alerts_and_navigators.dart';
import 'package:flutter_assesment/utils/constants.dart';
import 'package:flutter_assesment/utils/validations.dart';
import 'package:flutter_assesment/widgets/custom_button_widget.dart';
import 'package:flutter_assesment/widgets/custom_text_form_fields_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_assesment/presentation/pages/home_page/home_page.dart';

// ignore: must_be_immutable
class SignInFieldWidget extends StatefulWidget {
  const SignInFieldWidget({super.key});

  @override
  State<SignInFieldWidget> createState() => _SignInFieldWidgetState();
}

class _SignInFieldWidgetState extends State<SignInFieldWidget> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

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

  void _loginUser(BuildContext context) {
    if (!formKey.currentState!.validate()) return;

    context.read<SignInBloc>().add(
      UserSignInEvent(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInBloc, SignInState>(
      listener: (context, state) {
        if (state is UserSignInSuccessState) {
          customSnackbar(context, state.message);
          Future.delayed(const Duration(milliseconds: 600)).then((_) {
            nextScreenRemoveUntil(context, const HomePage());
          });
        } else if (state is UserSignInErrorState) {
          customSnackbar(context, state.errorMessage);
        }
      },
      builder: (context, state) {
        final isLoading = state is UserSignInLoadingState;
        final isPasswordHidden =
            state is SignInBaseState ? state.isPasswordHidden : true;

        return FadeInDown(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enter your details to continue your journey.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Email address field
                  CustomTxtFormField(
                    hintText: 'Email address',
                    controller: emailController,
                    validator: AppValidators.validateEmail,
                  ),

                  const SizedBox(height: 20),

                  /// Password
                  CustomTxtFormField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: isPasswordHidden,
                    suffix: IconButton(
                      onPressed: () {
                        context.read<SignInBloc>().add(
                          ToggleSignInPasswordVisibilityEvent(),
                        );
                      },
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 20,
                      ),
                    ),
                    validator: AppValidators.validatePassword,
                  ),

                  const SizedBox(height: 12),

                  /// Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: const Text('Forgot Password?'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Sign In Button
                  CustomButton(
                    buttonText: 'Login',
                    isLoading: isLoading,
                    onPressed: isLoading ? null : () => _loginUser(context),
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
