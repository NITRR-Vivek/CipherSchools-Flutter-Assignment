import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../models/chart_data.dart';
import '../../providers/transaction_provider.dart';
import 'empty_chart_message.dart';

Widget buildCategorySpendingChart(TransactionProvider provider, String month) {
  Map<String, double> categoryTotals = {};

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
        'Top Spending Categories',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      Expanded(
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(
            labelRotation: 45,
            labelStyle: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
            ),
          ),
          primaryYAxis: NumericAxis(
            numberFormat: NumberFormat.currency(symbol: '\₹'),
            labelStyle: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
            ),
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries>[
            BarSeries<ChartData, String>(
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              pointColorMapper: (ChartData data, _) => data.color,
              name: 'Spending',
              width: 0.6,
              spacing: 0.2,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelAlignment: ChartDataLabelAlignment.top,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}