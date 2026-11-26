import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../widgets.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  final ApiService _api = const ApiService();

  // STATE: S2 데모 상태 변경. 네트워크/빈/오류 UI 확인용이며 저장하지 않음.
  DemoState _demoState = DemoState.normal;
  late Future<List<SmokingRecord>> _future = _load();

  Future<List<SmokingRecord>> _load() {
    return _api.fetchRecords(demoState: _demoState);
  }

  void _reload() {
    setState(() => _future = _load());
  }

  void _changeState(DemoState value) {
    setState(() {
      _demoState = value;
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '흡연 추세',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    const PTag('P01 · P09'),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('json-server GET으로 최근 기록을 불러옵니다.'),
                const SizedBox(height: 14),
                _DemoStateSelector(
                  value: _demoState,
                  onChanged: _changeState,
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: FutureBuilder<List<SmokingRecord>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // C-1 P01: 로딩 상태를 명확히 보여 준다.
                        return const _LoadingView();
                      }

                      if (snapshot.hasError) {
                        // C-2 P09: 오류 이유와 다시 시도를 제공한다.
                        return _ErrorView(
                          message: snapshot.error.toString(),
                          onRetry: _reload,
                        );
                      }

                      final records = snapshot.data ?? const <SmokingRecord>[];
                      if (records.isEmpty) {
                        // C-3 P09: 빈 상태에서도 다음 행동을 알려 준다.
                        return const _EmptyView();
                      }

                      return _DataView(records: records);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoStateSelector extends StatelessWidget {
  const _DemoStateSelector({required this.value, required this.onChanged});

  final DemoState value;
  final ValueChanged<DemoState> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('정상'),
          selected: value == DemoState.normal,
          onSelected: (_) => onChanged(DemoState.normal),
        ),
        ChoiceChip(
          label: const Text('느린 로딩'),
          selected: value == DemoState.slow,
          onSelected: (_) => onChanged(DemoState.slow),
        ),
        ChoiceChip(
          label: const Text('오류'),
          selected: value == DemoState.error,
          onSelected: (_) => onChanged(DemoState.error),
        ),
        ChoiceChip(
          label: const Text('빈 상태'),
          selected: value == DemoState.empty,
          onSelected: (_) => onChanged(DemoState.empty),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 14),
          Text('최근 흡연 기록을 불러오는 중입니다.'),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 42),
                const SizedBox(height: 12),
                Text(
                  '기록을 불러오지 못했습니다.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 48),
          const SizedBox(height: 12),
          Text(
            '아직 기록이 없습니다.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          const Text('오늘 화면에서 첫 기록을 남겨 보세요.'),
        ],
      ),
    );
  }
}

class _DataView extends StatelessWidget {
  const _DataView({required this.records});

  final List<SmokingRecord> records;

  @override
  Widget build(BuildContext context) {
    final average = records.fold<int>(0, (sum, item) => sum + item.count) / records.length;
    final maxCount = records.map((e) => e.count).reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final chart = _Chart(records: records, maxCount: maxCount);
        final list = _RecordList(records: records);

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MetricCard(
                      label: '최근 평균',
                      value: '${average.toStringAsFixed(1)}개비',
                      caption: 'GET 데이터 기준',
                      icon: Icons.trending_down,
                    ),
                    const SizedBox(height: 14),
                    Expanded(child: chart),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: list),
            ],
          );
        }

        return ListView(
          children: [
            MetricCard(
              label: '최근 평균',
              value: '${average.toStringAsFixed(1)}개비',
              caption: 'GET 데이터 기준',
              icon: Icons.trending_down,
            ),
            const SizedBox(height: 14),
            SizedBox(height: 280, child: chart),
            const SizedBox(height: 14),
            SizedBox(height: 380, child: list),
          ],
        );
      },
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.records, required this.maxCount});

  final List<SmokingRecord> records;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('최근 기록'),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: records.map((record) {
                  final ratio = maxCount == 0 ? 0.0 : record.count / maxCount;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${record.count}'),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: ratio.clamp(0.08, 1.0).toDouble(),
                                widthFactor: 0.72,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(record.date.substring(5)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordList extends StatelessWidget {
  const _RecordList({required this.records});

  final List<SmokingRecord> records;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: records.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final record = records[index];
          final met = record.count <= record.target;
          return ListTile(
            leading: CircleAvatar(child: Text('${record.count}')),
            title: Text(record.date),
            subtitle: Text(record.note),
            trailing: Icon(
              met ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            ),
          );
        },
      ),
    );
  }
}
