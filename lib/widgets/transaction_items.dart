import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget transactionTile(Map<String, dynamic> txn) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
    child: Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(15), // Rounded corners

      ),
      child: Row(
        children: [
          // Icon inside rounded container
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getCategoryColor(txn['category']), // Custom color for category
              borderRadius: BorderRadius.circular(12),
            ),
            child: _getTransactionIcon(txn['category']),
          ),
          SizedBox(width: 12),

          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn['category'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  txn['description'],
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis, // Handle long text
                ),
              ],
            ),
          ),

          // Amount and Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                txn['type'] == 'income' ? '+ ₹${txn['amount']}' : '- ₹${txn['amount']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: txn['type'] == 'income' ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 2),
              Text(
                _formatTime(txn['date']),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// Function to format time
String _formatTime(String dateTime) {
  DateTime parsedDate = DateTime.parse(dateTime);
  return DateFormat('hh:mm a').format(parsedDate);
}

// Function to return category-based color
Color _getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'shopping':
      return Colors.amber.shade100;
    case 'subscription':
      return Colors.purple.shade100;
    case 'travel':
      return Colors.blue.shade100;
    default:
      return Colors.grey.shade200;
  }
}

// Function to return transaction category icons
Icon _getTransactionIcon(String category) {
  switch (category.toLowerCase()) {
    case 'shopping':
      return Icon(Icons.shopping_bag, color: Colors.orange);
    case 'subscription':
      return Icon(Icons.subscriptions, color: Colors.purple);
    case 'travel':
      return Icon(Icons.directions_car, color: Colors.blue);
    default:
      return Icon(Icons.category, color: Colors.grey);
  }
}
