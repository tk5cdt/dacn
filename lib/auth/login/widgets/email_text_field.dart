import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conexion/auth/login/cubit/login_cubit.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:shared/shared.dart';

class EmailTextField extends StatefulWidget {
  const EmailTextField({
    super.key,
  });

  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  final _debouncer = Debouncer();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<LoginCubit>()..resetState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        cubit.onEmailUnfocused();
      }
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailError = context.select(
      (LoginCubit cubit) => cubit.state.email.errorMessage,
    );
    final isLoading = context.select(
      (LoginCubit cubit) => cubit.state.status.isLoading,
    );

    return AppTextField(
      key: const ValueKey('loginEmailTextField'),
      filled: true,
      focusNode: _focusNode,
      hintText: context.l10n.emailText,
      enabled: !isLoading,
      textInputAction: TextInputAction.next,
      textInputType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      onChanged: (v) => _debouncer.run(
        () => context.read<LoginCubit>().onEmailChanged(v),
      ),
      errorText: emailError,
    );
  }
}
