import 'package:cipherx/utils/restore_system_chrome.dart';
import 'package:cipherx/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/constants.dart';

class AddTransactionScreen extends StatefulWidget {
  final PersistentTabController controller;
  final VoidCallback? onClose;
  const AddTransactionScreen({super.key,
    required this.controller,
    this.onClose});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isIncome = false;
  String selectedCategory = 'Shopping';
  String selectedWallet = 'Cash';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      Provider.of<TransactionProvider>(context, listen: false).addTransaction({
        'amount': double.parse(_amountController.text),
        'category': selectedCategory,
        'description': _descriptionController.text,
        'type': isIncome ? 'income' : 'expense',
        'date': DateTime.now().toIso8601String(),
      });

      if (widget.onClose != null) {
        widget.onClose!();
        restoreSystemChrome();
      } else {
        widget.controller.jumpToTab(0);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: isIncome ? AppColors.tonesAppColor300 : Colors.blue.shade400,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: widget.onClose ?? () {
            widget.controller.jumpToTab(0);
            restoreSystemChrome();
            },
        ),
        elevation: 0,
      ),
      backgroundColor: isIncome ? AppColors.tonesAppColor300 : Colors.blue.shade400,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _toggleButton('Income', isIncome),
                      _toggleButton('Expense', !isIncome),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('How much?', style: TextStyle(fontSize: 20, color: Colors.white)),
              TextFormField(
                controller: _amountController,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '₹0',
                  hintStyle: TextStyle(fontSize: 36, color: Colors.white70),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    CustomSnackbar.show(context, message: "Please Enter the Amount");
                  }
                  return null;
                },
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _dropdownField('Category', ['Shopping', 'Food', 'Travel'], selectedCategory, (val) {
                        setState(() => selectedCategory = val);
                      }),
                      _textField('Description', _descriptionController),
                      _dropdownField('Wallet', ['Cash', 'Bank'], selectedWallet, (val) {
                        setState(() => selectedWallet = val);
                      }),
                      Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          backgroundColor: isIncome ? AppColors.tonesAppColor300 : Colors.blue.shade400,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: _saveTransaction,
                        child: Text('Continue', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggleButton(String text, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => isIncome = text == 'Income'),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        decoration: BoxDecoration(
          color: isActive ? (isIncome ? AppColors.darkAppColor300 : Colors.blue) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _dropdownField(String label, List<String> items, String value, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        value: value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: (val) => onChanged(val!),
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}
