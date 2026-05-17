import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gospel_stream/screens/creator_screen.dart';
import 'package:gospel_stream/screens/home_screen.dart';
import 'package:gospel_stream/screens/music_screen.dart';
import 'package:gospel_stream/screens/profile_screen.dart';
import 'package:gospel_stream/services/app_state.dart';

void main() {
  runApp(const GospelApp());
}

class GospelApp extends StatelessWidget {
  const GospelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Gospel Stream',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0B1724),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF67D7F7),
            brightness: Brightness.dark,
            surface: const Color(0xFF0B1724),
            primary: const Color(0xFF67D7F7),
          ),
          textTheme: ThemeData.dark().textTheme.apply(
                fontFamily: 'Inter',
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Color(0x1AFFFFFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: const MainShell(),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    // Initialize app by fetching content from backend on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().initializeApp();
    });
  }

  static const List<Widget> pages = [
    HomeScreen(),
    MusicScreen(),
    CreatorScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      body: SafeArea(child: pages[appState.selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: appState.selectedIndex,
        onDestinationSelected: appState.updateTab,
        backgroundColor: Colors.white12,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.music_note), label: 'Music'),
          NavigationDestination(icon: Icon(Icons.create), label: 'Creator'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
