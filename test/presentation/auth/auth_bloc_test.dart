import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ocam_pos/core/network/exceptions.dart';
import 'package:ocam_pos/data/repositories/auth_repository.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_bloc.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_event.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;

  setUp(() {
    authRepository = MockAuthRepository();
    when(() => authRepository.authStateChanges())
        .thenAnswer((_) => const Stream<User?>.empty());
  });

  AuthBloc buildBloc() => AuthBloc(authRepository: authRepository);

  group('SignInRequested', () {
    blocTest<AuthBloc, AuthState>(
      'email formati noto\'g\'ri bo\'lsa repository chaqirilmaydi',
      build: buildBloc,
      act: (bloc) => bloc.add(const SignInRequested('notanemail', '123456')),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.hasError, 'hasError', true)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
      verify: (_) {
        verifyNever(
          () => authRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      },
    );

    blocTest<AuthBloc, AuthState>(
      'to\'g\'ri ma\'lumot bilan yuklanish holatini ko\'rsatadi',
      build: buildBloc,
      setUp: () {
        when(
          () => authRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async {});
      },
      act: (bloc) =>
          bloc.add(const SignInRequested('user@example.com', '123456')),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.action,
          'action',
          AuthActionStatus.loading,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'Firebase xatosini o\'zbekcha xabarga aylantiradi',
      build: buildBloc,
      setUp: () {
        when(
          () => authRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(
          const AuthException(
            "Email yoki parol noto'g'ri",
            code: 'wrong-password',
          ),
        );
      },
      act: (bloc) =>
          bloc.add(const SignInRequested('user@example.com', 'wrongpass')),
      skip: 1,
      expect: () => [
        isA<AuthState>()
            .having((s) => s.hasError, 'hasError', true)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains("noto'g'ri"),
            ),
      ],
    );
  });

  group('SignUpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'zaif parolni repository\'ga yubormaydi',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const SignUpRequested('user@example.com', '123', 'Ism', ''),
      ),
      expect: () => [
        isA<AuthState>().having((s) => s.hasError, 'hasError', true),
      ],
      verify: (_) {
        verifyNever(
          () => authRepository.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
          ),
        );
      },
    );
  });
}
