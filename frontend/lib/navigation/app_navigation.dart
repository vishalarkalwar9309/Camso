import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/products_screen.dart';
import '../screens/search_screen.dart';
import '../screens/support_screen.dart';
import '../screens/profile_screen.dart';

class RootNavigation extends StatelessWidget {
  const RootNavigation({super.key});
  static const pages=[HomeScreen(),ProductsScreen(),SearchScreen(),SupportScreen(),ProfileScreen()];
  @override Widget build(BuildContext context)=>pages[0];
}
