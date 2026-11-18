import 'package:flutter/material.dart';
import 'package:flutter_app/common/extension/async_value.dart';
import 'package:flutter_app/core/supabase/supabase_service.dart';
import 'package:flutter_app/features/authentication/authentication_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

// UI-only switch. Override in widget tests without initializing a live SDK.
// Authentication actions still require an actual configured Supabase client.
final authBackendConfiguredProvider = Provider<bool>(
  (ref) => SupabaseService.isConfigured,
);

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
    final theme = Theme.of(context);
    final oauthLoading = data.isGoogleSigningIn || data.isAppleSigningIn;

    return LayoutBuilder(
      builder: (context, viewport) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: viewport.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      backendConfigured ? 'Choose a sign-in method to continue.' : 'Explore the template with a mock session.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (!backendConfigured)
                      FilledButton(
                        key: const Key('auth_mock_button'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () => ref.read(authenticationStateProvider.notifier).mockSignIn(),
                        child: const Text('Mock Sign In'),
                      )
                    else ...[
                      FilledButton.icon(
                        key: const Key('auth_google_button'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: oauthLoading ? null : () => ref.read(authenticationStateProvider.notifier).signInWithGoogle(),
                        icon: data.isGoogleSigningIn
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : SvgPicture.asset(
                                'assets/svg/ic_google.svg',
                                width: 20,
                                height: 20,
                              ),
                        label: const Text('Sign in with Google'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        key: const Key('auth_apple_button'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: oauthLoading ? null : () => ref.read(authenticationStateProvider.notifier).signInWithApple(),
                        icon: data.isAppleSigningIn
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : SvgPicture.asset(
                                'assets/svg/ic_apple.svg',
                                width: 20,
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  theme.colorScheme.onSurface,
                                  BlendMode.srcIn,
                                ),
                              ),
                        label: const Text('Sign in with Apple'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('or', style: theme.textTheme.bodySmall),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        key: const Key('auth_anonymous_button'),
                        style: TextButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: oauthLoading ? null : () => ref.read(authenticationStateProvider.notifier).signInAnonymously(),
                        child: const Text('Sign in Anonymously'),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Social sign-in requires the corresponding Supabase provider to be enabled.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
