import 'package:app_ui/app_ui.dart';
import 'package:conexion/app/di/di.dart';
import 'package:conexion/login/widgets/widgets.dart';
import 'package:env/env.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared/shared.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      releaseFocus: true,
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoginForm(),
            GoogleSignInButton(),
            LogoutButton(),
          ],
        ),
      )),
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
    // await Supabase.instance.client.auth.signInWithOAuth(
    //   OAuthProvider.google
    // );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: lines_longer_than_80_chars
    return Tappable(
      color: context.theme.focusColor,
      borderRadius: 24,
      animationEffect: TappableAnimationEffect.scale,
      scaleStrength: ScaleStrength.xxxxs,
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
