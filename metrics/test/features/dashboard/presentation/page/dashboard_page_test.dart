import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics/features/common/presentation/drawer/widget/metrics_drawer.dart';
import 'package:metrics/features/common/presentation/metrics_theme/store/theme_store.dart';
import 'package:metrics/features/common/presentation/metrics_theme/widgets/metrics_theme_builder.dart';
import 'package:metrics/features/dashboard/presentation/model/project_metrics.dart';
import 'package:metrics/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:metrics/features/dashboard/presentation/state/project_metrics_store.dart';
import 'package:metrics/features/dashboard/presentation/strings/dashboard_strings.dart';
import 'package:metrics/features/dashboard/presentation/widgets/circle_percentage.dart';
import 'package:metrics/features/dashboard/presentation/widgets/sparkline_graph.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  group("Dashboard configuration", () {
    testWidgets(
      "Contains Circle percentage with coverage and stability",
      (WidgetTester tester) async {
        await tester.pumpWidget(const DashboardTestbed());
        await tester.pumpAndSettle();

        expect(
          find.descendant(
              of: find.byType(CirclePercentage),
              matching: find.text(DashboardStrings.coverage)),
          findsOneWidget,
        );
        expect(
          find.descendant(
              of: find.byType(CirclePercentage),
              matching: find.text(DashboardStrings.stability)),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Contains SparklineGraph widgets with performance and build metrics',
      (WidgetTester tester) async {
        await tester.pumpWidget(const DashboardTestbed());
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byType(SparklineGraph),
            matching: find.text(DashboardStrings.performance),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(SparklineGraph),
            matching: find.text(DashboardStrings.builds),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      "Displays an error, occured during loading the metrics data",
      (WidgetTester tester) async {
        const metricsStore = MetricsStoreErrorStub();

        await tester.pumpWidget(const DashboardTestbed(
          metricsStore: metricsStore,
        ));

        await tester.pumpAndSettle();

        expect(
          find.text(DashboardStrings.getLoadingErrorMessage(
              '${MetricsStoreErrorStub.errorMessage}')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      "Displays the drawer on tap on menu button",
      (WidgetTester tester) async {
        await tester.pumpWidget(const DashboardTestbed());
        await tester.pumpAndSettle();

        await tester.tap(find.descendant(
          of: find.byType(AppBar),
          matching: find.byType(IconButton),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(MetricsDrawer), findsOneWidget);
      },
    );

    testWidgets(
      "Changes the widget theme on switching theme in the drawer",
      (WidgetTester tester) async {
        final themeStore = ThemeStore();

        await tester.pumpWidget(DashboardTestbed(
          themeStore: themeStore,
        ));
        await tester.pumpAndSettle();

        final circlePercentageTitleColor =
            _getCirclePercentageTitleColor(tester);

        await tester.tap(find.descendant(
          of: find.byType(AppBar),
          matching: find.byType(IconButton),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(CheckboxListTile));
        await tester.pump();

        final newCirclePercentageTitleColor =
            _getCirclePercentageTitleColor(tester);

        expect(
          newCirclePercentageTitleColor,
          isNot(circlePercentageTitleColor),
        );
      },
    );
  });
}

Color _getCirclePercentageTitleColor(WidgetTester tester) {
  final circlePercentageFinder = find.descendant(
    of: find.widgetWithText(CirclePercentage, DashboardStrings.coverage),
    matching: find.text(DashboardStrings.coverage),
  );

  final titleWidget = tester.widget<Text>(
    circlePercentageFinder,
  );

  return titleWidget.style?.color;
}

class DashboardTestbed extends StatelessWidget {
  final ProjectMetricsStore metricsStore;
  final ThemeStore themeStore;

  const DashboardTestbed({
    Key key,
    this.metricsStore = const MetricsStoreStub(),
    this.themeStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Injector(
        inject: [
          Inject<ProjectMetricsStore>(() => metricsStore),
          Inject<ThemeStore>(() => themeStore ?? ThemeStore()),
        ],
        initState: () {
          Injector.getAsReactive<ProjectMetricsStore>().setState(
            (store) => store.subscribeToProjects(),
            catchError: true,
          );
          Injector.getAsReactive<ThemeStore>()
              .setState((store) => store.isDark = false);
        },
        builder: (BuildContext context) => MetricsThemeBuilder(
          builder: (_, __) {
            return DashboardPage();
          },
        ),
      ),
    );
  }
}

class MetricsStoreStub implements ProjectMetricsStore {
  static const _projectMetrics = ProjectMetrics(
    projectId: '1',
    projectName: 'project',
    coverage: 0.4,
    stability: 0.7,
    numberOfBuilds: 1,
    averageBuildDuration: 1,
    performanceMetrics: [],
    buildResultMetrics: [],
    buildNumberMetrics: [],
  );

  const MetricsStoreStub();

  @override
  Stream<List<ProjectMetrics>> get projectsMetrics =>
      Stream.value([_projectMetrics]);

  @override
  Future<void> subscribeToProjects() async {}

  @override
  void dispose() {}
}

class MetricsStoreErrorStub extends MetricsStoreStub {
  static const String errorMessage = "Unknown error";

  const MetricsStoreErrorStub();

  @override
  Stream<List<ProjectMetrics>> get projectsMetrics => throw errorMessage;

  @override
  Future<void> subscribeToProjects() {
    throw errorMessage;
  }

  @override
  void dispose() {}
}
