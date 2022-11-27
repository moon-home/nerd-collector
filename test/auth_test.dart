import 'package:flutter_test/flutter_test.dart';
import 'package:nerdcollector/services/auth/auth_exceptions.dart';
import 'package:nerdcollector/services/auth/auth_provider.dart';
import 'package:nerdcollector/services/auth/auth_user.dart';

void main() {
  group('Mock Authrntification', () {
    final provider = MockAuthProvider();
    test('Should not be initalized', () {
      expect(provider.isInitialized, false);
    });
    test('Cannot log out if not initalized', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });
    test(
      'Should be able to be initalized in 2 seconds',
      () async {
        await provider.initliaze();
        expect(
          provider.isInitialized,
          true,
        );
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );
    test('User should be null after initialization', () async {
      expect(provider.currentUser, null);
    });
    test('User should be null after initialization', () async {
      expect(provider.currentUser, null);
    });
    test('Create user should delegate to login function', () async {
      expect(
        () async => await provider.createUser(
          email: 'bad@gmail.com',
          password: 'goodpassword',
        ),
        throwsA(isA<UserNotFoundAuthException>()),
      );

      expect(
        () async => await provider.createUser(
          email: 'good@gmail.com',
          password: 'badbad',
        ),
        throwsA(isA<WrongPasswordAuthException>()),
      );
      final goodUser = await provider.createUser(
        email: 'good@gmail.com',
        password: 'goodpassword',
      );
      expect(provider.currentUser, goodUser);
      expect(goodUser.isEmailVerified, false);
    });
    test('Logged in user can be email verified', () async {
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test('Should be able to log out and log in', () async {
      await provider.logOut();
      await provider.logIn(
        email: 'good@gmail.com',
        password: 'goodpassword',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;
  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    print('BEFORE email: $email');
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initliaze() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'bad@gmail.com') {
      throw UserNotFoundAuthException();
    }
    if (password == 'badbad') {
      throw WrongPasswordAuthException();
    }
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
