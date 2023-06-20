import 'package:flutter/material.dart';
import 'colors.dart';

class TaskRaceTheme {
  static Color primarycolor = const Color(0xff010101);
  static Color primaryVariant = const Color(0xff0f4041);
  static Color backgroundcolor = const Color(0xff202020);
  static Color secondaryColor = const Color(0xff136061);
  static Color onPrimary = const Color(0xffffffff);
  static ThemeData theme = ThemeData(
    primarySwatch: createMaterialColor(primarycolor),
    primaryColor: primarycolor,
    backgroundColor: backgroundcolor,
    bottomAppBarColor: secondaryColor,
    cardColor: primaryVariant,
    brightness: Brightness.dark,
  );
}
