enum HomeMode {
  home,
  away,
  night,
  eco,
}

class DeviceSchedule {
  const DeviceSchedule({
    required this.label,
    required this.days,
    required this.from,
    required this.to,
    this.enabled = true,
  });

  final String label;
  final String days;
  final String from;
  final String to;
  final bool enabled;

  DeviceSchedule copyWith({
    String? label,
    String? days,
    String? from,
    String? to,
    bool? enabled,
  }) {
    return DeviceSchedule(
      label: label ?? this.label,
      days: days ?? this.days,
      from: from ?? this.from,
      to: to ?? this.to,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'days': days,
      'from': from,
      'to': to,
      'enabled': enabled,
    };
  }

  factory DeviceSchedule.fromJson(Map<String, dynamic> json) {
    return DeviceSchedule(
      label: json['label'] as String,
      days: json['days'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}

class UsagePoint {
  const UsagePoint({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;
}

class SmartDevice {
  const SmartDevice({
    required this.id,
    required this.name,
    required this.room,
    required this.kind,
    required this.svgAsset,
    required this.imageAsset,
    required this.isOn,
    required this.intensity,
    required this.targetValue,
    required this.usageToday,
    required this.usageWeek,
    required this.usageMonth,
    required this.schedules,
    this.colorLabel,
  });

  final int id;
  final String name;
  final String room;
  final String kind;
  final String svgAsset;
  final String imageAsset;
  final bool isOn;
  final double intensity;
  final double targetValue;
  final double usageToday;
  final double usageWeek;
  final double usageMonth;
  final List<DeviceSchedule> schedules;
  final String? colorLabel;

  SmartDevice copyWith({
    int? id,
    String? name,
    String? room,
    String? kind,
    String? svgAsset,
    String? imageAsset,
    bool? isOn,
    double? intensity,
    double? targetValue,
    double? usageToday,
    double? usageWeek,
    double? usageMonth,
    List<DeviceSchedule>? schedules,
    String? colorLabel,
  }) {
    return SmartDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      room: room ?? this.room,
      kind: kind ?? this.kind,
      svgAsset: svgAsset ?? this.svgAsset,
      imageAsset: imageAsset ?? this.imageAsset,
      isOn: isOn ?? this.isOn,
      intensity: intensity ?? this.intensity,
      targetValue: targetValue ?? this.targetValue,
      usageToday: usageToday ?? this.usageToday,
      usageWeek: usageWeek ?? this.usageWeek,
      usageMonth: usageMonth ?? this.usageMonth,
      schedules: schedules ?? this.schedules,
      colorLabel: colorLabel ?? this.colorLabel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'room': room,
      'kind': kind,
      'svgAsset': svgAsset,
      'imageAsset': imageAsset,
      'isOn': isOn,
      'intensity': intensity,
      'targetValue': targetValue,
      'usageToday': usageToday,
      'usageWeek': usageWeek,
      'usageMonth': usageMonth,
      'schedules': schedules.map((schedule) => schedule.toJson()).toList(),
      'colorLabel': colorLabel,
    };
  }

  factory SmartDevice.fromJson(Map<String, dynamic> json) {
    return SmartDevice(
      id: json['id'] as int,
      name: json['name'] as String,
      room: json['room'] as String,
      kind: json['kind'] as String,
      svgAsset: json['svgAsset'] as String,
      imageAsset: json['imageAsset'] as String,
      isOn: json['isOn'] as bool,
      intensity: (json['intensity'] as num).toDouble(),
      targetValue: (json['targetValue'] as num).toDouble(),
      usageToday: (json['usageToday'] as num).toDouble(),
      usageWeek: (json['usageWeek'] as num).toDouble(),
      usageMonth: (json['usageMonth'] as num).toDouble(),
      schedules: (json['schedules'] as List<dynamic>)
          .map((item) => DeviceSchedule.fromJson(item as Map<String, dynamic>))
          .toList(),
      colorLabel: json['colorLabel'] as String?,
    );
  }
}

class RoomSummary {
  const RoomSummary({
    required this.name,
    required this.imageAsset,
    required this.deviceCount,
    required this.activeCount,
    required this.averageTargetValue,
  });

  final String name;
  final String imageAsset;
  final int deviceCount;
  final int activeCount;
  final double averageTargetValue;
}

class SmartAlert {
  const SmartAlert({
    required this.title,
    required this.message,
    required this.severity,
  });

  final String title;
  final String message;
  final String severity;
}
