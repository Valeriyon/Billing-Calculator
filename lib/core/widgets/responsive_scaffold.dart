import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

/// Responsive scaffold that adapts layout for phone vs tablet
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.phoneBody,
    this.tabletBody,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.breakpoint = AppSizes.phoneMaxWidth,
  });

  final PreferredSizeWidget? appBar;
  final Widget phoneBody;
  final Widget? tabletBody;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= breakpoint;
          return isTablet ? (tabletBody ?? phoneBody) : phoneBody;
        },
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
    );
  }

  /// Helper to check if current layout is tablet
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppSizes.phoneMaxWidth;
  }

  /// Helper to check if current layout is landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get responsive value based on screen size
  static T responsive<T>(
    BuildContext context, {
    required T phone,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= AppSizes.desktopMinWidth && desktop != null) {
      return desktop;
    }
    if (width >= AppSizes.phoneMaxWidth && tablet != null) {
      return tablet;
    }
    return phone;
  }
}

/// Two-column layout for tablets
class TwoColumnLayout extends StatelessWidget {
  const TwoColumnLayout({
    super.key,
    required this.leftColumn,
    required this.rightColumn,
    this.leftFlex = 1,
    this.rightFlex = 1,
    this.spacing = AppSizes.spacingLarge,
    this.padding,
  });

  final Widget leftColumn;
  final Widget rightColumn;
  final int leftFlex;
  final int rightFlex;
  final double spacing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(AppSizes.paddingLarge),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: leftFlex, child: leftColumn),
          SizedBox(width: spacing),
          Expanded(flex: rightFlex, child: rightColumn),
        ],
      ),
    );
  }
}
