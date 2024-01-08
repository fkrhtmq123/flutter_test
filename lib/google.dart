import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/provider/google_user_data_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: scopes,
    clientId:
        "197201865154-43fvhia4eh4kniooehs0k83o6rko985o.apps.googleusercontent.com");

void main() {
  runApp(const MaterialApp(
    title: "Google Sign In",
    home: GoogleSignInPage(),
  ));
}

class GoogleSignInPage extends StatefulWidget {
  const GoogleSignInPage({super.key});

  @override
  State createState() => _GoogleSignInPageState();
}

class _GoogleSignInPageState extends State<GoogleSignInPage> {
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  String _contactText = "";

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

      if (isAuthorized) {
        unawaited(_handleGoogleGetContact(account!));
      }

      _googleSignIn.signInSilently();
    });
  }

  Future<void> _handleGoogleGetContact(GoogleSignInAccount user) async {
    setState(() {
      _contactText = "Loading contact info...";
    });

    final http.Response response = await http.get(
      Uri.parse(
          "https://people.googleapis.com/v1/people/me/connections?requestMask.includeField=person.names"),
      headers: await user.authHeaders,
    );

    if (response.statusCode != 200) {
      setState(() {
        _contactText =
            "People API gave a ${response.statusCode} response. Check logs for details.";
      });
      print("People API ${response.statusCode} response: ${response.body}");
      return;
    }

    // final Map<String, dynamic> data =
    //     json.decode(response.body) as Map<String, dynamic>;

    // final String? nameContact = _pickFirstNamedContact(data);

    // setState(() {
    //   if (nameContact != null) {
    //     _contactText = "I see you know $nameContact!";
    //   } else {
    //     _contactText = "No contects to display.";
    //   }
    // });
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data["connections"] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
      (dynamic contact) => (contact as Map<Object?, dynamic>)["names"] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;

    if (contact != null) {
      final List<dynamic> names = contact["names"] as List<dynamic>;
      final Map<String, dynamic>? name = names.firstWhere(
        (dynamic name) =>
            (name as Map<Object?, dynamic>)["displayName"] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;

      if (name != null) {
        return name["displayName"] as String?;
      }
    }

    return null;
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn().then((value) => Navigator.pop(context));
    } catch (error) {
      print("Error: $error");
    }
  }

  // Future<void> _handleAuthorizeScopes() async {
  //   final bool isAuthorized = await _googleSignIn.requestScopes(scopes);

  //   setState(() {
  //     _isAuthorized = isAuthorized;
  //   });

  //   if (isAuthorized) {
  //     unawaited(_handleGoogleGetContact(_currentUser!));
  //   }
  // }

  // Future<void> _handleSignOut() => _googleSignIn.disconnect();

  // Widget _buildBody() {
  //   final GoogleSignInAccount? user = _currentUser;

  //   if (user != null) {
  //     return Column(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: <Widget>[
  //         ListTile(
  //           leading: GoogleUserCircleAvatar(identity: user),
  //           title: Text(user.displayName ?? ""),
  //           subtitle: Text(user.email),
  //         ),
  //         const Text("Sign in successfully."),
  //         if (_isAuthorized) ...<Widget>[
  //           Text(_contactText),
  //           ElevatedButton(
  //               onPressed: () => _handleGoogleGetContact(user),
  //               child: const Text("Refresh"))
  //         ],
  //         if (_isAuthorized) ...<Widget>[
  //           const Text("Additional permissions needed to read your contacts"),
  //           ElevatedButton(
  //               onPressed: _handleAuthorizeScopes,
  //               child: const Text("Request Permissions"))
  //         ],
  //         ElevatedButton(
  //             onPressed: _handleSignOut, child: const Text("Sign Out"))
  //       ],
  //     );
  //   } else {
  //     return Column(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: <Widget>[
  //         SignInButton(Buttons.google, onPressed: _handleSignIn),
  //       ],
  //     );
  //   }
  // }
  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        SignInButton(Buttons.google, onPressed: _handleSignIn),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Sign In"),
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _buildBody(),
      ),
    );
  }
}
