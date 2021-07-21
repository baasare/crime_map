import 'package:crime_map/routes/routes.dart';
import 'package:crime_map/services/authentication_service.dart';
import 'package:crime_map/utils/app_config.dart';
import 'package:crime_map/utils/colors.dart';
import 'package:crime_map/utils/constants.dart';
import 'package:flutter/material.dart';

class LogOutAlert extends StatefulWidget {
  @override
  _LogOutAlertState createState() => _LogOutAlertState();
}

class _LogOutAlertState extends State<LogOutAlert> {
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: SizeConfig.blockSizeVertical * 3,
                  bottom: SizeConfig.blockSizeVertical * 2,
                  left: SizeConfig.blockSizeHorizontal * 5,
                  right: SizeConfig.blockSizeHorizontal * 5,
                ),
                child: Text(
                  'Are you sure you want to log out?',
                  style: TextStyle(
                    fontFamily: AvailableFonts.primaryFont,
                    color: purpleDark,
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: SizeConfig.blockSizeVertical * 3,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    OutlinedButton(
                      child: Padding(
                        padding: EdgeInsets.all(
                          SizeConfig.blockSizeHorizontal * 2.5,
                        ),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontFamily: AvailableFonts.primaryFont,
                            fontWeight: FontWeight.w400,
                            color: purpleDark,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        primary: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    OutlinedButton(
                      child: Padding(
                        padding: EdgeInsets.all(
                          SizeConfig.blockSizeHorizontal * 2.5,
                        ),
                        child: Text(
                          'Yes',
                          style: TextStyle(
                            fontFamily: AvailableFonts.primaryFont,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        primary: Colors.teal,
                        backgroundColor: Colors.red[700],
                        side: BorderSide(color: Colors.red[700], width: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {
                        _logout();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _logout() async {
    try {
      GoogleAuthService().signOut().then((value) => Navigator.of(context)
          .pushNamedAndRemoveUntil(
              welcomeViewRoute, (Route<dynamic> route) => false));
    } catch (error) {
      print("ERROR: $error");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: purpleDark,
          content: Text(
            error.toString(),
            style: TextStyle(color: greyPrimary),
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
