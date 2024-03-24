import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/media/media_item.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/pages/messages.dart';
import 'package:flutter_application_1/pages/user_discovery.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});
  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  int _selectedIndex = 0;
  List<String>? userInstruments;
  late File _image_profile;
  final imagePicker = ImagePicker();
  final userCollectionRef = FirebaseFirestore.instance.collection('users');
  String bio = '';
  late Stream<QuerySnapshot> _mediaStream;
  late List<DocumentSnapshot> _mediaDocs = [];

  late String? userId;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    userId = Provider.of<UserModel>(context, listen: false).userId;
    _getUserInstruments();
    _getUserBio();
    // Loads the media for the current user
    _mediaStream = FirebaseFirestore.instance
        .collection('media')
        .where('userId', isEqualTo: userId)
        .snapshots();
    _loadMedia();
  }

  Future getImage(bool isCamera) async {
    final pickedFile = await imagePicker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image_profile = File(pickedFile.path);
      });
    }
  }

  Future UploadImageToFirebaseStorage(File image) async {
    //userId = 'userId';
    Reference storageReference = FirebaseStorage.instance.ref();
    Reference imageFolderRef = storageReference.child('images');
    Reference imageReference = imageFolderRef.child('$userId.jpg');
    //upload file
    UploadTask uploadTask = imageReference.putFile(image);
    //handle upload tasks state
    uploadTask.whenComplete(() async {
      try {
        imageUrl = await imageReference.getDownloadURL();
        await userCollectionRef.doc(userId).set({
          'imageUrl': imageUrl,
        }, SetOptions(merge: true));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('failed to update profile imageUrl in user table: $e')));
      }
    });
  }

  Future<void> uploadMedia(String userId, File mediaFile, String type) async {
    // Generate a unique file name
    String fileName =
        'images/${userId}_${DateTime.now().millisecondsSinceEpoch}';

    // Upload to Firebase Storage
    Reference ref = FirebaseStorage.instance.ref().child(fileName);
    await ref.putFile(mediaFile);

    // Get the download URL
    String downloadUrl = await ref.getDownloadURL();

    // Save media item to Firestore
    await FirebaseFirestore.instance.collection('media').add({
      'userId': userId,
      'url': downloadUrl,
      'type': type, // 'image', 'video', 'audio'
    });
  }

  Future<bool?> _showImageSourceDialogue(BuildContext context) async {
    return showDialog<bool>(
        context: context,
        barrierDismissible:
            true, //user can dismiss dialogue box by tapping outside of it
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Provide Image'),
            content: SingleChildScrollView(
                child: ListBody(children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context, true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context, false);
                },
              )
            ])),
          );
        });
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const Text(
        'User Profile Screen'), // Replace with your actual User Profile Screen
    const Text(
        'Viewing Other User Profiles'), // Replace with your actual User Profiles Screen
    const Text(
        'Messaging Match Screen'), // Replace with your actual Messaging Match Screen
  ];

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

  Future<String?> _getUserProfileImageUrl(String userId) async {
    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data()?['imageUrl'] as String?;
  }

  Future<String?> _getUserInstruments() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      setState(() {
        userInstruments =
            (userDoc['instruments'] as List<dynamic>).cast<String>();
      });
    }
    return null;
  }

  Future<void> _getUserBio() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      setState(() {
        bio = userDoc['userBio'] ?? '';
      });
    }
  }

// Function to load media on initial state
  Future<void> _loadMedia() async {
    QuerySnapshot mediaQuerySnapshot = await FirebaseFirestore.instance
        .collection('media')
        .where('userId', isEqualTo: userId)
        .get();
    setState(() {
      _mediaDocs = mediaQuerySnapshot.docs;
    });
  }

  Future<String?> _getMediaUrl(String userId) async {
    var userDoc =
        await FirebaseFirestore.instance.collection('media').doc(userId).get();
    return userDoc.data()?['url'] as String?;
  }

  Widget _displayMediaItem(DocumentSnapshot mediaDoc) {
    switch (mediaDoc['type']) {
      case 'image':
        //check mediaDoc url if it is = to empty string; if so, display error message using snackbar
        if (mediaDoc['url'] == '') {
          return const Text('Error: no image found');
        }
        return Image(
          image: NetworkImage(mediaDoc['url']),
          height: 48,
          width: 48,
          fit: BoxFit.cover,
        );
      case 'video':
      //return VideoPlayerWidget(url : mediaDoc['url']);
      case 'audio':
      //return AudioPlayerWidget(url : mediaDoc['url']);

      default:
        return const Placeholder();
    }
  }

  Future<void> _handleEditMedia(DocumentSnapshot mediaDoc) async {
    // Example: Edit metadata via a Dialog
    await showDialog(
      context: context,
      builder: (context) {
        TextEditingController titleController = TextEditingController(
            text: mediaDoc['images']); // Add more controllers

        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              // ... Add fields for other editable metadata ...
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                mediaDoc.reference.update({
                  'url': titleController.text,
                  // ... Other metadata fields ...
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDeleteMedia(DocumentSnapshot mediaDoc) async {
    try {
      // 1. Delete file from Storage
      await FirebaseStorage.instance.refFromURL(mediaDoc['url']).delete();

      // 2. Delete document entry from Firestore
      await mediaDoc.reference.delete();

      // 3. (Optional) Reload media
      _loadMedia(); // Reload media data to reflect changes
    } on FirebaseException catch (e) {
      // Handle potential errors during deletion
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting media: $e')));
    }
  }

// This method handles the addition of new media
  void _handleAddMedia(BuildContext context) async {
    final bool? useCamera = await _showImageSourceDialogue(context);
    if (useCamera != null) {
      await (useCamera ? getImage(true) : getImage(false));
      await uploadMedia(userId!, _image_profile, "image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.email),
            onPressed: () {
              // Handle unread messages
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            const Text(
              'User name: ',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: () async {
                // display dialogue box to ask if the user wants to use the camera or the gallery
                final bool? useCamera = await _showImageSourceDialogue(context);
                if (useCamera != null) {
                  await (useCamera
                          ? getImage(true)
                          : getImage(false) //true for camera, false for gallery
                      );
                  //once the image is selected, upload it to firebase storage
                  UploadImageToFirebaseStorage(_image_profile);
                }
              },
              child: FutureBuilder<String?>(
                future: _getUserProfileImageUrl(userId!),
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return CircleAvatar(
                        backgroundImage: NetworkImage(snapshot.data!));
                  }
                  return const CircleAvatar(child: Icon(Icons.add_a_photo));
                },
              ),
            ),

            //display list of instruments
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Instruments', style: TextStyle(fontSize: 24)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: userInstruments != null
                    ? userInstruments!
                        .map((instrument) => Chip(label: Text(instrument)))
                        .toList()
                    : [],
              ),
            ),
            // Add a button to edit instruments
            ElevatedButton(
              onPressed: () async {
                await Navigator.pushNamed(context, '/instrument');
                // Update the instruments in the user table
                setState(() {
                  userInstruments = userInstruments;
                });
                await _getUserInstruments();
              },
              child: const Text('Edit Instruments'),
            ),

            const SizedBox(height: 20),
            const Text(
              'User Bio',
              style: TextStyle(fontSize: 24),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: TextEditingController(text: bio),
                onSubmitted: (value) async {
                  setState(() {
                    bio = value;
                  });
                  //update firestore
                  await userCollectionRef.doc(userId).set({
                    'userBio': bio,
                  }, SetOptions(merge: true));
                },
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Media',
              style: TextStyle(fontSize: 24),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _mediaStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());

                  default:
                    if (snapshot.data?.docs.isEmpty ?? true) {
                      // Display a friendly message when there's no media
                      return Column(
                        children: [
                          const Text('No media yet, add your first item!'),
                          IconButton(
                            icon: const Icon(Icons.add_a_photo),
                            onPressed: () => _handleAddMedia(context),
                          ),
                        ],
                      );
                    } else {
                      // Display media items in a grid view
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width >
                                  600
                              ? 4
                              : 3, // Adjust grid columns based on screen width
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                        ),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot mediaDoc =
                              snapshot.data!.docs[index];

                          return MediaItem(
                            mediaDoc: mediaDoc,
                            //onEdit: () => _handleEditMedia(mediaDoc),
                            onDelete: () => _handleDeleteMedia(mediaDoc),
                          );
                        },
                      );
                    }
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleAddMedia(context),
        tooltip: 'Add Media',
        child: const Icon(Icons.add),
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
