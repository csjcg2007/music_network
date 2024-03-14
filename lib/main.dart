import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/messages.dart';
import 'package:flutter_application_1/pages/start.dart';
import 'package:flutter_application_1/services/auth.service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/user_model.dart';
import 'pages/instrument.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAnalytics.instance;
  runApp(ChangeNotifierProvider(
      create: (context) => UserModel(), child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late AuthService authService;

  @override
  void initState() {
    super.initState();
    authService = AuthService();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [Provider<AuthService>(create: (_) => authService)],
      child: Builder(builder: (context) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const StartPage(),
          onGenerateRoute: (RouteSettings settings) {
            if (settings.name == '/instrument') {
              return MaterialPageRoute(
                  builder: (context) =>
                      const Instrument()); // Replace with your page widget
            }
            if (settings.name == '/messages') {
              return MaterialPageRoute(
                  builder: (context) =>
                      const Messages()); // Replace with your page widget
            }
            // Handle other routes or return null for unhandled routes
            return null;
          },
        );
      }),
    );
  }
}
