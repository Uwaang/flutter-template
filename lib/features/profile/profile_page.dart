import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/navigation/app_router.dart';
import 'package:flutter_app/common/component/custom_app_bar.dart';
import 'package:flutter_app/core/supabase/supabase_service.dart';
import 'package:flutter_app/features/profile/profile_page_content.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    if (SupabaseService.isConfigured) {
      // GoTrue emits signedOut after clearing the SDK session. Navigate on
      // that authoritative event even if a subsequent local cache update
      // prevents the profile button's async callback from completing.
      _authSubscription = SupabaseService.client.auth.onAuthStateChange.listen((state) {
        if (mounted && state.event == AuthChangeEvent.signedOut) {
          context.router.root.replaceAll([const AuthenticationRoute()]);
        }
      });
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile'),
      body: SafeArea(
        child: ProfilePageContent(
          onSignedOut: () async {
            if (mounted) {
              await context.router.root.replaceAll([const AuthenticationRoute()]);
            }
          },
        ),
      ),
    );
  }
}
