import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nerdcollector/firebase_options.dart';
import 'package:nerdcollector/views/login_view.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized;
  runApp(MaterialApp(
    title: 'Welcome to Flutter',
    theme: ThemeData(primarySwatch: Colors.amber),
    home: const HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // final wordPair = WordPair.random();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: ((context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if (user?.emailVerified ?? false) {
                print('Verified email');
              } else {
                print('You need to verify your email');
              }
              return const Text('Done');

            default:
              return const Text('Loading...');
          }
        }),
      ),
    );
  }
}
