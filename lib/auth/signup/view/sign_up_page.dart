import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:conexion/auth/auth.dart';
import 'package:conexion/auth/signup/widgets/widgets.dart';
import 'package:conexion_blocks_ui/conexion_blocks_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:conexion_blocks_ui/src/widgets/widgets.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpCubit(
        userRepository: context.read<UserRepository>(),
      ),
      child: const SignUpView(),
    );
  }
}

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  File? _avatarFile;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      body: AppConstrainedScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xlg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxxlg + AppSpacing.xlg),
            // AppLogo(
            //   fit: BoxFit.fitHeight,
            // ),
            const Text(
              'Conexion',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pacifico',
              ),
            ),
            AvatarImagePicker(
              onUpload: (_, avatarFile) {
                setState(() {
                  _avatarFile = avatarFile;
                });
              },
            ),
            Expanded(
              child: Column(
                children: [
                  const Gap.v(AppSpacing.xlg),
                  const SignUpForm(),
                  SignUpButton(
                    avatarFile: _avatarFile,
                  ),
                ],
              ),
            ),
            //Login in account button
            const SignInIntoAccountButton(),
            const Gap.v(AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
