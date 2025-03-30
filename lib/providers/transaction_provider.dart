import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _transactions = [];
  double totalIncome = 0;
  double totalExpense = 0;

  List<Map<String, dynamic>> get transactions => _transactions;
  double get balance => totalIncome - totalExpense;

  TransactionProvider() {
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final data = await _dbHelper.getTransactions();
    double income = 0, expense = 0;

    for (var txn in data) {
      if (txn['type'] == 'income') {
        income += txn['amount'];
      } else {
        expense += txn['amount'];
      }
    }

    _transactions = data;
    totalIncome = income;
    totalExpense = expense;
    notifyListeners();
  }

  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    await _dbHelper.insertTransaction(transaction);
    await fetchTransactions(); // Refresh UI
  }

  Future<void> deleteTransaction(int id) async {
    await _dbHelper.deleteTransaction(id);
    await fetchTransactions(); // Refresh UI
  }

  List<Map<String, dynamic>> getFilteredTransactions(String filter) {
    DateTime now = DateTime.now();
    return _transactions.where((txn) {
      DateTime txnDate;

      try {
        txnDate = DateTime.parse(txn['date']);
      } catch (e) {
        return false;
      }
      switch (filter) {
        case 'Today':
          return txnDate.year == now.year &&
              txnDate.month == now.month &&
              txnDate.day == now.day;
        case 'Week':
          DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          return txnDate.isAfter(startOfWeek);
        case 'Month':
          return txnDate.year == now.year && txnDate.month == now.month;
        case 'Year':
          return txnDate.year == now.year;
        default:
          return true; // Show all transactions
      }
    }).toList();
  }

  Map<String, Map<String, double>> getMonthlyTrends(int year) {
    Map<String, Map<String, double>> monthlyTrends = {};

    // Initialize all months with zero values
    List<String> months = List.generate(12, (index) =>
        DateFormat('MMMM').format(DateTime(year, index + 1, 1)));

    for (var month in months) {
      monthlyTrends[month] = {'income': 0, 'expense': 0};
    }

    for (var txn in _transactions) {
      DateTime txnDate;
      try {
        txnDate = DateTime.parse(txn['date']);
      } catch (e) {
        continue;
      }

      if (txnDate.year == year) {
        String month = DateFormat('MMMM').format(txnDate);

        if (txn['type'] == 'income') {
          monthlyTrends[month]!['income'] =
              (monthlyTrends[month]!['income'] ?? 0) + txn['amount'];
        } else {
          monthlyTrends[month]!['expense'] =
              (monthlyTrends[month]!['expense'] ?? 0) + txn['amount'];
        }
      }
    }

    return monthlyTrends;
  }

  // Get spending by category for a specific month and year
  Map<String, double> getCategoryBreakdown(String month, int year, String type) {
    Map<String, double> categoryTotals = {};

    for (var txn in _transactions) {
      DateTime txnDate;
      try {
        txnDate = DateTime.parse(txn['date']);
      } catch (e) {
        continue;
      }

      if (txnDate.year == year &&
          DateFormat('MMMM').format(txnDate) == month &&
          txn['type'] == type) {
        categoryTotals[txn['category']] =
            (categoryTotals[txn['category']] ?? 0) + txn['amount'];
      }
    }

    return categoryTotals;
  }

  // Calculate year-to-date totals
  Map<String, double> getYearToDateTotals(int year) {
    double income = 0, expense = 0;

    for (var txn in _transactions) {
      DateTime txnDate;
      try {
        txnDate = DateTime.parse(txn['date']);
      } catch (e) {
        continue;
      }

      if (txnDate.year == year) {
        if (txn['type'] == 'income') {
          income += txn['amount'];
        } else {
          expense += txn['amount'];
        }
      }
    }

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense
    };
  }
}