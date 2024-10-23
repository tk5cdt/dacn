import 'package:app_ui/app_ui.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class EmailFormFeild extends StatefulWidget {
  const EmailFormFeild({super.key});

  @override
  State<EmailFormFeild> createState() => _EmailFormFeildState();
}

class _EmailFormFeildState extends State<EmailFormFeild> {
  late Debouncer _debouncer;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _debouncer = Debouncer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      filled: true,
      textController: _controller,
      focusNode: _focusNode,
      hintText: 'Email',
      textInputType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: (value) => _debouncer.run(() => _onChanged(value)),
    );
  }
}
