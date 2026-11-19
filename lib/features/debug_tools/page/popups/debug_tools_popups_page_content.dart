import 'package:flutter/material.dart';
import 'package:flutter_app/common/component/custom_snackbar/custom_snackbar_error.dart';
import 'package:flutter_app/common/component/custom_snackbar/custom_snackbar_message.dart';
import 'package:flutter_app/common/component/custom_snackbar/custom_snackbar_success.dart';
import 'package:flutter_app/core/flogger.dart';

/// Standard Material 3 dialogs, bottom sheets, pickers and feedback samples.
class DebugToolsPopupsPageContent extends StatelessWidget {
  const DebugToolsPopupsPageContent({super.key});

  Future<void> _confirmDeletion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete event'),
        content: const Text("Are you sure you want to delete this event? This action can't be recovered."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && context.mounted) {
      await CustomSnackbarMessage(context: context, message: 'Event deleted').show();
    }
  }

  Future<void> _showListDialog(BuildContext context) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('List dialog'),
        content: SizedBox(
          width: 420,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final item in const ['one', 'two', 'three', 'four', 'five'])
                ListTile(
                  title: Text(item),
                  onTap: () => Navigator.of(dialogContext).pop(item),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (selected != null && context.mounted) {
      await CustomSnackbarMessage(context: context, message: 'Clicked $selected').show();
    }
  }

  Future<void> _showBottomSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.viewInsetsOf(sheetContext).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Some scrollable content here', style: Theme.of(sheetContext).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Placeholder(fallbackHeight: 200),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Dialogs and sheets', style: theme.textTheme.headlineLarge),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => _confirmDeletion(context),
          child: const Text('Material 3 alert dialog'),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => _showListDialog(context),
          child: const Text('Material 3 list dialog'),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => _showBottomSheet(context),
          child: const Text('Material 3 bottom sheet'),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () async {
            final today = DateTime.now();
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: today,
              firstDate: today,
              lastDate: today.add(const Duration(days: 365)),
            );
            if (pickedDate != null) Flogger.d('Picked date: $pickedDate');
          },
          child: const Text('Material 3 Date Picker'),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () async {
            final pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (pickedTime != null) Flogger.d('Picked time: $pickedTime');
          },
          child: const Text('Material 3 Time Picker'),
        ),
        const SizedBox(height: 48),
        Text('Snackbars', style: theme.textTheme.headlineLarge),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => CustomSnackbarMessage(
            context: context,
            message: 'Example of message snackbar',
          ).show(),
          child: const Text('Show Message snackbar'),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => CustomSnackbarError(
            context: context,
            message: 'Example of error state widget',
          ).show(),
          child: const Text('Show Error snackbar'),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => CustomSnackbarSuccess(
            context: context,
            message: 'Example of confirmation widget',
          ).show(),
          child: const Text('Show Confirmation snackbar'),
        ),
      ],
    );
  }
}
