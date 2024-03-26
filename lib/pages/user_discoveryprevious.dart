import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/messages.dart';
import 'package:flutter_application_1/pages/user_profile_page.dart';

class UserDiscovery extends StatefulWidget {
  const UserDiscovery({super.key});
  @override
  State<UserDiscovery> createState() => _UserDiscoveryState();
}

class _UserDiscoveryState extends State<UserDiscovery> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [
    const UserProfile(),
    const UserDiscovery(),
    Messages(),
    const LoginPage(),
  ];

  //this function finds the next profile from firestore and gets it
  Future<DocumentSnapshot<Map<String, dynamic>>> getNextProfile() async {
    // firestore search for the next user different from the current user
    QuerySnapshot<Map<String, dynamic>> snapshot =
        // Get the next user different from the current user
        await _firestore.collection('users').limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      // return the first profile found
      return snapshot.docs.first;
    } else {
      throw Exception('no more users found');
    }
  }

  void onLike(String userId) {
    // Step 1: Add the user to the 'likes' collection of the current user
    _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'likes': FieldValue.arrayUnion([userId])
    });
    // Step 2: fetch the next profile
    getNextProfile();
    // Step 3: setState
    setState(() {});
  }

  void onDislike(String userId) {
    // Step 1: Add the user to the 'dislikes' collection of the current user
        _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'dislikes': FieldValue.arrayUnion([userId])
    });
    // Step 2: fetch the next profile
    getNextProfile();
    // Step 3: setState
    setState(() {});
  }

  Future<void> _onItemTapped(int index) async {
    print("Tapped index: $index");
    if (index == _selectedIndex) {
      // Prevent navigation to the same page
      return;
    }

    setState(() {
      _selectedIndex = index;
      print("Updated _selectedIndex: $_selectedIndex");
    });

    Widget page;
    switch (index) {
      case 0:
        page = const UserProfile();
        break;
      case 1:
        return; // Current page, do nothing
      case 2:
        page = Messages();
      case 3:
        await FirebaseAuth.instance.signOut();
        page = const LoginPage();
        break;
      default:
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('User Discovery')),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getNextProfile(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(
              child: Text('no profile available'),
            );
          }
          var userProfile = snapshot.data!.data()!;
          var userId = snapshot.data!.id;

          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                //_widgetOptions.elementAt(_selectedIndex),
                const SizedBox(height: 20),

                CircleAvatar(
                  backgroundImage: NetworkImage(userProfile['imageUrl'] ?? ''),
                ),
                Text(
                  userProfile['username'] ?? 'no name provided',
                  style: const TextStyle(fontSize: 24),
                ),
                Text(
                  userProfile['UserBio'] ?? 'no bio provided',
                  style: const TextStyle(fontSize: 16),
                ),
                Wrap(
                  spacing: 8.0,
                  children: List<Widget>.from(
                      userProfile['instruments']?.map((instrument) {
                            return Chip(label: Text(instrument));
                          }) ??
                          []),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                        onPressed: () => onDislike(userId),
                        icon: const Icon(
                          Icons.close,
                          size: 50,
                          color: Colors.red,
                        )),
                    IconButton(
                        onPressed: () => onLike(userId),
                        icon: const Icon(
                          Icons.favorite,
                          size: 50,
                          color: Colors.green,
                        ))
                  ],
                )
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
