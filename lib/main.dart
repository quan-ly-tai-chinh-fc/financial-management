import 'package:flutter/material.dart';
import './financial_profile.dart' show FinancialProfile;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Tài Chính',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _saying = "What comes around will turn around !";
  // Gọi hàm lấy chuỗi thông tin tài chính từ class FinancialProfile
  String test = FinancialProfile().getFinancialProfile();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Welcome to My Home Page"),
      ),
      body: Center(
        child: Container(
          color: const Color(0xFFE9F5F8),
          width: width * 0.95,
          height: width * 0.99,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(_saying),
              const SizedBox(height: 12),
              Text(
                test,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}