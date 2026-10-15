import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'state/app_state.dart';
import 'screens/calculators_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/products_screen.dart';
import 'screens/search_screen.dart';
import 'screens/support_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/employee_portal_screen.dart';
import 'screens/oem_portal_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/error_screen.dart';


// ============================================================================
// CAMSO APP
// ============================================================================

class CamsoApp extends StatelessWidget {
  const CamsoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CAMSO by CEAT',
      theme: buildTheme(),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final isWide = mediaQuery.size.width > 680;
        final constrainedWidth = isWide ? 680.0 : mediaQuery.size.width;

        return Container(
          color: const Color(0xFFE5E9F2),
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: MediaQuery(
              data: mediaQuery.copyWith(
                size: Size(constrainedWidth, mediaQuery.size.height),
              ),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      routes: {
        '/login': (_) => const LoginScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/calculators': (_) => const CalculatorsScreen(),
        '/employee-portal': (_) => const EmployeePortalScreen(),
        '/oem-portal': (_) => const OemPortalScreen(),
        '/admin-dashboard': (_) => const AdminDashboardScreen(),
        '/error': (_) => const ErrorScreen(),
        '/no-internet': (_) => const ErrorScreen.noInternet(),
        '/server-error': (_) => const ErrorScreen.serverError(),
      },
      home: const SplashScreen(),
    );
  }
}


// ============================================================================
// MAIN APPLICATION NAVIGATION
// ============================================================================
//
// This is the main shell after the user enters the application.
//
// 0 → Home
// 1 → Products
// 2 → Search
// 3 → Support
// 4 → Profile
//
// The main bottom navigation stays visible here.
// ============================================================================

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  static const List<Widget> _pages = [
  HomeScreen(),
  ProductsScreen(),
  SearchScreen(),
  SupportScreen(),
  CalculatorsScreen(),
];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),

      body: IndexedStack(
        index: state.tab,
        children: _pages,
      ),

      bottomNavigationBar: const _MainBottomNavigationBar(),
    );
  }
}


// ============================================================================
// MAIN BOTTOM NAVIGATION
// ============================================================================

class _MainBottomNavigationBar extends StatelessWidget {
  const _MainBottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final items = [
      (
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: state.tr('nav_home'),
      ),
      (
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view,
        label: state.tr('nav_products'),
      ),
      (
        icon: Icons.search_outlined,
        activeIcon: Icons.search,
        label: state.tr('nav_search'),
      ),
      (
        icon: Icons.support_agent_outlined,
        activeIcon: Icons.support_agent,
        label: state.tr('nav_support'),
      ),
      (
        icon: Icons.calculate_outlined,
        activeIcon: Icons.calculate,
        label: state.language == 'fr'
            ? 'Calculateurs'
            : state.language == 'de'
                ? 'Rechner'
                : state.language == 'it'
                    ? 'Calcolatori'
                    : 'Calculators',
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE4E7EF),
            width: 1,
          ),
        ),
      ),

      child: SafeArea(
        top: false,

        child: SizedBox(
          height: 68,

          child: Row(
            children: [
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      state.setTab(i);
                    },

                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,

                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 7,
                        bottom: 4,
                      ),

                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [
                          // ------------------------------------------------
                          // ICON
                          // ------------------------------------------------

                          Icon(
                            state.tab == i
                                ? items[i].activeIcon
                                : items[i].icon,

                            size: 22,

                            color: state.tab == i
                                ? const Color(0xFF203F99)
                                : const Color(0xFF9CA3AF),
                          ),

                          const SizedBox(height: 3),

                          // ------------------------------------------------
                          // LABEL
                          // ------------------------------------------------

                          Text(
                            items[i].label,

                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,

                              fontWeight: state.tab == i
                                  ? FontWeight.w600
                                  : FontWeight.w400,

                              color: state.tab == i
                                  ? const Color(0xFF203F99)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


// ============================================================================
// SECONDARY SCREEN NAVIGATION HELPER
// ============================================================================
//
// Use this helper when opening a secondary screen:
//
// push(
//   context,
//   ProductDetailScreen(product: product),
// );
//
// The secondary page will automatically receive a bottom navigation bar.
// ============================================================================

Future<T?> push<T>(
  BuildContext context,
  Widget page,
) {
  return Navigator.push<T>(
    context,

    MaterialPageRoute(
      builder: (_) => _SecondaryPageShell(
        page: page,
      ),
    ),
  );
}


// ============================================================================
// SECONDARY PAGE SHELL
// ============================================================================
//
// This wraps secondary screens such as:
//
// Product Details
// Document Details
// Testimonial Details
// FAQ
// Notifications
// Settings
// Language
// About CAMSO
// Contact
// etc.
//
// The bottom navigation remains visible.
// ============================================================================

class _SecondaryPageShell extends StatelessWidget {
  final Widget page;

  const _SecondaryPageShell({
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),

      body: page,

      bottomNavigationBar:
          const _SecondaryBottomNavigationBar(),
    );
  }
}


// ============================================================================
// SECONDARY PAGE BOTTOM NAVIGATION
// ============================================================================
//
// This is intentionally separate from the main navigation.
//
// Why?
//
// MainNavigation is already the root shell.
//
// When we open:
//
// MainNavigation
//       ↓
// Product Details
//
// Product Details is now inside another route.
//
// Therefore, when the user taps a bottom navigation item here,
// we first change the selected tab and then return to the
// MainNavigation route.
// ============================================================================

class _SecondaryBottomNavigationBar extends StatelessWidget {
  const _SecondaryBottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    const items = [
      (
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
      ),
      (
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view,
        label: 'Products',
      ),
      (
        icon: Icons.search_outlined,
        activeIcon: Icons.search,
        label: 'Search',
      ),
      (
        icon: Icons.support_agent_outlined,
        activeIcon: Icons.support_agent,
        label: 'Support',
      ),
      (
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,

        border: Border(
          top: BorderSide(
            color: Color(0xFFE4E7EF),
            width: 1,
          ),
        ),
      ),

      child: SafeArea(
        top: false,

        child: SizedBox(
          height: 68,

          child: Row(
            children: [
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      // Change the selected main tab.
                      state.setTab(i);

                      // Return from the secondary screen
                      // to the MainNavigation screen.
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },

                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,

                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 7,
                        bottom: 4,
                      ),

                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [
                          // ------------------------------------------------
                          // ICON
                          // ------------------------------------------------

                          Icon(
                            state.tab == i
                                ? items[i].activeIcon
                                : items[i].icon,

                            size: 22,

                            color: state.tab == i
                                ? const Color(0xFF203F99)
                                : const Color(0xFF9CA3AF),
                          ),

                          const SizedBox(height: 3),

                          // ------------------------------------------------
                          // LABEL
                          // ------------------------------------------------

                          Text(
                            items[i].label,

                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,

                              fontWeight: state.tab == i
                                  ? FontWeight.w600
                                  : FontWeight.w400,

                              color: state.tab == i
                                  ? const Color(0xFF203F99)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}