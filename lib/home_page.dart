import 'package:flutter/material.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});
  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  padding: WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.all(10)),
                  leading: const Icon(Icons.search),
                  backgroundColor: WidgetStatePropertyAll<Color>(Theme.of(context).colorScheme.secondary),
                );
              },
              suggestionsBuilder: (BuildContext context, SearchController controller) {
                return [Container()];
              }
            ),
          ),
          Text('TODO: finish home page')
        ],
      ),
    );
  }
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: [HomePageContent(), ProfilePage()][_selectedIndex]
      ),
      bottomNavigationBar: BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
          
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      onTap: _onItemTapped,
      ),
    );
  }
}