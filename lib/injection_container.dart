import 'package:get_it/get_it.dart';
import 'core/services/bluetooth_hid_service.dart';
import 'core/services/preferences_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Remote Control
  // Services
  sl.registerLazySingleton(() => BluetoothHidService());
  
  // Preferences (needs async initialization)
  final prefsService = await PreferencesService.create();
  sl.registerSingleton<PreferencesService>(prefsService);
}
