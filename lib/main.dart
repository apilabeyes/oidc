import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OIDCデモ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var CLIENT_NAME = "demoapp";
  var CLIENT_SECRET = "9089fafc-82a9-4ced-b003-275c452f265a";
  var DISCOVERY_URL =
      "https://keycloak.briscola-api.com/auth/realms/apilabeyes/.well-known/openid-configuration";
  var REDIRECT_URL = "com.example.demo2:/callback";

  var appAuth = FlutterAppAuth();
  String accessToken = "";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              accessToken,
              style: TextStyle(
                color: Color(0xFF000000),
                fontSize: 9,
                fontFamily: 'NotoSerif',
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(height: 5.0),
            ElevatedButton(
              child: Text("ログイン"),
              onPressed: () async {
                AuthorizationTokenResponse? result;
                try {
                  result = await appAuth.authorizeAndExchangeCode(
                    AuthorizationTokenRequest(
                      CLIENT_NAME,
                      REDIRECT_URL,
                      promptValues: ['login'],
                      clientSecret: CLIENT_SECRET,
                      discoveryUrl: DISCOVERY_URL,
                    ),
                  );
                } on PlatformException catch (err) {
                  print("PlatformException: ${err.message}");
                }
                setState(() {
                  accessToken = result!.accessToken!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
