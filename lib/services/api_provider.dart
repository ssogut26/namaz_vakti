import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_vakti/services/api.dart';

final apiProvider = Provider((ref) => ApiService.instance);
