import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:namaz_vakti/constants/constants.dart';
import 'package:namaz_vakti/features/screens/home/view/home_screen.dart';

class DailyPrayerTimesWidget extends ConsumerWidget {
  const DailyPrayerTimesWidget({
    required this.upcomingTime,
    required this.remainingTime,
    required this.prayerTimesByDay,
    this.index,
    super.key,
  });

  final int? upcomingTime;
  final FindRemainingTimeNotifier remainingTime;
  final List<List<String>>? prayerTimesByDay;
  final int? index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageIndex = ref.watch(pageIndexProvider.notifier).pageIndex;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListTile(
        leading: SvgPicture.asset(AppConstants.timeIcons[index ?? 0]),
        title: Center(
          child: Text(
            remainingTime.getNextPrayerTime(index ?? 0),
          ),
        ),
        trailing: Text(
          prayerTimesByDay?[pageIndex ?? 0][index ?? 0] ?? '',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
