import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'screens/login_screen.dart';
import 'screens/staff/staff_main_screen.dart';
import 'screens/admin/admin_main_screen.dart';

void main() {
  runApp(const ShiftMarkApp());
}

class ShiftMarkApp extends StatelessWidget {
  const ShiftMarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShiftMark',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brand,
          primary: AppColors.brand,
          secondary: AppColors.gold,
          surface: AppColors.screen,
          onSurface: AppColors.ink,
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          displayLarge: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
          displayMedium: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
          titleLarge: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(color: AppColors.ink2),
          bodyMedium: TextStyle(color: AppColors.ink2),
        ),
        scaffoldBackgroundColor: AppColors.bg,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const RootNavigator(),
    );
  }
}

enum UserRole { staff, admin }

class RootNavigator extends StatefulWidget {
  const RootNavigator({super.key});

  @override
  State<RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<RootNavigator> {
  bool _isLoggedIn = false;
  UserRole _currentRole = UserRole.staff;
  Map<String, dynamic>? _currentUser;

  void _login(UserRole role, Map<String, dynamic> user) {
    setState(() {
      _isLoggedIn = true;
      _currentRole = role;
      _currentUser = user;
    });
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return LoginScreen(onLogin: _login);
    }

    return _currentRole == UserRole.staff
        ? StaffMainScreen(onLogout: _logout, user: _currentUser!)
        : AdminMainScreen(onLogout: _logout, user: _currentUser!);
  }
}
