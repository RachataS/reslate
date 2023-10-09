import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import '/controllers/question_controller.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constants.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 35,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF3F4768), width: 3),
        borderRadius: BorderRadius.circular(50),
      ),
      child: GetBuilder<QuestionController>(
        init: QuestionController(),
        builder: (controller) {
          return Stack(
            children: [
              //new style green to red
              LayoutBuilder(
                builder: (context, constraints) {
                  final animationValue = controller.animation.value;
                  final color = ColorTween(
                          begin: Colors.redAccent, end: Colors.greenAccent)
                      .lerp(animationValue);

                  return Container(
                    // from 0 to 1 it takes 60s
                    width: constraints.maxWidth * animationValue,
                    decoration: BoxDecoration(
                      color: color, // Use the interpolated color
                      borderRadius: BorderRadius.circular(50),
                    ),
                  );
                },
              ),
              //Old style all green
              // LayoutBuilder(
              //   builder: (context, constraints) => Container(
              //     // from 0 to 1 it takes 60s
              //     width: constraints.maxWidth * controller.animation.value,
              //     decoration: BoxDecoration(
              //       gradient: kPrimaryGradient,
              //       borderRadius: BorderRadius.circular(50),
              //     ),
              //   ),
              // ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: kDefaultPadding / 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${(controller.animation.value * 15).round()} sec"),
                      SvgPicture.asset("assets/icons/clock.svg"),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
