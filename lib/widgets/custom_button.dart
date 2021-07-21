import 'package:crime_map/utils/app_config.dart';
import 'package:crime_map/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Color buttonColor;
  final String buttonText;
  final double buttonHeight;
  final double buttonWidth;
  final Function buttonOnPressed;

  const CustomButton({
    Key key,
    this.buttonColor,
    this.buttonText,
    this.buttonHeight,
    this.buttonWidth,
    this.buttonOnPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Container(
      height: buttonHeight,
      width: buttonWidth,
      child: Material(
        borderRadius: BorderRadius.circular(7.0),
        color: buttonColor,
        elevation: 5.0,
        shadowColor: Colors.white70,
        child: MaterialButton(
          onPressed: buttonOnPressed,
          child: Text(
            buttonText,
            style: TextStyle(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w500,
              fontFamily: AvailableFonts.primaryFont,
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
