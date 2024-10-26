// ignore_for_file: deprecated_member_use

import 'package:app_ui/app_ui.dart';
import 'package:conexion/auth/cubit/manage_password_cubit.dart';
import 'package:conexion/auth/forgot_password/change_password/widgets/change_password_button.dart';
import 'package:conexion/auth/forgot_password/change_password/widgets/change_password_form.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  void _confirmGoBack(BuildContext context) => context.confirmAction(
        fn: () => context
            .read<ManagePasswordCubit>()
            .changeScreen(showForgotPassword: true),
        title: context.l10n.goBackConfirmationText,
        content: context.l10n.loseAllEditsText,
        noText: context.l10n.cancelText,
        yesText: context.l10n.goBackText,
        yesTextStyle: context.labelLarge?.apply(color: AppColors.blue),
      );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _confirmGoBack(context);
        return Future.value(false);
      },
      child: AppScaffold(
        appBar: AppBar(
          title: Text(context.l10n.changePasswordText),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.adaptive.arrow_back),
            onPressed: () => _confirmGoBack(context),
          ),
        ),
        releaseFocus: true,
        resizeToAvoidBottomInset: true,
        body: const AppConstrainedScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xlg),
          child: Column(
            children: [
              Gap.v(AppSpacing.xxxlg * 3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ChangePasswordForm(),
                    Gap.v(AppSpacing.xs * 3),
                    Align(child: ChangePasswordButton()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
