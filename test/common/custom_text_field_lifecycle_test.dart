import 'package:flutter/material.dart';
import 'package:flutter_app/app/configuration/configuration.dart';
import 'package:flutter_app/app/setup/flavor.dart';
import 'package:flutter_app/common/component/custom_text_field.dart';
import 'package:flutter_app/common/validator/text_field_validator_state.dart';
import 'package:flutter_app/common/validator/text_validator_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _TrackingValidator extends TextValidatorController {
  int added = 0;
  int removed = 0;

  @override
  TextFieldValidatorState get state => const TextFieldValidatorState.initial();

  @override
  Future<void> validate() async {}

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    added++;
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    removed++;
  }
}

void main() {
  Configuration.setup(flavor: Flavor.develop);

  testWidgets('CustomTextField detaches and reattaches validator listeners', (
    tester,
  ) async {
    final initial = _TrackingValidator();
    final replacement = _TrackingValidator();

    Widget fieldFor(_TrackingValidator validator) => MaterialApp(
      home: Scaffold(
        body: CustomTextField(validatorController: validator),
      ),
    );

    try {
      await tester.pumpWidget(fieldFor(initial));
      expect(initial.added, 1);
      expect(initial.removed, 0);

      await tester.pumpWidget(fieldFor(replacement));
      expect(initial.removed, 1);
      expect(replacement.added, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      expect(replacement.removed, 1);
    } finally {
      initial.dispose();
      replacement.dispose();
    }
  });
}
