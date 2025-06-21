import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, int> _voteCounts = {};
  String? _winner;

  @override
  void initState() {
    super.initState();
    _fetchVoteCounts();
  }

  Future<void> _fetchVoteCounts() async {
    final candidates = [
      'Amitabh Bachchan',
      'Shah Rukh Khan',
      'Mahesh Babu',
      'Allu Arjun',
      'Rajnikanth',
      'Kamal Haasan'
    ];

    Map<String, int> voteCounts = {};
    String? winner;
    int highestVotes = 0;

    for (final candidate in candidates) {
      try {
        final doc = await _firestore.collection('votes').doc(candidate).get();
        if (doc.exists && doc.data() != null) {
          final votes = doc.data()!['votes'] as int? ?? 0;
          voteCounts[candidate] = votes;

          if (votes > highestVotes) {
            highestVotes = votes;
            winner = candidate;
          }
        } else {
          voteCounts[candidate] = 0;
        }
      } catch (e) {
        print('Error fetching votes for $candidate: $e');
        voteCounts[candidate] = 0;
      }
    }

    setState(() {
      _voteCounts = voteCounts;
      _winner = winner;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Election Results'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.green,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _voteCounts.entries.map((entry) {
              return _buildResultCard(entry.key, entry.value);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(String candidateName, int votes) {
    final isWinner = _winner == candidateName;
    final imageName = candidateName.replaceAll(' ', '');
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: isWinner ? Color(0xffFFC100) : Colors.blue,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60.0,
              backgroundImage: AssetImage('assets/$imageName.jpg'),
            ),
            const SizedBox(height: 16.0),
            Text(
              candidateName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              '$votes votes',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            if (isWinner)
              const Text(
                'Winner!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
