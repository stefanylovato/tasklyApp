import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LinkRowWidget extends StatelessWidget {
  final String mainText;
  final String linkText;
  final String route;

  const LinkRowWidget({
    super.key,
    required this.mainText,
    required this.linkText,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(mainText),
        GestureDetector(
          onTap: () => context.go(route),
          child: Text(
            linkText,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
