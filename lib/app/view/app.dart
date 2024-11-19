import 'dart:math';

import 'package:app_ui/app_ui.dart';
import 'package:chats_repository/chats_repository.dart';
import 'package:conexion/app/app.dart';
import 'package:conexion/feed/feed.dart';
import 'package:firebase_remote_config_repository/firebase_remote_config_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:search_repository/search_repository.dart';
import 'package:user_repository/user_repository.dart';

import '../../selector/selector.dart';

final snackbarKey = GlobalKey<AppSnackbarState>();

final loadingIndeterminateKey = GlobalKey<AppLoadingIndeterminateState>();

class App extends StatelessWidget {
  const App({
    required this.user,
    required this.userRepository,
    required this.chatsRepository,
    required this.postsRepository,
    required this.searchRepository,
    required this.firebaseRemoteConfigRepository,
    super.key,
  });

  final User user;
  final UserRepository userRepository;
  final ChatsRepository chatsRepository;
  final PostsRepository postsRepository;
  final SearchRepository searchRepository;
  final FirebaseRemoteConfigRepository firebaseRemoteConfigRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: userRepository,
        ),
        RepositoryProvider.value(
          value: chatsRepository,
        ),
        RepositoryProvider.value(
          value: postsRepository,
        ),
        RepositoryProvider.value(value: firebaseRemoteConfigRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppBloc(
              user: user,
              userRepository: userRepository,
            ),
          ),
          BlocProvider(create: (_) => LocaleBloc()),
          BlocProvider(create: (_) => ThemeModeBloc()),
          BlocProvider(
            create: (context) => FeedBloc(
              postsRepository: context.read<PostsRepository>(),
              firebaseRemoteConfigRepository:
                  context.read<FirebaseRemoteConfigRepository>(),
            ),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

void toggleLoadingIndeterminate({bool enable = true, bool autoHide = false}) =>
    loadingIndeterminateKey.currentState
        ?.setVisibility(visible: enable, autoHide: autoHide);

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
