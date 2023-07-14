import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_vakti/screens/home/mixins/prayer_times_mixin.dart';
import 'package:namaz_vakti/screens/home/view/home_screen.dart';
import 'package:namaz_vakti/screens/home/view_model/countdown.dart';
import 'package:namaz_vakti/screens/home/view_model/moon_slider.dart';
import 'package:namaz_vakti/screens/home/view_model/prayer_times.dart';
import 'package:namaz_vakti/screens/home/view_model/sun_slider.dart';
import 'package:namaz_vakti/utils/time_utils.dart';

class PrayerTimesView extends ConsumerStatefulWidget {
  const PrayerTimesView({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PrayerTimesViewState();
}

class _PrayerTimesViewState extends ConsumerState<PrayerTimesView>
    with PrayerTimesViewMixin {
  @override
  Widget build(BuildContext context) {
    final remainingTime = ref.watch(
      findRemainingTimeProvider(
        prayerTimes ?? [],
      ).notifier,
    );
    final date = ref.watch(dateProvider.notifier).getDate();
    final maghrib = timeToMinutes(prayerTimes?[0][4] ?? '');
    final time = ref.watch(currentTimeProvider.notifier).currentTime;

    return PageView.builder(
      onPageChanged: onPageChanged,
      itemCount: prayerTimes?.length,
      itemBuilder: (context, pageIndex) {
        return Column(
          children: [
            if (pageIndex != 0)
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.20,
                  child: Card(
                    color: const Color(0XFFC3D350),
                    child: Center(
                      child: Text(
                        date,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                flex: 3,
                child: Card(
                  margin: const EdgeInsets.all(2),
                  color: const Color(0XFFC3D350),
                  child: NextPrayerTimeCard(
                    times: prayerTimes ?? [],
                  ),
                ),
              ),
            Expanded(
              flex: 10,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                // ignore: lines_longer_than_80_chars
                children: [
                  SizedBox(
                    width: pageIndex == 0
                        ? MediaQuery.of(context).size.width * 0.80
                        : MediaQuery.of(context).size.width * 0.95,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      // There is 6 value on each day so
                      // we need to set itemCount to 6
                      itemCount: prayerTimes?[0].length ?? 0,
                      itemBuilder: (context, index) {
                        return Card(
                          color: upcomingTime == index && pageIndex == 0
                              ? const Color(0xFF7A918D)
                              : const Color(0XFFC2F9BB),
                          child: DailyPrayerTimesWidget(
                            upcomingTime: upcomingTime,
                            remainingTime: remainingTime,
                            prayerTimesByDay: prayerTimes,
                            index: index,
                          ),
                        );
                      },
                    ),
                  ),
                  if (pageIndex != 0)
                    const SizedBox.shrink()
                  else
                    time < maghrib ? const SunSlider() : const MoonSlider()
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
