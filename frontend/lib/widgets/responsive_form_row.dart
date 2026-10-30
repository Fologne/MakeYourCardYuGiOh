import 'package:flutter/material.dart';

class ResponsiveFormRow extends StatelessWidget {
  const ResponsiveFormRow({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= 500 &&
          MediaQuery.textScalerOf(context).scale(1) <= 1.3) {
        return Row(crossAxisAlignment: crossAxisAlignment, children: children);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children.map((child) {
          if (child is Expanded) return child.child;
          if (child is SizedBox) return const SizedBox(height: 16);
          return child;
        }).toList(),
      );
    },
  );
}
