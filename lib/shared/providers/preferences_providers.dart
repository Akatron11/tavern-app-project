import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// main() içinde gerçek instance ile override edilir.
/// (SharedPreferences.getInstance() async olduğu için uygulama başlarken
/// yüklenip override edilir; böylece tercihler senkron okunabilir.)
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError(
    'sharedPreferencesProvider main() içinde override edilmelidir',
  ),
);
