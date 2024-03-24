import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/user_discovery.dart';
import 'package:flutter_application_1/pages/user_profile_page.dart';
import 'package:provider/provider.dart';

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  late String? userId;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Implement your logic to handle incoming messages here.
      // For example, you might want to show a notification or update the UI.
    });

    Future.delayed(Duration.zero, () {
      userId = Provider.of<UserModel>(context, listen: false).userId;
    });
  }

  void sendMessage(String receiverUserId, String message) async {
    if (message.trim().isNotEmpty) {
      await _firestore.collection('messages').add({
        'senderId': userId,
        'receiverId': receiverUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'content': message,
      });
      _messageController.clear();
    }
  }

  Future<void> _onItemTapped(int index) async {
    if (index == _selectedIndex) {
      // Prevent navigation to the same page
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    Widget page;
    switch (index) {
      case 0:
        page = const UserProfile();
        break;
      case 1:
        page = const UserDiscovery();
        break;
      case 2:
        return; // Current page, do nothing
      case 3:
        await FirebaseAuth.instance.signOut();
        page = const LoginPage();
        break;
      default:
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Widget itemBuilder(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        final matchDoc = snapshot.data!.docs[index];
        return ListTile(
          title: Text(matchDoc['matchedUsername']),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(matchDoc['matchedUserImageUrl'] ?? 'default_image_url'),
          ),
          onTap: () {
            String? userIdReceiver = matchDoc['matchedUserId'];
            // Navigate to chat screen with userIdReceiver
            // e.g., Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(userIdReceiver: userIdReceiver)))
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('matches')
            .where('users', arrayContains: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching matches'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No matches yet'));
          }

          return itemBuilder(context, snapshot);
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
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
