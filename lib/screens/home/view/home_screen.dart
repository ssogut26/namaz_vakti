// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:namaz_vakti/extensions/extensions.dart';
import 'package:namaz_vakti/generated/locale_keys.g.dart';
import 'package:namaz_vakti/models/prayer_times.dart';
import 'package:namaz_vakti/screens/home/mixins/home_mixin.dart';
import 'package:namaz_vakti/screens/home/view/prayer_times_view.dart';
import 'package:namaz_vakti/screens/home/view_model/drawer.dart';
import 'package:namaz_vakti/screens/location/providers/location_providers.dart';
import 'package:namaz_vakti/screens/no_conneciton_screen.dart';
import 'package:namaz_vakti/services/connection_service.dart';
import 'package:namaz_vakti/utils/loading.dart';
import 'package:namaz_vakti/utils/time_utils.dart';

// get part
part '../providers/home_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with HomeScreenMixin {
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
    if (isLoading == true) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          isLoading = false;
        });
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      key: key,
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
                    error: (error, stackTrace) => Center(
                      child: Text(LocaleKeys.error_wentWrong.locale),
                    ),
                    data: (PrayerTimesModel? prayerModel) {
                      if (prayerModel?.times?.isEmpty ?? true) {
                        return Center(
                          child: Text(
                            LocaleKeys.error_locationNotFound.locale,
                          ),
                        );
                      }

                      ref.read(prayerTimesProvider.notifier).setPrayerTimes =
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
                        ..setPrayerTimes = prayerModel?.times?.values.toList()
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
    final prayerTimes =
        ref.read(prayerTimesProvider.notifier)._prayerTimesModel;

    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        cacheHive.get('prayerTimes')?.place?.city.toString() ??
            prayerTimes?.place?.city ??
            '',
      ),
      actions: [
        IconButton(
          onPressed: () async {
            key.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
      ],
    );
  }
}
