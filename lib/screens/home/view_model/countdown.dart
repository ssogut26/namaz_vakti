import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_vakti/screens/home/view/home_screen.dart';

class NextPrayerTimeCard extends ConsumerStatefulWidget {
  const NextPrayerTimeCard({
    required this.times,
    super.key,
  });

  final List<List<String>> times;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NextPrayerTimeCardState();
}

class _NextPrayerTimeCardState extends ConsumerState<NextPrayerTimeCard>
    with TickerProviderStateMixin {
  Timer? _timer;
  AnimationController? _controller;
  int countTimer = 0;
  String nextPrayerTime = '';

  @override
  void initState() {
    super.initState();
    countTimer = ref
        .read(findRemainingTimeProvider(widget.times).notifier)
        .getRemainingTime();
    nextPrayerTime = ref
        .read(findRemainingTimeProvider(widget.times).notifier)
        .getNextPrayerTime(
          ref.read(findRemainingTimeProvider(widget.times).notifier).index,
        );
    _startTimer();
  }

  /// When the timer is completed we are refreshing the timer
  void _refreshTimer() {
    setState(() {
      countTimer = ref
          .read(findRemainingTimeProvider(widget.times).notifier)
          .getRemainingTime();
    });
    _startTimer();
  }

  void _startTimer() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: countTimer),
    );

    _controller?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Timer reached 00:00, perform necessary actions here
        _refreshTimer();
      }
    });
    _controller?.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countTimer == 0) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.20,
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [
          Text(
            '$nextPrayerTime in',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Countdown(
            animation: StepTween(
              begin: countTimer,
              end: 0,
            ).animate(
              _controller ??
                  AnimationController(
                    vsync: this,
                    duration: Duration(
                      seconds: countTimer,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

final class Countdown extends AnimatedWidget {
  Countdown({super.key, this.animation}) : super(listenable: animation!);
  final Animation<int>? animation;

  @override
  Row build(BuildContext context) {
    final clockTimer = Duration(seconds: animation?.value ?? 10);
    final hourTimer = clockTimer.inHours.remainder(24);
    final minuteTimer = clockTimer.inMinutes.remainder(60);
    final secondTimer = clockTimer.inSeconds.remainder(60);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          elevation: 10,
          child: Column(
            children: [
              Text(
                hourTimer == 0
                    ? minuteTimer.toString().padLeft(2, '0')
                    : hourTimer.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 55,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                hourTimer == 0 ? 'Minutes' : 'Hours',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const Text(':', style: TextStyle(fontSize: 45)),
        Card(
          color: Colors.white,
          elevation: 10,
          child: Column(
            children: [
              Text(
                hourTimer != 0
                    ? minuteTimer.toString().padLeft(2, '0')
                    : secondTimer.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 55,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                hourTimer != 0 ? 'Minutes' : 'Seconds',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
