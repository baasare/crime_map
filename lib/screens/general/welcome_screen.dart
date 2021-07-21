import 'package:crime_map/routes/routes.dart';
import 'package:crime_map/utils/app_config.dart';
import 'package:crime_map/utils/colors.dart';
import 'package:crime_map/utils/constants.dart';
import 'package:crime_map/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: SizeConfig.blockSizeVertical * 2,
              ),
              child: Center(
                child: Container(
                  height: SizeConfig.blockSizeVertical * 50,
                  child: Image.asset(
                    AvailableImages.welcomeLogo["assetPath"],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  "Crime Map",
                  style: TextStyle(
                    color: blackPrimary,
                    fontSize: 45.0,
                    fontFamily: AvailableFonts.primaryFont,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 2.0,
                ),
                Text(
                  "See it, Hear it, Report it",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: greyPrimary,
                    fontSize: 18.0,
                    fontFamily: AvailableFonts.primaryFont,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            // Spacer (),
            Padding(
              padding: EdgeInsets.only(
                top: SizeConfig.blockSizeVertical * 3,
                bottom: SizeConfig.blockSizeVertical * 5,
              ),
              child: CustomButton(
                buttonColor: purplePrimary,
                buttonText: "Next",
                buttonHeight: SizeConfig.blockSizeVertical * 6,
                buttonWidth: SizeConfig.blockSizeHorizontal * 70,
                buttonOnPressed: () =>
                    Navigator.of(context).pushReplacementNamed(loginViewRoute),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
