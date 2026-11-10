import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/navigation/app_router.dart';
import 'package:flutter_app/common/component/custom_app_bar.dart';
import 'package:flutter_app/features/profile/profile_page_content.dart';


@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile'),
      body: SafeArea(
        child: ProfilePageContent(
          onSignedOut: () async {
            if (context.mounted) {
              await context.router.root.replaceAll([const LandingRoute()]);
            }
          },
        ),
      ),
    );
  }
}
