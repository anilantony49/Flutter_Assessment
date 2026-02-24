import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class CustomAppbar {
  static AppBar show(BuildContext context, enableIcon, titleText) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      leading:
          enableIcon
              ? FadeInLeft(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 1000),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios),
                ),
              )
              : const SizedBox(),
      title: FadeInDown(
        delay: const Duration(milliseconds: 400),
        duration: const Duration(milliseconds: 1000),
        child:   Text(titleText, style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
