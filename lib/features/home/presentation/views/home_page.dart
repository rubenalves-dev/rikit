import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rikit/features/home/presentation/fakes/fake_tool_catalog.dart';
import 'package:rikit/shared/presentation/page_header.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(36, 34, 36, 44),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                eyebrow: 'Workspace',
                title: 'Good tools. Zero friction.',
                description:
                    'Your private developer workspace, ready for the next task.',
                trailing: _DateRangePill(),
              ),
              const SizedBox(height: 34),
              const _MetricGrid(),
              const SizedBox(height: 26),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 860;
                  final chart = const _ActivityPreview();
                  final tools = const _ToolPanel();
                  return stacked
                      ? Column(
                          children: [chart, const SizedBox(height: 18), tools],
                        )
                      : const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: _ActivityPreview()),
                            SizedBox(width: 18),
                            Expanded(flex: 4, child: _ToolPanel()),
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

class _DateRangePill extends StatelessWidget {
  const _DateRangePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: RikitColors.surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: RikitColors.border),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_rounded, size: 14),
          SizedBox(width: 8),
          Text('This week', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid();

  @override
  Widget build(BuildContext context) {
    const metrics = [
      ('Tool runs', '0', Icons.bolt_rounded),
      ('Successful', '0', Icons.check_circle_outline_rounded),
      ('Bytes processed', '0 B', Icons.data_usage_rounded),
      ('Active tools', '1', Icons.widgets_outlined),
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
                child: _MetricCard(
                  label: metric.$1,
                  value: metric.$2,
                  icon: metric.$3,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: RikitColors.primary),
                const Spacer(),
                const Text(
                  '—',
                  style: TextStyle(color: RikitColors.textMuted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              value,
              style: const TextStyle(
                color: RikitColors.text,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ActivityPreview extends StatelessWidget {
  const _ActivityPreview();

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 34),
            const SizedBox(height: 190, child: _EmptyChart()),
          ],
        ),
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ChartPainter(),
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
              'Your activity will appear here',
              style: TextStyle(color: RikitColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = RikitColors.borderSubtle
      ..strokeWidth = 1;
    for (var index = 0; index < 5; index++) {
      final y = size.height * index / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final line = Paint()
      ..shader = const LinearGradient(
        colors: [RikitColors.primaryMuted, RikitColors.primary],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..moveTo(0, size.height * .78)
      ..cubicTo(
        size.width * .24,
        size.height * .76,
        size.width * .34,
        size.height * .54,
        size.width * .52,
        size.height * .58,
      )
      ..cubicTo(
        size.width * .7,
        size.height * .63,
        size.width * .82,
        size.height * .35,
        size.width,
        size.height * .31,
      );
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ToolPanel extends StatelessWidget {
  const _ToolPanel();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tools', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Ready when you are',
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
}
