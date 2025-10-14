import 'package:flutter/material.dart';

/// A widget that returns different layouts based on screen size
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget? desktop;

  const Responsive({
    super.key,
    required this.mobile,
    required this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200 && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= 600) {
          return tablet;
        } else {
          return mobile;
        }
      },
    );
  }
}
