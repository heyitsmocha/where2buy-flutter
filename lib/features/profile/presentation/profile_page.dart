import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:w2b_flutter/auth_state.dart';
import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/core/network_results.dart';
import 'package:w2b_flutter/util/api_util.dart';
import 'package:w2b_flutter/util/auth_util.dart';

class ProfilePage extends StatefulWidget {
  final Dio dio;

  const ProfilePage({super.key, required this.dio});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;
  String _username = 'Guest';
  String _email = '';

  @override
  void initState() {
    super.initState();
    
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateUserDetails();
      });
  }

  void _updateUserDetails() async {
    bool isLoggedIn = context.read<AuthState>().isLoggedIn;
    print('Checking login status in ProfilePage...');
    const storage = FlutterSecureStorage();
    bool hasToken = await storage.containsKey(key: 'auth_token');
    if (isLoggedIn && hasToken) {
      print('Auth token found, user is logged in');
      String tempName, tempEmail;
      // Name and email from sharedprefs
      final prefs = await SharedPreferences.getInstance();
      tempName = prefs.getString('username') ?? 'Guest';
      tempEmail = prefs.getString('email') ?? '';
      setState(() {
        _username = tempName;
        _email = tempEmail;
      });
    } else {
      print('No auth token found, user is not logged in');
      setState(() {
        _username = 'Guest';
        _email = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthState authState = context.read<AuthState>();
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
                    Text(_username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                    Text(_email),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 50,),
          const Expanded(child: Text('')),
          const Divider(height: 25,),
          ElevatedButton(
            onPressed: 
              authState.isLoggedIn
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
                  print('DioException: Logout failed');
                }

                // Assume logout is successful even if it failed to ensure user is logged out locally

                // Notify the AuthState to update UI across the app
                authState.logout();

                const storage = FlutterSecureStorage();
                storage.delete(key: 'auth_token');

                final prefs = await SharedPreferences.getInstance();
                prefs.remove('username');
                prefs.remove('email');

                _updateUserDetails();
                if (context.mounted) {
                  // Dismiss sidebar and show success message in main scaffold
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
                Result loginResult = await AuthUtil.showAuthForm(
                  context,
                  widget.dio, 
                  onAuthSuccess: (successMessage) => _updateUserDetails(),
                );

                // Dismiss the sidebar and show success message in the main scaffold
                if (loginResult is Success) {
                   if(context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: Text(loginResult.value == "Login" ? "Logged in successfully. Welcome back!" : "Account created successfully. Welcome aboard!"),
                      ),
                    );
                   }
                }
              },
            child: 
              authState.isLoggedIn
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