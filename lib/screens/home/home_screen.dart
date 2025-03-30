import 'dart:typed_data';

import 'package:cipherx/screens/home/notification_screen.dart';
import 'package:cipherx/utils/restore_system_chrome.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../services/sharedpreference_helper.dart';
import '../../utils/constants.dart';
import '../../widgets/transaction_items.dart';

class HomeScreen extends StatefulWidget {
  final PersistentTabController controller;
  const HomeScreen({super.key, required this.controller});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = "";
  Uint8List? _userImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    final image = await SharedPreferencesHelper.getUserImg();

    setState(() {
      _userImage = image;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final transactions = provider.getFilteredTransactions(selectedFilter);
    String selectedMonth = DateFormat('MMMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- Account Balance & Filters ---
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFFDF6EC),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.darkAppColor300.withValues(alpha: 0.7), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.darkAppColor300,
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : CircleAvatar(
                            radius: 40,
                            backgroundImage: _userImage != null
                                ? MemoryImage(_userImage!)
                                : AssetImage('assets/images/person.jpg') as ImageProvider,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.keyboard_arrow_down, color: AppColors.darkAppColor300),
                            SizedBox(width: 5),
                            Text(
                              selectedMonth,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications),
                          iconSize: 32,
                          color: AppColors.darkAppColor300,onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NotificationScreen()),
                        );
                      }),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text('Account Balance', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  Text('₹${provider.balance}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoCard('Income', provider.totalIncome, Colors.green, "assets/images/income_icon.png"),
                      _infoCard('Expenses', provider.totalExpense, Colors.red, "assets/images/expense_icon.png"),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['Today', 'Week', 'Month', 'Year']
                        .map((filter) => _filterButton(filter))
                        .toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),

            // --- Recent Transactions Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      widget.controller.jumpToTab(1);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.tonesAppColor700, // Light purple background
                        borderRadius: BorderRadius.circular(20), // Rounded edges
                      ),
                      child: Text(
                        'See All',
                        style: TextStyle(
                          color: AppColors.darkAppColor300, // Purple text color
                          fontSize: 16, // Slightly larger font
                          fontWeight: FontWeight.bold, // Bold text
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            // --- Transactions List ---
            Expanded(
              child: transactions.isEmpty
                  ? Center(child: Text("No transactions found!", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final txn = transactions[index];
                  return Dismissible(
                    key: Key(txn['id'].toString()),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => provider.deleteTransaction(txn['id']),
                    child: transactionTile(txn),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Filter Button Widget ---
  Widget _filterButton(String filter) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: selectedFilter == filter ? Colors.orange.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          filter,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: selectedFilter == filter ? Colors.orange : Colors.black,
          ),
        ),
      ),
    );
  }

  // --- Info Cards for Income & Expenses ---
  Widget _infoCard(String title, double amount, Color color, String icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Image.asset(icon),
          SizedBox(width: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.white, fontSize: 14)),
              SizedBox(height: 5),
              Text('₹$amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
