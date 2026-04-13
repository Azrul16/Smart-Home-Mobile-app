import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../models/smart_home_models.dart';
import '../widgets/Ktext.dart';
import '../widgets/render_img.dart';
import '../widgets/status_toggle_switch.dart';
import 'details_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GetBuilder<HomeController>(
          builder: (controller) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final activeDevices = controller.activeDevices.take(3).toList();
            final roomSummaries = controller.roomSummaries;
            final alerts = controller.alerts.take(3).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4C7380),
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
                                    text: 'Smart Home',
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  KText(
                                    text: controller.modeLabel,
                                    color: Colors.white,
                                    fontSize: 28,
                                  ),
                                  const SizedBox(height: 4),
                                  KText(
                                    text: controller.modeDescription,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.home_work_outlined,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                KText(
                                  text:
                                      controller.isSomeoneHome ? 'Occupied' : 'Empty',
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: HomeMode.values
                              .map((mode) => _modeChip(controller, mode))
                              .toList(),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            _headlineMetric(
                              label: 'Active',
                              value: '${controller.activeDevices.length}',
                            ),
                            const SizedBox(width: 12),
                            _headlineMetric(
                              label: 'Today',
                              value:
                                  '${controller.totalUsageToday.toStringAsFixed(1)} kWh',
                            ),
                            const SizedBox(width: 12),
                            _headlineMetric(
                              label: 'Saved',
                              value:
                                  '${controller.potentialMonthlySavings.toStringAsFixed(0)} kWh',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      KText(text: 'Alerts', fontSize: 20),
                      Switch(
                        value: controller.isSomeoneHome,
                        onChanged: controller.setPresence,
                        activeThumbColor: const Color(0xFF4C7380),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...alerts.map(
                    (alert) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _alertBackground(alert.severity),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KText(text: alert.title, fontSize: 16),
                          const SizedBox(height: 4),
                          KText(
                            text: alert.message,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      KText(text: 'Rooms', fontSize: 20),
                      KText(
                        text: '${roomSummaries.length} total',
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: roomSummaries.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (context, index) {
                      final room = roomSummaries[index];
                      return InkWell(
                        onTap: () {
                          controller.selectRoom(room.name);
                          controller.updateNavIndex(1);
                        },
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD8E4E8),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4C7380),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: KText(
                                    text:
                                        '${room.averageTargetValue.toStringAsFixed(0)}°',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: RenderImg(
                                    path: room.imageAsset,
                                    height: 76,
                                    width: 76,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              KText(text: room.name, fontSize: 18),
                              const SizedBox(height: 4),
                              KText(
                                text:
                                    '${room.activeCount}/${room.deviceCount} active devices',
                                fontWeight: FontWeight.w400,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      KText(text: 'Quick Control', fontSize: 20),
                      KText(
                        text: 'Tap for details',
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...activeDevices.map(
                    (device) => InkWell(
                      onTap: () {
                        Get.to(() => DetailsPage(deviceId: device.id));
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9A7265),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            RenderImg(
                              path: device.imageAsset,
                              height: 62,
                              width: 62,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  KText(
                                    text: device.name,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  KText(
                                    text: device.room,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  const SizedBox(height: 6),
                                  KText(
                                    text: device.kind == 'AC'
                                        ? 'Target ${device.targetValue.round()}°C'
                                        : 'Brightness ${device.intensity.round()}%',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ],
                              ),
                            ),
                            StatusToggleSwitch(
                              value: device.isOn,
                              height: 24,
                              indicatorSize: const Size(28, 18),
                              onChanged: (value) {
                                controller.toggleDevice(device.id, value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _modeChip(HomeController controller, HomeMode mode) {
    final selected = controller.currentMode == mode;
    return ChoiceChip(
      label: Text(_modeName(mode)),
      selected: selected,
      onSelected: (_) => controller.applyMode(mode),
      selectedColor: Colors.white,
      backgroundColor: Colors.white.withValues(alpha: 0.14),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF4C7380) : Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _modeName(HomeMode mode) {
    switch (mode) {
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

  Color _alertBackground(String severity) {
    switch (severity) {
      case 'high':
        return const Color(0xFFFBE4E2);
      case 'medium':
        return const Color(0xFFF8EFD6);
      default:
        return const Color(0xFFD8E4E8);
    }
  }

  Widget _headlineMetric({
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KText(
              text: label,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
            const SizedBox(height: 6),
            KText(
              text: value,
              color: Colors.white,
              fontSize: 16,
            ),
          ],
        ),
      ),
    );
  }
}
