import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:namaz_vakti/models/prayer_times.dart';
import 'package:namaz_vakti/screens/home/view_model/index.dart';
import 'package:namaz_vakti/screens/location_selection.dart';
import 'package:namaz_vakti/utils/time_utils.dart';

// get part
part '../providers/home_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.isLocation});

  final bool? isLocation;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // ignore: prefer_final_locals
    final prayerTimes = (widget.isLocation ?? false)
        ? ref.watch(
            getPrayerTimesWithLocation(
              DateFormat('yyyy-MM-dd').format(DateTime.now()),
            ),
          )
        : ref.watch(
            getPrayerTimesWithSelection(
              DateFormat('yyyy-MM-dd').format(DateTime.now()),
            ),
          );
    return Scaffold(
      drawer: const Drawer(
        child: Column(),
      ),
      appBar: _homeAppBar(context, prayerTimes),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: prayerTimes.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Text(error.toString()),
          ),
          data: (PrayerTimesModel? prayerModel) {
            if (prayerModel?.times?.isEmpty ?? true) {
              return const Center(
                child: Text('No data'),
              );
            } else {
              ref.read(prayerTimesProvider.notifier).prayerTimes =
                  prayerModel?.times?.values.map((e) => e).toList();

              return const PrayerTimesView();
            }
          },
        ),
      ),
    );
  }

  AppBar _homeAppBar(
    BuildContext context,
    AsyncValue<PrayerTimesModel?> prayerTimes,
  ) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.location_on),
      ),
      title: prayerTimes.when(
        data: (i) {
          return Column(
            children: [
              Text(i?.place?.city ?? ''),
              Text(i?.times?.keys.first ?? ''),
            ],
          );
        },
        error: (error, stacktrace) {
          return Text(error.toString());
        },
        loading: CircularProgressIndicator.new,
      ),
      actions: [
        IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
      ],
    );
  }
}

class PrayerTimesView extends ConsumerStatefulWidget {
  const PrayerTimesView({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PrayerTimesViewState();
}

class _PrayerTimesViewState extends ConsumerState<PrayerTimesView> {
  List<List<String>>? prayerTimes;
  Duration? remainingTime;
  String? nextPrayerTime;
  int? upcomingTime;
  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    final prayerTimes = ref.read(prayerTimesProvider.notifier).prayerTimes;
    final remainingTime = ref.read(
      findRemainingTimeProvider(
        prayerTimes ?? [],
      ).notifier,
    );
    final date = ref.watch(dateProvider.notifier).getDate();
    final maghrib = timeToMinutes(prayerTimes?[0][4] ?? '');
    final time = ref.watch(currentTimeProvider)._time =
        timeToMinutes(DateFormat('HH:mm').format(DateTime.now()));
    return PageView.builder(
      onPageChanged: (index) {
        ref.read(dateProvider.notifier).updateDate(
              DateTime.now().add(
                Duration(days: index),
              ),
            );
        ref.read(pageIndexProvider.notifier).pageIndex = index;
      },
      itemCount: ref.read(prayerTimesProvider.notifier).prayerTimes?.length,
      itemBuilder: (context, pageIndex) {
        return Column(
          children: [
            if (pageIndex != 0)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.20,
                child: Card(
                  child: Center(
                    child: Text(date),
                  ),
                ),
              )
            else
              NextPrayerTimeCard(
                times: prayerTimes ?? [],
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              // ignore: lines_longer_than_80_chars
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  width: pageIndex == 0
                      ? MediaQuery.of(context).size.width * 0.80
                      : MediaQuery.of(context).size.width * 0.95,
                  child: ListView.builder(
                    // There is 6 value on each day so
                    // we need to set itemCount to 6
                    itemCount: prayerTimes?[0].length ?? 0,
                    itemBuilder: (context, index) {
                      return Card(
                        color: upcomingTime == index && pageIndex == 0
                            ? Colors.grey
                            : Colors.white,
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
          ],
        );
      },
    );
  }
}