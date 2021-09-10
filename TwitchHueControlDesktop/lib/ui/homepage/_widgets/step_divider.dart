import 'package:flutter/material.dart';

class StepDivider extends StatelessWidget {
  const StepDivider({
    Key? key,
    required this.child,
    this.hasDivider = true,
    this.dividerSideIsLeft = false,
  }) : super(key: key);

  final Widget child;
  final bool hasDivider;
  final bool dividerSideIsLeft;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.05),
            child: Container(
              decoration: hasDivider
                  ? BoxDecoration(
                      border: dividerSideIsLeft
                          ? const Border(
                              right: BorderSide(color: Colors.black, width: 2))
                          : const Border(
                              left: BorderSide(color: Colors.black, width: 2)))
                  : const BoxDecoration(),
            ),
          ),
        ),
      ],
    );
  }
}
