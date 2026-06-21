import 'package:flutter/material.dart';
import '../main.dart';
import 'beranda.dart';
import 'halaman_profil.dart';
import 'halaman_setting.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    appLanguage.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const Beranda(),
      const HalamanProfil(),
      const HalamanSettings(),
    ];
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: appLanguage.t('home')),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: appLanguage.t('profile')),
          BottomNavigationBarItem(icon: const Icon(Icons.settings_outlined), label: appLanguage.t('settings')),
        ],
      ),
    );
  }
}