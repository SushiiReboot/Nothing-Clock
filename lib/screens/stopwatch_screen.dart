import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:nothing_clock/widgets/stopwatch_btn_controller.dart';

class StopwatchScreen extends StatelessWidget {
  const StopwatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _buildStopwatchUI()),
          Padding(
            padding: const EdgeInsets.only(bottom: 75.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const StopwatchBtnController(
                    isFilled: false,
                    filledColor: null,
                    borderColor: Colors.red,
                    iconColor: null,
                    icon: Icons.stop),
                const SizedBox(
                  width: 40,
                ),
                Transform.scale(
                  scale: 1.5,
                  child: StopwatchBtnController(
                      isFilled: true,
                      filledColor: theme.colorScheme.secondary,
                      borderColor: theme.colorScheme.secondary,
                      iconColor: theme.colorScheme.surface,
                      icon: Icons.pause),
                ),
                const SizedBox(
                  width: 40,
                ),
                const StopwatchBtnController(
                    isFilled: false,
                    filledColor: null,
                    borderColor: Colors.white,
                    iconColor: null,
                    icon: Icons.add),
              ],
            ),
          )
        ],
      ),
    );
  }

  Center _buildStopwatchUI() {
    return Center(
      child: Container(
        width: 375,
        height: 375,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(180)),
        child: Stack(
          children: [
            Center(
              child: Transform.rotate(
                angle: 3.03,
                child: DottedBorder(
                  strokeCap: StrokeCap.round,
                  strokeWidth: 6,
                  borderType: BorderType.Circle,
                  color: const Color.fromARGB(255, 88, 88, 88),
                  dashPattern: const [2, 40],
                  child: Container(
                    width: 275,
                    height: 275,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: Material(
                  color: Colors.red,
                  shape: const CircleBorder(),
                  child: InkWell(
                      onTap: () {},
                      customBorder: const CircleBorder(),
                      child: const Icon(Icons.play_arrow)),
                ),
              ),
            ),
            Positioned(
              left: 162.5,
              top: 0,
              child: Container(
                width: 50,
                height: 22,
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: const Color.fromARGB(255, 88, 88, 88)),
                    borderRadius: BorderRadius.circular(50)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
