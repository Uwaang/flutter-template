import 'package:flutter/material.dart';
import 'package:flutter_app/common/component/custom_button/custom_button_primary.dart';
import 'package:flutter_app/common/component/custom_snackbar/custom_snackbar_message.dart';
import 'package:flutter_app/common/component/custom_text/custom_text.dart';
import 'package:flutter_app/common/component/custom_text_field.dart';
import 'package:flutter_app/common/extension/async_value.dart';
import 'package:flutter_app/common/extension/build_context.dart';
import 'package:flutter_app/features/debug_tools/page/widgets/debug_tools_widgets_page_event.dart';
import 'package:flutter_app/features/debug_tools/page/widgets/debug_tools_widgets_page_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebugToolsWidgetsPageContent extends ConsumerWidget {
  const DebugToolsWidgetsPageContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(debugToolsWidgetsPageStateProvider);

    ref.listen(
      debugToolsWidgetsPageEventNotifierProvider,
      (_, next) => next?.when(
        fieldValidated: (message) => CustomSnackbarMessage(
          context: context,
          message: message,
        ).show(),
        error: (error) => error.showErrorSnackbar(context: context),
      ),
    );

    return state.mapContentState(
      provider: debugToolsWidgetsPageStateProvider,
      data: (data) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CustomText(text: 'Custom Buttons', style: context.textTheme.headlineLarge),
          const SizedBox(height: 20),
          CustomButtonPrimary(text: 'Primary', onPressed: () {}),
          const SizedBox(height: 64),
          CustomText(text: 'CustomTextField', style: context.textTheme.headlineLarge),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Example of custom text field',
            validatorController: ref.read(debugToolsWidgetsPageStateProvider.notifier).exampleTextController,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 20),
          CustomButtonPrimary(
            onPressed: () => ref.read(debugToolsWidgetsPageStateProvider.notifier).validateSampleTextField(),
            text: 'Validate text field',
          ),
          const SizedBox(height: 64),
          CustomText(text: 'Material 3 radio group', style: context.textTheme.headlineLarge),
          const SizedBox(height: 16),
          RadioGroup<String>(
            groupValue: data.selectedOption,
            onChanged: (value) {
              if (value != null) {
                ref.read(debugToolsWidgetsPageStateProvider.notifier).onOptionChanged(value);
              }
            },
            child: const Column(
              children: [
                RadioListTile<String>(value: 'First', title: Text('First')),
                RadioListTile<String>(value: 'Second', title: Text('Second')),
                RadioListTile<String>(value: 'Third', title: Text('Third')),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
