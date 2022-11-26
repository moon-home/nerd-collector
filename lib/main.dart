import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nerdcollector/constants/routes.dart';
import 'package:nerdcollector/firebase_options.dart';
import 'package:nerdcollector/views/login_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nerdcollector/views/register_view.dart';
import 'package:nerdcollector/views/verify_email_view.dart';
import 'dart:developer' as devtools show log;

void main() {
  // WidgetsFlutterBinding.ensureInitialized;
  runApp(MaterialApp(
    title: 'Welcome to Flutter',
    theme: ThemeData(primarySwatch: Colors.amber),
    home: const WelcomePage(),
    routes: {
      loginRoute: (context) => LoginView(),
      registerRoute: (context) => RegisterView(),
      homeRoute: (context) => HomeView(),
      verifyEmailRoute: (context) => VerifyEmailView(),
    },
  ));
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // final wordPair = WordPair.random();
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: ((context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (user.emailVerified) {
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

enum MenuAction { logout }

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nerd Collector'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              devtools.log(
                value.toString(),
              );
              switch (value) {
                case MenuAction.logout:
                  final isLogout = await logoutDialogue(context);
                  if (isLogout) {
                    devtools.log('User logged out');
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login/', (_) => false);
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                ),
              ];
            },
          )
        ],
      ),
      body: const Text('something'),
    );
  }
}

Future<bool> logoutDialogue(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Log out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
