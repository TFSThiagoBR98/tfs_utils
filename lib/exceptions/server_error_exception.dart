import 'package:flutter/material.dart';

import '../utils/func_utils.dart';
import '../widgets/error_dialog.dart';
import 'ui_exception.dart';

class ServerErrorException implements UiException {
  final String message;

  ServerErrorException({this.message = 'Internal Server Error'}) : super();

  @override
  String toString() => message;

  @override
  Future<void> callDialog(
    BuildContext context, {
    ErrorCallback? onError,
    VoidCallback? onRetry,
    VoidCallback? onSuccess,
  }) async {
    var willShowDialog = true;
    if (onError != null) {
      willShowDialog = onError(this);
    }

    if (willShowDialog) {
      await showDialog<void>(
        context: context,
        builder: (context) => ErrorDialog(
          errorMessage: 'Falha no servidor\n'
              'Aguarde alguns minutos e tente novamente\n'
              'Caso o problema persista entre em contato com o suporte.\n',
          onRetry: onRetry,
          onOk: onSuccess,
        ),
        barrierDismissible: false,
      );
    }
  }
}
