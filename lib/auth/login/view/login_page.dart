import 'package:app_ui/app_ui.dart';
import 'package:conexion/app/app.dart';
import 'package:conexion/app/di/di.dart';
import 'package:conexion/auth/login/cubit/login_cubit.dart';
import 'package:conexion/auth/login/widgets/auth_provider_sign_in_button.dart';
import 'package:conexion/auth/login/widgets/login_form.dart';
import 'package:conexion/auth/login/widgets/sign_in_button.dart';
import 'package:conexion/auth/login/widgets/widgets.dart';
import 'package:env/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared/shared.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_repository/user_repository.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LoginCubit(userRepository: context.read<UserRepository>()),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      body: AppConstrainedScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xlg,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Gap.v(AppSpacing.xxxlg + AppSpacing.xxxlg),
            // const AppLogo(
            //   height: AppSpacing.xxxlg,
            //   fit: BoxFit.fitHeight,
            //   width: double.infinity,
            // ),
            const Text(
              'Conexion',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pacifico',
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LoginForm(),
                  const Padding(
                    padding: EdgeInsets.only(
                      bottom: AppSpacing.md,
                      top: AppSpacing.xs,
                    ),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: ForgotPasswordButton(),
                    ),
                  ),
                  const SignInButton(),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: AppDivider(
                      withText: true,
                    ),
                  ),
                  AuthProviderSignInButton(
                    provider: AuthProvider.google,
                    onPressed: () =>
                        context.read<LoginCubit>().loginWithGoogle(),
                  ),
                  // const GoogleSignInButton(),
                  // Gap.v(AppSpacing.xxxlg),
                  // LogoutButton(),
                ],
              ),
            ),
            const SignUpNewAccountButton(),
            const Gap.v(AppSpacing.lg),
            // ElevatedButton(
            //   onPressed: () => context.read<UserRepository>().logOut(),
            //   child: const Text('Log out'),
            // ),
          ],
        ),
      ),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  Future<void> _googleSignIn() async {
    final webClientId = getIt<AppFlavor>().getEnv(Env.webClientId);
    final iOSClientId = getIt<AppFlavor>().getEnv(Env.iOSClientId);

    final googleSignIn = GoogleSignIn(
      clientId: webClientId,
      // serverClientId: webClientId,
    );

    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser?.authentication;
    if (googleAuth == null) {
      throw Exception('Google sign in failed');
    }
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;
    if (accessToken == null) {
      throw Exception('No Access Token found');
    }
    if (idToken == null) {
      throw Exception('No ID Token found');
    }
    await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
    await Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.google);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: lines_longer_than_80_chars
    return Tappable(
      backgroundColor: context.theme.focusColor,
      borderRadius: BorderRadius.circular(10),
      scaleStrength: ScaleStrength.xxs,
      scaleAlignment: Alignment.bottomCenter,
      onTap: () async {
        try {
          await _googleSignIn();
        } catch (e, st) {
          logE('Google sign in failed', error: e, stackTrace: st);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + AppSpacing.xxs,
        ),
        child: Text(
          'Google sign in',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final session = snapshot.data!.session;
          if (session != null) {
            return ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: Text(
                'Logout',
                // ignore: lines_longer_than_80_chars
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.apply(color: Colors.red),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}
