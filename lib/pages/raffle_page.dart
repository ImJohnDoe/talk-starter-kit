import 'package:flutter/material.dart';
import 'package:social_raffle/api.dart';

class RaffleArguments {
  final int raffleId;
  const RaffleArguments(this.raffleId);
}

class RafflePage extends StatefulWidget {
  const RafflePage({Key? key}) : super(key: key);

  @override
  State<RafflePage> createState() => _RafflePageState();

  static routeHere(BuildContext context, RaffleArguments args) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RafflePage(),
        settings: RouteSettings(
          arguments: args,
        ),
      ),
    );
  }
}

class _RafflePageState extends State<RafflePage> {
  Future<RaffleWithRelations>? raffles;
  Api api = Api();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as RaffleArguments;
    raffles ??= api.fetchRaffleWithRelations(args.raffleId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<RaffleWithRelations>(
          future: raffles,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!.name);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
      body: FutureBuilder<RaffleWithRelations>(
        future: raffles,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final raffle = snapshot.data!;
            return Column(
              children: [
                Container(
                  color: Theme.of(context).backgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text('Use Social'),
                            Switch(value: false, onChanged: (v) {}),
                            const Text('Allow Repeat'),
                            Switch(value: false, onChanged: (v) {}),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            api.addWinningEntry(raffle.raffleId, 2);
                            final args = ModalRoute.of(context)!
                                .settings
                                .arguments as RaffleArguments;
                            setState(() {
                              raffles =
                                  api.fetchRaffleWithRelations(args.raffleId);
                            });
                          },
                          child: const Text('Draw a Winner'),
                        )
                      ],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: (raffle.entries
                          ..sort((a, b) => raffle.isWinningEntry(a) ? 0 : 1))
                        .map(
                          (e) => ListTile(
                            title: Text(
                              e.cost,
                              style: TextStyle(
                                color: raffle.isWinningEntry(e)
                                    ? Colors.green
                                    : Colors.black,
                              ),
                            ),
                            trailing: Wrap(
                              children: [
                                Stack(
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.arrow_upward),
                                    ),
                                    VoteCountWidget(e.positiveVotes()),
                                  ],
                                ),
                                Stack(
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.arrow_downward),
                                    ),
                                    VoteCountWidget(e.negativeVotes())
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

class VoteCountWidget extends StatelessWidget {
  final int count;
  const VoteCountWidget(
    this.count, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (count > 0)
        ? Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 16,
              child: Center(
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
        : Container(
            width: 0,
          );
  }
}
