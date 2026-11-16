import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/common/extension/build_context.dart';
import 'package:flutter_app/features/home/home_page_content.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.locale.featureHomepageTitle)),
      body: const HomePageContent(),
    );
  }
}
