import 'package:dio/dio.dart';
import 'package:ferry/typed_links.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:universal_io/io.dart';

import '../exceptions/account_deletation_in_progress.dart';
import '../exceptions/auth_exception.dart';
import '../exceptions/auth_wrong_exception.dart';
import '../exceptions/generic_error_exception.dart';
import '../exceptions/graphql_error_exception.dart';
import '../exceptions/outdated_client_exception.dart';
import '../exceptions/payment_refused_exception.dart';
import '../exceptions/permission_exception.dart';
import '../exceptions/register_must_verify_email_exception.dart';
import '../exceptions/server_error_exception.dart';
import '../exceptions/ui_exception.dart';
import '../exceptions/validation_exception.dart';
import '../widgets/error_dialog.dart';

Future<T> runFutureWithErrorDialog<T>(BuildContext context,
    {required Future<T> Function() callback,
    required VoidCallback onError,
    ProgressDialog? dialog,
    VoidCallback? onRetry,
    VoidCallback? onSuccess}) async {
  try {
    return await callback();
  } on GraphQLErrorException catch (e) {
    try {
      throw rethrowAuth(e);
    } catch (e) {
      dialog?.dismiss();
      displayErrorDialog(context, error: e, onError: onError, onRetry: onRetry, onSuccess: onSuccess);
      rethrow;
    }
  } catch (e) {
    dialog?.dismiss();
    displayErrorDialog(context, error: e, onError: onError, onRetry: onRetry, onSuccess: onSuccess);
    rethrow;
  }
}

Exception rethrowAuth(GraphQLErrorException exception) {
  if (exception.errors != null) {
    for (final error in exception.errors!) {
      switch (error.message) {
        case 'Unauthenticated.':
        case 'Not Authenticated':
          return AuthException();
        case 'invalid_grant':
          return AuthWrongException();
        case 'Outdated Client':
          return OutdatedClientException();
        case 'This action is unauthorized.':
          return PermissionException();
        case 'PAYMENT_REFUSED':
          return PaymentRefusedException(
            code: error.extensions?['code'] as String?,
            reason: error.extensions?['reason'] as String?,
            operation: error.extensions?['operation'] as String?,
          );
        case 'Account Terminated.':
          return AccountDeletationInProgressException();
        case 'Internal server error':
          return ServerErrorException();
        case 'Generic Error':
          return GenericErrorException(
            code: error.extensions?['code'] as String?,
            reason: error.extensions?['reason'] as String?,
            operation: error.extensions?['operation'] as String?,
          );
        default:
          if (error.message.contains('Validation failed')) {
            return ValidationException(fields: error.extensions?['validation'] as Map?);
          } else if (error.message.contains('[Keycloak Guard]')) {
            return AuthException();
          } else {
            return Exception('Unknown Error');
          }
      }
    }
  }

  if (exception.linkException != null) {
    if (exception.linkException is ServerException && exception.linkException!.originalException is DioException) {
      return exception.linkException!.originalException! as DioException;
    } else if (exception.linkException is ServerException && exception.linkException!.originalException is Exception) {
      return exception.linkException!.originalException! as Exception;
    } else if (exception.linkException is LinkException && exception.linkException!.originalException is DioException) {
      return exception.linkException!.originalException! as DioException;
    } else if (exception.linkException is LinkException && exception.linkException!.originalException is Exception) {
      return exception.linkException!.originalException! as Exception;
    } else {
      return exception;
    }
  }

  return Exception('Unknown Error');
}

void displayErrorDialog(BuildContext context,
    {required dynamic error, required Function onError, VoidCallback? onRetry, VoidCallback? onSuccess}) {
  if (error is AuthException) {
    error.callDialog(context, onRetry: onRetry, onSuccess: onSuccess).whenComplete(() => onError);
  } else if (error is PermissionException) {
    error.callDialog(context, onRetry: onRetry, onSuccess: onSuccess).whenComplete(() => onError);
  } else if (error is AuthWrongException) {
    error.callDialog(context, onRetry: onRetry, onSuccess: onSuccess).whenComplete(() => onError);
  } else if (error is RegisterMustVerifyEmailException) {
    error.callDialog(context, onSuccess: onSuccess).whenComplete(() => onSuccess ?? () {});
  } else if (error is OutdatedClientException) {
    error.callDialog(context, onRetry: onRetry, onSuccess: onSuccess).whenComplete(() => onError);
  } else if (error is ValidationException) {
    error.callDialog(context, onRetry: onRetry, onSuccess: onSuccess).whenComplete(() => onError);
  } else if (error is PaymentRefusedException) {
    error.callDialog(context, onRetry: onRetry, onSuccess: onSuccess).whenComplete(() => onError);
  } else if (error is AccountDeletationInProgressException) {
    error.callDialog(context, onRetry: onRetry, onSuccess: onSuccess).whenComplete(() => onError);
  } else if (error is ServerErrorException) {
    error.callDialog(context, onRetry: onRetry, onSuccess: onSuccess).whenComplete(() => onError);
  } else if (error is GenericErrorException) {
    error.callDialog(context, onRetry: onRetry, onSuccess: onSuccess).whenComplete(() => onError);
  } else if (error is GraphQLErrorException) {
    var r = rethrowAuth(error);
    return displayErrorDialog(context, error: r, onError: onError, onRetry: onRetry, onSuccess: onSuccess);
  } else if (error is DioException) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      showDialog<void>(
        context: context,
        builder: (context) => ErrorDialog(
            errorMessage: 'Falha ao executar a ação\n'
                'Tempo esgotado aguardando resposta do servidor\n'
                'Verifique sua conexão com a internet e tente novamente.\n'
                'Caso o problema persista e não seja sua internet, entre em contato com o suporte.\n',
            onRetry: onRetry),
        barrierDismissible: false,
      ).whenComplete(() => onError);
    } else if (error.type == DioExceptionType.badCertificate) {
      showDialog<void>(
        context: context,
        builder: (context) => ErrorDialog(
            errorMessage: 'Falha ao conectar ao Servidor\n'
                'Falha na verificação de segurança, não é possível conectar no momento\n',
            onRetry: onRetry),
        barrierDismissible: false,
      ).whenComplete(() => onError);
    } else if (error.type == DioExceptionType.badResponse) {
      showDialog<void>(
        context: context,
        builder: (context) => ErrorDialog(
            errorMessage: 'Falha ao conectar ao Servidor\n'
                'Resposta inválida do servidor\n'
                'Entre em contato com o suporte.\n',
            onRetry: onRetry),
        barrierDismissible: false,
      ).whenComplete(() => onError);
    } else if (error.type == DioExceptionType.cancel) {
      showDialog<void>(
        context: context,
        builder: (context) => ErrorDialog(
            errorMessage: 'Falha ao conectar ao Servidor\n'
                'Conexão cancelada antes de obter os dados do servidor',
            onRetry: onRetry),
        barrierDismissible: false,
      ).whenComplete(() => onError);
    } else if (error.type == DioExceptionType.connectionError) {
      showDialog<void>(
        context: context,
        builder: (context) => ErrorDialog(
            errorMessage: 'Falha ao conectar ao Servidor\n'
                'Não foi possível fazer uma conexão no momento\n'
                'Verifique sua conexão com a internet e tente novamente\n',
            onRetry: onRetry),
        barrierDismissible: false,
      ).whenComplete(() => onError);
    } else if (error.type == DioExceptionType.unknown) {
      showDialog<void>(
        context: context,
        builder: (context) => ErrorDialog(
            errorMessage: 'Falha ao conectar ao Servidor\n'
                'Verifique sua conexão com a internet e tente novamente\n',
            onRetry: onRetry),
        barrierDismissible: false,
      ).whenComplete(() => onError);
    } else if (error.response == null) {
      showDialog<void>(
        context: context,
        builder: (context) => ErrorDialog(
            errorMessage: 'O Servidor não enviou uma resposta\n'
                'Verifique sua conexão com a internet e tente novamente\n',
            onRetry: onRetry),
        barrierDismissible: false,
      ).whenComplete(() => onError);
    } else {
      if (error.response?.statusCode == null) {
        showDialog<void>(
          context: context,
          builder: (context) => ErrorDialog(
              errorMessage: 'Erro desconhecido na conexão com o servidor\n'
                  'Verifique sua conexão com a internet e tente novamente\n'
                  'Detalhes do Erro: Código de Estado HTTP está Nulo \n',
              onRetry: onRetry),
          barrierDismissible: false,
        ).whenComplete(() => onError);
      } else if (error.response?.statusCode == 460) {
        showDialog<void>(
          context: context,
          builder: (context) => ErrorDialog(
              errorMessage: 'Este aplicativo está desatualizado\n'
                  'Por favor faça uma atualização na loja de aplicativos de seu dispositivo\n',
              onRetry: onRetry),
          barrierDismissible: false,
        ).whenComplete(() => onError);
      } else if (error.response?.statusCode == 401) {
        showDialog<void>(
          context: context,
          builder: (context) => ErrorDialog(
              errorMessage: 'É necessário fazer login, reinicie o app\n'
                  'Em caso de dúvidas, entre em contato com o suporte',
              onRetry: onRetry),
          barrierDismissible: false,
        ).whenComplete(() => onError);
      } else if (error.response?.statusCode == 403) {
        showDialog<void>(
          context: context,
          builder: (context) => ErrorDialog(
              errorMessage: 'Acesso Negado\n'
                  'Em caso de dúvidas, entre em contato com o suporte',
              onRetry: onRetry),
          barrierDismissible: false,
        ).whenComplete(() => onError);
      } else if (error.response?.statusCode == 404) {
        showDialog<void>(
          context: context,
          builder: (context) => ErrorDialog(
              errorMessage: 'Recurso não encontrado\n'
                  'Em caso de dúvidas, entre em contato com o suporte',
              onRetry: onRetry),
          barrierDismissible: false,
        ).whenComplete(() => onError);
      } else if (error.response?.statusCode == 429) {
        showDialog<void>(
          context: context,
          builder: (context) => ErrorDialog(
              errorMessage: 'Você fez várias requisições em um curto periodo de tempo\n'
                  'Muitas tentativas de conexão, tente mais tarde\n',
              onRetry: onRetry),
          barrierDismissible: false,
        ).whenComplete(() => onError);
      } else if (error.response?.statusCode == 503) {
        showDialog<void>(
          context: context,
          builder: (context) => ErrorDialog(
              errorMessage: 'Sistema em manutenção\n'
                  'Por favor tente mais tarde\n'
                  'Em caso de dúvidas, entre em contato com o suporte',
              onRetry: onRetry),
          barrierDismissible: false,
        ).whenComplete(() => onError);
      } else if (error.response!.statusCode! >= 500 || error.response!.statusCode! <= 599) {
        showDialog<void>(
          context: context,
          builder: (context) => ErrorDialog(
              errorMessage: 'Falha no servidor\n'
                  'Ocorreu um problema no nosso sistema\n'
                  'Aguarde um pouco e tente novamente\n'
                  'Caso o problema persista entre em contato com o suporte.\n',
              onRetry: onRetry),
          barrierDismissible: false,
        ).whenComplete(() => onError);
      } else {
        showDialog<void>(
          context: context,
          builder: (context) => ErrorDialog(
              errorMessage: 'Erro desconhecido na conexão com o servidor\n'
                  'Verifique sua conexão com a internet e tente novamente\n'
                  'Detalhes do Erro $error \n',
              onRetry: onRetry),
          barrierDismissible: false,
        ).whenComplete(() => onError);
      }
    }
  } else if (error is SocketException) {
    showDialog<void>(
      context: context,
      builder: (context) => ErrorDialog(
          errorMessage: 'Falha ao conectar-se ao servidor\n'
              'Verifique sua conexão com a internet e tente novamente\n',
          onRetry: onRetry),
      barrierDismissible: false,
    ).whenComplete(() => onError);
  } else if (error is UiException) {
    error.callDialog(context, onRetry: onRetry, onSuccess: onSuccess).whenComplete(() => onError);
  } else {
    showDialog<void>(
      context: context,
      builder: (context) => ErrorDialog(
          errorMessage: 'Falha ao executar a ação\n'
              'Erro: $error\n',
          onRetry: onRetry),
      barrierDismissible: false,
    ).whenComplete(() => onError);
  }
}
