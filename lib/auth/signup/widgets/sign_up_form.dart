import 'package:app_ui/app_ui.dart';
import 'package:conexion/app/view/app.dart';
import 'package:conexion/auth/signup/cubit/sign_up_cubit.dart';
import 'package:conexion/auth/signup/widgets/email_form_field.dart';
import 'package:conexion/auth/signup/widgets/full_name_form_field.dart';
import 'package:conexion/auth/signup/widgets/pass_word_form_field.dart';
import 'package:conexion/auth/signup/widgets/user_name_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignupState>(
      listener: (context, state) {
        if (state.submissionStatus.isError) {
          openSnackbar(
            SnackbarMessage.error(
              title:
                  signupSubmissionStatusMessage[state.submissionStatus]!.title,
              description: signupSubmissionStatusMessage[state.submissionStatus]
                  ?.description,
            ),
            clearIfQueue: true,
          );
        }
      },
      listenWhen: (previous, current) =>
          previous.submissionStatus != current.submissionStatus,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmailFormField(),
          FullNameFormField(),
          UserNameFormField(),
          PasswordFormField(),
        ],
      ),
    );
  }
}
