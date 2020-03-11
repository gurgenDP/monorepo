import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:metrics/features/dashboard/domain/entities/core/percent.dart';
import 'package:metrics/features/dashboard/presentation/model/build_result_bar_data.dart';

/// Represents the metrics of the project.
@immutable
class ProjectMetricsData {
  final String projectId;
  final String projectName;
  final Percent coverage;
  final Percent stability;
  final int numberOfBuilds;
  final int averageBuildDurationInMinutes;
  final List<Point<int>> performanceMetrics;
  final List<Point<int>> buildNumberMetrics;
  final List<BuildResultBarData> buildResultMetrics;

  /// Creates the [ProjectMetricsData].
  ///
  /// [projectId] is the unique identifier of the project these metrics belong to.
  /// [projectName] is the name of the project these metrics belongs to.
  /// [coverage] is the tests code coverage of the project.
  /// [stability] is the percentage of the successful builds to total builds of the project.
  /// [numberOfBuilds] is the number of builds the [buildNumberMetrics] are based on.
  /// [averageBuildDurationInMinutes] is the average duration in minutes of the single build.
  /// [performanceMetrics] is metric that represents the duration of the builds.
  /// [buildNumberMetrics] is the metric that represents the number of builds during some period of time.
  /// [buildResultMetrics] is the metric that represents the results of the builds.
  const ProjectMetricsData({
    this.projectId,
    this.projectName,
    this.coverage,
    this.stability,
    this.numberOfBuilds,
    this.averageBuildDurationInMinutes,
    this.performanceMetrics,
    this.buildNumberMetrics,
    this.buildResultMetrics,
  });

  /// Creates a copy of this project metrics but with the given fields replaced with the new values.
  ProjectMetricsData copyWith({
    String projectId,
    String projectName,
    Percent coverage,
    Percent stability,
    int numberOfBuilds,
    int averageBuildDurationInMinutes,
    List<Point<int>> performanceMetrics,
    List<Point<int>> buildNumberMetrics,
    List<BuildResultBarData> buildResultMetrics,
  }) {
    return ProjectMetricsData(
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      coverage: coverage ?? this.coverage,
      stability: stability ?? this.stability,
      numberOfBuilds: numberOfBuilds ?? this.numberOfBuilds,
      averageBuildDurationInMinutes:
          averageBuildDurationInMinutes ?? this.averageBuildDurationInMinutes,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      buildNumberMetrics: buildNumberMetrics ?? this.buildNumberMetrics,
      buildResultMetrics: buildResultMetrics ?? this.buildResultMetrics,
    );
  }
}