import 'package:flutter/material.dart';
import 'package:twitch_hue_control_desktop/misc/k_config.dart';

import 'outline_button.dart';

class StepOne extends StatefulWidget {
  const StepOne({Key? key}) : super(key: key);

  @override
  State<StepOne> createState() => _StepOneState();
}

class _StepOneState extends State<StepOne> {
  LinearGradient test = const LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [kAppPurple, kAppBlue],
  );

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.red,
            ),
          ),
        ],
      ),
      Positioned.fill(
        bottom: MediaQuery.of(context).size.height * 0.05,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: NoneStickyLabeledButton(
            isExtended: false,
            hasGradient: true,
            gradient: test,
            action: () {
              print("hello");
              /* setState(() {
                test = const LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Colors.green, Colors.lime],
                );
              }); */
            },
            label: "Hellooo",
          ),
        ),
      ),
    ]);
  }
}
