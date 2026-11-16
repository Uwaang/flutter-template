import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/navigation/app_router.dart';
import 'package:flutter_app/core/supabase/supabase_service.dart';

@RoutePage()
class RootPage extends StatelessWidget {
  const RootPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // A direct browser deep link to /root-route must not bypass real Auth.
    // Supabase.initialize has restored persisted sessions before runApp.
    if (SupabaseService.isConfigured) {
      final session = SupabaseService.client.auth.currentSession;
      if (session == null || session.isExpired) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.router.replaceAll([const LandingRoute()]);
        });
        return const SizedBox.shrink();
      }
    }

    return AutoTabsRouter(
      routes: const [HomeRoute(), EventsRoute(), ProfileRoute()],
      homeIndex: 0,
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        // Use available layout width, not the current platform. This also
        // adapts when a desktop window or browser is resized at runtime.
        return LayoutBuilder(
          builder: (context, constraints) {
            final useRail = constraints.maxWidth >= 600;

            return Scaffold(
              body: useRail
                  ? Row(
                      children: [
                        SafeArea(
                          right: false,
                          child: NavigationRail(
                            selectedIndex: tabsRouter.activeIndex,
                            onDestinationSelected: tabsRouter.setActiveIndex,
                            labelType: NavigationRailLabelType.all,
                            destinations: const [
                              NavigationRailDestination(
                                icon: Icon(Icons.home_outlined),
                                selectedIcon: Icon(Icons.home),
                                label: Text('Home'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.event_outlined),
                                selectedIcon: Icon(Icons.event),
                                label: Text('Events'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.person_outline),
                                selectedIcon: Icon(Icons.person),
                                label: Text('Profile'),
                              ),
                            ],
                          ),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(child: child),
                      ],
                    )
                  : child,
              bottomNavigationBar: useRail
                  ? null
                  : NavigationBar(
                      selectedIndex: tabsRouter.activeIndex,
                      onDestinationSelected: tabsRouter.setActiveIndex,
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: 'Home',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.event_outlined),
                          selectedIcon: Icon(Icons.event),
                          label: 'Events',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.person_outline),
                          selectedIcon: Icon(Icons.person),
                          label: 'Profile',
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}
