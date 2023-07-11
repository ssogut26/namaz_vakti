import 'package:easy_localization/easy_localization.dart';

extension Localization on String {
  String get locale => this.tr();
  String localeWithValue(String argument) {
    return this.tr(args: [argument]);
  }
}

extension CheckNull on String? {
  bool get isEmptyOrNull => this == null || (this?.isEmpty ?? true);
  bool get isNotEmptyOrNull => this != null && (this?.isNotEmpty ?? false);
}
