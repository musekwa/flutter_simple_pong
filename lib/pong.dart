import 'package:flutter/material.dart';
import 'bat.dart';
import 'ball.dart';
import 'dart:math';

enum Direction { up, down, left, right }

class Pong extends StatefulWidget {
  const Pong({Key? key}) : super(key: key);

  @override
  _PongState createState() => _PongState();
}

class _PongState extends State<Pong> with SingleTickerProviderStateMixin {
  double width = 0;
  double height = 0;
  double posX = 0;
  double posY = 0;
  double batWidht = 0;
  double batHeight = 0;
  double batPosition = 0;
  double increment = 5;
  double randX = 1;
  double randY = 1;

  int score = 0;

  late Animation<double> animation;
  late AnimationController controller;

  Direction vDir = Direction.down;
  Direction hDir = Direction.right;

  @override
  void initState() {
    posX = 0;
    posY = 0;
    controller = AnimationController(
      duration: const Duration(minutes: 10000),
      vsync: this,
    );
    animation = Tween<double>(begin: 0, end: 100).animate(controller);
    animation.addListener(() {
      safeSetState(() {
        (hDir == Direction.right)
            ? posX += ((increment * randX).round())
            : posX -= ((increment * randX).round());
        (vDir == Direction.down)
            ? posY += ((increment * randY).round())
            : posY -= ((increment * randY).round());
      });
      checkBorders();
    });
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      height = constraints.maxHeight;
      width = constraints.maxWidth;
      batHeight = height / 20;
      batWidht = width / 5;
      return Stack(
        children: [
          Positioned(
            top: 0,
            right: 24,
            child: Text('Score: ' + score.toString()),
          ),
          Positioned(
            child: Ball(),
            top: posY,
            left: posX,
          ),
          Positioned(
            child: GestureDetector(
              onHorizontalDragUpdate: (DragUpdateDetails update) =>
                  moveBat(update),
              child: Bat(batWidht, batHeight),
            ),
            left: (batPosition >= width - batWidht)
                ? width - batWidht
                : (batPosition <= 0)
                    ? 0
                    : batPosition,
            bottom: 0,
          ),
        ],
      );
    });
  }

  void showMessage(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Game Over'),
            content: Text('Would you like to play again?'),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      posX = 0;
                      posY = 0;
                      score = 0;
                    });
                    Navigator.of(context).pop();
                    controller.repeat();
                  },
                  child: Text('Yes')),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  dispose();
                },
                child: Text('No'),
              ),
            ],
          );
        });
  }

  double randomNumber() {
    var ran = new Random();
    int myNum = ran.nextInt(101);
    return (50 + myNum) / 100;
  }

  void safeSetState(Function function) {
    if (mounted && controller.isAnimating) {
      setState(() {
        function();
      });
    }
  }

  void moveBat(DragUpdateDetails update) {
    safeSetState(() {
      batPosition += update.delta.dx;
    });
  }

  void checkBorders() {
    double diameter = 50;
    if (posX <= 0 && hDir == Direction.left) {
      hDir = Direction.right;
      randX = randomNumber();
    }

    if (posX >= width - 50 && hDir == Direction.right) {
      hDir = Direction.left;
      randX = randomNumber();
    }

    if (posY >= height - 50) {
      if (posX >= (batPosition - 50) && posX <= (batPosition + batWidht + 50)) {
        vDir = Direction.up;
        randY = randomNumber();
        safeSetState(() {
          score++;
        });
      } else {
        controller.stop();
        showMessage(context);
      }
    }

    //  if (posY >= height - 50 - batHeight && vDir == Direction.down) {
    //    vDir = Direction.up;
    /*
      if (posX >= (batPosition - 50) &&
          posX <= (batPosition + batWidht + 50)) {
        vDir = Direction.up;
      } else {
        controller.stop();
        dispose();
      }
      */
    //}

    if (posY <= 0 && vDir == Direction.up) {
      vDir = Direction.down;
      randY = randomNumber();
    }
  }
}
