part of '../view/home_screen.dart';

final homeScreenProvider = Provider<HomeScreen>((ref) => const HomeScreen());

class ConnectivityStatusNotifier extends StateNotifier<ConnectivityStatus> {
  ConnectivityStatusNotifier() : super(ConnectivityStatus.NotDetermined) {
    initConnectivity();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await Connectivity().checkConnectivity();
    } on PlatformException catch (e) {
      print(e);
      return;
    }
    if (!mounted) {
      return;
    }
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile ||
            ConnectivityResult.wifi ||
            ConnectivityResult.vpn ||
            ConnectivityResult.ethernet:
        state = ConnectivityStatus.isConnected;

      case ConnectivityResult.none ||
            ConnectivityResult.bluetooth ||
            ConnectivityResult.other:
        state = ConnectivityStatus.isDisconnected;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityStatusNotifier, ConnectivityStatus>(
  (ref) => ConnectivityStatusNotifier(),
);

final class CurrentTimeNotifier extends StateNotifier<int> {
  CurrentTimeNotifier(
    this.currentTime,
  ) : super(currentTime);

  int currentTime = timeToMinutes(DateFormat('HH:mm').format(DateTime.now()));
}

final currentTimeProvider =
    StateNotifierProvider<CurrentTimeNotifier, int?>((ref) {
  return CurrentTimeNotifier(
    timeToMinutes(DateFormat('HH:mm').format(DateTime.now())),
  );
});

final class PrayerTimesNotifier extends StateNotifier<List<List<String>>> {
  PrayerTimesNotifier(
    this.prayerTimes,
  ) : super(prayerTimes ?? []);

  List<List<String>>? prayerTimes;
  List<List<String>>? get setPrayerTimes => prayerTimes;
  PrayerTimesModel? _prayerTimesModel;
  PrayerTimesModel? get prayerTimesModel => _prayerTimesModel;
  final cachedPrayerTimes = Hive.box<PrayerTimesModel>('prayerTimesModel');

  set prayerTimesModel(PrayerTimesModel? prayerTimesModel) {
    _prayerTimesModel = prayerTimesModel;
  }

  Future<void> updatePrayerTimesModel() async {
    await cachedPrayerTimes.put(
      'prayerTimes',
      _prayerTimesModel ?? const PrayerTimesModel(),
    );
  }

  set setPrayerTimes(List<List<String>>? prayerTime) {
    prayerTimes = prayerTime;
  }
}

final prayerTimesProvider =
    StateNotifierProvider<PrayerTimesNotifier, List<List<String>>?>((ref) {
  return PrayerTimesNotifier(null);
});

final class PageIndex extends StateNotifier<int> {
  PageIndex(
    this._pageIndex,
  ) : super(_pageIndex ?? 0);

  int? _pageIndex;
  int? get pageIndex => _pageIndex;

  set pageIndex(int? pageIndex) {
    _pageIndex = pageIndex;
  }
}

final pageIndexProvider = StateNotifierProvider<PageIndex, int?>((ref) {
  return PageIndex(null);
});

final dateProvider = StateNotifierProvider<DateNotifier, String>((ref) {
  return DateNotifier();
});

final class DateNotifier extends StateNotifier<String> {
  DateNotifier() : super(DateFormat('yyyy-MM-dd').format(DateTime.now()));
  String? date;
  void updateDate(DateTime date) {
    state = DateFormat.MMMd().format(date);
  }

  String getDate() {
    return date = state;
  }
}

final class FindRemainingTimeNotifier
    extends StateNotifier<List<List<String>>> {
  FindRemainingTimeNotifier(super.state);

  /// Index of the prayer time in the day
  int index = 0;

  /// Current time in minutes
  int time = 0;

  /// Checking indexes and find next prayer time
  int nextTime = 0;

  /// Time to next prayer time
  Duration? remainingTime;

  /// Next prayer time
  String? nextPrayerTime;

  /// Index of next prayer time
  int nextPrayerTimeIndex = 0;

  /// This requires for the find remaining time and
  /// using the value on other functions
  Duration? findRemainingTime() {
    /// Converting current time to coming prayer time
    final currentTime = DateFormat('HH:mm').format(DateTime.now().toLocal());

    /// Converting current time to minutes
    time = timeToMinutes(currentTime);

    /// Checking indexes and find next prayer time
    for (index = 0; index < state[0].length;) {
      /// Converting next prayer time to minutes
      nextTime = timeToMinutes(state[0][index]);

      /// Checking if the next prayer time is less than current time
      var checkTime = nextTime - time;

      /// Checking if the next prayer time is less than current time
      /// we are checking 5th index because the last prayer time is Isha
      if (checkTime.isNegative && index == 5) {
        /// Converting next day sunrise to minutes
        index = 0;
        nextTime = timeToMinutes(state[1][0]);

        /// Checking if the next day sunrise is less than current time
        if (time < 1440) {
          /// Last time minus current time and adding next day sunrise
          checkTime = 1440 - time + nextTime;
        } else {
          /// Next day sunrise minus current time
          checkTime = nextTime - time;
        }
        remainingTime = Duration(minutes: checkTime);
        break;
      } else if (checkTime.isNegative || checkTime == 0) {
        /// if its negative or equal to 0 we are checking the next index
        index++;
      } else {
        return remainingTime = Duration(minutes: checkTime);
      }
    }
    return remainingTime;
  }

  /// Getting next prayer time in string because
  /// backend only sends times in string
  /// and next prayer time index FOR THE COLOR
  String getNextPrayerTime([int customIndex = 0]) {
    switch (customIndex) {
      case 0:
        nextPrayerTime = LocaleKeys.prayerTimes_fajr.locale;
        nextPrayerTimeIndex = 0;
      case 1:
        nextPrayerTime = LocaleKeys.prayerTimes_sunrise.locale;
        nextPrayerTimeIndex = 1;
      case 2:
        nextPrayerTime = LocaleKeys.prayerTimes_dhuhr.locale;
        nextPrayerTimeIndex = 2;
      case 3:
        nextPrayerTime = LocaleKeys.prayerTimes_asr.locale;
        nextPrayerTimeIndex = 3;
      case 4:
        nextPrayerTime = LocaleKeys.prayerTimes_maghrib.locale;
        nextPrayerTimeIndex = 4;
      case 5:
        nextPrayerTime = LocaleKeys.prayerTimes_isha.locale;
        nextPrayerTimeIndex = 5;
      default:
        nextPrayerTime = LocaleKeys.prayerTimes_prayerTime.locale;
    }
    return nextPrayerTime ?? '';
  }

  /// We are using this value on the timer
  /// and converting to seconds
  int getRemainingTime() {
    final difference = remainingTime;
    final hours = difference?.inHours.remainder(24);
    final minutes = difference?.inMinutes.remainder(60);
    final seconds = difference?.inSeconds.remainder(60);

    /// Checking if the remaining time is 0 or negative
    /// if its 0 or negative we are calling the findRemainingTime function
    /// but i am not sure it is necessary
    if (remainingTime?.inMinutes == 0 || (remainingTime?.isNegative ?? true)) {
      findRemainingTime();
    }
    return (hours ?? 0) * 3600 + (minutes ?? 0) * 60 + (seconds ?? 0);
  }
}

/// All the functions for the timer and next prayer time
final findRemainingTimeProvider = StateNotifierProvider.family(
  (ref, List<List<String>> times) => FindRemainingTimeNotifier(
    times,
  ),
);
