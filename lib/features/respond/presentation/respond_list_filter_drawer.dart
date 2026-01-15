import 'package:flutter/material.dart';

class RespondFilterDrawer extends StatefulWidget {
  const RespondFilterDrawer({super.key});

  @override
  State<RespondFilterDrawer> createState() => _RespondFilterDrawerState();
}

class _RespondFilterDrawerState extends State<RespondFilterDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Filter Requests',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.local_grocery_store),
              title: const Text('Groceries'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Electronics'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.toys),
              title: const Text('Collectibles'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.spa),
              title: const Text('Beauty & Wellness'),
              onTap: () {},
            ),
          ],
        ),
      );
    }
  }