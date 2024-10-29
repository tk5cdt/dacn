import 'package:app_ui/app_ui.dart';
import 'package:conexion/app/bloc/app_bloc.dart';
import 'package:conexion/app/routes/routes.dart';
import 'package:conexion/app/view/app.dart';
import 'package:conexion/auth/view/auth_page.dart';
import 'package:conexion/l10n/arb/app_localizations.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:conexion/auth/login/login.dart';
import 'package:conexion/selector/selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final routeConfig = router(context.read<AppBloc>());

    return BlocBuilder<LocaleBloc, Locale>(
      builder: (context, locale) {
        return BlocBuilder<ThemeModeBloc, ThemeMode>(
          builder: (context, themeMode) {
            return AnimatedSwitcher(
              duration: 300.ms,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.noScaling,
                ),
                child: MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  themeMode: themeMode,
                  theme: const AppTheme().theme,
                  darkTheme: const AppDarkTheme().theme,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        child!,
                        AppSnackbar(key: snackbarKey),
                        AppLoadingIndeterminate(key: loadingIndeterminateKey),
                      ],
                    );
                  },
                  routerConfig: routeConfig,
                  locale: locale,
                ),
              ),
            );
          },
        );
      },
    );
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   themeMode: ThemeMode.dark,
    //   theme: const AppTheme().theme,
    //   darkTheme: const AppDarkTheme().theme,
    //   localizationsDelegates: AppLocalizations.localizationsDelegates,
    //   supportedLocales: AppLocalizations.supportedLocales,
    //   home: const AuthPage(),
    // );
  }
}
