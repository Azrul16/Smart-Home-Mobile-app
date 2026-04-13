import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../widgets/Ktext.dart';
import '../widgets/render_img.dart';
import '../widgets/status_toggle_switch.dart';

class DetailsPage extends StatelessWidget {
  DetailsPage({
    super.key,
    required this.deviceId,
  });

  final int deviceId;
  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<HomeController>(
        builder: (controller) {
          final device = controller.deviceById(deviceId);
          if (device == null) {
            return const Center(child: Text('Device not found'));
          }

          final isLight = device.kind == 'Light';
          const primaryColor = Color(0xFF4C7380);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: Get.back,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      const SizedBox(width: 4),
                      KText(text: device.room, color: Colors.black54),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  KText(
                                    text: device.name,
                                    color: Colors.white,
                                    fontSize: 26,
                                  ),
                                  const SizedBox(height: 8),
                                  KText(
                                    text: device.kind,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  const SizedBox(height: 18),
                                  StatusToggleSwitch(
                                    value: device.isOn,
                                    onChanged: (value) {
                                      controller.toggleDevice(device.id, value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            RenderImg(
                              path: device.imageAsset,
                              height: 96,
                              width: 96,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        KText(
                          text: isLight
                              ? 'Brightness ${device.intensity.round()}%'
                              : 'Target ${device.targetValue.round()}°C',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.white,
                            inactiveTrackColor:
                                Colors.white.withValues(alpha: 0.25),
                            thumbColor: const Color(0xFF9A7265),
                          ),
                          child: Slider(
                            min: isLight ? 0 : 16,
                            max: isLight ? 100 : 30,
                            value:
                                isLight ? device.intensity : device.targetValue,
                            onChanged: (value) {
                              if (isLight) {
                                controller.updateIntensity(device.id, value);
                              } else {
                                controller.updateTargetValue(device.id, value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _usageCard(
                        label: 'Today',
                        value: '${device.usageToday.toStringAsFixed(1)} kWh',
                      ),
                      const SizedBox(width: 12),
                      _usageCard(
                        label: 'Week',
                        value: '${device.usageWeek.toStringAsFixed(1)} kWh',
                      ),
                      const SizedBox(width: 12),
                      _usageCard(
                        label: 'Month',
                        value: '${device.usageMonth.toStringAsFixed(1)} kWh',
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      KText(text: 'Schedules', fontSize: 20),
                      KText(
                        text: '${device.schedules.length} total',
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(device.schedules.length, (index) {
                    final schedule = device.schedules[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8E4E8),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: SwitchListTile(
                        value: schedule.enabled,
                        activeThumbColor: primaryColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: KText(text: schedule.label, fontSize: 16),
                        subtitle: KText(
                          text:
                              '${schedule.days} - ${schedule.from} to ${schedule.to}',
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                        onChanged: (_) {
                          controller.toggleSchedule(device.id, index);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _usageCard({
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFD8E4E8),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KText(
              text: label,
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
            const SizedBox(height: 6),
            KText(text: value, fontSize: 16),
          ],
        ),
      ),
    );
  }
}
