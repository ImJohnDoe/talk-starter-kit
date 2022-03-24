import 'package:flutter/material.dart';
import 'package:social_raffle/widgets/raffle_list_widget.dart';

class RafflesPage extends StatelessWidget {
  const RafflesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Raffle'),
      ),
      body: const RafflesListWidget(),
    );
  }
}
