import 'package:flutter/material.dart';
import 'package:flutter_app/common/composition/dialog/custom_dialog.dart';
import 'package:flutter_app/common/composition/responsive_widget.dart';
import 'package:flutter_app/common/extension/build_context.dart';

class DebugToolsListDialog {
  DebugToolsListDialog({
    required this.context,
    required this.title,
    required this.list,
    required this.onItemSelect,
  });

  final BuildContext context;
  final String title;
  final List<String> list;
  final ValueChanged<String> onItemSelect;

  Future<bool?> show() async {
    return CustomDialog.custom(
      context: context,
      title: title,
      content: SizedBox(
        width: ResponsiveWidget.mediumSizeThreshold,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: list.length,
          separatorBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(8),
            child: Container(height: 1, color: context.colorScheme.divider),
          ),
          itemBuilder: (context, index) {
            final item = list[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              title: Text(item, style: context.textTheme.bodyMedium),
              onTap: () {
                onItemSelect(item);
                Navigator.of(context).pop(true);
              },
            );
          },
        ),
      ),
    ).show();
  }
}
