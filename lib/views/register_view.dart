import 'package:flutter/material.dart';
import 'package:nerdcollector/constants/routes.dart';
import 'package:nerdcollector/services/auth/auth_exceptions.dart';
import 'package:nerdcollector/services/auth/auth_service.dart';
import 'package:nerdcollector/utilities/show_error_dialogue.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final wordPair = WordPair.random();
    return Scaffold(
      appBar: AppBar(title: const Text('Resgister')),
      body: Column(
        children: [
          TextField(
            controller: _email,
            decoration: const InputDecoration(hintText: 'Enter your email'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'Enter your password'),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );
                AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(verifyEmailRoute);
              } on WeakPasswordAuthException {
                await errorDialogue(
                  context,
                  'Weak password',
                );
              } on InvalidEmailAuthException {
                await errorDialogue(
                  context,
                  'Invalid email',
                );
              } on EmailAlreadyInUseAuthException {
                await errorDialogue(
                  context,
                  'Email already in use',
                );
              } on GenericAuthException {
                await errorDialogue(
                  context,
                  'Failed to register',
                );
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: const Text(
              'Login here',
            ),
          ),
        ],
      ),
    );
  }
}
