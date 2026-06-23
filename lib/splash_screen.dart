import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vendorapp/home_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(child: Lottie.asset('assets/animation/gaslogo.json')),
      nextScreen: const MyHomePage(), // Replace with your actual home screen
      duration: 9000,
      backgroundColor: const Color.fromARGB(255, 255, 115, 0),
      splashIconSize: 1000,
      splashTransition: SplashTransition.fadeTransition,
      animationDuration: const Duration(seconds: 9),
    );
  }
}
