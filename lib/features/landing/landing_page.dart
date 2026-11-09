import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/navigation/app_router.dart';
import 'package:flutter_app/common/provider/current_user_state.dart';
import 'package:flutter_app/common/usecase/authentication/sign_in_completion_use_case.dart';
import 'package:flutter_app/core/flogger.dart';
import 'package:flutter_app/core/supabase/supabase_service.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleLandingPageNavigation());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox());
  }

  Future<void> _handleLandingPageNavigation() async {
    // The SDK restores its locally stored session during initialize().
    // Do not trust a cached mock profile when a real Supabase project is set.
    if (SupabaseService.isConfigured) {
      final session = SupabaseService.client.auth.currentSession;
      if (session == null || session.isExpired) {
        await ref.read(currentUserStateProvider.notifier).updateCurrentUser(null);
      } else {
        final user = await ref.read(signInCompletionUseCaseProvider.future);
        await ref.read(currentUserStateProvider.notifier).updateCurrentUser(user);
      }
    }

    final currentUser = await ref.read(currentUserStateProvider.future);
    if (!mounted) return;

    FlutterNativeSplash.remove();
    if (currentUser == null) {
      Flogger.d('[LandingPage] Redirecting to Authentication page');
      await context.replaceRoute(const AuthenticationRoute());
    } else {
      Flogger.d('[LandingPage] Redirecting to Root page');
      await context.replaceRoute(const RootRoute());
    }
  }
}
