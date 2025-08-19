import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../models/settings.dart';

final settingsRepositoryProvider = StateNotifierProvider<SettingsRepository, Settings>((ref) {
  return SettingsRepository();
});

class SettingsRepository extends StateNotifier<Settings> {
  late Box<Settings> _box;
  bool _initialized = false;

  SettingsRepository() : super(Settings(lastBackup: DateTime.now())) {
    _initBox();
  }

  Future<void> _initBox() async {
    try {
      // Register adapter if not already registered
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(SettingsAdapter());
      }
      
      _box = await Hive.openBox<Settings>('settings');
      final settings = _box.get('settings');
      if (settings != null) {
        state = settings;
      } else {
        // Create default settings
        final defaultSettings = Settings(lastBackup: DateTime.now());
        _box.put('settings', defaultSettings);
        state = defaultSettings;
      }
      _initialized = true;
    } catch (e) {
      print('Error al inicializar SettingsRepository: $e');
      _initialized = false;
    }
  }

  Settings getSettings() {
    if (!_initialized) return Settings(lastBackup: DateTime.now());
    return state;
  }

  void updateSettings(Settings settings) {
    if (!_initialized) return;
    try {
      _box.put('settings', settings);
      state = settings;
    } catch (e) {
      print('Error al actualizar configuraciones: $e');
    }
  }
}