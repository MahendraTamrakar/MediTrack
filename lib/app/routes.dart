import 'package:flutter/material.dart';
import 'package:medtrack/screens/home_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String addMedicine = '/add-medicine';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case addMedicine:
        //return MaterialPageRoute(builder: (_) => const AddMedicineScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}