import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
 

 
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.buttonText,
    required this.isLoading,
    this.onPressed,
  });

  final String buttonText;
  final bool isLoading;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    // final loginAuthProvider = context.watch<LoginAuthProvider>();
    // final registerAuthProvider = context.watch<RegisterAuthProvider>();

    var theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        color: theme.colorScheme.primary,
        onPressed: isLoading ? () {} : onPressed,
        child: FadeInUp(
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 1000),
          child:
              // loginAuthProvider.isLoading || registerAuthProvider.isLoading
              //     ? SizedBox(
              //       height: 22,
              //       width: 22,
              //       child: Center(
              //         child: CupertinoActivityIndicator(
              //           radius: 12,
              //           color: theme.colorScheme.onPrimaryContainer,
              //         ),
              //       ),
              //     )
              //     : 
              Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
        ),
      ),
    );
  }
}
