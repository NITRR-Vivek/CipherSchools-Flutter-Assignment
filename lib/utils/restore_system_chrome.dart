import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';

void restoreSystemChrome({Color? color = AppColors.tonesAppColor400}){
  Future.delayed(Duration(milliseconds: 20));{
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: color,
        systemNavigationBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        systemNavigationBarDividerColor: color,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
}