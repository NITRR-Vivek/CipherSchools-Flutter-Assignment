import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../models/chart_data.dart';
import '../../providers/transaction_provider.dart';
import 'empty_chart_message.dart';

Widget buildExpenseBreakdownChart(TransactionProvider provider, String month) {
  Map<String, double> categoryTotals = {};
  double totalExpense = 0;

  for (var txn in provider.transactions) {
    DateTime txnDate;
    try {
      txnDate = DateTime.parse(txn['date']);
    } catch (e) {
      continue;
    }
    if (DateFormat('MMMM').format(txnDate) == month && txn['type'] == 'expense') {
      categoryTotals[txn['category']] =
          (categoryTotals[txn['category']] ?? 0) + txn['amount'];
      totalExpense += txn['amount'];
    }
  }

  if (categoryTotals.isEmpty) {
    return buildEmptyChartMessage("No expense data available for this month.");
  }

  List<MapEntry<String, double>> sortedCategories = categoryTotals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  List<ChartData> chartData = sortedCategories
      .map((entry) => ChartData(
    entry.key,
    entry.value,
    Colors.primaries[sortedCategories.indexOf(entry) % Colors.primaries.length],
  ))
      .toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Expense Breakdown',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        'Total Expense: ${NumberFormat.currency(symbol: '\₹').format(totalExpense)}',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade700,
        ),
      ),
      Expanded(
        child: SfCircularChart(
          legend: Legend(
            isVisible: true,
            overflowMode: LegendItemOverflowMode.wrap,
            position: LegendPosition.bottom,
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CircularSeries>[
            PieSeries<ChartData, String>(
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              pointColorMapper: (ChartData data, _) => data.color,
              dataLabelMapper: (ChartData data, _) =>
              '${data.x}\n${NumberFormat.percentPattern().format(data.y / totalExpense)}',
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
                connectorLineSettings: ConnectorLineSettings(
                  type: ConnectorType.curve,
                  length: '10%',
                ),
              ),
              enableTooltip: true,
              explode: true,
              explodeIndex: 0,
            ),
          ],
        ),
      ),
    ],
  );
}