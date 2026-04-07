import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/features/login/presentation/login_page.dart';
import 'package:w2b_flutter/features/login/presentation/register_page.dart';
import 'package:w2b_flutter/util/api_util.dart';

class ProfilePage extends StatefulWidget {
  final Dio dio;

  const ProfilePage({super.key, required this.dio});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String _username = 'Guest';
  String _email = '';

  @override
  void initState() {
    super.initState();
    
    // Determine login status from existence of access token
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
    
  }

  void _checkLoginStatus() async {
    print('Checking login status in ProfilePage...');
    const storage = FlutterSecureStorage();
    bool hasToken = await storage.containsKey(key: 'auth_token');
    if (hasToken) {
      print('Auth token found, user is logged in');
      String tempName, tempEmail;
      // Name and email from sharedprefs
      final prefs = await SharedPreferences.getInstance();
      tempName = prefs.getString('username') ?? 'Guest';
      tempEmail = prefs.getString('email') ?? '';
      setState(() {
        _isLoggedIn = true;
        _username = tempName;
        _email = tempEmail;
      });
    } else {
      print('No auth token found, user is not logged in');
      setState(() {
        _isLoggedIn = false;
        _username = 'Guest';
        _email = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton(
            onPressed: () {},
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  // backgroundImage: 
                ),
                const SizedBox(width: 20,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_username, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                    Text(_email),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 50,),
          const Expanded(child: Text('Placeholder')),
          const Divider(height: 25,),
          ElevatedButton(
            onPressed: 
              _isLoggedIn
              ? () async { // Logout if logged in
                setState(() {
                  _isLoading = true;
                });
                // Perform logout
                try {
                  final response = await ApiService(widget.dio).logout();
                  
                  if (response.response.statusCode == 200) {
                    // TODO
                  }
                } on DioException catch (e) {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(
                  //     backgroundColor: Colors.red,
                  //     content: Text("Logout failed: ${e.response?.data['message'] ?? e.message}")
                  //   ),
                  // );
                  print('DioException: Logout failed');
                }

                // Clear stored credentials on successful logout
                const storage = FlutterSecureStorage();
                storage.delete(key: 'auth_token');

                final prefs = await SharedPreferences.getInstance();
                prefs.remove('username');
                prefs.remove('email');

                _checkLoginStatus();
                if (context.mounted) {
                  // Dismiss sidebar
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      content: Text("Logged out successfully")
                    ),
                  );
                }
                setState(() {
                  _isLoading = false;
                });
              }
              : () async { // Show login modal if not logged in
                // Show bottom modal with login form
                bool? success = await showModalBottomSheet<bool>(
                  isScrollControlled: true,
                  context: context, 
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) {
                    PageController pageController = PageController();

                    return SizedBox(
                      height: (MediaQuery.of(context).size.height * 0.5) + MediaQuery.of(context).viewInsets.bottom, // Use 50% of screen height plus keyboard height
                      child: Scaffold(
                        resizeToAvoidBottomInset: true,
                        backgroundColor: Colors.transparent,
                        body: BaseLayout(
                          child: PageView(
                            controller: pageController,
                            physics: const NeverScrollableScrollPhysics(), // Disable swipe to change pages
                            children: [
                              LoginPage(
                                widget.dio, 
                                onGoToRegister: () {
                                  pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                },
                                onLoginFailure: (message) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(message)
                                    ),
                                  );
                                }, 
                                onLoginSuccess: () => Navigator.of(context).pop(true), // Pass true to indicate successful login, which will trigger the success flow in the caller after the modal is dismissed
                              ),
                              RegisterPage(
                                onGoToLogin: () {
                                  pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                );

                if (success != null && success == true) {
                  _checkLoginStatus();
              
                  // Dismiss the modal and show success message in the main scaffold
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text("Logged in successfully")
                      ),
                    );
                  }
                }
              },
            child: 
              _isLoggedIn
              ? _isLoading 
                ? const CircularProgressIndicator()
                : const Text('Logout', style: TextStyle(color: Colors.red),) 
              : const Text('Login'),
            ),
        ],
      ),
    );
  }
}