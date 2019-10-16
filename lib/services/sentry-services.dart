import 'package:sentry/sentry.dart';

final SentryClient sentry = new SentryClient(dsn: "https://83ee630432cd4633ac187ef159196b35@sentry.io/1781096");

class SentryError {

  Future<Null> reportError(dynamic error, dynamic stackTrace) async {
    print('Caught error: $error');

    print('Reporting to Sentry.io...');

    final SentryResponse response = await sentry.captureException(
      exception: error,
      stackTrace: stackTrace,
    );

    if (response.isSuccessful) {
      print('Success! Event ID: ${response.eventId}');
    } else {
      print('Failed to report to Sentry.io: ${response.error}');
    }
  }

}