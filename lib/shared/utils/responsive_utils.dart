import 'package:flutter/material.dart';

class ResponsiveUtils {
  const ResponsiveUtils._();

  static double topSpacing(BuildContext context){
    final height = MediaQuery.sizeOf(context).height;
    return (height * 0.04).clamp(12.0, 32.0);
  }

  static double horizontalSpacing(BuildContext context){
    final width = MediaQuery.sizeOf(context).width;
    return (width * 0.04).clamp(12.0, 32.0);
  }

  static double bottomSpacing(BuildContext context){
    final height = MediaQuery.sizeOf(context).height;
    return (height * 0.015).clamp(8.0, 20.0);
  }
}