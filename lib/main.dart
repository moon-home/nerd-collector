import 'package:flutter/material.dart';
import 'package:nerdcollector/constants/routes.dart';
import 'package:nerdcollector/services/auth/auth_service.dart';
import 'package:nerdcollector/views/home_view.dart';
import 'package:nerdcollector/views/login_view.dart';
import 'package:nerdcollector/views/register_view.dart';
import 'package:nerdcollector/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized;
  runApp(MaterialApp(
    title: 'Welcome to Flutter',
    theme: ThemeData(primarySwatch: Colors.amber),
    home: const WelcomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      homeRoute: (context) => const HomeView(),
      verifyEmailRoute: (context) => const VerifyEmailView(),
    },
  ));
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initliaze(),
      builder: ((context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const HomeView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }

          default:
            return const CircularProgressIndicator();
        }
      }),
    );
  }
}
