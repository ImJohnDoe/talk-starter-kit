import 'package:flutter/material.dart';
import 'package:social_raffle/pages/raffles_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Raffle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RafflesPage(),
    );
  }
}
