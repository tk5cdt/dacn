import 'package:app_ui/app_ui.dart';
import 'package:conexion/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

final snackbarKey = GlobalKey<AppSnackbarState>();

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

/// Snack bar to show messages to the user.
void openSnackbar(
  SnackbarMessage message, {
  bool clearIfQueue = false,
  bool undismissable = false,
}) {
  snackbarKey.currentState
      ?.post(message, clearIfQueue: clearIfQueue, undismissable: undismissable);
}

// closes the snackbar
void closeSnackbar() {
  snackbarKey.currentState?.closeAll();
}
