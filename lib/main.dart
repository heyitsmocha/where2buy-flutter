import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:retrofit/retrofit.dart';
import 'package:w2b_flutter/core/app_keys.dart';
import 'package:w2b_flutter/core/auth_interceptor.dart';
import 'package:w2b_flutter/core/logger_interceptor.dart';
import 'package:w2b_flutter/features/inquiry/presentation/inquiry_responses_page.dart';
import 'package:w2b_flutter/features/profile/presentation/profile_page.dart';
import 'package:w2b_flutter/features/inquiry/presentation/my_inquiries_page.dart';
import 'package:w2b_flutter/features/respond/presentation/add_response_page.dart';
import 'package:w2b_flutter/features/search/presentation/search_page.dart';
import 'package:w2b_flutter/features/respond/presentation/respond_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:w2b_flutter/models/inquiry_model.dart';
import 'package:w2b_flutter/util/api_util.dart';

Future<void> main() async {
  // Load api url from .env file
  await dotenv.load(fileName: ".env");
  
  final String apiBaseUrl = dotenv.env['API_BASE_URL'] ?? "http://192.168.0.1:8000/api";
  print('API Base URL: $apiBaseUrl');

  Dio dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      headers: {
        // "Content-Type": "application/json",
        "Accept": "application/json",
        "X-Platform": "mobile-flutter",
      }
    ),
  );

  // Add the AuthInterceptor to automatically include the auth token in requests if needed
  dio.interceptors.add(AuthInterceptor());
  dio.interceptors.add(LoggerInterceptor());

  // Test the API connection by making a simple request
  try {
    HttpResponse userResponse = await ApiService(dio).getUser();
  } on DioException catch (e) {
    print('Error fetching user data: ${e.message}');
  }

  runApp(MainApp(dio: dio));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.dio});

  final Dio dio;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 1;

  late final List<Widget> _views = [
      RespondPage(widget.dio),
      SearchPage(widget.dio),
      MyInquiriesPage(widget.dio),
  ];

  final List<Widget> _destinations = const [
    NavigationDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat), label: 'Respond'),
    NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Search'),
    NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'My Requests'),
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

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        switch(settings.name) {
          case '/respond/add':
            return MaterialPageRoute(
              builder: (context) => AddResponsePage(widget.dio, inquiry: settings.arguments as NearbyInquiry), // Pass the inquiry data to the AddResponsePage
              settings: settings, // Pass the settings to the new route
            );
          case '/inquiry/responses':
            return MaterialPageRoute(
              builder: (context) => InquiryResponsesPage(widget.dio, inquiry: settings.arguments as Inquiry), // Pass the inquiry data to the InquiryResponsesPage
              settings: settings, // Pass the settings to the new route
            );
          default:
            return null; // TODO: 404 page
        }
      },
      home: SafeArea(
        child: Scaffold(
          key: AppKeys.mainScaffoldKey,
          body: _views[_currentIndex],
          drawer: Drawer(
            child: ProfilePage(dio: widget.dio),
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