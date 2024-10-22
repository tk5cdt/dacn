import 'package:animations/animations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:conexion/app/home/home.dart';
import 'package:conexion/login/login.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter router() {
  return GoRouter(
    initialLocation: '/feed',
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const LoginPage(),
      ),
      StatefulShellRoute.indexedStack(
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/feed',
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      child: AppScaffold(
                        body: Center(
                          child: Text(
                            'Feed',
                            style: context.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
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
                    return CustomTransitionPage(
                      child: AppScaffold(
                        body: Center(
                          child: Text(
                            'User Profile',
                            style: context.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
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
          ],
          builder: (context, state, navigationShell) {
            return HomePage(navigationShell: navigationShell);
          },),
    ],
    redirect: (context, state) {
      return null;
    },
    refreshListenable: GoRounterAppBlocRefreshStream(),
  );
}

class GoRounterAppBlocRefreshStream extends ChangeNotifier {}
