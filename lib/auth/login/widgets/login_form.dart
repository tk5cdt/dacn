import 'package:app_ui/app_ui.dart';
import 'package:conexion/app/view/app.dart';
import 'package:conexion/auth/forgot_password/change_password/view/change_password_page.dart';
import 'package:conexion/auth/login/cubit/login_cubit.dart';
import 'package:conexion/auth/login/widgets/email_form_field.dart';
import 'package:conexion/auth/login/widgets/password_form_field.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status.isError) {
          openSnackbar(
            SnackbarMessage.error(
              title: loginSubmissionStatusMessage[state.status]?.title ??
              state.message ??
              context.l10n.somethingWentWrongText,
              description:
                  loginSubmissionStatusMessage[state.status]?.description,
            ),
            clearIfQueue: true,
          );
        }
      },
      listenWhen: (previous, curent) => previous.status != curent.status,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmailFormField(),
          PasswordFormField(),
        ],
      ),
    );
  }
}
