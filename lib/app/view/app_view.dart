import 'package:app_ui/app_ui.dart';
import 'package:conexion/app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conexion/app/app.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:conexion/selector/selector.dart';
import 'package:shared/shared.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final routerConfig = AppRouter(context.read<AppBloc>()).router;

    return BlocBuilder<LocaleBloc, Locale>(
      builder: (context, locale) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => LocaleSettings.setLocaleRaw(locale.languageCode),
        );
        return BlocBuilder<ThemeModeBloc, ThemeMode>(
          builder: (context, themeMode) {
            return AnimatedSwitcher(
              duration: 350.ms,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.noScaling,
                ),
                child: MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'Instagram',
                  routerConfig: routerConfig,
                  builder: (context, child) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => initUtilities(context, locale),
                    );

                    return Stack(
                      children: [
                        child!,
                        AppSnackbar(key: snackbarKey),
                        AppLoadingIndeterminate(key: loadingIndeterminateKey),
                      ],
                    );
                  },
                  themeMode: themeMode,
                  theme: const AppTheme().theme,
                  darkTheme: const AppDarkTheme().theme,
                  locale: locale,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
