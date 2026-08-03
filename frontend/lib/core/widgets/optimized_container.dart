import 'package:flutter/material.dart';
import 'dart:ui';

class OptimizedContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final bool enableBlur;

  const OptimizedContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.backgroundColor,
    this.gradientColors,
    this.enableBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.1),
        gradient: gradientColors != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors!,
              )
            : null,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (enableBlur) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: container,
        ),
      );
    }

    return container;
  }

  // Factory constructors para casos comunes
  factory OptimizedContainer.card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return OptimizedContainer(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      backgroundColor: Colors.white.withOpacity(0.05),
      borderRadius: 12,
      child: child,
    );
  }

  factory OptimizedContainer.glass({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
  }) {
    return OptimizedContainer(
      width: width,
      height: height,
      padding: padding,
      backgroundColor: Colors.white.withOpacity(0.1),
      borderRadius: 16,
      enableBlur: true,
      child: child,
    );
  }

  factory OptimizedContainer.gradient({
    required Widget child,
    required List<Color> colors,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
  }) {
    return OptimizedContainer(
      width: width,
      height: height,
      padding: padding,
      gradientColors: colors,
      borderRadius: 16,
      child: child,
    );
  }
}
