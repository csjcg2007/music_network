import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/messages.dart';
import 'package:flutter_application_1/pages/user_profile_page.dart';

class UserDiscovery extends StatefulWidget {
  const UserDiscovery({super.key});
  @override
  State<UserDiscovery> createState() => _UserDiscoveryState();
}

class _UserDiscoveryState extends State<UserDiscovery> {
  int _selectedIndex = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final List<Widget> _widgetOptions = <Widget>[
    const Text('User Profile Screen'), // Replace with your actual User Profile Screen (currently empty)
    const Text('Viewing Other User Profiles'), // Replace with your actual User Profiles Screen
    const Text('Messaging Match Screen'), // Replace with your actual Messaging Match Screen
  ];

  //this function finds the next profile from firestore and gets it
  Future<DocumentSnapshot<Map<String, dynamic>>> getNextProfile() async{
    //firestore search
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore.collection('users').limit(1).get();
    if(snapshot.docs.isNotEmpty){
      return snapshot.docs.first;
    } 
    throw Exception('no profiles found');
  } 
  
  void onLike(String userId){
    //TODO: handle the 'like' action
    //fetch the next profile
    //setState
  }

  void onDislike(String userId){
    //TODO: handle the 'dislike' action
    //fetch the next profile
    //setState
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
            MaterialPageRoute(
            builder: (context) => const UserProfile()),
                      );

        break;
      case 1:
        //Navigator.pushNamed(context, 'userDiscovery');
          Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) => const UserDiscovery()),
                      );

        break;
      case 2:
        //Navigator.pushNamed(context, 'messages');
        Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => const Messages()),
                      );
        
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Discovery'),
      ),
      //body: Center(
        //child: _widgetOptions.elementAt(_selectedIndex),
      //),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getNextProfile(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          } else if(snapshot.hasError){
            return Center(child: Text('error: ${snapshot.error}'));
          } else if(!snapshot.hasData || snapshot.data!.data() == null){
            return const Center(child: Text('no profile available'),);
          }
          var userProfile = snapshot.data!.data()!;
          var userId = snapshot.data!.id;

          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20), 
                userProfile['imageUrl'] != null ? Image.network(userProfile['imageUrl']): const Placeholder(fallbackHeight: 200,),
                Text(userProfile['username'] ?? 'no name provided', style: const TextStyle(fontSize: 24),),
                Text(userProfile['bio'] ?? 'no bio provided', style: const TextStyle(fontSize: 16),),
                Wrap(
                  spacing: 8.0,
                  children: List<Widget>.from(userProfile['instruments']?.Map(
                    (instrument){
                      return Chip(label: Text(instrument));
                    }
                  ) ?? []), 
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(onPressed: ()=>onDislike(userId), icon: const Icon(Icons.close, size: 50, color: Colors.red,)),
                    IconButton(onPressed: ()=>onLike(userId), icon: const Icon(Icons.favorite, size: 50, color: Colors.green,))
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
            label: 'Home', //profile page (picture, bio, media, etc.)
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
