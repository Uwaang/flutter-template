import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/navigation/app_router.dart';

class EventsPageContent extends StatelessWidget {
  const EventsPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Explore a sample route', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'A simple Material 3 list item demonstrates navigation without '
                'pretending there is a live event feed.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Card.outlined(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Icon(Icons.event_outlined, color: theme.colorScheme.onSecondaryContainer),
                  ),
                  title: const Text('Event Detail'),
                  subtitle: const Text('Open the AutoRoute detail example'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.pushRoute(const EventDetailRoute()),
                ),
              ),
              const SizedBox(height: 20),
              Card.filled(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This is sample UI only. No events database or CRUD API is configured.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
