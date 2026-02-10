import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:w2b_flutter/core/app_keys.dart';
import 'package:w2b_flutter/features/profile/presentation/profile_page.dart';
import 'package:w2b_flutter/features/inquiry/presentation/inquiries_page.dart';
import 'package:w2b_flutter/features/answer/presentation/answer_page.dart';
import 'package:w2b_flutter/features/search/presentation/search_page.dart';
import 'package:w2b_flutter/features/answer/presentation/answers_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 1;

  late final Dio dio;

  late final List<Widget> _views = [
      InquiriesPage(dio),
      SearchPage(dio),
      AnswersPage(dio),
  ];

  final List<Widget> _destinations = const [
    NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Requests'),
    NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Search'),
    NavigationDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat), label: 'Respond'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // https://www.color-hex.com/color-palette/1017208
  // static const Color primaryColor = Color(0xFF3100A2);
  static const Color primaryColor = Color(0xFF4500E2);

  @override
  void initState() {
    super.initState();

    dio = Dio(
      BaseOptions(
        baseUrl: "http://192.168.0.81:8000/api",
      ),
    );

    // final inquityService = 
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      routes: {
        '/respond': (context) => const AnswerPage(),
      },
      home: SafeArea(
        child: Scaffold(
          key: AppKeys.mainScaffoldKey,
          body: _views[_currentIndex],
          drawer: const Drawer(
            child: ProfilePage(),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onItemTapped,
            destinations: _destinations,
          ),
        ),
      ),
    );
  }
}