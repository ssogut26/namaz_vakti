import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:namaz_vakti/models/prayer_times.dart';
import 'package:namaz_vakti/screens/home/mixins/prayer_times_mixin.dart';
import 'package:namaz_vakti/screens/home/view_model/index.dart';
import 'package:namaz_vakti/screens/location/providers/location_providers.dart';
import 'package:namaz_vakti/screens/no_conneciton_screen.dart';
import 'package:namaz_vakti/screens/qibla/compass_qibla.dart';
import 'package:namaz_vakti/screens/selection/selection_screen.dart';
import 'package:namaz_vakti/services/connection_service.dart';
import 'package:namaz_vakti/services/notification.dart';
import 'package:namaz_vakti/utils/time_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

// get part
part '../providers/home_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool? isLocation;

  /// It was'nt work with the hive so I used shared preferences in here.
  Future<void> getLocationBoolValue() async {
    final prefs = await SharedPreferences.getInstance();
    isLocation = prefs.getBool('isLocationEnabled');
  }

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final cacheHive = Hive.box<PrayerTimesModel>('prayerTimesModel');

  Future<void> showNotification(List<String> prayerTimes) async {
    await NotificationService().initNotifications();
    await NotificationService().showNotification(prayerTimes);
  }

  @override
  void initState() {
    getLocationBoolValue();
    final prayerTimes = ref.read(prayerTimesProvider.notifier)._prayerTimes;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showNotification(
        prayerTimes?.first ??
            cacheHive.get('prayerTimes')?.times?.values.first ??
            [],
      ),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = ref.watch(connectivityProvider);
    final prayerTimesModel = ref
        .watch(prayerTimesProvider.notifier)
        .cachedPrayerTimes
        .get('prayerTimes');
    final format = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final prayerTimes = (isLocation ?? true)
        ? ref.watch(
            getPrayerTimesWithLocation(
              format,
            ),
          )
        : ref.watch(
            getPrayerTimesWithSelection(
              format,
            ),
          );

    if (connectivity == ConnectivityStatus.isDisconnected &&
        prayerTimesModel == null) {
      return const NoConnectionScreenView();
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {},
      ),
      key: _key,
      drawer: const HomeDrawer(),
      appBar: _homeAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: connectivity == ConnectivityStatus.NotDetermined
            ? const Center(child: CircularProgressIndicator())
            : prayerTimesModel == null ||
                    (prayerTimesModel.times?.isEmpty ?? true) &&
                        connectivity == ConnectivityStatus.isConnected
                ? prayerTimes.when(
                    loading: LoadingWidget.new,
                    error: (error, stackTrace) =>
                        const Center(child: Text('Something went wrong')),
                    data: (PrayerTimesModel? prayerModel) {
                      if (prayerModel?.times?.isEmpty ?? true) {
                        return const Center(
                          child: Text(
                            "We didn't find any data on this location. Please check your location.",
                          ),
                        );
                      }

                      ref.read(prayerTimesProvider.notifier).prayerTimes =
                          prayerModel!.times!.values.toList();
                      ref.read(prayerTimesProvider.notifier)._prayerTimesModel =
                          prayerModel;
                      ref
                          .read(prayerTimesProvider.notifier)
                          .updatePrayerTimesModel();

                      return const PrayerTimesView();
                    },
                  )
                : Builder(
                    builder: (context) {
                      final prayerModel = cacheHive.get('prayerTimes');
                      ref.read(prayerTimesProvider.notifier)
                        ..prayerTimes = prayerModel?.times?.values.toList()
                        .._prayerTimesModel = prayerModel
                        ..updatePrayerTimesModel();
                      return const PrayerTimesView();
                    },
                  ),
      ),
    );
  }

  AppBar _homeAppBar(
    BuildContext context,
  ) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(cacheHive.get('prayerTimes')?.place?.city.toString() ?? ''),
      actions: [
        IconButton(
          onPressed: () async {
            _key.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
      ],
    );
  }
}

class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appBarPrayerTimes =
        ref.watch(prayerTimesProvider.notifier).prayerTimesModel;
    final prayerTimesModel = ref
        .watch(prayerTimesProvider.notifier)
        .cachedPrayerTimes
        .get('prayerTimes');
    final date = DateFormat.MMMd()
        .format(DateTime.parse(appBarPrayerTimes?.times?.keys.first ?? ''));
    return Drawer(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            DrawerHeader(
              child: ListTile(
                subtitle: Text(
                  date,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                title: Text(
                  appBarPrayerTimes?.place?.city ??
                      prayerTimesModel?.place?.city ??
                      '',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                await Hive.box<PrayerTimesModel>('prayerTimesModel').clear();
                await Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (context) => const SelectionScreenView(),
                  ),
                );
              },
              leading: const Icon(Icons.location_on_outlined),
              title: Text(
                'Change Location',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const QiblaCompassView(),
                  ),
                );
              },
              leading: const Icon(Icons.compass_calibration_outlined),
              title: Text(
                'Find Qibla',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Spacer(),
            ListTile(
              onTap: () {},
              leading: const Icon(
                Icons.report_problem_outlined,
                color: Colors.red,
              ),
              title: Text(
                'Report a problem',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.red),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            )
          ],
        ),
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
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
