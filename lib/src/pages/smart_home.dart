import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../widgets/Ktext.dart';
import '../widgets/status_toggle_switch.dart';
import 'details_page.dart';

class SmartHome extends StatelessWidget {
  SmartHome({super.key});

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

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4C7380),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (controller.selectedRoom != 'All')
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: controller.clearRoomFilter,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.14),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          Expanded(
                            child: KText(
                              text: 'Devices & Automations',
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      KText(
                        text:
                            '${controller.activeDevices.length} active - ${controller.selectedRoom} view',
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final room = controller.rooms[index];
                            final selected = room == controller.selectedRoom;
                            return ChoiceChip(
                              label: Text(room),
                              selected: selected,
                              onSelected: (_) => controller.selectRoom(room),
                              selectedColor: Colors.white,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.18),
                              labelStyle: TextStyle(
                                color: selected
                                    ? const Color(0xFF4C7380)
                                    : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemCount: controller.rooms.length,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD8E4E8),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              color: Color(0xFF4C7380),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: KText(
                                text:
                                    'Tip: ${controller.alerts.first.message}',
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...controller.filteredDevices.map((device) {
                        final subtitle =
                            '${device.room} - ${device.schedules.length} schedule${device.schedules.length == 1 ? '' : 's'}';
                        final reading = device.kind == 'AC'
                            ? 'Target ${device.targetValue.round()} deg C'
                            : 'Brightness ${device.intensity.round()}%';
                        return InkWell(
                          onTap: () {
                            Get.to(() => DetailsPage(deviceId: device.id));
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD8E4E8),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    device.kind == 'AC'
                                        ? Icons.ac_unit_rounded
                                        : device.kind == 'TV'
                                            ? Icons.tv_rounded
                                            : Icons.lightbulb_rounded,
                                    color: const Color(0xFF4C7380),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      KText(text: device.name, fontSize: 16),
                                      KText(
                                        text: subtitle,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(height: 6),
                                      KText(
                                        text: reading,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black87,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    StatusToggleSwitch(
                                      value: device.isOn,
                                      height: 24,
                                      indicatorSize: const Size(26, 18),
                                      onChanged: (value) {
                                        controller.toggleDevice(device.id, value);
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    KText(
                                      text:
                                          '${device.usageToday.toStringAsFixed(1)} kWh',
                                      color: const Color(0xFF4C7380),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
