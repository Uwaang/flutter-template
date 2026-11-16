import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/event_detail/event_detail_page_content.dart';

@RoutePage()
class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Detail')),
      body: const SafeArea(child: EventDetailPageContent()),
    );
  }
}
