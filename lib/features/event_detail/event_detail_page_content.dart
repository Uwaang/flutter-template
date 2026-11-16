import 'package:flutter/material.dart';

class EventDetailPageContent extends StatelessWidget {
  const EventDetailPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card.filled(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.route_outlined, size: 40, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text('A detail route', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'This page shows a simple detail destination. Replace it with '
                      'your own data and feature content.',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
