import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_vakti/screens/home/view/home_screen.dart';

mixin PrayerTimesViewMixin on ConsumerState<PrayerTimesView> {
  List<List<String>>? prayerTimes;
  Duration? remainingTime;
  String? nextPrayerTime;
  int? upcomingTime;
  @override
  WidgetRef get ref;
  List<List<String>>? cachedPrayerTimes;
  // Future<void> getCachedPrayerTimes() async {
  //   final encodedPrayerTimes = await CacheManager().get<String>('prayerTimes');
  //   cachedPrayerTimes = (json.decode(encodedPrayerTimes) as List<dynamic>)
  //       .map((e) => (e as List<dynamic>).map((f) => f as String).toList())
  //       .toList();
  // }

  @override
  void initState() {
    // getCachedPrayerTimes();
    prayerTimes = ref.read(prayerTimesProvider.notifier).prayerTimes;

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
