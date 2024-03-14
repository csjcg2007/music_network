import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/pages/user_discovery.dart';
import 'package:flutter_application_1/pages/user_profile_page.dart';
import 'package:provider/provider.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key); // Fixed constructor syntax
  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  late String? userId;

  void sendMessage(String receiverUserId, String message) async {
    if (message.trim().isNotEmpty) {
      //save message to firestore 'messages' collection
      await _firestore.collection('message').add({
        'senderId': userId,
        'receiverId': receiverUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'content': message,
      });
      _messageController.clear();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        //Navigator.pushNamed(context, 'userProfile');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserProfile()),
        );

        break;
      case 1:
        //Navigator.pushNamed(context, 'userDiscovery');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserDiscovery()),
        );

        break;
      case 2:
        //Navigator.pushNamed(context, 'messages');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Messages()),
        );

        break;
      default:
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //handle incoming messages for real-time updates
      //TODO: update the message list view with a new message
    });
    userId = Provider.of<UserModel>(context, listen: false).userId;
  }

  Widget itemBuilder(BuildContext context, int index) {
    return ListTile(
      title: Text('Item $index'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      //body: Center(
      //child: _widgetOptions.elementAt(_selectedIndex),
      //),
      body: StreamBuilder<QuerySnapshot>(
        //stream of matches where the user is involved
        stream: _firestore
            .collection('matches')
            .where('users', arrayContains: userId)
            .snapshots(),
        builder: (context, snapshot) {
          Future.delayed(const Duration(milliseconds: 10), () => '1');
          if (snapshot.connectionState == ConnectionState.waiting) {
            // ERROR 1: Fixed equality operator
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching matches'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No matches yet'),
            );
          }
          //assuming that each match document contains 'matchedUserId', 'matchedUsername', 'matchedUserImageUrl'
          return ListView.builder(
              itemBuilder: itemBuilder); // ERROR 2: see line 50
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
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
