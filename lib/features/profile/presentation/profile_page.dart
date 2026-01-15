import 'package:flutter/material.dart';
import 'package:w2b_flutter/components/base_layout.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton(
            onPressed: () {},
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  // backgroundImage: 
                ),
                SizedBox(width: 20,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Username', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                    Text('user@example.com'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 50,),
          const Expanded(child: Text('Placeholder')),
          const Divider(height: 50,),
          // TODO: Display login/logout button based on authentication status
          ElevatedButton(
            onPressed: () {},
            child: const Text('Logout', style: TextStyle(color: Colors.red),),
            ),
        ],
      ),
    );
  }
}