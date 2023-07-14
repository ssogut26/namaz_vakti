import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_vakti/screens/home/view/home_screen.dart';
import 'package:namaz_vakti/screens/home/view/prayer_times_view.dart';

mixin PrayerTimesViewMixin on ConsumerState<PrayerTimesView> {
  List<List<String>>? prayerTimes;
  Duration? remainingTime;
  String? nextPrayerTime;
  int? upcomingTime;
  @override
  WidgetRef get ref;

  @override
  void initState() {
    prayerTimes = ref.read(prayerTimesProvider.notifier).setPrayerTimes;

    final providerRemainingTime =
        ref.read(findRemainingTimeProvider(prayerTimes ?? []).notifier);
    remainingTime = providerRemainingTime.findRemainingTime();
    nextPrayerTime = providerRemainingTime.getNextPrayerTime(
      providerRemainingTime.index,
    );
    upcomingTime = providerRemainingTime.nextPrayerTimeIndex;
    super.initState();
  }

  void onPageChanged(int index) {
    setState(() {
      ref.read(dateProvider.notifier).updateDate(
            DateTime.now().add(
              Duration(days: index),
            ),
          );
      ref.read(pageIndexProvider.notifier).pageIndex = index;
    });
  }
}
