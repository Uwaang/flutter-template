import 'package:flutter/material.dart';

/// Interactive Material 3 examples with local-only form and selection state.
/// The template intentionally does not require a custom validation framework.
class DebugToolsWidgetsPageContent extends StatefulWidget {
  const DebugToolsWidgetsPageContent({super.key});

  @override
  State<DebugToolsWidgetsPageContent> createState() => _DebugToolsWidgetsPageContentState();
}

class _DebugToolsWidgetsPageContentState extends State<DebugToolsWidgetsPageContent> {
  final _formKey = GlobalKey<FormState>();
  String _selectedOption = 'Second';

  void _validateName() {
    final valid = _formKey.currentState?.validate() ?? false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(valid ? 'Name is valid' : 'Please correct the name')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Material 3 buttons', style: theme.textTheme.headlineLarge),
        const SizedBox(height: 20),
        FilledButton(onPressed: () {}, child: const Text('Primary')),
        const SizedBox(height: 48),
        Text('Material 3 form', style: theme.textTheme.headlineLarge),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: TextFormField(
            key: const Key('debug_sample_name_field'),
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full name',
              helperText: 'At least 3 characters',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final name = value?.trim() ?? '';
              if (name.isEmpty) return 'Please enter a name.';
              if (name.length < 3) return 'Enter at least 3 characters.';
              if (name.length > 48) return 'Use 48 characters or fewer.';
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _validateName,
          child: const Text('Validate name'),
        ),
        const SizedBox(height: 48),
        Text('Material 3 radio group', style: theme.textTheme.headlineLarge),
        const SizedBox(height: 16),
        RadioGroup<String>(
          groupValue: _selectedOption,
          onChanged: (value) {
            if (value != null) setState(() => _selectedOption = value);
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
    );
  }
}

/// Native Material 3 controls with local state, not mock backend data.
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
