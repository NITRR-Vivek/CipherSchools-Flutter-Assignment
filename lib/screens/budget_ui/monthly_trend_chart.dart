import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../models/chart_data.dart';
import 'empty_chart_message.dart';

Widget buildMonthlyTrendChart(Map<String, Map<String, double>> monthlyTrends, int selectedYear) {
  List<ChartData> incomeData = [];
  List<ChartData> expenseData = [];
  List<String> months = List.generate(
      12, (index) => DateFormat('MMMM').format(DateTime(selectedYear, index + 1, 1)));

  for (int i = 0; i < months.length; i++) {
    double income = monthlyTrends[months[i]]?['income'] ?? 0;
    double expense = monthlyTrends[months[i]]?['expense'] ?? 0;

    // Use abbreviated month names for display
    String month = months[i].substring(0, 3);

    incomeData.add(ChartData(month, income, Colors.green));
    expenseData.add(ChartData(month, expense, Colors.red));
  }

  bool hasData = incomeData.any((data) => data.y > 0) || expenseData.any((data) => data.y > 0);

  if (!hasData) {
    return buildEmptyChartMessage("No transaction trends available for this year.");
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Monthly Trends (Income vs Expense)',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      Expanded(
        child: SfCartesianChart(
          legend: Legend(
            isVisible: true,
            position: LegendPosition.bottom,
          ),
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(
            numberFormat: NumberFormat.currency(symbol: '\₹'),
            labelStyle: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
            ),
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          zoomPanBehavior: ZoomPanBehavior(
            enablePinching: true,
            enablePanning: true,
            enableDoubleTapZooming: true,
          ),
          series: <CartesianSeries>[
            LineSeries<ChartData, String>(
              dataSource: incomeData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              name: 'Income',
              color: Colors.green,
              markerSettings: const MarkerSettings(isVisible: true),
              dataLabelSettings: const DataLabelSettings(isVisible: false),
              enableTooltip: true,
            ),
            LineSeries<ChartData, String>(
              dataSource: expenseData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              name: 'Expense',
              color: Colors.red,
              markerSettings: const MarkerSettings(isVisible: true),
              dataLabelSettings: const DataLabelSettings(isVisible: false),
              enableTooltip: true,
            ),
          ],
        ),
      ),
    ],
  );
}