import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/navigation/app_router.dart';
import 'package:flutter_app/common/component/custom_app_bar.dart';
import 'package:flutter_app/common/provider/current_user_state.dart';
import 'package:flutter_app/features/profile/profile_page_content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observe the authoritative local user state, rather than a transient
    // auto-dispose navigation event. The sign-out UseCase clears this state
    // only after Supabase Auth has successfully signed out.
    ref.listen(currentUserStateProvider, (previous, next) {
      if (previous?.value != null && next.value == null) {
        context.router.root.replaceAll([const LandingRoute()]);
      }
    });

    return const Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
      ),
      body: SafeArea(
        child: ProfilePageContent(),
      ),
    );
  }
}
