import 'dart:io';

import 'package:cipherx/screens/transactions/add_transaction.dart';
import 'package:cipherx/screens/budget_ui/budget_screen.dart';
import 'package:cipherx/screens/profile/profile_screen.dart';
import 'package:cipherx/screens/startings/splash_screen.dart';
import 'package:cipherx/screens/transactions/transaction_screen.dart';
import 'package:cipherx/utils/constants.dart';
import 'package:cipherx/utils/restore_system_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../services/auth_service.dart';
import '../services/sharedpreference_helper.dart';
import '../widgets/custom_snackbar.dart';
import 'home/home_screen.dart';
import 'auth/login_screen.dart';
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PersistentTabController _controller;
  final AuthenticationService _authService = AuthenticationService();


  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);

    /// Listen for tab changes and restore system UI colors accordingly
    _controller.addListener(() {
      _restoreUIForCurrentTab(_controller.index);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreUIForCurrentTab(_controller.index);
    });
  }

  /// Restore system UI colors based on the active tab
  void _restoreUIForCurrentTab(int index) {
    Color statusBarColor;
    Color navBarColor = Colors.transparent;

    switch (index) {
      case 0:
        statusBarColor = Color(0xFFFDF6EC);
        break;
      case 1:
        statusBarColor = AppColors.tonesAppColor400;
        break;
      case 2:
        statusBarColor = AppColors.tonesAppColor400;
        break;
      case 3:
        statusBarColor = AppColors.tonesAppColor400;
        break;
      case 4:
        statusBarColor = Colors.white;
        break;
      default:
        statusBarColor = Colors.white;
    }

    restoreSystemChrome(color: statusBarColor);
  }


  Future<bool> _showExitDialog() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Exit App"),
        content:
        Text("Are you sure want to exit the App?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            // Stay in app
            child: Text("No",
                style: TextStyle(color: AppColors.darkAppColor300)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Exit app
            child: Text("Yes",
                style: TextStyle(color: AppColors.darkAppColor300)),
          ),
        ],
      ),
    ) ??
        false; // Default to false if dialog is dismissed
  }

  void _logout() async {
    try {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      CustomSnackbar.show(context, message: "Successfully Logged Out!");
    } catch (e) {
      CustomSnackbar.show(context, message: "Error: $e");
    }
  }

  List<Widget> _buildScreens() {
    return <Widget>[
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          bool shouldExit = await _showExitDialog();
          if (shouldExit) {
            if (Platform.isAndroid) {
              SystemNavigator.pop();
            } else if (Platform.isIOS) {
              exit(0);
            }
          }
        },
        child: HomeScreen(controller: _controller),
      ),
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          _controller.jumpToTab(0);
        },
        child: TransactionScreen(controller: _controller),
      ),
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          _controller.jumpToTab(0);
        },
        child: AddTransactionScreen(controller: _controller)
      ),
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          _controller.jumpToTab(0);
        },
        child: BudgetScreen(),
      ),
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          _controller.jumpToTab(0);
        },
        child: ProfileScreen(onLogout: _logout, controller: _controller),
      ),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: ("Home"),
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.shopping_bag),
        title: ("Transaction"),
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
        title: (""),
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: AppColors.primaryColor,
        onPressed: (context) {
          _showAddTransactionSheet();
          return false;
        },
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.notifications),
        title: ("Budget"),
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: ("Profile"),
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }
  void _showAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: AddTransactionScreen(
          controller: _controller,
          onClose: () => Navigator.pop(context)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: PersistentTabView(
        context,
        controller: _controller,
        padding: EdgeInsets.symmetric(vertical: 6),
        margin: EdgeInsets.only(bottom: 10),
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineToSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        bottomScreenMargin: kBottomNavigationBarHeight,
        stateManagement: true,
        navBarHeight: MediaQuery.of(context).viewInsets.bottom > 0
            ? 0.0
            : kBottomNavigationBarHeight,
        hideNavigationBarWhenKeyboardAppears: true,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(16.0),
          colorBehindNavBar: Colors.white,
        ),
        popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
        animationSettings: const NavBarAnimationSettings(
          onNavBarHideAnimation: OnHideAnimationSettings(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          ),
          navBarItemAnimation: ItemAnimationSettings(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          ),
        ),
        navBarStyle: NavBarStyle.style15,
      ),
    );
  }
}
