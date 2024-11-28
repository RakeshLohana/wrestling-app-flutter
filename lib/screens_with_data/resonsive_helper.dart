import 'package:flutter/material.dart';

double getResponsiveHeight(BuildContext context, double height) {
  return MediaQuery.of(context).size.height *
      (height / 750.0); // 812.0 is the height of a reference device (e.g., iPhone X)
}

double getResponsiveWidth(BuildContext context, double width) {
  return MediaQuery.of(context).size.width *
      (width / 375.0); // 375.0 is the width of a reference device (e.g., iPhone X)
}

double getResponsiveFontSize(BuildContext context, double fontSize) {
  return MediaQuery.of(context).size.width * (fontSize / 375.0); // Adjust font size based on width
}
