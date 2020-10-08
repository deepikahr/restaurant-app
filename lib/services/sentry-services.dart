import 'dart:async';

import 'package:sentry/sentry.dart';

final SentryClient sentry = new SentryClient(
    dsn: "https://83ee630432cd4633ac187ef159196b35@sentry.io/1781096");

class SentryError {
  Future<Null> reportError(dynamic error, dynamic stackTrace) async {}
}
