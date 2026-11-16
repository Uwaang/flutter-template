import 'package:flutter/material.dart';
import 'package:flutter_app/common/component/custom_button/custom_button_primary.dart';
import 'package:flutter_app/common/component/custom_profile_avatar.dart';
import 'package:flutter_app/common/extension/async_value.dart';
import 'package:flutter_app/features/profile/profile_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePageContent extends ConsumerWidget {
  const ProfilePageContent({required this.onSignedOut, super.key});

  final Future<void> Function() onSignedOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileStateProvider);

    return state.mapContentState(
      provider: profileStateProvider,
      loading: (loading) => const Center(child: CircularProgressIndicator()),
      data: (data) => _ProfileOverview(data: data, onSignedOut: onSignedOut),
    );
  }
}

class _ProfileOverview extends ConsumerWidget {
  const _ProfileOverview({required this.data, required this.onSignedOut});

  final ProfileState data;
  final Future<void> Function() onSignedOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final displayName = data.displayName.trim().isEmpty ? 'Guest' : data.displayName;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card.filled(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    CustomProfileAvatar(imageUrl: data.imageUrl, size: 80),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName, style: theme.textTheme.headlineSmall),
                          const SizedBox(height: 4),
                          Text('Example profile', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text('Account', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            const Card.outlined(
              child: ListTile(
                leading: Icon(Icons.verified_user_outlined),
                title: Text('Authentication'),
                subtitle: Text('Supabase Auth when configured; otherwise a mock session.'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CustomButtonPrimary(
                text: 'Sign out',
                isLoading: data.isSigningOut,
                onPressed: () async {
                  final success = await ref.read(profileStateProvider.notifier).signOut();
                  if (success) await onSignedOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
