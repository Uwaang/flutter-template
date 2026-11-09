import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/common/component/custom_snackbar/custom_snackbar_error.dart';
import 'package:flutter_app/common/extension/build_context.dart';
import 'package:flutter_app/core/flogger.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'custom_exception.freezed.dart';

@freezed
sealed class CustomException with _$CustomException implements Exception {
  const CustomException._();

  const factory CustomException.general() = _General;
  const factory CustomException.withMessage({String? message}) = _WithMessage;
  const factory CustomException.unauthenticated() = _Unauthenticated;
  const factory CustomException.notConnectedToTheInternet() = _NotConnectedToTheInternet;
  const factory CustomException.decodingFailed() = _DecodingFailed;

  const factory CustomException.signInCancelled() = _SignInCancelled;

  factory CustomException.fromErrorObject({required Object? error}) {
    Flogger.e('[CustomException] Received error $error, ');

    if (error is CustomException) {
      return error;
    } else if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionError:
          return const CustomException.notConnectedToTheInternet();
        default:
          final data = error.response?.data;
          final statusCode = error.response?.statusCode;
          if (data is Map) {
            Flogger.e("[CustomException] error.response: ${data["errorCode"]}");
          }

          // Note: This is the place to handle your own error codes, response, or states, and map them to you own CustomException.

          if (statusCode == 401) {
            return const CustomException.unauthenticated();
          }

          return CustomException.withMessage(message: error.message);
      }
    } else if (error is AuthException) {
      if (error.message.toLowerCase().contains('cancel')) {
        return const CustomException.signInCancelled();
      }
      return CustomException.withMessage(message: error.message);
    } else if (error is StateError) {
      return CustomException.withMessage(message: error.message);
    } else {
      return const CustomException.general();
    }
  }

  String getMessage({required BuildContext context}) => maybeWhen(
    withMessage: (message) => message ?? context.locale.customExceptionGeneralMessage,
    unauthenticated: () => context.locale.customExceptionUnauthenticatedMessage,
    notConnectedToTheInternet: () => context.locale.customExceptionInternetConnectionMessage,
    orElse: () => context.locale.customExceptionGeneralMessage,
  );

  String getDetails({required BuildContext context}) => maybeWhen(
    notConnectedToTheInternet: () => context.locale.customExceptionInternetConnectionDetails,
    orElse: () => context.locale.customExceptionGeneralDetails,
  );

  Future<void> showErrorSnackbar({
    required BuildContext context,
    double optionalBottomSpacing = 0,
  }) async {
    await CustomSnackbarError(
      context: context,
      message: getMessage(context: context),
      optionalBottomSpacing: optionalBottomSpacing,
    ).show();
  }
}
