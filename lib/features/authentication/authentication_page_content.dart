import 'package:flutter/material.dart';
import 'package:flutter_app/common/component/custom_button/custom_button_primary.dart';
import 'package:flutter_app/common/extension/async_value.dart';
import 'package:flutter_app/core/supabase/supabase_service.dart';
import 'package:flutter_app/features/authentication/authentication_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// UI-only switch. Override in widget tests without initializing a live SDK.
// Authentication actions still require an actual configured Supabase client.
final authBackendConfiguredProvider = Provider<bool>((ref) => SupabaseService.isConfigured);

class AuthenticationPageContent extends ConsumerWidget {
  const AuthenticationPageContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authenticationStateProvider);
    final backendConfigured = ref.watch(authBackendConfiguredProvider);

    return state.mapContentState(
      provider: authenticationStateProvider,
      data: (data) => _DataStateWidget(data: data, backendConfigured: backendConfigured),
    );
  }
}

class _DataStateWidget extends ConsumerWidget {
  const _DataStateWidget({required this.data, required this.backendConfigured});

  final AuthenticationState data;
  final bool backendConfigured;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Spacer(),
            if (!backendConfigured)
              CustomButtonPrimary(
                text: 'Mock Sign In',
                onPressed: () => ref.read(authenticationStateProvider.notifier).mockSignIn(),
              )
            else ...[
              CustomButtonPrimary(
                text: 'Sign in Anonymously',
                onPressed: () => ref.read(authenticationStateProvider.notifier).signInAnonymously(),
              ),
              const SizedBox(height: 24),
              CustomButtonPrimary(
                text: 'Sign in with Google',
                isLoading: data.isGoogleSigningIn,
                onPressed: () => ref.read(authenticationStateProvider.notifier).signInWithGoogle(),
              ),
              const SizedBox(height: 8),
              CustomButtonPrimary(
                text: 'Sign in with Apple',
                isLoading: data.isAppleSigningIn,
                onPressed: () => ref.read(authenticationStateProvider.notifier).signInWithApple(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
