import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/user_discovery.dart';
import 'package:flutter_application_1/pages/user_profile_page.dart';
import 'package:provider/provider.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  int _selectedIndex =
      0; // Keep track of the selected index for the bottom navigation bar
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  late String? userId;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      userId = Provider.of<UserModel>(context, listen: false).userId;
    });
  }

  void sendMessage(String receiverUserId, String message) async {
    if (message.trim().isEmpty) {
      return;
    }

    try {
      await _firestore.collection('messages').add({
        'senderId': userId,
        'receiverId': receiverUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'content': message.trim(),
      });

      _messageController.clear();
    } catch (error) {
      print("Error sending message: $error");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .where('senderId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message =
                        messages[index].data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(message['content']),
                      subtitle: Text(message['timestamp'].toDate().toString()),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Enter your message here...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => sendMessage(
                      "receiverUserId",
                      _messageController
                          .text), // Update "receiverUserId" accordingly
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
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
