import 'package:flutter/material.dart';
import 'package:w2b_flutter/components/base_layout.dart';

class RespondListPage extends StatefulWidget {
  const RespondListPage({super.key});

  @override
  State<RespondListPage> createState() => _RespondListPageState();
}

class _RespondListPageState extends State<RespondListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
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
      ),
      body: BaseLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Search bar
          IntrinsicHeight(
            child: SearchBar(
              hintText: 'Search for requests...',
              onChanged: (value) {
                // Handle search input change
              },
              onSubmitted: (value) {
                // Handle search submission
              },
              trailing: [
                const Icon(Icons.search),
                const VerticalDivider(),
                IconButton(
                  onPressed: () {
                    // TODO: temporary: go to respond page
                    Navigator.pushNamed(context, '/respond');

                    // _scaffoldKey.currentState?.openEndDrawer();
                  }, 
                  icon: const Icon(Icons.filter_alt_outlined), 
                  tooltip: "Filter requests",
                ),
              ],
            ),
          ),
          // List of nearby requests
          const Expanded(
            child: Center(
              child: Text('List of nearby requests will be shown here.'),
            ),
          ),
        ],
      ),
    ),
    );
  }
}