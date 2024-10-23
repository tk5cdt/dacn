// import 'package:equatable/equatable.dart';
part of 'login_cubit.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  const LoginState._({
    required this.status,
    required this.email,
    required this.password,
  });

  const LoginState.initial()
      : this._(
          status: LoginStatus.initial,
          email: const Email.unvalidated(),
          password: const Password.unvalidated(),
        );

  final LoginStatus status;
  final Email email;
  final Password password;

  @override
  List<Object> get props => [status, email, password];

  LoginState copyWith({
    LoginStatus? status,
    Email? email,
    Password? password,
  }) {
    return LoginState._(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
