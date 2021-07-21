import 'package:crime_map/routes/routes.dart';
import 'package:crime_map/screens/authentication/login_screen.dart';
import 'package:crime_map/screens/authentication/registration_screen.dart';
import 'package:crime_map/screens/general/welcome_screen.dart';
import 'package:crime_map/screens/home/home_screen.dart';
import 'package:crime_map/screens/test.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case welcomeViewRoute:
      return PageTransition(
        child: WelcomeScreen(),
        type: PageTransitionType.fade,
      );

    case loginViewRoute:
      return PageTransition(
        child: LoginScreen(),
        type: PageTransitionType.fade,
      );
    case registrationViewRoute:
      return PageTransition(
        child: RegistrationScreen(),
        type: PageTransitionType.fade,
      );

    case homeViewRoute:
      return PageTransition(
        child: HomeScreen(),
        type: PageTransitionType.fade,
      );

    case testViewRoute:
      return PageTransition(
        child: TestScreen(),
        type: PageTransitionType.fade,
      );

    default:
      return PageTransition(
        child: WelcomeScreen(),
        type: PageTransitionType.fade,
      );
  }
}
