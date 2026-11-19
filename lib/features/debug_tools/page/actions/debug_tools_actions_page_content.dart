import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app/common/component/custom_button/custom_button_primary.dart';
import 'package:flutter_app/common/component/custom_text/custom_text.dart';
import 'package:flutter_app/common/extension/build_context.dart';
import 'package:flutter_app/core/flogger.dart';
import 'package:flutter_app/features/debug_tools/debug_tools_page_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

class DebugToolsActionsPageContent extends ConsumerStatefulWidget {
  const DebugToolsActionsPageContent({super.key});

  @override
  ConsumerState<DebugToolsActionsPageContent> createState() => _DebugToolsActionsPageContentState();
}

class _DebugToolsActionsPageContentState extends ConsumerState<DebugToolsActionsPageContent> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CustomText(text: 'Component samples', style: context.textTheme.headlineLarge),
        const SizedBox(height: 8),
        const Text('Try the reusable widgets and native Material 3 examples below.'),
        const SizedBox(height: 20),
        ...getSamplesSectionList(context, ref),
        const SizedBox(height: 32),
        ExpansionTile(
          title: const Text('Developer tools'),
          subtitle: const Text('Logs, layout overlays and animation diagnostics'),
          childrenPadding: const EdgeInsets.only(bottom: 16),
          children: [
            CustomButtonPrimary(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => Theme(
                      data: ThemeData(colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey)),
                      child: TalkerScreen(
                        talker: Flogger.talker,
                        theme: const TalkerScreenTheme(
                          logColors: {'debug': Colors.green},
                        ),
                      ),
                    ),
                  ),
                );
              },
              text: 'Console Logs',
            ),
            const SizedBox(height: 16),
            ...getToolsSectionList(context, ref),
          ],
        ),
      ],
    );
  }

  List<Widget> getToolsSectionList(BuildContext context, WidgetRef ref) {
    return [
      SwitchListTile.adaptive(
        title: const Text('Show Layout Bounds'),
        value: debugPaintSizeEnabled,
        dense: true,
        onChanged: (value) => setState(() => debugPaintSizeEnabled = value),
      ),
      SwitchListTile.adaptive(
        title: const Text('Show Baselines'),
        value: debugPaintBaselinesEnabled,
        dense: true,
        onChanged: (value) => setState(() => debugPaintBaselinesEnabled = value),
      ),
      SwitchListTile.adaptive(
        title: const Text('Show Repaint'),
        value: debugRepaintRainbowEnabled,
        dense: true,
        onChanged: (value) => setState(() => debugRepaintRainbowEnabled = value),
      ),
      SwitchListTile.adaptive(
        title: const Text('Time Dilation'),
        value: timeDilation != 1,
        dense: true,
        onChanged: (value) => setState(() => timeDilation = value ? 6 : 1),
      ),
    ];
  }

  List<Widget> getSamplesSectionList(BuildContext context, WidgetRef ref) {
    return [
      CustomButtonPrimary(
        text: 'Widgets sample',
        onPressed: () => ref.read(debugToolsPageStateProvider.notifier).setAction(DebugToolsSampleType.widgets),
      ),
      const SizedBox(height: 16),
      CustomButtonPrimary(
        text: 'Popups sample',
        onPressed: () => ref.read(debugToolsPageStateProvider.notifier).setAction(DebugToolsSampleType.popups),
      ),
      const SizedBox(height: 16),
      CustomButtonPrimary(
        text: 'Colors sample',
        onPressed: () => ref.read(debugToolsPageStateProvider.notifier).setAction(DebugToolsSampleType.colors),
      ),
      const SizedBox(height: 16),
      CustomButtonPrimary(
        text: 'Text Styles sample',
        onPressed: () => ref.read(debugToolsPageStateProvider.notifier).setAction(DebugToolsSampleType.textStyles),
      ),
      const SizedBox(height: 16),
    ];
  }
}
