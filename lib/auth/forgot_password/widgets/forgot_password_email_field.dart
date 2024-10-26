import 'package:app_ui/app_ui.dart';
import 'package:conexion/auth/forgot_password/cubit/forgot_password_cubit.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class ForgotPasswordEmailField extends StatefulWidget {
  const ForgotPasswordEmailField({super.key});

  @override
  State<ForgotPasswordEmailField> createState() =>
      _ForgotPasswordEmailFieldState();
}

class _ForgotPasswordEmailFieldState extends State<ForgotPasswordEmailField> {
  late Debouncer _debouncer;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer();
    final cubit = context.read<ForgotPasswordCubit>()..resetState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        cubit.onEmailUnfocused();
      }
    });
  }

  void _forcusNodeListener() {
    if (!_focusNode.hasFocus) {
      context.read<ForgotPasswordCubit>().onEmailUnfocused();
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _focusNode
      ..removeListener(_forcusNodeListener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailError = context.select(
      (ForgotPasswordCubit cubit) => cubit.state.email.errorMessage,
    );
    final isLoading = context.select(
      (ForgotPasswordCubit cubit) => cubit.state.status.isLoading,
    );

    return AppTextField(
      filled: true,
      focusNode: _focusNode,
      hintText: context.l10n.emailText,
      enabled: !isLoading,
      textInputAction: TextInputAction.next,
      textInputType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      onChanged: (v) => _debouncer.run(
        () => context.read<ForgotPasswordCubit>().onEmailChanged(v),
      ),
      errorText: emailError,
    );
    
  }
}
