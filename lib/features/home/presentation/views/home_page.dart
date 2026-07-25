import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rikit/features/activity/domain/activity_models.dart';
import 'package:rikit/features/activity/domain/activity_repository.dart';
import 'package:rikit/features/home/presentation/fakes/fake_tool_catalog.dart';
import 'package:rikit/shared/presentation/page_header.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.repository, super.key});
  final ActivityRepository repository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ActivityRange range = ActivityRange.week;

  ActivitySummary get summary {
    final through = DateTime.now().toUtc();
    return widget.repository.summary(
      from: through.subtract(Duration(days: range.days - 1)),
      through: through,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activity = summary;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(36, 34, 36, 44),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                eyebrow: 'Workspace',
                title: 'Good tools. Zero friction.',
                description:
                    'Private activity insights from your local developer workspace.',
                trailing: _RangeSelector(
                  value: range,
                  onChanged: (value) => setState(() => range = value),
                ),
              ),
              const SizedBox(height: 34),
              _MetricGrid(summary: activity),
              const SizedBox(height: 26),
              LayoutBuilder(
                builder: (context, constraints) {
                  final chart = _ActivityCard(summary: activity, range: range);
                  final tools = _ToolPanel(summary: activity);
                  if (constraints.maxWidth < 860) {
                    return Column(
                      children: [chart, const SizedBox(height: 18), tools],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: chart),
                      const SizedBox(width: 18),
                      Expanded(flex: 4, child: tools),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.value, required this.onChanged});
  final ActivityRange value;
  final ValueChanged<ActivityRange> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(left: 11),
    decoration: BoxDecoration(
      color: RikitColors.surface,
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: RikitColors.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.calendar_today_rounded, size: 14),
        const SizedBox(width: 7),
        DropdownButton<ActivityRange>(
          key: const ValueKey('activity-range'),
          value: value,
          underline: const SizedBox.shrink(),
          onChanged: (next) {
            if (next != null) onChanged(next);
          },
          items: [
            for (final item in ActivityRange.values)
              DropdownMenuItem(value: item, child: Text(item.label)),
          ],
        ),
      ],
    ),
  );
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.summary});
  final ActivitySummary summary;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('Tool runs', '${summary.runs}', Icons.bolt_rounded),
      (
        'Successful',
        '${summary.successes}',
        Icons.check_circle_outline_rounded,
      ),
      (
        'Bytes processed',
        _bytes(summary.bytesProcessed),
        Icons.data_usage_rounded,
      ),
      ('Active tools', '${summary.activeTools}', Icons.widgets_outlined),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 720 ? 2 : 4;
        final width = (constraints.maxWidth - ((columns - 1) * 14)) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: width,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(17),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(metric.$3, size: 16, color: RikitColors.primary),
                        const SizedBox(height: 22),
                        Text(
                          metric.$2,
                          key: ValueKey('metric-${metric.$1}'),
                          style: const TextStyle(
                            color: RikitColors.text,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.7,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          metric.$1,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _bytes(int value) {
    if (value < 1024) return '$value B';
    if (value < 1024 * 1024) return '${(value / 1024).toStringAsFixed(1)} KB';
    return '${(value / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.summary, required this.range});
  final ActivitySummary summary;
  final ActivityRange range;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toUtc();
    final values = List<int>.generate(range.days, (index) {
      final day = DateTime.utc(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: range.days - index - 1));
      return summary.days
          .where(
            (item) =>
                item.day.year == day.year &&
                item.day.month == day.month &&
                item.day.day == day.day,
          )
          .fold(0, (total, item) => total + item.runs);
    });
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Runs across your developer toolkit',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 194,
              child: values.every((value) => value == 0)
                  ? const _EmptyActivity()
                  : CustomPaint(
                      key: const ValueKey('activity-chart'),
                      painter: _ActivityChartPainter(values),
                      size: Size.infinite,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _GridPainter(),
    child: const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.query_stats_rounded,
            color: RikitColors.textMuted,
            size: 25,
          ),
          SizedBox(height: 8),
          Text(
            'Format JSON to begin your activity history',
            style: TextStyle(color: RikitColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

class _ActivityChartPainter extends CustomPainter {
  const _ActivityChartPainter(this.values);
  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    _GridPainter().paint(canvas, size);
    final maximum = values.reduce((a, b) => a > b ? a : b);
    final path = Path();
    for (var index = 0; index < values.length; index++) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * index / (values.length - 1);
      final y =
          size.height - (values[index] / maximum * (size.height - 18)) - 8;
      index == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = RikitColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ActivityChartPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RikitColors.borderSubtle
      ..strokeWidth = 1;
    for (var index = 0; index < 5; index++) {
      final y = size.height * index / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ToolPanel extends StatelessWidget {
  const _ToolPanel({required this.summary});
  final ActivitySummary summary;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tools', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            '${summary.runs} runs in this range',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          for (final tool in FakeToolCatalog.tools)
            Material(
              color: RikitColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                key: ValueKey('tool-${tool.name}'),
                onTap: () => context.go(tool.route),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0x18FF4D5E),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          tool.icon,
                          color: RikitColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tool.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              tool.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: RikitColors.textMuted,
                        size: 17,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
