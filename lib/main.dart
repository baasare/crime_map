import 'package:crime_map/routes/router.dart' as router;
import 'package:crime_map/routes/routes.dart';
import 'package:crime_map/utils/app_config.dart';
import 'package:crime_map/utils/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';

bool _isLoggedIn = false;
final FirebaseAuth _auth = FirebaseAuth.instance;

void main() async {
  // bind all files to the app before the app starts. enables environment
  // variables to be bounded to app before the app starts
  WidgetsFlutterBinding.ensureInitialized();

  // load the environment variables
  await FlutterConfig.loadEnvVariables();

  // initialize firebase
  await Firebase.initializeApp();

  if (_auth.currentUser != null) {
    _isLoggedIn = true;
    print("USER IS LOGGED IN");
  }

  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // app name
      title: AppConfig.appName,

      // app theme
      theme: AppTheme.lightTheme,

      // disable test banner
      debugShowCheckedModeBanner: false,

      //make flutter aware of app routes using router generator in router.dart file
      onGenerateRoute: router.generateRoute,

      initialRoute: _isLoggedIn ? homeViewRoute : welcomeViewRoute,
    );
  }
}
