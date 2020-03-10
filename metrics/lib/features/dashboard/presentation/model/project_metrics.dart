import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:metrics/features/dashboard/presentation/model/build_result_bar_data.dart';

/// Represents the metrics of the project.
@immutable
class ProjectMetrics {
  final String projectId;
  final String projectName;
  final double coverage;
  final double stability;
  final int numberOfBuilds;
  final int averageBuildDuration;
  final List<Point<int>> performanceMetrics;
  final List<Point<int>> buildNumberMetrics;
  final List<BuildResultBarData> buildResultMetrics;

  /// Creates the [ProjectMetrics].
  ///
  /// [projectId] - id of the project these metrics belong to.
  /// [projectName] is the name of the project these metrics belongs to.
  /// [coverage] is the tests code coverage of the project.
  /// [stability] is the percentage of the successful builds to total builds of the project.
  /// [numberOfBuilds] is the number of builds the [buildNumberMetrics] are based on.
  /// [averageBuildDuration] is the average duration of the single build.
  /// [performanceMetrics] is metric that represents the duration of the builds.
  /// [buildNumberMetrics] is the metric that represents the number of builds during some period of time.
  /// [buildResultMetrics] is the metric that represents the results of the builds.
  const ProjectMetrics({
    this.projectId,
    this.projectName,
    this.coverage,
    this.stability,
    this.numberOfBuilds,
    this.averageBuildDuration,
    this.performanceMetrics,
    this.buildNumberMetrics,
    this.buildResultMetrics,
  });

  /// Creates a copy of this project metrics but with the given fields replaced with the new values.
  ProjectMetrics copyWith({
    String projectId,
    String projectName,
    double coverage,
    double stability,
    int numberOfBuilds,
    int averageBuildDuration,
    List<Point<int>> performanceMetrics,
    List<Point<int>> buildNumberMetrics,
    List<BuildResultBarData> buildResultMetrics,
  }) {
    return ProjectMetrics(
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      coverage: coverage ?? this.coverage,
      stability: stability ?? this.stability,
      numberOfBuilds: numberOfBuilds ?? this.numberOfBuilds,
      averageBuildDuration: averageBuildDuration ?? this.averageBuildDuration,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      buildNumberMetrics: buildNumberMetrics ?? this.buildNumberMetrics,
      buildResultMetrics: buildResultMetrics ?? this.buildResultMetrics,
    );
  }
}
