import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BallotScreen extends StatefulWidget {
  const BallotScreen({super.key});

  @override
  State<BallotScreen> createState() => _BallotScreenState();
}

class _BallotScreenState extends State<BallotScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _selectedCandidate;
  bool _hasVoted = false;

  @override
  void initState() {
    super.initState();
    _checkUserVoteStatus();
  }

  Future<void> _checkUserVoteStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _hasVoted = doc.exists;
      });
    }
  }

  Future<void> _voteForCandidate(String candidate) async {
    final user = _auth.currentUser;
    if (user != null && !_hasVoted) {
      // Update votes collection
      final candidateDoc = _firestore.collection('votes').doc(candidate);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(candidateDoc);
        if (snapshot.exists) {
          transaction.update(candidateDoc, {
            'votes': FieldValue.increment(1),
          });
        } else {
          transaction.set(candidateDoc, {
            'votes': 1,
          });
        }
      });

      // Update users collection
      await _firestore.collection('users').doc(user.uid).set({
        'votedFor': candidate,
      });

      setState(() {
        _selectedCandidate = candidate;
        _hasVoted = true;
      });

      // Show snack bar with vote confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You voted for $candidate'),
        ),
      );

      // Show dialog with vote confirmation
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Vote Confirmation'),
            content: Text('You have successfully voted for $candidate.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Election Candidates'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.green,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCandidateCard(
                  'Amitabh Bachchan', 'assets/AmitabhBachchan.jpg'),
              _buildCandidateCard('Shah Rukh Khan', 'assets/ShahRukhKhan.jpg'),
              _buildCandidateCard('Mahesh Babu', 'assets/MaheshBabu.jpg'),
              _buildCandidateCard('Allu Arjun', 'assets/AlluArjun.jpg'),
              _buildCandidateCard('Rajnikanth', 'assets/Rajnikanth.jpg'),
              _buildCandidateCard('Kamal Haasan', 'assets/KamalHaasan.jpg'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCandidateCard(String candidateName, String assetPath) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60.0,
              backgroundImage: AssetImage(assetPath),
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
            ElevatedButton(
              onPressed: _hasVoted
                  ? null
                  : () {
                      _voteForCandidate(candidateName);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 18.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Vote'),
            ),
          ],
        ),
      ),
    );
  }
}
