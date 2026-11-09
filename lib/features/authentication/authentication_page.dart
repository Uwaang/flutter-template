import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/navigation/app_router.dart';
import 'package:flutter_app/common/component/custom_app_bar.dart';
import 'package:flutter_app/core/flogger.dart';
import 'package:flutter_app/core/supabase/supabase_service.dart';
import 'package:flutter_app/features/authentication/authentication_event.dart';
import 'package:flutter_app/features/authentication/authentication_page_content.dart';
import 'package:flutter_app/features/authentication/authentication_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@RoutePage()
class AuthenticationPage extends ConsumerStatefulWidget {
  const AuthenticationPage({super.key});

  @override
  ConsumerState<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends ConsumerState<AuthenticationPage> {
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    if (SupabaseService.isConfigured) {
      _authStateSubscription = SupabaseService.client.auth.onAuthStateChange.listen(
        (state) {
          if (!mounted) return;
          // A restored expired session may become valid after background refresh.
          if ((state.event == AuthChangeEvent.signedIn || state.event == AuthChangeEvent.tokenRefreshed) &&
              state.session != null &&
              !state.session!.isExpired) {
            ref.read(authenticationStateProvider.notifier).completeSupabaseSignIn();
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          // Auth refresh failures (e.g. offline) surface as stream errors.
          // They should be reported, never crash the app's event zone.
          Flogger.e('[Authentication] Auth state stream error: $error', exception: error, stackTrace: stackTrace);
        },
      );
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      authenticationEventNotifierProvider,
      (_, next) => next?.when(
        signedIn: () => context.router.replaceAll([const LandingRoute()]),
        error: (error) => error.showErrorSnackbar(context: context),
      ),
    );

    return const Scaffold(
      appBar: CustomAppBar(title: 'Authentication'),
      body: SafeArea(child: AuthenticationPageContent()),
    );
  }
}
