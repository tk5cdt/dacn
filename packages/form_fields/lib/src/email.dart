import 'package:equatable/equatable.dart' show EquatableMixin;
import 'package:form_fields/form_fields.dart';
import 'package:formz/formz.dart';

/// {@template email}
/// Formz input for email. It can be empty or invalid.
/// {@endtemplate}
class Email extends FormzInput<String, EmailValidationError>
    with EquatableMixin, FormzValidationMixin {
  /// {@macro email.pure}
  const Email.unvalidated([super.value = '']) : super.pure();

  /// {@macro email.dirty}
  const Email.validated(super.value) : super.dirty();

  static final _emailRegex = RegExp(
    r'^(([\w-]+\.)+[\w-]+|([a-zA-Z]|[\w-]{2,}))@((([0-1]?'
    r'[0-9]{1,2}|25[0-5]|2[0-4][0-9])\.([0-1]?[0-9]{1,2}|25[0-5]|2[0-4][0-9])\.'
    r'([0-1]?[0-9]{1,2}|25[0-5]|2[0-4][0-9])\.([0-1]?[0-9]{1,2}|25[0-5]|2[0-4][0-9])'
    r')|([a-zA-Z]+[\w-]+\.)+[a-zA-Z]{2,4})$',
  );

  @override
  EmailValidationError? validator(String value) {
    if (value.isEmpty) return EmailValidationError.empty;
    if (!_emailRegex.hasMatch(value)) return EmailValidationError.invalid;
    return null;
  }

  /// Email validation errors message
  @override
  Map<EmailValidationError?, String?> get validationErrorMessage => {
        EmailValidationError.empty: '',
        EmailValidationError.empty: 'This field is required',
        EmailValidationError.invalid: 'Email is not correct',
        null: null,
      };

  @override
  List<Object> get props => [isPure, value];

  // ignore: public_member_api_docs
  bool get invalid => validator(value) != null;
}

/// Validation errors for [Email]. It can be empty, invalid or already
/// registered.
enum EmailValidationError {
  /// Empty email.
  empty,

  /// Invalid email.
  invalid,
}
