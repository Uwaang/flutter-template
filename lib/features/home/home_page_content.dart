import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/navigation/app_router.dart';
import 'package:flutter_app/common/extension/build_context.dart';

/// A truthful starter landing page, not a fake production dashboard.
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Home',
                    key: const Key('home_title'),
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Card.filled(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.layers_outlined, size: 40, color: theme.colorScheme.primary),
                            const SizedBox(height: 20),
                            Text('Start with the essentials', style: theme.textTheme.headlineMedium),
                            const SizedBox(height: 8),
                            Text(
                              'An adaptable Flutter starter with navigation, theming, '
                              'state management and optional authentication.',
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () => context.pushRoute(const DebugToolsRoute()),
                              icon: const Icon(Icons.widgets_outlined),
                              label: Text(context.locale.featureHomepageOpenDebugTools),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('Included in the template', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Use these building blocks as a starting point for your own app.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = constraints.maxWidth >= 680 ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: const _FeatureCard(
                              icon: Icons.palette_outlined,
                              title: 'Material 3',
                              description: 'Native widgets and a shared light and dark theme.',
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: const _FeatureCard(
                              icon: Icons.view_sidebar_outlined,
                              title: 'Adaptive navigation',
                              description: 'Bottom navigation on phones, a rail on wider windows.',
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: const _FeatureCard(
                              icon: Icons.account_tree_outlined,
                              title: 'App architecture',
                              description: 'Riverpod state management and AutoRoute navigation.',
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: const _FeatureCard(
                              icon: Icons.lock_outline,
                              title: 'Optional authentication',
                              description: 'Supabase Auth when configured, mock sign-in for a demo.',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(icon, color: theme.colorScheme.onSecondaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
