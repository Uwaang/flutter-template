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
          const SizedBox(height: 48),
          const Material3InteractionSamples(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Two native Material 3 controls with local state, not mock backend data.
class Material3InteractionSamples extends StatefulWidget {
  const Material3InteractionSamples({super.key});

  @override
  State<Material3InteractionSamples> createState() => _Material3InteractionSamplesState();
}

class _Material3InteractionSamplesState extends State<Material3InteractionSamples> {
  static const _examples = <String, String>{
    'Buttons': 'Use FilledButton, OutlinedButton and TextButton for actions.',
    'Inputs': 'Use TextFormField and InputDecoration for forms.',
    'Feedback': 'Use SnackBar, Dialog and progress indicators for feedback.',
  };

  final _selectedCategories = <String>{..._examples.keys};
  bool _showCards = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Material 3 interactions', style: theme.textTheme.headlineLarge),
        const SizedBox(height: 8),
        const Text('Filter the local examples and switch their layout. No API or database is involved.'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in _examples.keys)
              FilterChip(
                label: Text(category),
                selected: _selectedCategories.contains(category),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(value: true, label: Text('Cards'), icon: Icon(Icons.grid_view_outlined)),
            ButtonSegment<bool>(value: false, label: Text('List'), icon: Icon(Icons.view_list_outlined)),
          ],
          selected: {_showCards},
          onSelectionChanged: (selection) => setState(() => _showCards = selection.first),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final visible = _examples.entries.where((item) => _selectedCategories.contains(item.key)).toList();
            if (visible.isEmpty) {
              return const Card.filled(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No examples selected. Choose a category above.'),
                ),
              );
            }

            if (!_showCards) {
              return Column(
                key: const Key('sample_list_preview'),
                children: [
                  for (final item in visible)
                    ListTile(
                      leading: const Icon(Icons.widgets_outlined),
                      title: Text('${item.key} example'),
                      subtitle: Text(item.value),
                    ),
                ],
              );
            }

            final cardWidth = constraints.maxWidth >= 600 ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
            return Wrap(
              key: const Key('sample_card_preview'),
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final item in visible)
                  SizedBox(
                    width: cardWidth,
                    child: Card.outlined(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${item.key} example', style: theme.textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(item.value),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
