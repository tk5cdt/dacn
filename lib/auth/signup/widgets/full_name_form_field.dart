import 'package:app_ui/app_ui.dart';
import 'package:conexion/auth/signup/cubit/sign_up_cubit.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class FullNameFormField extends StatefulWidget {
  const FullNameFormField({super.key});

  @override
  State<FullNameFormField> createState() => _FullNameFormFieldState();
}

class _FullNameFormFieldState extends State<FullNameFormField> {
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
      context.read<SignUpCubit>().onFullNameUnfocused();
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
    final fullNameError = context.select(
      (SignUpCubit cubit) => cubit.state.fullName.validationErrorMessage[
          cubit.state.fullName.validator(cubit.state.fullName.value)],
    );

    return AppTextField(
      filled: true,
      errorText: fullNameError,
      focusNode: _focusNode,
      enabled: !isLoading,
      hintText: context.l10n.nameText,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      autofillHints: const [AutofillHints.givenName],
      onChanged: (v) => _debouncer.run(
        () => context.read<SignUpCubit>().onFullNameChanged(v),
      ),
    );
  }
}
