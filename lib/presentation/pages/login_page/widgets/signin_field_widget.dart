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
                    validator: AppValidators.validateEmail,
                  ),

                  kHeight(20),

                  /// Password
                  CustomTxtFormField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: isPasswordHidden,
                    suffix: GestureDetector(
                      onTap: () {
                        context.read<SignInBloc>().add(
                          ToggleSignInPasswordVisibilityEvent(),
                        );
                      },
                      child: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 20,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    validator: AppValidators.validatePassword,
                  ),

                  kHeight(25),

                  /// Sign In Button
                  CustomButton(
                    buttonText: 'Login',
                    isLoading: isLoading,
                    onPressed: isLoading ? null : () => _loginUser(context),
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
                          color: Theme.of(context).colorScheme.primary,
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
      },
    );
  }
}
