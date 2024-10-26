import 'package:app_ui/app_ui.dart';
import 'package:conexion/auth/auth.dart';
import 'package:conexion/auth/signup/widgets/widgets.dart';
import 'package:conexion_blocks_ui/conexion_blocks_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

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

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      body: AppConstrainedScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xlg),
        child: Column(
          children: [
            SizedBox(height: AppSpacing.xxxlg + AppSpacing.xlg),
            AppLogo(
              fit: BoxFit.fitHeight,
            ),
            AvatarImagePicker(),
            Expanded(
              child: Column(
                children: [
                  Gap.v(AppSpacing.xlg),
                  SignUpForm(),
                  SignUpButton(),
                ],
              ),
            ),
            //Login in account button
            SignInIntoAccountButton(),
            Gap.v(AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
