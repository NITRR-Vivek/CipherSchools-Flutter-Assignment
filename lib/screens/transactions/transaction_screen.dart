import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/constants.dart';
import '../../utils/restore_system_chrome.dart';
import '../../widgets/transaction_items.dart';

class TransactionScreen extends StatefulWidget {
  final PersistentTabController controller;

  const TransactionScreen({super.key, required this.controller});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    restoreSystemChrome();
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.getFilteredTransactions(selectedFilter)
        .where((txn) => txn['category'].toLowerCase().contains(searchQuery.toLowerCase()) ||
        txn['description'].toLowerCase().contains(searchQuery.toLowerCase()) ||
        txn['amount'].toString().contains(searchQuery) ||
        txn['type'].toLowerCase().contains(searchQuery.toLowerCase()) ||
        txn['date'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.tonesAppColor400,
        title: Text('Transactions'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButton<String>(
              value: selectedFilter,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedFilter = newValue;
                  });
                }
              },
              items: ['All', 'Today', 'Week', 'Month', 'Year']
                  .map((filter) => DropdownMenuItem(value: filter, child: Text(filter)))
                  .toList(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, description, amount, type, or date',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? Center(child: Text('No transactions found'))
                : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return transactionTile(transactions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
