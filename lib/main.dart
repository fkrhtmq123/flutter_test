import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/firebase/model/user.dart';
import 'package:flutter_application/firebase/repository/userRepository.dart';
import 'package:flutter_application/firebase_options.dart';
import 'package:flutter_application/google.dart';
import 'package:flutter_application/map.dart';
import 'package:flutter_application/provider/google_user_data_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: scopes,
    clientId:
        "197201865154-43fvhia4eh4kniooehs0k83o6rko985o.apps.googleusercontent.com");

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ChangeNotifierProvider(
    create: (context) => UserData(),
    child: const MaterialApp(
      title: "",
      home: HomePage(title: ""),
    ),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // google account
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  // firebase instance
  final userRepository = UserRepository();

  @override
  void initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      bool isAuthorized = account != null;

      if (kIsWeb && account != null) {
        isAuthorized = await _googleSignIn.canAccessScopes(scopes);
      }

      setState(() {
        Provider.of<UserData>(context, listen: false).setCurrentUser(account);
        _currentUser = account;
        _isAuthorized = isAuthorized;
      });

      debugPrint("user : $_currentUser");

      if (isAuthorized) {
        unawaited(_handleGoogleGetContact(account!));
      }

      _googleSignIn.signInSilently();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Application Home"),
        backgroundColor: Colors.green[700],
      ),
      body: _buildBody(),
    );
  }

  Future<void> _firebaseInsertData() async {
    final now = DateTime.now();
    final insertUser = User(
        name: "kim_dongwook",
        email: "fkrhtmq456@gmail.com",
        department: "サービス開発室",
        team: "WEB開発チーム",
        deviceId: "deviceId",
        createdAt: now);
    final documentId = await userRepository.createUser(insertUser);
    debugPrint("ドキュメントID: ${documentId.toString()}");
  }

  Future<void> _firebaseSelectData() async {
    final users = await userRepository.getUser("fkrhtmq456@gmail.com");
    for (var user in users) {
      debugPrint("documentId : ${user.id}");
      debugPrint("name : ${user.data().name}");
      debugPrint("department : ${user.data().department}");
    }
  }

  Widget? _buildBody() {
    final GoogleSignInAccount? user = _currentUser;

    if (user != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              leading: GoogleUserCircleAvatar(identity: user),
              title: Text(user.displayName ?? ""),
              subtitle: Text(user.email),
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GoogleSignInPage(),
                  ),
                );
              },
              child: const Text("Google Login page"),
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MapPage(),
                  ),
                );
              },
              child: const Text("Google Map Page"),
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () {
                _firebaseInsertData();
              },
              child: const Text("Firebase Insert"),
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () {
                _firebaseSelectData();
              },
              child: const Text("Firebase Select"),
            ),
          ],
        ),
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const GoogleSignInPage()));
      });
      return null;
    }
  }

  Future<void> _handleGoogleGetContact(GoogleSignInAccount user) async {
    final http.Response response = await http.get(
      Uri.parse(
          "https://people.googleapis.com/v1/people/me/connections?requestMask.includeField=person.names"),
      headers: await user.authHeaders,
    );

    if (response.statusCode != 200) {
      debugPrint(
          "People API ${response.statusCode} response: ${response.body}");
      return;
    } else {
      debugPrint("response : $response");
    }
  }
}
