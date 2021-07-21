import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crime_map/routes/routes.dart';
import 'package:crime_map/services/authentication_service.dart';
import 'package:crime_map/utils/app_config.dart';
import 'package:crime_map/utils/colors.dart';
import 'package:crime_map/utils/constants.dart';
import 'package:crime_map/utils/validator.dart';
import 'package:crime_map/widgets/custom_button.dart';
import 'package:crime_map/widgets/custom_password_field.dart';
import 'package:crime_map/widgets/custom_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final fireBaseFirestoreRef = FirebaseFirestore.instance;

  final emailController = TextEditingController();
  final fullnameController = TextEditingController();
  final passwordOneController = TextEditingController();
  final passwordTwoController = TextEditingController();

  final emailFocusNode = FocusNode();
  final fullnameFocusNode = FocusNode();
  final passwordOneFocusNode = FocusNode();
  final passwordTwoFocusNode = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    fullnameController.dispose();
    passwordOneController.dispose();
    passwordTwoController.dispose();

    emailFocusNode.dispose();
    fullnameFocusNode.dispose();
    passwordOneFocusNode.dispose();
    passwordTwoFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome to Crime Map 👋",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: AvailableFonts.primaryFont,
            color: blackPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 27,
          ),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 1.5,
        ),
        Text(
          "Hello, I guess you are new around here. You can start using the application after signing up.",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: AvailableFonts.primaryFont,
            color: greyPrimary,
            fontWeight: FontWeight.w400,
            fontSize: 17,
            letterSpacing: 0.5,
          ),
        )
      ],
    );

    final fullnameField = CustomTextField(
      fieldIcon: Icons.account_circle,
      currentFocus: fullnameFocusNode,
      nextFocus: emailFocusNode,
      fieldHintText: "Full Name",
      fieldValidator: Validator.textValidator,
      fieldController: fullnameController,
      fieldTextInputAction: TextInputAction.next,
    );

    final emailField = CustomTextField(
      fieldIcon: Icons.email_outlined,
      currentFocus: emailFocusNode,
      nextFocus: passwordOneFocusNode,
      fieldHintText: "Email",
      fieldValidator: Validator.emailValidator,
      fieldController: emailController,
      fieldTextInputAction: TextInputAction.next,
    );

    final passwordOneField = CustomPasswordField(
      fieldIcon: Icons.lock_outlined,
      currentFocus: passwordOneFocusNode,
      nextFocus: passwordTwoFocusNode,
      fieldHintText: "Password",
      fieldValidator: Validator.passwordValidator,
      fieldController: passwordOneController,
      fieldTextInputAction: TextInputAction.next,
    );

    final passwordTwoField = CustomPasswordField(
      fieldIcon: Icons.lock_outlined,
      currentFocus: passwordTwoFocusNode,
      fieldHintText: "Repeat Password",
      fieldValidator: (password) {
        if (passwordOneController.text != passwordTwoController.text)
          return 'Passwords do not match!';
        return null;
      },
      fieldController: passwordTwoController,
      fieldTextInputAction: TextInputAction.done,
    );

    final registrationForm = Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.only(
          top: SizeConfig.blockSizeVertical * 5,
        ),
        child: Column(
          children: <Widget>[
            fullnameField,
            SizedBox(
              height: 10.0,
            ),
            emailField,
            SizedBox(
              height: 10.0,
            ),
            passwordOneField,
            SizedBox(
              height: 10.0,
            ),
            passwordTwoField,
          ],
        ),
      ),
    );

    final registrationFormBtn = Padding(
      padding: EdgeInsets.only(
        top: SizeConfig.blockSizeVertical * 2,
      ),
      child: CustomButton(
        buttonColor: purplePrimary,
        buttonText: "Sign Up",
        buttonHeight: SizeConfig.blockSizeVertical * 6,
        buttonWidth: SizeConfig.blockSizeHorizontal * 100,
        buttonOnPressed: () {
          if (_formKey.currentState.validate()) {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
            _signUp(
              context,
              emailController.text,
              passwordOneController.text,
            );
          }
        },
      ),
    );

    final or = Padding(
      padding: EdgeInsets.only(
        top: SizeConfig.blockSizeVertical * 5,
        bottom: SizeConfig.blockSizeVertical * 5,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Text(
          'or',
          style: TextStyle(
            letterSpacing: 0.5,
            fontWeight: FontWeight.w400,
            fontFamily: AvailableFonts.primaryFont,
            fontSize: 17.0,
            color: greyPrimary,
          ),
        ),
      ),
    );

    final googleSignUp = SizedBox(
      height: SizeConfig.blockSizeVertical * 6,
      child: OutlinedButton(
        onPressed: () => _loginInGoogle(context),
        child: Row(
          children: [
            Image.asset(
              AvailableIcons.googleIcon["assetPath"],
              fit: BoxFit.cover,
              height: 25.0,
              width: 25.0,
            ),
            Expanded(
              child: Text(
                "Sign Up with Google",
                textAlign: TextAlign.center,
                style: TextStyle(
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                  fontFamily: AvailableFonts.primaryFont,
                  fontSize: 15.0,
                  color: greyDarker,
                ),
              ),
            ),
          ],
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              7.0,
            ),
          ),
          side: BorderSide(
            width: 2,
            color: greyLighter,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );

    final signIn = Container(
      padding: EdgeInsets.only(
        top: SizeConfig.blockSizeVertical * 5,
        left: SizeConfig.safeBlockHorizontal * 10,
        right: SizeConfig.safeBlockHorizontal * 10,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: RichText(
          text: TextSpan(
              text: 'Already have an account?',
              style: TextStyle(
                letterSpacing: 0.5,
                fontWeight: FontWeight.w400,
                fontFamily: AvailableFonts.primaryFont,
                fontSize: 14.0,
                color: blackLighter,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: ' Sign in',
                  style: TextStyle(
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500,
                    fontFamily: AvailableFonts.primaryFont,
                    fontSize: 14.0,
                    color: blackPrimary,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pushReplacementNamed(context, loginViewRoute);
                    },
                )
              ]),
        ),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: SizeConfig.blockSizeVertical * 5,
              left: SizeConfig.blockSizeHorizontal * 5,
              right: SizeConfig.blockSizeHorizontal * 5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                title,
                registrationForm,
                registrationFormBtn,
                or,
                googleSignUp,
                signIn
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signUp(BuildContext context, String email, String password) async {
    try {
      AuthenticationService()
          .signUp(
        email: emailController.text,
        password: passwordOneController.text,
      )
          .then(
        (user) {
          fireBaseFirestoreRef
              .collection(RealtimeDatabaseKeys.users)
              .doc(user.user.uid)
              .set(
            {
              'fullname': fullnameController.text,
              'email': emailController.text,
            },
            SetOptions(merge: true),
          ).then(
            (value) => Navigator.of(context).pushNamedAndRemoveUntil(
              homeViewRoute,
              (Route<dynamic> route) => false,
            ),
          );
        },
      );
    } catch (error) {
      print("ERROR: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: purpleLight,
          content: Text(
            error,
            style: TextStyle(color: blackPrimary),
          ),
          duration: Duration(seconds: 10),
        ),
      );
    }
  }

  void _loginInGoogle(BuildContext context) async {
    try {
      GoogleAuthService().signIn().then(
        (user) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              homeViewRoute, (Route<dynamic> route) => false);
        },
      );
    } catch (error) {
      print("ERROR: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: purpleLight,
          content: Text(
            error,
            style: TextStyle(color: blackPrimary),
          ),
          duration: Duration(seconds: 10),
        ),
      );
    }
  }
}
