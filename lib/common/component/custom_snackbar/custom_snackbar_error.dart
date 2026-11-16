import 'package:flutter_app/common/component/custom_snackbar/app_snackbar.dart';

/// Semantic convenience API; shared presentation lives in AppSnackbar.
class CustomSnackbarError extends AppSnackbar {
  CustomSnackbarError({
    required super.context,
    required super.message,
    super.optionalBottomSpacing,
  }) : super(kind: AppSnackbarKind.error);
}
