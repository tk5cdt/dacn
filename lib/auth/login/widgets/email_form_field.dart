import 'package:app_ui/app_ui.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:conexion/auth/login/cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class EmailFormField extends StatefulWidget {
  const EmailFormField({super.key});

  @override
  State<EmailFormField> createState() => _EmailFormFieldState();
}

class _EmailFormFieldState extends State<EmailFormField> {
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
      context.read<LoginCubit>().onEmailUnfocused();
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
    final emailError = context.select(
      (LoginCubit cubit) => cubit.state.email.validationErrorMessage[
          cubit.state.email.validator(cubit.state.email.value)],
    );

    return AppTextField(
      key: const ValueKey('loginEmailTextField'),
      filled: true,
      errorText: emailError,
      focusNode: _focusNode,
      hintText: context.l10n.emailText,
      textInputAction: TextInputAction.next,
      textInputType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      onChanged: (v) => _debouncer.run(
        () => context.read<LoginCubit>().onEmailChanged(v),
      ),
    );
  }
}
