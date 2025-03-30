import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../models/chart_data.dart';
import 'empty_chart_message.dart';

Widget buildIncomeExpenseChart(double income, double expense) {
  if (income == 0 && expense == 0) {
    return buildEmptyChartMessage("No income or expenses recorded for this month.");
  }

  final List<ChartData> chartData = [
    ChartData('Income', income, const Color(0xFF4CAF50)),
    ChartData('Expense', expense, const Color(0xFFF44336)),
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: Text(
          'Income vs Expenses',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: 300,
        child: SfCircularChart(
          legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CircularSeries>[
            DoughnutSeries<ChartData, String>(
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              pointColorMapper: (ChartData data, _) => data.color,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
                textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                useSeriesColor: true,
                connectorLineSettings: ConnectorLineSettings(
                  type: ConnectorType.curve,
                  length: '10%',
                ),
              ),
              enableTooltip: true,
            ),
          ],
          annotations: <CircularChartAnnotation>[
            CircularChartAnnotation(
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Balance',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(income - expense),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: (income - expense) >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
