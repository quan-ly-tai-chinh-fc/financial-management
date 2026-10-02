import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/transaction_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản Lý Tài Chính',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    TransactionScreen(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  final List<String> titles = const [
    'Trang chủ',
    'Giao dịch',
    'Thống kê',
    'Cá nhân',
  ];

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: Text(
          titles[currentIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade100,
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: changePage,
      ),
    );
  }
}