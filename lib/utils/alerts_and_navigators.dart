import 'package:flutter/material.dart';
import 'package:flutter_assesment/utils/constants.dart';
 import 'package:page_transition/page_transition.dart';

Future<dynamic> nextScreen(BuildContext context, Widget page) {
  return Navigator.push(
    context,
    PageTransition(child: page, type: PageTransitionType.fade),
  );
}

Future<dynamic> nextScreenRemoveUntil(BuildContext context, Widget page) {
  return Navigator.pushAndRemoveUntil(
    context,
    PageTransition(child: page, type: PageTransitionType.fade),
    (route) => false,
  );
}

void customSnackbar( 
  
  BuildContext context,
  String message, {
  IconData? leading,
  String? trailing,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      backgroundColor: dLightBlueGrey2,
      dismissDirection: DismissDirection.up,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          if (leading != null) Icon(leading, color: lWhite),
          kWidth(10),
          SizedBox(
            width: MediaQuery.of(context).size.width - 150,
            child: Text(
              message,
              // overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: lWhite),
            ),
          ),
          const Spacer(),
          if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(
                fontVariations: fontWeightW700,
                fontSize: 12,
                color: lWhite,
              ),
            ),
        ],
      ),
    ),
  );
}