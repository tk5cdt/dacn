import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:conexion/auth/auth.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpButton extends StatelessWidget {
  const SignUpButton({
    super.key,
    this.avatarFile,
  });

  final File? avatarFile;

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
    final isLoading = context
        .select((SignUpCubit bloc) => bloc.state.submissionStatus.isLoading);
    final child = switch (isLoading) {
      true => AppButton.inProgress(style: style, scale: 0.5),
      _ => AppButton.auth(
          context.l10n.signUpText,
          () => context.read<SignUpCubit>().onSubmit(avatarFile),
          style: style,
          outlined: true,
        ),
    };
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: switch (context.screenWidth) {
          > 600 => context.screenWidth * .6,
          _ => context.screenWidth,
        },
      ),
      child: child,
    );
  }
}
