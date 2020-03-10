import 'dart:async';
import 'dart:math';

import 'package:metrics/features/dashboard/domain/entities/build_metrics.dart';
import 'package:metrics/features/dashboard/domain/entities/build_number_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/build_result_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/performance_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/project.dart';
import 'package:metrics/features/dashboard/domain/usecases/parameters/project_id_param.dart';
import 'package:metrics/features/dashboard/domain/usecases/receive_build_metrics_updates.dart';
import 'package:metrics/features/dashboard/domain/usecases/receive_poject_updates.dart';
import 'package:metrics/features/dashboard/presentation/model/build_result_bar_data.dart';
import 'package:metrics/features/dashboard/presentation/model/project_metrics.dart';
import 'package:rxdart/rxdart.dart';

/// The store for the project metrics.
///
/// Stores the [Project]s and its [BuildMetrics].
class ProjectMetricsStore {
  final ReceiveProjectUpdates _receiveProjectsUpdates;
  final ReceiveBuildMetricsUpdates _receiveBuildMetricsUpdates;
  final Map<String, StreamSubscription> _buildMetricsSubscriptions = {};
  final BehaviorSubject<Map<String, ProjectMetrics>> _projectsMetricsSubject =
      BehaviorSubject();

  StreamSubscription _projectsSubscription;

  /// Creates the project metrics store.
  ///
  /// The provided use cases should not be null.
  ProjectMetricsStore(
    this._receiveProjectsUpdates,
    this._receiveBuildMetricsUpdates,
  ) : assert(
          _receiveProjectsUpdates != null &&
              _receiveBuildMetricsUpdates != null,
          'The use cases should not be null',
        );

  Stream<List<ProjectMetrics>> get projectsMetrics =>
      _projectsMetricsSubject.map((metricsMap) => metricsMap.values.toList());

  /// Subscribes to projects and its metrics.
  Future<void> subscribeToProjects() async {
    final projectsStream = _receiveProjectsUpdates();
    await _projectsSubscription?.cancel();

    _projectsSubscription = projectsStream.listen(_projectsListener);
  }

  /// Listens to project updates.
  void _projectsListener(List<Project> newProjects) {
    if (newProjects == null || newProjects.isEmpty) {
      _projectsMetricsSubject.add({});
      return;
    }

    final projectsMetrics = _projectsMetricsSubject.value ?? {};

    final projectIds = newProjects.map((project) => project.id);
    projectsMetrics.removeWhere((projectId, value) {
      final remove = !projectIds.contains(projectId);
      if (remove) {
        _buildMetricsSubscriptions.remove(projectId)?.cancel();
      }

      return remove;
    });

    for (final project in newProjects) {
      final projectId = project.id;

      ProjectMetrics projectMetrics =
          projectsMetrics[projectId] ?? const ProjectMetrics();

      if (projectMetrics.projectName != project.name) {
        projectMetrics = projectMetrics.copyWith(
          projectName: project.name,
        );
      }

      if (!projectsMetrics.containsKey(projectId)) {
        _subscribeToBuildMetrics(projectId);
      }
      projectsMetrics[projectId] = projectMetrics;
    }

    _projectsMetricsSubject.add(projectsMetrics);
  }

  /// Subscribes to project metrics.
  void _subscribeToBuildMetrics(String projectId) {
    final buildMetricsStream = _receiveBuildMetricsUpdates(
      ProjectIdParam(projectId),
    );

    // We are storing subscriptions to map to cancel them later,
    // but the analyzer can't handle this, so we should add this ignoring.
    // ignore: cancel_subscriptions
    final metricsSubscription = buildMetricsStream.listen((metrics) {
      _createBuildMetrics(metrics, projectId);
    });

    _buildMetricsSubscriptions[projectId] = metricsSubscription;
  }

  /// Create project metrics form [BuildMetrics].
  void _createBuildMetrics(BuildMetrics buildMetrics, String projectId) {
    final projectsMetrics = _projectsMetricsSubject.value;

    final projectMetrics = projectsMetrics[projectId];

    if (projectMetrics == null || buildMetrics == null) return;

    final performanceMetrics = _getPerformanceMetrics(
      buildMetrics.performanceMetrics,
    );
    final buildNumberMetrics = _getBuildNumberMetrics(
      buildMetrics.buildNumberMetrics,
    );
    final buildResultMetrics = _getBuildResultMetrics(
      buildMetrics.buildResultMetrics,
    );
    final averageBuildDuration =
        buildMetrics.performanceMetrics.averageBuildDuration.inMinutes;
    final numberOfBuilds = buildMetrics.buildNumberMetrics.totalNumberOfBuilds;

    projectsMetrics[projectId] = projectMetrics.copyWith(
      performanceMetrics: performanceMetrics,
      buildNumberMetrics: buildNumberMetrics,
      buildResultMetrics: buildResultMetrics,
      numberOfBuilds: numberOfBuilds,
      averageBuildDuration: averageBuildDuration,
      coverage: buildMetrics.coverage,
      stability: buildMetrics.stability,
    );

    _projectsMetricsSubject.add(projectsMetrics);
  }

  /// Creates the project build number metrics from [BuildNumberMetric].
  List<Point<int>> _getBuildNumberMetrics(BuildNumberMetric metric) {
    final buildNumberMetrics = metric?.buildsPerDate ?? [];

    if (buildNumberMetrics.isEmpty) {
      return [];
    }

    final buildNumberPoints = buildNumberMetrics.map((metric) {
      return Point(
        metric.date.millisecondsSinceEpoch,
        metric.numberOfBuilds,
      );
    }).toList();

    return buildNumberPoints;
  }

  /// Creates the project performance metrics from [PerformanceMetric].
  List<Point<int>> _getPerformanceMetrics(PerformanceMetric metric) {
    final performanceMetrics = metric?.buildsPerformance ?? [];

    if (performanceMetrics.isEmpty) {
      return [];
    }

    return performanceMetrics.map((metric) {
      return Point(
        metric.date.millisecondsSinceEpoch,
        metric.duration.inMilliseconds,
      );
    }).toList();
  }

  /// Creates the project build result metrics from [BuildResultsMetric].
  List<BuildResultBarData> _getBuildResultMetrics(BuildResultsMetric metrics) {
    final buildResults = metrics?.buildResults ?? [];

    if (buildResults.isEmpty) {
      return [];
    }

    return buildResults.map((result) {
      return BuildResultBarData(
        url: result.url,
        result: result.result,
        value: result.duration.inMilliseconds,
      );
    }).toList();
  }

  /// Cancels all created subscriptions.
  void dispose() {
    _projectsSubscription?.cancel();
    for (final subscription in _buildMetricsSubscriptions.values) {
      subscription?.cancel();
    }
    _buildMetricsSubscriptions.clear();
  }
}
