import 'dart:async';
import 'package:animations/animations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:conexion/app/app.dart';
import 'package:conexion/app/home/home.dart';
import 'package:conexion/auth/view/auth_page.dart';
import 'package:conexion/feed/view/feed_page.dart';
import 'package:conexion/user_profile/user_profile.dart';
import 'package:conexion/user_profile/widgets/user_profile_create_post.dart';
import 'package:conexion/user_profile/widgets/user_profile_statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:user_repository/user_repository.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter router(AppBloc appBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/feed',
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthPage(),
      ),
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return HomePage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/feed',
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                    child: const FeedPage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return SharedAxisTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                        child: child,
                      );
                    },
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/timeline',
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                    child: AppScaffold(
                      body: Center(
                        child: Text(
                          'Timeline',
                          style: context.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOut)
                            .animate(animation),
                        child: child,
                      );
                    },
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/create_media',
                redirect: (context, state) => null,
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reels',
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                    child: AppScaffold(
                      body: Center(
                        child: Text(
                          'Reels',
                          style: context.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurveTween(curve: Curves.easeInOut)
                            .animate(animation),
                        child: child,
                      );
                    },
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/user',
                pageBuilder: (context, state) {
                  final user =
                      context.select((AppBloc bloc) => bloc.state.user);

                  return CustomTransitionPage(
                    child: UserProfilePage(userId: user.id),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return SharedAxisTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                        child: child,
                      );
                    },
                  );
                },
                routes: [
                  GoRoute(
                    path: 'create_post',
                    name: 'create_post',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final pickVideo = state.extra as bool? ?? false;

                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: UserProfileCreatePost(
                          pickVideo: pickVideo,
                          wantKeepAlive: false,
                        ),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        },
                      );
                    },
                    routes: [
                      GoRoute(
                        name: 'publish_post',
                        path: 'publish_post',
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final props = state.extra! as CreatePostProps;

                          return CustomTransitionPage(
                            key: state.pageKey,
                            child: CreatePostPage(props: props),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return SharedAxisTransition(
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                transitionType:
                                    SharedAxisTransitionType.horizontal,
                                child: child,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'statistics',
                    name: 'user_statistics',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final userId = state.uri.queryParameters['user_id']!;
                      final tabIndex = state.extra! as int;

                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: BlocProvider(
                          create: (context) => UserProfileBloc(
                            userId: userId,
                            userRepository: context.read<UserRepository>(),
                            postsRepository: context.read<PostsRepository>(),
                          )
                            ..add(const UserProfileSubscriptionRequested())
                            ..add(
                              const UserProfileFollowingsCountSubscriptionRequested(),
                            )
                            ..add(
                              const UserProfileFollowersCountSubscriptionRequested(),
                            ),
                          child: UserProfileStatistics(tabIndex: tabIndex),
                        ),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        },
                      );
                    },
                  ),
                  GoRoute(
                    path: 'edit',
                    name: 'edit_profile',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: const UserProfileEdit(),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.vertical,
                            child: child,
                          );
                        },
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'info/:label',
                        name: 'edit_profile_info',
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final query = state.uri.queryParameters;
                          final label = state.pathParameters['label']!;
                          final appBarTitle = query['title']!;
                          final description = query['description'];
                          final infoValue = query['value'];
                          final infoType = state.extra as ProfileEditInfoType?;

                          return MaterialPage<void>(
                            fullscreenDialog: true,
                            child: ProfileInfoEditPage(
                              appBarTitle: appBarTitle,
                              description: description,
                              infoValue: infoValue,
                              infoLabel: label,
                              infoType: infoType!,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authenticated = appBloc.state.status == AppStatus.authenticated;
      final authenticating = state.matchedLocation == '/auth';
      final isInFeed = state.matchedLocation == '/feed';

      if (isInFeed && !authenticated) return '/auth';
      if (!authenticated) return '/auth';
      if (authenticating && authenticated) return '/feed';

      return null;
    },
    refreshListenable: GoRouterAppBlocRefreshStream(appBloc.stream),
  );
}

/// {@template go_router_refresh_stream}
/// A [ChangeNotifier] that notifies listeners when a [Stream] emits a value.
/// This is used to rebuild the UI when the [AppBloc] emits a new state.
/// {@endtemplate}
class GoRouterAppBlocRefreshStream extends ChangeNotifier {
  /// {@macro go_router_refresh_stream}
  GoRouterAppBlocRefreshStream(Stream<AppState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((appState) {
      // if (_appState == appState) return;
      // _appState = appState;
      notifyListeners();
    });
  }

  // AppState _appState = const AppState.unauthenticated();

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
