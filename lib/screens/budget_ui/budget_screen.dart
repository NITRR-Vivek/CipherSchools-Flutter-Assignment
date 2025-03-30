import 'package:cipherx/screens/budget_ui/summary_cards.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/constants.dart';
import 'category_spending_chart.dart';
import 'expense_breakdown_chart.dart';
import 'income_expense_chart.dart';
import 'monthly_trend_chart.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());
  int selectedYear = DateTime.now().year;
  String selectedChartView = 'Overview';

  final List<String> chartViews = ['Overview', 'Categories', 'Trends', 'Breakdown'];

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final monthlyTrends = transactionProvider.getMonthlyTrends(selectedYear);
    final income = monthlyTrends[selectedMonth]?['income'] ?? 0;
    final expense = monthlyTrends[selectedMonth]?['expense'] ?? 0;
    final balance = income - expense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Analysis'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.tonesAppColor400,
        foregroundColor: Colors.black,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFiltersSection(),
          buildSummaryCards(income, expense, balance),
          _buildChartViewSelector(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSelectedChart(transactionProvider, monthlyTrends),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.tonesAppColor400,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Period',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.darkAppColor500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMonth,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onChanged: (value) => setState(() => selectedMonth = value!),
                      items: List.generate(12, (index) {
                        String month = DateFormat('MMMM').format(DateTime(2024, index + 1, 1));
                        return DropdownMenuItem(value: month, child: Text(month));
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedYear,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onChanged: (value) => setState(() => selectedYear = value!),
                      items: List.generate(5, (index) {
                        int year = DateTime.now().year - index;
                        return DropdownMenuItem(value: year, child: Text('$year'));
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10,)
        ],
      ),
    );
  }

  Widget _buildChartViewSelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chartViews.length,
        itemBuilder: (context, index) {
          final isSelected = selectedChartView == chartViews[index];
          return GestureDetector(
            onTap: () => setState(() => selectedChartView = chartViews[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.darkAppColor300.withValues(alpha: 0.7)
                    : AppColors.darkAppColor300.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Text(
                chartViews[index],
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.darkAppColor300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedChart(
      TransactionProvider transactionProvider, Map<String, Map<String, double>> monthlyTrends) {
    switch (selectedChartView) {
      case 'Overview':
        return buildIncomeExpenseChart(
            monthlyTrends[selectedMonth]?['income'] ?? 0,
            monthlyTrends[selectedMonth]?['expense'] ?? 0);
      case 'Categories':
        return buildCategorySpendingChart(transactionProvider, selectedMonth);
      case 'Trends':
        return buildMonthlyTrendChart(monthlyTrends, selectedYear);
      case 'Breakdown':
        return buildExpenseBreakdownChart(transactionProvider, selectedMonth);
      default:
        return buildIncomeExpenseChart(
            monthlyTrends[selectedMonth]?['income'] ?? 0,
            monthlyTrends[selectedMonth]?['expense'] ?? 0);
    }
  }
}