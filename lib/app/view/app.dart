import 'package:api_repository/api_repository.dart';
import 'package:conexion/app/app.dart';
import 'package:conexion/app/view/app_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

class App extends StatelessWidget {
  const App({
    required this.user,
    required this.userRepository,
    super.key,
  });

  final User user;
  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: userRepository,
      child: BlocProvider(
        create: (context) => AppBloc(
          user: user,
          userRepository: userRepository,
        ),
        child: const AppView(),
      ),
    );
  }
}
