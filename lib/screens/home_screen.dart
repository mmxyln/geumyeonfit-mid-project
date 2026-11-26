import 'package:flutter/material.dart';

import '../widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // STATE: S1 오늘 기록 수. 데모용 로컬 표시만 변경하며 저장하지 않음.
  int _todayCount = 8;
  static const int _todayTarget = 10;

  void _openQuickRecord() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // A-6 P07: 핵심 기록 동작을 한 번의 선택으로 끝낸다.
                Text(
                  '빠른 흡연 기록',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                const Text('데모 화면입니다. 실제 데이터는 저장되지 않습니다.'),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => _todayCount += 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('1개비를 화면에만 반영했습니다.')),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('1개비 기록'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_todayCount / _todayTarget).clamp(0.0, 1.0).toDouble();

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          final content = <Widget>[
            _TodaySummary(
              todayCount: _todayCount,
              target: _todayTarget,
              progress: progress,
              onQuickRecord: _openQuickRecord,
            ),
            const SizedBox(height: 16),
            const _InsightCard(),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '금연핏',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '기록은 빠르게, 변화는 한눈에',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const PTag('P01 · P07'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: content[0]),
                          const SizedBox(width: 16),
                          Expanded(child: content[2]),
                        ],
                      )
                    else
                      ...content,
                    const SizedBox(height: 20),
                    const SectionTitle('오늘 바로 확인할 것'),
                    const SizedBox(height: 12),
                    const _QuickInfoGrid(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TodaySummary extends StatelessWidget {
  const _TodaySummary({
    required this.todayCount,
    required this.target,
    required this.progress,
    required this.onQuickRecord,
  });

  final int todayCount;
  final int target;
  final double progress;
  final VoidCallback onQuickRecord;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A-1 P01: 현재 상태를 첫 화면에서 즉시 보여 준다.
            Row(
              children: [
                Expanded(
                  child: Text(
                    '오늘의 흡연 기록',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                Text('$todayCount / $target 개비'),
              ],
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(value: progress, minHeight: 10),
            const SizedBox(height: 10),
            Text(
              todayCount <= target
                  ? '목표 범위 안입니다. 기록을 이어 가세요.'
                  : '오늘 목표를 넘었습니다. 내일은 한 단계 낮춰 보세요.',
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                // A-2 P07: 홈에서 바로 기록한다.
                onPressed: onQuickRecord,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('빠른 기록'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: SectionTitle('이번 주 변화')),
                const PTag('P01'),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '지난주보다 하루 평균 1.4개비 감소',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              '단순히 “며칠 성공했는지”가 아니라, 실제 흡연량이 어떻게 변했는지 보여 줍니다.',
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Icon(Icons.trending_down),
                SizedBox(width: 8),
                Expanded(child: Text('최근 7일 평균 7.6개비')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickInfoGrid extends StatelessWidget {
  const _QuickInfoGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 650;
        final width = twoColumns ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;

        final cards = const [
          MetricCard(
            label: '이번 주 평균',
            value: '7.6개비',
            caption: '지난주 9.0개비',
            icon: Icons.calendar_view_week,
          ),
          MetricCard(
            label: '감량 목표',
            value: '하루 6개비',
            caption: '다음 단계까지 1.6개비',
            icon: Icons.flag_outlined,
          ),
        ];

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards.map((card) => SizedBox(width: width, child: card)).toList(),
        );
      },
    );
  }
}
