import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:namaz_vakti/models/prayer_times.dart';
import 'package:namaz_vakti/screens/home/prayer_times_mixin.dart';
import 'package:namaz_vakti/screens/home/view_model/index.dart';
import 'package:namaz_vakti/screens/location/providers/location_providers.dart';
import 'package:namaz_vakti/screens/selection/selection_screen.dart';
import 'package:namaz_vakti/services/cache_service.dart';
import 'package:namaz_vakti/utils/time_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

// get part
part '../providers/home_providers.dart';

class HomeCacheNotifier extends StateNotifier<List<List<String>>?> {
  HomeCacheNotifier(this.cachedPrayerTimes) : super(cachedPrayerTimes);

  final List<List<String>>? cachedPrayerTimes;

  Future<void> getPrayerTimesFromCache() async {
    final encodedPrayerTimes = await CacheManager().get<String>('prayerTimes');

    state = (json.decode(encodedPrayerTimes) as List<dynamic>)
        .map((e) => (e as List<dynamic>).map((f) => f as String).toList())
        .toList();
  }
}

final homeCacheProvider =
    StateNotifierProvider<HomeCacheNotifier, List<List<String>>?>(
  (ref) => HomeCacheNotifier(null),
);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool? isLocation;
  Future<void> getLocationBoolValue() async {
    final prefs = await SharedPreferences.getInstance();
    isLocation = prefs.getBool('isLocationEnabled');
  }

  List<List<String>>? cachedPrayerTimes;

  Future<List<List<String>>?> getPrayerTimesFromCache() async {
    final encodedPrayerTimes = await CacheManager().get<String>('prayerTimes');

    return cachedPrayerTimes =
        (json.decode(encodedPrayerTimes) as List<dynamic>)
            .map((e) => (e as List<dynamic>).map((f) => f as String).toList())
            .toList();
  }

  @override
  void initState() {
    getLocationBoolValue();
    getPrayerTimesFromCache();
    print(cachedPrayerTimes);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cprayer = ref.watch(homeCacheProvider.notifier).state;
    
    final prayerTimes = (isLocation ?? true)
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
        child: (cprayer?.isEmpty ?? true)
            ? prayerTimes.when(
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
                    ref
                        .read(prayerTimesProvider.notifier)
                        .savePrayerTimesToCache();
                    return const PrayerTimesView();
                  }
                },
              )
            : const PrayerTimesView(),
      ),
    );
  }

  AppBar _homeAppBar(
    BuildContext context,
    AsyncValue<PrayerTimesModel?> prayerTimes,
  ) {
    return AppBar(
      leading: IconButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (context) => const SelectionScreenView(),
            ),
          );
        },
        icon: const Icon(Icons.location_on),
      ),
      title: prayerTimes.when(
        data: (i) {
          return Text(i?.place?.city ?? '');
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.20,
                child: Card(
                  child: Center(
                    child: Text(
                      date,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
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
