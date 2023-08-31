import 'package:flutter/material.dart';
import 'screen/all_screen_export.dart';
import 'screen/feedback_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  PageController pageController = PageController();

  void onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('English Research'),
      ),
      body: PageView(
        // Prevent from swiping between views
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: const [
          AudioList(),
          ClarityListView(),
          FeedbackListView(),
          SettingScreen()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.audiotrack), label: 'Audios'),
          BottomNavigationBarItem(
              icon: Icon(Icons.record_voice_over), label: 'Records'),
          BottomNavigationBarItem(
              icon: Icon(Icons.feedback), label: 'Feedback'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: onTapped,
      ),
    );
  }
}
