import 'package:metrics/features/dashboard/domain/entities/core/build.dart';
import 'package:metrics/features/dashboard/domain/entities/core/project.dart';

/// Base class for metrics repositories.
///
/// Provides an ability to get the data.
abstract class MetricsRepository {
  /// Provides the stream of [Project]s.
  Stream<List<Project>> projectsStream();

  /// Provides the stream of [Build]s of the project with [projectId] limited by [limit] elements.
  Stream<List<Build>> latestProjectBuildsStream(String projectId, int limit);

  /// Provides the stream of [Build]s of the project with [projectId] starting [from] date.
  Stream<List<Build>> projectBuildsFromDateStream(
    String projectId,
    DateTime from,
  );
}
