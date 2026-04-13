import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../models/smart_home_models.dart';
import '../widgets/Ktext.dart';
import '../widgets/grap.dart';
import '../widgets/hex_color.dart';

class PowerUser extends StatelessWidget {
  PowerUser({super.key});

  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<HomeController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final sortedDevices = [...controller.devices]
            ..sort((a, b) => b.usageWeek.compareTo(a.usageWeek));

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 44, 16, 20),
                decoration: BoxDecoration(
                  color: HexColor('#4C7380'),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KText(
                      text: 'Energy Center',
                      color: Colors.white,
                      fontSize: 24,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _summaryCard(
                          label: 'Today',
                          value:
                              '${controller.totalUsageToday.toStringAsFixed(1)} kWh',
                        ),
                        const SizedBox(width: 12),
                        _summaryCard(
                          label: 'This Week',
                          value:
                              '${controller.totalUsageWeek.toStringAsFixed(1)} kWh',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 220,
                      child: UsageLineChart(points: controller.weeklyUsage),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8E4E8),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KText(text: 'Monthly Goal', fontSize: 18),
                          const SizedBox(height: 6),
                          KText(
                            text:
                                '${controller.totalUsageMonth.toStringAsFixed(1)} / ${controller.monthlyEnergyGoal.toStringAsFixed(0)} kWh',
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: controller.monthlyGoalProgress.clamp(0, 1),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(20),
                            backgroundColor: Colors.white,
                            color: controller.monthlyGoalProgress > 1
                                ? Colors.redAccent
                                : const Color(0xFF4C7380),
                          ),
                          Slider(
                            min: 100,
                            max: 350,
                            divisions: 25,
                            value: controller.monthlyEnergyGoal,
                            onChanged: controller.setMonthlyEnergyGoal,
                          ),
                          KText(
                            text:
                                'Estimated savings opportunity: ${controller.potentialMonthlySavings.toStringAsFixed(1)} kWh/month',
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8EFD6),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KText(text: 'Recommended Action', fontSize: 18),
                          const SizedBox(height: 6),
                          KText(
                            text: controller.alerts.first.message,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                          const SizedBox(height: 10),
                          FilledButton(
                            onPressed: () => controller.applyMode(HomeMode.eco),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF4C7380),
                            ),
                            child: const Text('Apply Eco Mode'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...sortedDevices.map((device) {
                      final trend = device.isOn ? '+8.4%' : '-4.1%';
                      final trendColor = device.isOn
                          ? Colors.green.shade700
                          : HexColor('#A78980');
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: HexColor('#D8E4E8'),
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
                                color: HexColor('#4C7380'),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  KText(text: device.name, fontSize: 16),
                                  KText(
                                    text:
                                        '${device.room} • ${device.schedules.length} schedule${device.schedules.length == 1 ? '' : 's'}',
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(height: 4),
                                  KText(
                                    text:
                                        'Today ${device.usageToday.toStringAsFixed(1)} kWh • Month ${device.usageMonth.toStringAsFixed(1)} kWh',
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                KText(
                                  text:
                                      '${device.usageWeek.toStringAsFixed(1)} kWh',
                                  color: HexColor('#4C7380'),
                                ),
                                KText(
                                  text: trend,
                                  color: trendColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ],
                            ),
                          ],
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
    );
  }

  Widget _summaryCard({
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
              fontSize: 18,
            ),
          ],
        ),
      ),
    );
  }
}
