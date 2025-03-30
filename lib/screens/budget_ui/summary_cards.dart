import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
  return Expanded(
    child: Container(
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

Widget buildSummaryCards(double income, double expense, double balance) {
  final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      children: [
        _buildSummaryCard('Income', currencyFormat.format(income), Icons.arrow_upward, Colors.green),
        _buildSummaryCard('Expenses', currencyFormat.format(expense), Icons.arrow_downward, Colors.red),
        _buildSummaryCard('Balance', currencyFormat.format(balance), balance >= 0 ? Icons.account_balance_wallet : Icons.warning, balance >= 0 ? Colors.blue : Colors.orange),
      ],
    ),
  );
}
