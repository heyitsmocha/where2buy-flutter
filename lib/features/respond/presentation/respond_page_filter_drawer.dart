import 'package:flutter/material.dart';

class RespondPageFilterDrawer extends StatefulWidget {
  const RespondPageFilterDrawer({super.key});

  @override
  State<RespondPageFilterDrawer> createState() => _RespondPageFilterDrawerState();
}

class _RespondPageFilterDrawerState extends State<RespondPageFilterDrawer> {
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