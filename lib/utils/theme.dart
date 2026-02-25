import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_assesment/utils/constants.dart';

var mainFont = 'Coco-Gothic-Pro-Alt';

void mySystemTheme(BuildContext context) {
  final brightness = Theme.of(context).colorScheme.brightness;
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          brightness == Brightness.light ? Brightness.dark : Brightness.light,
      statusBarBrightness: brightness,
      systemNavigationBarColor: Theme.of(context).colorScheme.surface,
      systemNavigationBarIconBrightness:
          brightness == Brightness.light ? Brightness.dark : Brightness.light,
    ),
  );
}

void changeSystemThemeOnPopup({
  Color? color,
  required BuildContext context,
  Color? statusColor,
}) {
  final brightness = Theme.of(context).colorScheme.brightness;
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: statusColor ?? Colors.transparent,
      statusBarIconBrightness:
          brightness == Brightness.light ? Brightness.dark : Brightness.light,
      statusBarBrightness: brightness,
      systemNavigationBarColor: color ?? Theme.of(context).colorScheme.surface,
      systemNavigationBarIconBrightness:
          brightness == Brightness.light ? Brightness.dark : Brightness.light,
    ),
  );
}

var lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: mainFont,
  unselectedWidgetColor: lGray,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  splashFactory: NoSplash.splashFactory,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: lBlue,
    onPrimary: lWhite,
    primaryContainer: lWhite,
    onPrimaryContainer: lBlack,
    secondary: lGray,
    onSecondary: lWhite,
    secondaryContainer: lLightGrey4,
    onSecondaryContainer: lBlack,
    surface: lWhite,
    onSurface: lBlack,
    surfaceContainer: lWhite,
    surfaceTint: Colors.transparent,
    error: Colors.red,
    onError: lWhite,
  ),
  scaffoldBackgroundColor: lLightWhite,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: lBlue,
      foregroundColor: lWhite,
      disabledBackgroundColor: lBlue,
      disabledForegroundColor: lWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: lBlue,
      foregroundColor: lWhite,
      disabledBackgroundColor: lBlue,
      disabledForegroundColor: lWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: lBlue,
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
  listTileTheme: const ListTileThemeData(iconColor: lBlack, textColor: lBlack),
  bottomAppBarTheme: const BottomAppBarTheme(color: lLightWhite),
  appBarTheme: AppBarTheme(
    backgroundColor: lLightWhite,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: lBlack,
      fontFamily: mainFont,
      fontSize: 20,
      fontVariations: fontWeightRegular,
    ),
    iconTheme: const IconThemeData(color: lBlack),
  ),
  iconTheme: const IconThemeData(color: lBlack),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontVariations: fontWeightRegular, color: lBlack),
    bodyMedium: TextStyle(fontVariations: fontWeightRegular, color: lBlack),
    bodySmall: TextStyle(fontVariations: fontWeightRegular, color: lBlack),
    labelSmall: TextStyle(fontVariations: fontWeightRegular, color: lBlack),
    labelMedium: TextStyle(fontVariations: fontWeightRegular, color: lBlack),
    labelLarge: TextStyle(fontVariations: fontWeightRegular, color: lBlack),
    displaySmall: TextStyle(fontVariations: fontWeightRegular, color: lBlack),
    displayMedium: TextStyle(fontVariations: fontWeightRegular, color: lBlack),
    displayLarge: TextStyle(fontVariations: fontWeightRegular, color: lBlack),
    titleSmall: TextStyle(fontVariations: fontWeightRegular, color: lBlack),
    titleMedium: TextStyle(fontVariations: fontWeightRegular, color: lBlack),
    titleLarge: TextStyle(fontVariations: fontWeightRegular, color: lBlack),
    headlineSmall: TextStyle(fontVariations: fontWeightRegular, color: lBlack),
    headlineMedium: TextStyle(fontVariations: fontWeightRegular, color: lBlack),
    headlineLarge: TextStyle(fontVariations: fontWeightRegular, color: lBlack),
  ),
);

var darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: mainFont,
  unselectedWidgetColor: lGray,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  splashFactory: NoSplash.splashFactory,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: lBlue,
    onPrimary: lWhite,
    primaryContainer: Color(0xFF1E1E1E),
    onPrimaryContainer: lWhite,
    secondary: lGray,
    onSecondary: lWhite,
    secondaryContainer: Color(0xFF2C2C2C),
    onSecondaryContainer: lWhite,
    surface: Color(0xFF121212),
    onSurface: lWhite,
    surfaceContainer: Color(0xFF1E1E1E),
    surfaceTint: Colors.transparent,
    error: Colors.redAccent,
    onError: lWhite,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: lBlue,
      foregroundColor: lWhite,
      disabledBackgroundColor: lBlue,
      disabledForegroundColor: lWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: lBlue,
      foregroundColor: lWhite,
      disabledBackgroundColor: lBlue,
      disabledForegroundColor: lWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: lWhite,
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
  listTileTheme: const ListTileThemeData(iconColor: lWhite, textColor: lWhite),
  bottomAppBarTheme: const BottomAppBarTheme(color: Color(0xFF1E1E1E)),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF121212),
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: lWhite,
      fontFamily: mainFont,
      fontSize: 20,
      fontVariations: fontWeightRegular,
    ),
    iconTheme: const IconThemeData(color: lWhite),
  ),
  iconTheme: const IconThemeData(color: lWhite),
  scaffoldBackgroundColor: const Color(0xFF121212),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontVariations: fontWeightRegular, color: lWhite),
    bodyMedium: TextStyle(fontVariations: fontWeightRegular, color: lWhite),
    bodySmall: TextStyle(fontVariations: fontWeightRegular, color: lWhite),
    labelSmall: TextStyle(fontVariations: fontWeightRegular, color: lWhite),
    labelMedium: TextStyle(fontVariations: fontWeightRegular, color: lWhite),
    labelLarge: TextStyle(fontVariations: fontWeightRegular, color: lWhite),
    displaySmall: TextStyle(fontVariations: fontWeightRegular, color: lWhite),
    displayMedium: TextStyle(fontVariations: fontWeightRegular, color: lWhite),
    displayLarge: TextStyle(fontVariations: fontWeightRegular, color: lWhite),
    titleSmall: TextStyle(fontVariations: fontWeightRegular, color: lWhite),
    titleMedium: TextStyle(fontVariations: fontWeightRegular, color: lWhite),
    titleLarge: TextStyle(fontVariations: fontWeightRegular, color: lWhite),
    headlineSmall: TextStyle(fontVariations: fontWeightRegular, color: lWhite),
    headlineMedium: TextStyle(fontVariations: fontWeightRegular, color: lWhite),
    headlineLarge: TextStyle(fontVariations: fontWeightRegular, color: lWhite),
  ),
);
