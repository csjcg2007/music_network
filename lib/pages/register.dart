import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/pages/instrument.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() => RegisterPageState();
}

class RegisterPageState extends State {
/*•	As a new user, I want to create an account by providing basic information such as private user name (not shared), email, password.
•	Name/email parameters
•	I want to ensure that the name consists of only alphanumeric characters; min 5 - max 25 characters
•	I want to ensure that the name is unique
•	I want to ensure that the email address is a valid email address and contains only valid email characters
•	I want to ensure that the email address is unique
•	I want to ensure the password has a minimum of 10 characters and contains a mix of uppercase/lowercase characters and symbols (!, +, #)
*/

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? get usernameErrorMsg {
    final username = usernameController.text;
    if (username.isNotEmpty) {
      if (username.length < 5 || username.length > 20) {
        if (username.length > 20) {
          usernameController.text = usernameController.text.substring(0, 20);
        }
        return "username must be between 5 and 20 characters";
      }
    }

    return null;
  }

  String? get emailErrorMsg {
    final email = emailController.text;
    List<String> errorMsgs = [];
    if (email.isNotEmpty) {
      if (email.length > 20) {
        emailController.text = emailController.text.substring(0, 20);
        errorMsgs.add("something about the length");
      }
      String tmp = "";
      for (int i = 0; i < email.length; i++) {
        var ch = email[i];
        if (isValidEmailCharacter(email, ch, i)) {
          tmp += ch;
        } else {
          errorMsgs.add("something about need a valid email address");
        }
      }
      emailController.text = tmp;
    }

    if (errorMsgs.isNotEmpty) {
      return errorMsgs.join("; ");
    } else {
      return null;
    }
  }

  bool isValidEmailCharacter(String substring, String ch, int index) {
    return true;
  }

  String? get passwordErrorMsg {
    final password = passwordController.text;
    if (password.isNotEmpty) {
      if (password.length < 5 || password.length > 20) {
        return "password must be between 5 and 20 characters";
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    //final authService = Provider.of<Authentication>(context);
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text("RegisterPage"))),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: TextField(
              controller: usernameController,
              decoration: InputDecoration(
                  labelText: 'username',
                  hintText: 'Enter username',
                  errorText: usernameErrorMsg),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: TextField(
              controller: emailController,
              decoration: InputDecoration(
                  labelText: 'email',
                  hintText: 'Enter email',
                  errorText: emailErrorMsg),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: 'password',
                  hintText: 'Enter password',
                  errorText: passwordErrorMsg),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                  onPressed: () async {
                    try {
                      UserCredential userCredential = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text);
                      final userReference = FirebaseFirestore.instance.collection('users');
                      //create user in case it does not exist
                      await userReference.doc(userCredential.user!.uid).set({});
                      final documentReference = userReference.doc(userCredential.user!.uid);
                      final userData = [
                        {'key': 'email', 'value': emailController.text},
                        {'key': 'username', 'value': usernameController.text},
                        {'key': 'imageUrl', 'value': ''},
                        {'key': 'userBio', 'value': ''},
                      ];
                      Map<String, dynamic> userDataMap = {};
                      for(final attribute in userData){
                        userDataMap[attribute['key'].toString()] = attribute['value'];
                        }
                      await documentReference.set(userDataMap);

                      Provider.of<UserModel>(context, listen: false).setUserId(userCredential.user!.uid);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Instrument()),
                      );
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Password too weak.'),
                        ));
                      } else if (e.code == 'email-already-in-use') {
                                                ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('The account already exists.'),
                        ));
                      }
                    } catch (e) {                     
                      print(e);
                    }
                  },
                  child: const Text("Register"))),
          Padding(
              padding: const EdgeInsets.only(top: 20),
              child: InkWell(
                  child: const Text("Back to login"),
                  onTap: () {
                    Navigator.pop(context);
                  }))
        ],
      )),
    );
  }
}
