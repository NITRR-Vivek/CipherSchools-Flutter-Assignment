import 'package:cipherx/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../utils/restore_system_chrome.dart';

class SplashScreen2 extends StatelessWidget {
  const SplashScreen2({super.key});
  @override
  Widget build(BuildContext context) {
    restoreSystemChrome(color: Color(0xff7b61ff));
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/splash.png', fit: BoxFit.cover),
          Positioned(
            top: 50,
            left: 20,
            child: Image.asset('assets/images/logo.png', height: 60),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Welcome to",
                          style: TextStyle(
                            fontFamily: 'BrunoAce',
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "CipherX",
                          style: TextStyle(
                            fontFamily: 'BrunoAce',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignupScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black,
                          size: 55,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "The best way to track your expenses.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // fontFamily: 'BrunoAce',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
