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
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            '$nextPrayerTime in',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Align(
            child: Countdown(
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
          ),
        ],
      ),
    );
  }
}

final class Countdown extends AnimatedWidget {
  Countdown({
    super.key,
    this.animation,
  }) : super(listenable: animation!);
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
        Column(
          children: [
            Card(
              elevation: 3,
              color: const Color(0xFF8ACDEA),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      hourTimer == 0
                          ? minuteTimer.toString().padLeft(2, '0')
                          : hourTimer.toString().padLeft(2, '0'),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              hourTimer == 0 ? 'Minutes' : 'Hours',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const AnimatedOpacity(
          opacity: 1,
          duration: Duration(seconds: 1),
          child: Text(':', style: TextStyle(fontSize: 45)),
        ),
        Column(
          children: [
            Card(
              color: const Color(0xFFF38D68),
              elevation: 3,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      hourTimer != 0
                          ? minuteTimer.toString().padLeft(2, '0')
                          : secondTimer.toString().padLeft(2, '0'),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              hourTimer != 0 ? 'Minutes' : 'Seconds',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}
