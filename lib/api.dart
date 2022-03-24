import 'dart:convert';

import 'package:http/http.dart' as http;

class Api {
  Future<List<Raffle>> fetchRaffles() async {
    final response = await http
        .get(Uri.parse('https://social-raffle-api.glitch.me/raffles'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return (jsonDecode(response.body) as List)
          .map((raffle) => Raffle.fromJson(raffle))
          .toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  Future<RaffleWithRelations> fetchRaffleWithRelations(int id) async {
    final filter = Uri.encodeQueryComponent(
        '{"include":[{"relation":"entries","scope":{"include":[{"relation":"votes"},{"relation":"participant"}]}},{"relation":"winningEntries","scope":{"include":[{"relation":"votes"},{"relation":"participant"}]}}]}');
    final response = await http.get(Uri.parse(
        'https://social-raffle-api.glitch.me/raffles/$id?filter=$filter'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return RaffleWithRelations.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  Future addWinningEntry(int raffleId, int entryId) async {
    final response = await http.post(
      Uri.parse('https://social-raffle-api.glitch.me/winning-entries'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, Object>{"raffleId": raffleId, "entryId": entryId}),
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then return
      return;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }
}

class Raffle {
  final int raffleId;
  final String name;
  final String cost;
  final String description;

  const Raffle({
    required this.raffleId,
    required this.name,
    required this.cost,
    required this.description,
  });

  factory Raffle.fromJson(Map<String, dynamic> json) {
    return Raffle(
      raffleId: json['raffleId'],
      name: json['name'],
      cost: json['cost'],
      description: json['description'],
    );
  }
}

class RaffleWithRelations {
  final int raffleId;
  final String name;
  final String cost;
  final String description;
  final List<Entry> entries;
  final List<Entry> winningEntries;

  const RaffleWithRelations({
    required this.raffleId,
    required this.name,
    required this.cost,
    required this.description,
    required this.entries,
    required this.winningEntries,
  });

  bool isWinningEntry(Entry entry) {
    return winningEntries
        .map(
          (e) => e.entryId,
        )
        .contains(entry.entryId);
  }

  factory RaffleWithRelations.fromJson(Map<String, dynamic> json) {
    return RaffleWithRelations(
      raffleId: json['raffleId'],
      name: json['name'],
      cost: json['cost'],
      description: json['description'],
      entries: ((json['entries'] ?? []) as List)
          .map((e) => Entry.fromJson(e))
          .toList(),
      winningEntries: ((json['winningEntries'] ?? []) as List)
          .map((e) => Entry.fromJson(e))
          .toList(),
    );
  }
}

class Entry {
  final int entryId;
  final String cost;
  final int raffleId;
  final int participantId;
  final List<Vote> votes;
  final Participant? participant;

  const Entry({
    required this.entryId,
    required this.cost,
    required this.raffleId,
    required this.participantId,
    required this.votes,
    this.participant,
  });

  int positiveVotes() {
    return votes.where((v) => v.isPositive).length;
  }

  int negativeVotes() {
    return votes.where((v) => !v.isPositive).length;
  }

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      entryId: json['entryId'],
      cost: json['cost'],
      raffleId: json['raffleId'],
      participantId: json['participantId'],
      votes:
          ((json['votes'] ?? []) as List).map((e) => Vote.fromJson(e)).toList(),
      participant: Participant.fromJson(json['participant']),
    );
  }
}

class Participant {
  final int participantId;
  final String name;

  const Participant({
    required this.participantId,
    required this.name,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      participantId: json['participantId'],
      name: json['name'],
    );
  }
}

class Vote {
  final int voteId;
  final bool isPositive;
  final int participantId;
  final int entryId;

  const Vote({
    required this.voteId,
    required this.isPositive,
    required this.participantId,
    required this.entryId,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      voteId: json['voteId'],
      isPositive: json['isPositive'],
      participantId: json['participantId'],
      entryId: json['entryId'],
    );
  }
}
