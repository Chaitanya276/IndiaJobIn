import 'package:flutter/material.dart';
import 'package:indiajobin/widgets/constants.dart';

class Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        height: 3.5,
        width: 18.0,
        color: mainColor);
  }
}
