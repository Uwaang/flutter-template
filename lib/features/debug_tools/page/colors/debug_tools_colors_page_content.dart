import 'package:flutter/material.dart';
import 'package:flutter_app/app/theme/app_theme.dart';
import 'package:flutter_app/features/debug_tools/page/colors/entity/debug_tools_color.dart';

class DebugToolsColorsPageContent extends StatelessWidget {
  const DebugToolsColorsPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final lightTheme = currentTheme.brightness == Brightness.light ? currentTheme : AppTheme.getThemeData(brightness: Brightness.light);
    final darkTheme = currentTheme.brightness == Brightness.dark ? currentTheme : AppTheme.getThemeData(brightness: Brightness.dark);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Light mode', style: currentTheme.textTheme.headlineLarge),
        const SizedBox(height: 20),
        _ColorGrid(colors: DebugToolsColor.getColors(theme: lightTheme)),
        const SizedBox(height: 40),
        Text('Dark mode', style: currentTheme.textTheme.headlineLarge),
        const SizedBox(height: 20),
        _ColorGrid(colors: DebugToolsColor.getColors(theme: darkTheme)),
      ],
    );
  }
}

class _ColorGrid extends StatelessWidget {
  const _ColorGrid({required this.colors});

  final List<DebugToolsColor> colors;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.5,
          ),
          itemCount: colors.length,
          itemBuilder: (context, index) {
            final sample = colors[index];
            final foreground = sample.color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
            return DecoratedBox(
              decoration: BoxDecoration(
                color: sample.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: foreground.withValues(alpha: 0.4)),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    sample.colorName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
