import 'package:rikit/features/activity/domain/activity_models.dart';

abstract interface class ActivityRepository {
  void record({
    required DateTime timestamp,
    required String tool,
    required ToolRunOutcome outcome,
    required int inputBytes,
    required int outputBytes,
  });

  ActivitySummary summary({required DateTime from, required DateTime through});

  void cleanUp({required DateTime now});
}
