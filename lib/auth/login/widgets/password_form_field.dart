import 'package:app_ui/app_ui.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:conexion/auth/login/cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_fields/form_fields.dart';
import 'package:shared/shared.dart';

class PasswordFormField extends StatefulWidget {
  const PasswordFormField({
    super.key,
  });

  @override
  State<PasswordFormField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordFormField> {
  late Debouncer _debouncer;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode()..addListener(_forcusNodeListener);
    _debouncer = Debouncer();
  }

  void _forcusNodeListener() {
    if (_focusNode.hasFocus) {
      context.read<LoginCubit>().onPasswordUnfocused();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode
      ..removeListener(_forcusNodeListener)
      ..dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordError = context.select(
      (LoginCubit cubit) => cubit.state.password.validationErrorMessage[
          cubit.state.password.validator(cubit.state.password.value)],
    );

    final showPassword = context.select(
      (LoginCubit cubit) => cubit.state.showPassword,
    );

    return AppTextField(
      key: const ValueKey('loginEmailTextField'),
      filled: true,
      errorText: passwordError,
      focusNode: _focusNode,
      hintText: context.l10n.passwordText,
      obscureText: !showPassword,
      suffixIcon: Tappable(
        onTap: () => context.read<LoginCubit>().changePasswordVisibility(),
        child: Icon(
          showPassword ? Icons.visibility : Icons.visibility_off,
          color: context.customAdaptiveColor(light: AppColors.grey),
        ),
      ),
      textInputAction: TextInputAction.done,
      textInputType: TextInputType.visiblePassword,
      autofillHints: const [AutofillHints.password],
      onChanged: (v) => _debouncer.run(
        () => context.read<LoginCubit>().onPasswordChanged(v),
      ),
    );
  }
}
