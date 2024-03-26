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
  DocumentSnapshot<Map<String, dynamic>>? currentProfile;

  Future<void> getNextProfile() async {
    // Adjust this query to avoid repeating profiles and exclude the current user's profile
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('users').limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        currentProfile = snapshot.docs.first;
      });
    } else {
      // Handle the case where no more profiles are found
      setState(() {
        currentProfile = null;
      });
    }
  }

  void onLike(String userId) {
    // Add the user to the 'likes' and then fetch the next profile
    _firestore.collection('users').doc(userId).update({
      'likes': FieldValue.arrayUnion([userId])
    }).then((_) => getNextProfile());
  }

  void onDislike(String userId) {
    // Add the user to the 'dislikes' and then fetch the next profile
    _firestore.collection('users').doc(userId).update({
      'dislikes': FieldValue.arrayUnion([userId])
    }).then((_) => getNextProfile());
  }

  @override
  void initState() {
    super.initState();
    getNextProfile(); // Fetch the first profile when the widget is initialized
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
        page = Messages(
            receiverUserId: currentProfile!.id,
            receiverUserName: currentProfile?.data()?['username']);
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
      body: currentProfile == null
          ? const Center(child: Text('No more profiles available'))
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 20),
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage(currentProfile?.data()?['imageUrl'] ?? ''),
                    radius: 60,
                  ),
                  Text(
                    currentProfile?.data()?['username'] ?? 'no name provided',
                    style: const TextStyle(fontSize: 24),
                  ),
                  Text(
                    currentProfile?.data()?['UserBio'] ?? 'no bio provided',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: List<Widget>.from(currentProfile
                            ?.data()?['instruments']
                            ?.map((instrument) {
                          return Chip(label: Text(instrument));
                        }) ??
                        []),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                          onPressed: () => onDislike(currentProfile!.id),
                          icon: const Icon(
                            Icons.close,
                            size: 50,
                            color: Colors.red,
                          )),
                      IconButton(
                          onPressed: () => onLike(currentProfile!.id),
                          icon: const Icon(
                            Icons.favorite,
                            size: 50,
                            color: Colors.green,
                          )),
                      IconButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Messages(
                                      receiverUserId: currentProfile!.id,
                                      receiverUserName: currentProfile
                                          ?.data()?['username']))),
                          icon: const Icon(
                            Icons.message,
                            size: 50,
                            color: Colors.blue,
                          ))
                    ],
                  )
                ],
              ),
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
