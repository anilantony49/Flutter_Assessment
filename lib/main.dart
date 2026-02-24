import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assesment/firebase_options.dart';
import 'package:flutter_assesment/presentation/pages/login_page/login_page.dart';
import 'package:flutter_assesment/presentation/bloc/registration/registration_bloc.dart';
import 'package:flutter_assesment/presentation/bloc/user_sign_in/sign_in_bloc.dart';
import 'package:flutter_assesment/presentation/bloc/password_visibility_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_assesment/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => RegistrationBloc()),
        BlocProvider(create: (context) => PasswordVisibilityBloc()),
        BlocProvider(create: (context) => SignInBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Login App',
        theme: lightTheme,
        home: const LoginPage(),
      ),
    );
  }
}
