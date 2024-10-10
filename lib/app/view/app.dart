import 'package:api_repository/api_repository.dart';
import 'package:conexion/app/view/app_view.dart';
import 'package:conexion/counter/counter.dart';
import 'package:conexion/l10n/arb/app_localizations.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({required this.apiRepository, super.key});

  final ApiRepository apiRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: apiRepository,
      child: const AppView(),
    );
  }
}
