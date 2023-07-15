part of 'home_screen.dart';

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
              _DateCard(date: date)
            else
              _NextTimeCard(prayerTimes: prayerTimes),
            _AllTimesCard(
              pageIndex: pageIndex,
              prayerTimes: prayerTimes,
              upcomingTime: upcomingTime,
              remainingTime: remainingTime,
              time: time,
              maghrib: maghrib,
            ),
          ],
        );
      },
    );
  }
}

class _AllTimesCard extends StatelessWidget {
  const _AllTimesCard({
    required this.prayerTimes,
    required this.upcomingTime,
    required this.remainingTime,
    required this.time,
    required this.maghrib,
    required this.pageIndex,
  });

  final List<List<String>>? prayerTimes;
  final int? upcomingTime;
  final FindRemainingTimeNotifier remainingTime;
  final int time;
  final int maghrib;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                      ? AppConstants.midnightBlue
                      : AppConstants.phosphoreGreen,
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
    );
  }
}

class _NextTimeCard extends StatelessWidget {
  const _NextTimeCard({
    required this.prayerTimes,
  });

  final List<List<String>>? prayerTimes;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Card(
        margin: const EdgeInsets.all(2),
        color: AppConstants.pistachio,
        child: NextPrayerTimeCard(
          times: prayerTimes ?? [],
        ),
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.date,
  });

  final String date;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.20,
        child: Card(
          color: AppConstants.pistachio,
          child: Center(
            child: Text(
              date,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        ),
      ),
    );
  }
}
