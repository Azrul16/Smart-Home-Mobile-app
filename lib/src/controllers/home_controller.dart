import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/smart_home_models.dart';
import 'smart_home_data.dart';

class HomeController extends GetxController {
  static const _devicesKey = 'smart_home_devices';
  static const _navIndexKey = 'smart_home_nav_index';
  static const _roomKey = 'smart_home_selected_room';
  static const _modeKey = 'smart_home_mode';
  static const _energyGoalKey = 'smart_home_energy_goal';
  static const _presenceKey = 'smart_home_presence';

  int currentNavIndex = 0;
  String selectedRoom = 'All';
  HomeMode currentMode = HomeMode.home;
  bool isSomeoneHome = true;
  bool isLoading = true;
  double monthlyEnergyGoal = 180;
  final List<int> _navHistory = [0];

  List<SmartDevice> _devices = List.of(seedDevices);
  SharedPreferences? _prefs;
  late final Map<int, SmartDevice> _defaultDevicesById = {
    for (final device in seedDevices) device.id: device,
  };

  @override
  void onInit() {
    super.onInit();
    _restoreState();
  }

  List<SmartDevice> get devices => List.unmodifiable(_devices);

  List<String> get rooms => [
        'All',
        ...{
          for (final device in _devices) device.room,
        }
      ];

  List<SmartDevice> get filteredDevices {
    if (selectedRoom == 'All') {
      return devices;
    }
    return _devices.where((device) => device.room == selectedRoom).toList();
  }

  List<SmartDevice> get activeDevices =>
      _devices.where((device) => device.isOn).toList();

  SmartDevice? deviceById(int id) {
    for (final device in _devices) {
      if (device.id == id) {
        return device;
      }
    }
    return null;
  }

  List<RoomSummary> get roomSummaries {
    final Map<String, List<SmartDevice>> grouped = {};
    for (final device in _devices) {
      grouped.putIfAbsent(device.room, () => []).add(device);
    }

    final roomImages = <String, String>{
      'Living Room': 'living-room.png',
      'Dining Room': 'bedroom.png',
      'Bedroom': 'bedroom.png',
      'Kitchen': 'bedroom.png',
    };

    return grouped.entries.map((entry) {
      final roomDevices = entry.value;
      final average = roomDevices
              .map((device) => device.targetValue)
              .fold<double>(0, (sum, value) => sum + value) /
          roomDevices.length;
      return RoomSummary(
        name: entry.key,
        imageAsset: roomImages[entry.key] ?? 'living-room.png',
        deviceCount: roomDevices.length,
        activeCount: roomDevices.where((device) => device.isOn).length,
        averageTargetValue: average,
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<UsagePoint> get weeklyUsage {
    final total = totalUsageWeek <= 0 ? 1.0 : totalUsageWeek;
    final weights = <double>[0.12, 0.15, 0.11, 0.16, 0.17, 0.16, 0.13];
    return List.generate(weeklyUsageSeed.length, (index) {
      final value = total * weights[index];
      return UsagePoint(
        label: weeklyUsageSeed[index].label,
        value: double.parse(value.toStringAsFixed(1)),
      );
    });
  }

  double get totalUsageToday =>
      _devices.fold(0, (sum, device) => sum + device.usageToday);
  double get totalUsageWeek =>
      _devices.fold(0, (sum, device) => sum + device.usageWeek);
  double get totalUsageMonth =>
      _devices.fold(0, (sum, device) => sum + device.usageMonth);

  double get monthlyGoalProgress {
    if (monthlyEnergyGoal <= 0) return 0;
    return (totalUsageMonth / monthlyEnergyGoal).clamp(0, 1.4);
  }

  double get potentialMonthlySavings {
    final standbyDevices = _devices.where((device) => !device.isOn).length;
    return double.parse((standbyDevices * 2.8).toStringAsFixed(1));
  }

  double get estimatedMonthlyBill {
    return double.parse((totalUsageMonth * 0.18).toStringAsFixed(2));
  }

  int get activeScheduledDevices =>
      _devices.where((device) => _hasActiveScheduleNow(device)).length;

  List<SmartAlert> get alerts {
    final items = <SmartAlert>[];
    final scheduleMismatch = _devices
        .where((device) => _hasActiveScheduleNow(device) && !device.isOn)
        .toList();
    final alwaysOn = _devices
        .where((device) => device.isOn && device.schedules.every((s) => !s.enabled))
        .toList();

    if (scheduleMismatch.isNotEmpty) {
      items.add(
        SmartAlert(
          title: 'Scheduled device is currently off',
          message:
              '${scheduleMismatch.first.name} should be active based on its schedule right now.',
          severity: 'high',
        ),
      );
    }

    if (!isSomeoneHome && activeDevices.isNotEmpty) {
      items.add(
        SmartAlert(
          title: 'Away mode can reduce standby usage',
          message:
              '${activeDevices.length} devices are still on while the home is marked empty.',
          severity: 'high',
        ),
      );
    }

    if (totalUsageMonth > monthlyEnergyGoal) {
      items.add(
        SmartAlert(
          title: 'Monthly energy goal exceeded',
          message:
              'You are ${(totalUsageMonth - monthlyEnergyGoal).toStringAsFixed(1)} kWh over your target.',
          severity: 'medium',
        ),
      );
    }

    if (alwaysOn.isNotEmpty) {
      items.add(
        SmartAlert(
          title: 'Devices without active schedules',
          message:
              '${alwaysOn.first.name}${alwaysOn.length > 1 ? ' and ${alwaysOn.length - 1} more' : ''} are running manually only.',
          severity: 'low',
        ),
      );
    }

    if (items.isEmpty) {
      items.add(
        const SmartAlert(
          title: 'System looks healthy',
          message: 'No urgent automation or energy issues right now.',
          severity: 'low',
        ),
      );
    }

    return items;
  }

  String get modeLabel {
    switch (currentMode) {
      case HomeMode.home:
        return 'Home';
      case HomeMode.away:
        return 'Away';
      case HomeMode.night:
        return 'Night';
      case HomeMode.eco:
        return 'Eco';
    }
  }

  String get modeDescription {
    switch (currentMode) {
      case HomeMode.home:
        return 'Comfort settings for occupied rooms.';
      case HomeMode.away:
        return 'Turns down nonessential devices while the house is empty.';
      case HomeMode.night:
        return 'Keeps only low-light and sleep-friendly devices active.';
      case HomeMode.eco:
        return 'Reduces power draw to help stay under the energy goal.';
    }
  }

  Future<void> _restoreState() async {
    _prefs = await SharedPreferences.getInstance();
    currentNavIndex = (_prefs?.getInt(_navIndexKey) ?? 0).clamp(0, 2);
    selectedRoom = _prefs?.getString(_roomKey) ?? 'All';
    monthlyEnergyGoal = _prefs?.getDouble(_energyGoalKey) ?? 180;
    isSomeoneHome = _prefs?.getBool(_presenceKey) ?? true;

    final modeName = _prefs?.getString(_modeKey);
    currentMode = HomeMode.values.firstWhere(
      (mode) => mode.name == modeName,
      orElse: () => HomeMode.home,
    );

    final stored = _prefs?.getString(_devicesKey);
    if (stored != null && stored.isNotEmpty) {
      final decoded = jsonDecode(stored) as List<dynamic>;
      _devices = decoded
          .map((item) => SmartDevice.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    isLoading = false;
    update();
  }

  Future<void> _persistState() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setInt(_navIndexKey, currentNavIndex);
    await prefs.setString(_roomKey, selectedRoom);
    await prefs.setString(_modeKey, currentMode.name);
    await prefs.setDouble(_energyGoalKey, monthlyEnergyGoal);
    await prefs.setBool(_presenceKey, isSomeoneHome);
    await prefs.setString(
      _devicesKey,
      jsonEncode(_devices.map((device) => device.toJson()).toList()),
    );
  }

  void updateNavIndex(int index) {
    if (index == currentNavIndex) {
      return;
    }
    _navHistory.remove(index);
    _navHistory.add(currentNavIndex);
    currentNavIndex = index;
    _persistState();
    update();
  }

  void selectRoom(String room) {
    selectedRoom = rooms.contains(room) ? room : 'All';
    _persistState();
    update();
  }

  void setPresence(bool value) {
    isSomeoneHome = value;
    if (!value && currentMode == HomeMode.home) {
      currentMode = HomeMode.away;
    } else if (value && currentMode == HomeMode.away) {
      currentMode = HomeMode.home;
    }
    _persistState();
    update();
  }

  void setMonthlyEnergyGoal(double value) {
    monthlyEnergyGoal = value;
    _persistState();
    update();
  }

  void clearRoomFilter() {
    if (selectedRoom == 'All') return;
    selectedRoom = 'All';
    _persistState();
    update();
  }

  bool handleShellBack() {
    if (currentNavIndex == 1 && selectedRoom != 'All') {
      clearRoomFilter();
      return false;
    }

    if (_navHistory.isNotEmpty && currentNavIndex != 0) {
      final previous = _navHistory.removeLast();
      currentNavIndex = previous.clamp(0, 2);
      _persistState();
      update();
      return false;
    }

    if (currentNavIndex != 0) {
      currentNavIndex = 0;
      _persistState();
      update();
      return false;
    }

    return true;
  }

  void applyMode(HomeMode mode) {
    currentMode = mode;
    switch (mode) {
      case HomeMode.home:
        isSomeoneHome = true;
        _devices = _devices
            .map(
              (device) {
                final baseline = _defaultDevicesById[device.id] ?? device;
                return device.copyWith(
                  isOn: baseline.isOn,
                  intensity: baseline.intensity,
                  targetValue: baseline.targetValue,
                );
              },
            )
            .toList();
        break;
      case HomeMode.away:
        isSomeoneHome = false;
        _devices = _devices
            .map(
              (device) => device.copyWith(
                isOn: false,
                intensity: device.kind == 'Light' ? 0 : device.intensity,
              ),
            )
            .toList();
        break;
      case HomeMode.night:
        isSomeoneHome = true;
        _devices = _devices
            .map(
              (device) => device.copyWith(
                isOn: device.room == 'Bedroom' || device.name.contains('Lamp'),
                intensity: device.kind == 'Light' ? 35 : device.intensity,
                targetValue: device.kind == 'AC' ? 23 : device.targetValue,
              ),
            )
            .toList();
        break;
      case HomeMode.eco:
        isSomeoneHome = true;
        _devices = _devices
            .map(
              (device) => device.copyWith(
                isOn: device.kind == 'TV' ? false : device.isOn,
                intensity: device.kind == 'Light' ? 45 : device.intensity,
                targetValue: device.kind == 'AC' ? 25 : device.targetValue,
              ),
            )
            .toList();
        break;
    }
    _persistState();
    update();
  }

  void toggleDevice(int id, bool value) {
    final index = _devices.indexWhere((device) => device.id == id);
    if (index == -1) return;

    final device = _devices[index];
    _devices[index] = device.copyWith(
      isOn: value,
      usageToday: _nextUsage(device.usageToday, value ? 0.2 : -0.1),
      usageWeek: _nextUsage(device.usageWeek, value ? 0.6 : -0.2),
      usageMonth: _nextUsage(device.usageMonth, value ? 1.4 : -0.5),
    );
    _persistState();
    update();
  }

  void updateIntensity(int id, double value) {
    final index = _devices.indexWhere((device) => device.id == id);
    if (index == -1) return;

    final device = _devices[index];
    _devices[index] = device.copyWith(
      isOn: value > 0 ? true : device.isOn,
      intensity: value,
      usageToday: _nextUsage(device.usageToday, value / 1000),
      usageWeek: _nextUsage(device.usageWeek, value / 500),
      usageMonth: _nextUsage(device.usageMonth, value / 220),
    );
    _persistState();
    update();
  }

  void updateTargetValue(int id, double value) {
    final index = _devices.indexWhere((device) => device.id == id);
    if (index == -1) return;

    final device = _devices[index];
    _devices[index] = device.copyWith(
      isOn: true,
      targetValue: value,
      usageToday: _nextUsage(device.usageToday, 0.1),
      usageWeek: _nextUsage(device.usageWeek, 0.3),
      usageMonth: _nextUsage(device.usageMonth, 0.9),
    );
    _persistState();
    update();
  }

  void toggleSchedule(int id, int scheduleIndex) {
    final index = _devices.indexWhere((device) => device.id == id);
    if (index == -1) return;

    final device = _devices[index];
    if (scheduleIndex < 0 || scheduleIndex >= device.schedules.length) return;

    final schedules = [...device.schedules];
    final schedule = schedules[scheduleIndex];
    schedules[scheduleIndex] = schedule.copyWith(enabled: !schedule.enabled);
    _devices[index] = device.copyWith(schedules: schedules);
    _persistState();
    update();
  }

  double _nextUsage(double current, double delta) {
    final value = current + delta;
    return double.parse((value < 0 ? 0 : value).toStringAsFixed(1));
  }

  bool _hasActiveScheduleNow(SmartDevice device) {
    final now = DateTime.now();
    for (final schedule in device.schedules) {
      if (!schedule.enabled) continue;
      if (!_scheduleMatchesDay(schedule.days, now)) continue;
      final minutes = now.hour * 60 + now.minute;
      final from = _parseMinutes(schedule.from);
      final to = _parseMinutes(schedule.to);
      if (from == null || to == null) continue;
      if (from <= to) {
        if (minutes >= from && minutes <= to) return true;
      } else {
        if (minutes >= from || minutes <= to) return true;
      }
    }
    return false;
  }

  bool _scheduleMatchesDay(String days, DateTime now) {
    final lower = days.toLowerCase();
    if (lower.contains('daily')) return true;
    const names = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return lower.contains(names[now.weekday - 1]);
  }

  int? _parseMinutes(String value) {
    final parts = value.trim().split(' ');
    if (parts.length != 2) return null;
    final timeParts = parts[0].split(':');
    if (timeParts.length != 2) return null;
    var hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || minute == null) return null;
    final meridiem = parts[1].toLowerCase();
    if (meridiem == 'pm' && hour != 12) hour += 12;
    if (meridiem == 'am' && hour == 12) hour = 0;
    return hour * 60 + minute;
  }
}
