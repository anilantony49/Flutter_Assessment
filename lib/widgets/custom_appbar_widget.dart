import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class CustomAppbar {
  static AppBar show(BuildContext context, bool enableIcon, String titleText) {
    final theme = Theme.of(context);
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      leading: enableIcon
          ? FadeInLeft(
              duration: const Duration(milliseconds: 500),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: theme.colorScheme.onSurface,
                  size: 20,
                ),
              ),
            )
          : null,
      title: FadeInDown(
        duration: const Duration(milliseconds: 500),
        child: Text(
          titleText,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
