import 'package:app_ui/app_ui.dart';
import 'package:conexion/app/routes/routes.dart';
import 'package:conexion/auth/view/auth_page.dart';
import 'package:conexion/l10n/arb/app_localizations.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:conexion/auth/login/login.dart';
import 'package:flutter/material.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final routeConfig = router();
    // return MaterialApp.router(
    //   debugShowCheckedModeBanner: false,
    //   themeMode: ThemeMode.dark,
    //   theme: const AppTheme().theme,
    //   darkTheme: const AppDarkTheme().theme,
    //   localizationsDelegates: AppLocalizations.localizationsDelegates,
    //   supportedLocales: AppLocalizations.supportedLocales,
    //   routerConfig: routeConfig,
    // );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: const AppTheme().theme,
      darkTheme: const AppDarkTheme().theme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AuthPage(),
    );
  }
}
