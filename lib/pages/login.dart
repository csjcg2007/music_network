import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/pages/register.dart';
import 'package:flutter_application_1/pages/user_profile_page.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text("Login"))),
      body: SingleChildScrollView(
          child: Column(
        children: [
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
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text);
                              Provider.of<UserModel>(context, listen: false).setUserId(userCredential.user!.uid);

                      //Navigator.pop(context);
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserProfile()),
                            //builder: (context) => const Messages()),                            
                      );
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Login failed')));
                    }
                  },
                  child: const Text("Login"))),
          Padding(
              padding: const EdgeInsets.only(top: 20),
              child: InkWell(
                child: const Text("register a new acount."),
                onTap: () => {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()))
                },
              ))
        ],
      )),
    );
  }
}
