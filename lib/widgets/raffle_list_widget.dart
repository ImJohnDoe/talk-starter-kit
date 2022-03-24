import 'package:flutter/material.dart';
import 'package:social_raffle/api.dart';
import 'package:social_raffle/pages/raffle_page.dart';

class RafflesListWidget extends StatefulWidget {
  const RafflesListWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<RafflesListWidget> createState() => _RafflesListWidgetState();
}

class _RafflesListWidgetState extends State<RafflesListWidget> {
  Future<List<Raffle>>? raffles;
  Api api = Api();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    raffles ??= api.fetchRaffles();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Raffle>>(
      future: raffles,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: snapshot.data!
                .map(
                  (e) => ListTile(
                    leading: const Icon(Icons.local_attraction),
                    title: Text(e.name),
                    subtitle: Text(e.description),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      RafflePage.routeHere(
                        context,
                        RaffleArguments(e.raffleId),
                      );
                    },
                  ),
                )
                .toList(),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
}
