import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:namaz_vakti/extensions/extensions.dart';
import 'package:namaz_vakti/generated/locale_keys.g.dart';
import 'package:namaz_vakti/models/prayer_times.dart';
import 'package:namaz_vakti/screens/home/view/home_screen.dart';
import 'package:namaz_vakti/screens/qibla/compass_qibla.dart';
import 'package:namaz_vakti/screens/selection/selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                LocaleKeys.drawer_changeLocation.locale,
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
                LocaleKeys.drawer_findQibla.locale,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Spacer(),
            ListTile(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final radioValue = prefs.getInt('language') ?? 2;

                await showModalBottomSheet<Column>(
                  context: context,
                  builder: (context) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text(
                              LocaleKeys.language_language.locale,
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.left,
                            ),
                            RadioListTile(
                              value: 0,
                              groupValue: radioValue,
                              onChanged: (value) async {
                                await prefs.remove('language');
                                await prefs.setInt('language', 0);
                                await context
                                    .setLocale(const Locale('en', 'US'));
                                Navigator.of(context).pop();
                              },
                              title: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/en.png',
                                    height: 40,
                                    width: 40,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      LocaleKeys.language_en.locale,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RadioListTile(
                              toggleable: true,
                              value: 1,
                              groupValue: radioValue,
                              onChanged: (value) async {
                                await prefs.remove('language');
                                await prefs.setInt('language', 1);
                                await context
                                    .setLocale(const Locale('tr', 'TR'));
                                Navigator.of(context).pop();
                              },
                              title: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/tr.png',
                                    height: 40,
                                    width: 40,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      LocaleKeys.language_tr.locale,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              leading: const Icon(Icons.settings_outlined),
              title: Text(
                LocaleKeys.language_changeLanguage.locale,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              onTap: () {},
              leading: const Icon(
                Icons.report_problem_outlined,
                color: Colors.red,
              ),
              title: Text(
                LocaleKeys.drawer_reportProblem.locale,
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
