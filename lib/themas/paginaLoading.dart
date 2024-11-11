// ignore_for_file: file_names, camel_case_types, library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: paginaLoading(),
    );
  }
}

class paginaLoading extends StatefulWidget {
  const paginaLoading({super.key});

  @override
  _paginaLoadingState createState() => _paginaLoadingState();
}

class _paginaLoadingState extends State<paginaLoading>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..forward();
    _startTimer();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    int seconds = 0;
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {
          seconds++;
          if (seconds >= 5) {
            timer.cancel();
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 7,
          child: AnimatedLinearProgressIndicator(
            animation: _animationController!,
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }
}

class AnimatedLinearProgressIndicator extends AnimatedWidget {
  final Color backgroundColor;
  final Animation<Color?> valueColor;

  const AnimatedLinearProgressIndicator({
    Key? key,
    required this.backgroundColor,
    required this.valueColor,
    required Animation<double> animation,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;

    return LinearProgressIndicator(
      value: animation.value,
      backgroundColor: backgroundColor,
      minHeight: 10,
      valueColor: valueColor,
    );
  }
}
