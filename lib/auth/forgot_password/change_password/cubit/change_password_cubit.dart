import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:form_fields/form_fields.dart';
import 'package:shared/shared.dart';
import 'package:supabase_authentication_client/supabase_authentication_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_repository/user_repository.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const ChangePasswordState.initial());

  final UserRepository _userRepository;

  /// Changes password visibility, making it visible or not.
  void changePasswordVisibility() => emit(
        state.copyWith(showPassword: !state.showPassword),
      );

  /// Emits initial state of login screen.
  void resetState() => emit(const ChangePasswordState.initial());

  /// OTP field was unfocused, here is checking if previous state with OTP
  /// was valid, in order to indicate it in state after unfocus.
  void onOtpUnfocused() {
    final previousScreenState = state;
    final previousOtpState = previousScreenState.otp;
    final previousOtpValue = previousOtpState.value;

    final newOtpState = Otp.dirty(
      previousOtpValue,
    );
    final newScreenState = previousScreenState.copyWith(
      otp: newOtpState,
    );
    emit(newScreenState);
  }

  /// OTP value was changed, triggering new changes in state.
  void onOtpChanged(String newValue) {
    final previousScreenState = state;
    final previousOtpState = previousScreenState.otp;
    final shouldValidate = previousOtpState.isValid;
    final newOtpState = shouldValidate
        ? Otp.dirty(
            newValue,
          )
        : Otp.pure(
            newValue,
          );

    final newScreenState = state.copyWith(
      otp: newOtpState,
    );

    emit(newScreenState);
  }

  /// Password field was unfocused, here is checking if previous state with
  /// password was valid, in order to indicate it in state after unfocus.
  void onPasswordUnfocused() {
    final previousScreenState = state;
    final previousPasswordState = previousScreenState.password;
    final previousPasswordValue = previousPasswordState.value;

    final newPasswordState = Password.validated(
      previousPasswordValue,
    );
    final newScreenState = previousScreenState.copyWith(
      password: newPasswordState,
    );
    emit(newScreenState);
  }

  /// Password value was changed, triggering new changes in state.
  void onPasswordChanged(String newValue) {
    final previousScreenState = state;
    final previousPasswordState = previousScreenState.password;
    final shouldValidate = previousPasswordState.isValid;
    final newPasswordState = shouldValidate
        ? Password.validated(
            newValue,
          )
        : Password.unvalidated(
            newValue,
          );

    final newScreenState = state.copyWith(
      password: newPasswordState,
    );

    emit(newScreenState);
  }

  Future<void> onSubmit({required String email}) async {
    final password = Password.validated(state.password.value);
    final otp = Otp.dirty(state.otp.value);
    final isFormValid = FormzValid([password, otp]).isFormValid;
    final newState = state.copyWith(
      password: password,
      otp: otp,
      status: isFormValid ? ChangePasswordStatus.loading : null,
    );

    emit(newState);

    if (!isFormValid) return;

    try {
      await _userRepository.resetPassword(
        email: email,
        token: state.otp.value,
        newPassword: state.password.value,
      );

      emit(state.copyWith(status: ChangePasswordStatus.success));
    } catch (error, stackTrace) {
      __errorFormatter(error, stackTrace);
    }
  }

  void __errorFormatter(Object error, StackTrace stackTrace) {
    addError(error, stackTrace);
    final status = switch (error) {
      ResetPasswordFailure(:final AuthException error) => switch (
            error.statusCode?.parse) {
          HttpStatus.unauthorized => ChangePasswordStatus.invalidOtp,
          _ => ChangePasswordStatus.failure,
        },
      _ => ChangePasswordStatus.failure,
    };
    emit(state.copyWith(status: status));
  }
}
