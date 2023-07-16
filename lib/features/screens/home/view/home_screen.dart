// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:namaz_vakti/constants/constants.dart';
import 'package:namaz_vakti/extensions/extensions.dart';
import 'package:namaz_vakti/features/models/prayer_times.dart';
import 'package:namaz_vakti/features/screens/home/widgets/index.dart';
import 'package:namaz_vakti/features/screens/no_connection/view/no_conneciton_screen.dart';
import 'package:namaz_vakti/generated/locale_keys.g.dart';
import 'package:namaz_vakti/mixins/mixin_index.dart';
import 'package:namaz_vakti/product/providers/location_providers.dart';
import 'package:namaz_vakti/product/services/connection_service.dart';
import 'package:namaz_vakti/product/utils/loading.dart';
import 'package:namaz_vakti/product/utils/time_utils.dart';

// get part
part '../../../../product/providers/home_providers.dart';
part 'prayer_times.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with HomeScreenMixin {
  @override
  Widget build(BuildContext context) {
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
    final connectivity = ref.watch(connectivityProvider);
    final prayerTimesModel = ref
        .watch(prayerTimesProvider.notifier)
        .cachedPrayerTimes
        .get('prayerTimes');
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
                      savePrayerTimes(prayerModel);
                      return prayerTimesView(prayerModel);
                    },
                  )
                : Builder(
                    builder: (context) {
                      fetchPrayerTimesFromLocal();
                      return const PrayerTimesView();
                    },
                  ),
      ),
    );
  }

  AppBar _homeAppBar(
    BuildContext context,
  ) {
    final prayerTimes = ref.read(prayerTimesProvider.notifier).prayerTimesModel;

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
