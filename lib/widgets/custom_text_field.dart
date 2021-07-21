import 'package:crime_map/utils/app_config.dart';
import 'package:crime_map/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final IconData fieldIcon;
  final FocusNode nextFocus;
  final FocusNode currentFocus;
  final Function fieldValidator;
  final String fieldHintText;
  final TextInputAction fieldTextInputAction;
  final TextEditingController fieldController;

  const CustomTextField(
      {Key key,
      @required this.fieldIcon,
      @required this.fieldController,
      @required this.fieldValidator,
      @required this.currentFocus,
      @required this.fieldHintText,
      @required this.fieldTextInputAction,
      this.nextFocus})
      : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  void initState() {
    super.initState();
    widget.currentFocus.addListener(_onOnFocusNodeEvent);
  }

  _onOnFocusNodeEvent() {
    setState(() {});
  }

  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return TextFormField(
      focusNode: widget.currentFocus,
      controller: widget.fieldController,
      textInputAction: widget.fieldTextInputAction,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
        prefixIconConstraints: BoxConstraints(minWidth: 0, maxHeight: 40),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 10.0, right: 5.0),
          child: Icon(widget.fieldIcon),
        ),
        filled: widget.currentFocus.hasFocus ? false : true,
        fillColor: greyLighter,
        errorStyle: TextStyle(
          fontSize: 11.0,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            width: widget.currentFocus.hasFocus ? 2.0 : 0.0,
            style: widget.currentFocus.hasFocus
                ? BorderStyle.solid
                : BorderStyle.none,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
        hintText: widget.fieldHintText,
        hintStyle: TextStyle(
          fontWeight: FontWeight.w400,
          color: Colors.blueGrey[300],
        ),
      ),
      keyboardType: TextInputType.text,
      style: TextStyle(color: blackPrimary),
      validator: widget.fieldValidator,
      onFieldSubmitted: (v) {
        FocusScope.of(context).requestFocus(widget.nextFocus);
      },
    );
  }
}
