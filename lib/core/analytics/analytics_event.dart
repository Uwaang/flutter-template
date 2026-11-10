import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_event.freezed.dart';

@freezed
sealed class AnalyticsEvent with _$AnalyticsEvent {
  factory AnalyticsEvent({
    required String eventId,
    Map<String, String>? eventParams,
  }) = _AnalyticsEvent;

  factory AnalyticsEvent.onSampleEvent() => AnalyticsEvent(eventId: 'on_sample_event');
  factory AnalyticsEvent.onAnotherSampleEvent({required String sampleParamValue}) => AnalyticsEvent(
    eventId: 'on_another_sample_event',
    eventParams: {'sample_parameter_id': sampleParamValue},
  );
}
