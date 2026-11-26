import 'package:flutter/material.dart';

import '../widgets.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  void _showAiResult(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('AI 패턴 요약 · 데모'),
          content: const Text(
            '최근 기록에서는 저녁 시간대 흡연이 상대적으로 많았습니다. '
            '다음 7일은 하루 목표를 6개비로 유지하고, 저녁 흡연 1회를 다른 행동으로 바꾸는 것을 권장합니다.\n\n'
            '※ 실제 AI 호출이 아닌 미리 준비된 임의 결과입니다.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;

          final goalCard = Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(child: SectionTitle('7일 감량 계획')),
                      const PTag('P02 · P05'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _PlanRow(day: '1–2일', target: '8개비'),
                  const _PlanRow(day: '3–4일', target: '7개비'),
                  const _PlanRow(day: '5–7일', target: '6개비'),
                  const SizedBox(height: 12),
                  const Text(
                    '한 번의 실패로 전체 기록을 초기화하지 않고, 현재 기록을 기준으로 다음 단계부터 다시 이어 갑니다.',
                  ),
                ],
              ),
            ),
          );

          final aiCard = Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('AI 활용 기회'),
                  const SizedBox(height: 12),
                  const Text(
                    '최근 흡연 기록과 감량 목표를 바탕으로 자주 흡연하는 시간대와 패턴을 요약하고 다음 행동을 제안합니다.',
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showAiResult(context),
                      icon: const Icon(Icons.auto_awesome_outlined),
                      label: const Text('AI 분석 결과 보기'),
                    ),
                  ),
                ],
              ),
            ),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '감량 계획',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text('완전 금연뿐 아니라 단계적 감량도 계속 기록할 수 있게 합니다.'),
                    const SizedBox(height: 20),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: goalCard),
                          const SizedBox(width: 16),
                          Expanded(child: aiCard),
                        ],
                      )
                    else ...[
                      goalCard,
                      const SizedBox(height: 16),
                      aiCard,
                    ],
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

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.day, required this.target});

  final String day;
  final String target;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 72, child: Text(day)),
          Expanded(child: LinearProgressIndicator(value: target == '6개비' ? .6 : .75)),
          const SizedBox(width: 12),
          Text(target, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
