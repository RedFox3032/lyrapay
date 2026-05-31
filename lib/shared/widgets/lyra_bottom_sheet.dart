import 'package:flutter/material.dart';

class LyraBottomSheet extends StatelessWidget {
  final Widget child;
  const LyraBottomSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF131313),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(child: child),
    );
  }
}
