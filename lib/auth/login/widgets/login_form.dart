import 'package:app_ui/app_ui.dart';
import 'package:conexion/auth/login/widgets/email_form_field.dart';
import 'package:conexion/auth/login/widgets/password_form_field.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EmailFormField(),
        // SizedBox(
        //   height: AppSpacing.md,
        // ),
        PasswordFormField(),
      ],
    );
  }
}
