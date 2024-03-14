import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/pages/user_profile_page.dart';
import 'package:provider/provider.dart';

class Instrument extends StatefulWidget {
  const Instrument({super.key});
  @override
  State<Instrument> createState() => _InstrumentState();
}

class _InstrumentState extends State<Instrument> {
  final List<String> _instruments = [
    'Guitar',
    'Piano',
    'Violin',
    'Drums',
    'Bass',
    'Saxophone',
    'Flute',
    'Cello',
    'Voice',
    'Other'
    // Add more instruments as needed
  ];

  // This map keeps track of which instruments are selected
  final Map<String, bool> _selectedInstruments = {};
  late String? userId;
  String _otherInstrument =
      ''; // To store the name of the instrument if "Other" is selected

  @override
  void initState() {
    super.initState();
    userId = Provider.of<UserModel>(context, listen: false).userId;
    for (var instrument in _instruments) {
      _selectedInstruments[instrument] = false;
    }
    _getUserInstruments();
  }

  void _handleInstrumentChange(String instrument, bool isSelected) {
    setState(() {
      _selectedInstruments[instrument] = isSelected;
      // If "Other" is deselected, clear the text field
      if (instrument == 'Other' && !isSelected) {
        _otherInstrument = '';
      }
    });
  }

  Future<String?> _getUserInstruments() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    List<String> instruments =
        (userDoc['instruments'] as List<dynamic>).cast<String>();
    if (userDoc.exists) {
      //setState(() {
      for (var instrument in instruments) {
        _selectedInstruments[instrument] = true;
      }
      //});
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Instruments'),
      ),
      body: FutureBuilder(
        
        future: 
          // Wait until initState has competed its execution
          Future.delayed(const Duration(milliseconds: 1), () => '1'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: _instruments.length +
                (_selectedInstruments['Other'] == true
                    ? 1
                    : 0), // Add one more item if "Other" is selected
            itemBuilder: (context, index) {
              if (index < _instruments.length) { // Display the list of instruments
                return CheckboxListTile(
                  title: Text(_instruments[index]),
                  value: _selectedInstruments[_instruments[index]],
                  onChanged: (bool? value) {
                    _handleInstrumentChange(_instruments[index], value!);
                  },
                );
              } else {
                return ListTile(
                  title: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Other Instrument:',
                    ),
                    onChanged: (otherInstrument) {
                      //setState(() {
                        _otherInstrument = otherInstrument;
                      //});
                    },
                  ),
                  trailing: Checkbox(
                    value: _selectedInstruments['Other'],
                    onChanged: (bool? value) {
                      _handleInstrumentChange('Other', value!);
                    },
                  ),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //user credential needs to be shared by the successful login process
          try {
            // Create a new list of strings containg the selected instruments
            List<String> selectedInstruments = [];
            for (var instrument in _selectedInstruments.keys) {
              if (_selectedInstruments[instrument] == true) {
                selectedInstruments.add(instrument);
              }
            }
            if (_selectedInstruments['Other'] == true) {
              selectedInstruments.add(_otherInstrument);
            }
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .set({'instruments': selectedInstruments},
                      SetOptions(merge: true));
          
            // Conditionally navigate to the user profile page after saving
            // the instruments if navigation is coming from the registration
            // page. Otherwise, navigate to the previous page.
            if (ModalRoute.of(context)?.settings.name == '/register') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UserProfile()),
              );
            } else {
              Navigator.pop(context);
            }
          } catch (error) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('failed to save instruments: $error')));
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
