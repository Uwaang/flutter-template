import 'package:flutter_app/common/data/entity/user_entity.dart';
import 'package:flutter_app/core/analytics/analytics_event.dart';
import 'package:flutter_app/core/flogger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_manager.g.dart';

// Intentionally no external analytics service in the Supabase-first template.
// Retain the existing Riverpod entrypoints for optional future adapters.
@riverpod
Future<void> analyticsManagerUpdateUserInfo(Ref ref, {required UserEntity? user}) async {}

@riverpod
Future<void> analyticsManagerLogScreenView(Ref ref, String screenName) async {
  Flogger.d('[Navigation] Screen: $screenName');
}

@riverpod
Future<void> analyticsManagerLogEvent(Ref ref, AnalyticsEvent event) async {
  Flogger.d('[Analytics] Local-only event: ${event.eventId}');
}
