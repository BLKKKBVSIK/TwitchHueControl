import 'package:flutter/material.dart';
import '_widgets/step_divider.dart';
import '_widgets/step_one.dart';

class TwitchHueControl extends StatefulWidget {
  const TwitchHueControl({Key? key}) : super(key: key);

  @override
  State<TwitchHueControl> createState() => _TwitchHueControlState();
}

class _TwitchHueControlState extends State<TwitchHueControl> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hello"),
      ),
      body: Row(
        children: [
          const Flexible(
            child: StepDivider(
              hasDivider: true,
              dividerSideIsLeft: true,
              child: StepOne(),
            ),
          ),
          Flexible(
            child: StepDivider(
              hasDivider: false,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.blue,
                    ),
                  )
                ],
              ),
            ),
          ),
          Flexible(
            child: StepDivider(
              hasDivider: true,
              dividerSideIsLeft: false,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.green,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
