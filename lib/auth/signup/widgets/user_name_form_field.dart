import 'package:app_ui/app_ui.dart';
import 'package:conexion/auth/signup/cubit/sign_up_cubit.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class UserNameFormField extends StatefulWidget {
  const UserNameFormField({super.key});

  @override
  State<UserNameFormField> createState() => _UserNameFormFieldState();
}

class _UserNameFormFieldState extends State<UserNameFormField> {
  late Debouncer _debouncer;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_forcusNodeListener);
    _debouncer = Debouncer();
  }

  void _forcusNodeListener() {
    if (_focusNode.hasFocus) {
      context.read<SignUpCubit>().onUsernameUnfocused();
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_forcusNodeListener)
      ..dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select(
      (SignUpCubit cubit) => cubit.state.submissionStatus.isLoading,
    );
    final usernameError = context.select(
      (SignUpCubit cubit) => cubit.state.username.validationErrorMessage[
          cubit.state.username.validator(cubit.state.username.value)],
    );

    return AppTextField(
      filled: true,
      errorText: usernameError,
      focusNode: _focusNode,
      enabled: !isLoading,
      hintText: context.l10n.usernameText,
      textInputAction: TextInputAction.next,
      errorMaxLines: 3,
      autofillHints: const [AutofillHints.name],
      onChanged: (v) => _debouncer.run(
        () => context.read<SignUpCubit>().onUsernameChanged(v),
      ),
    );
  }
}
