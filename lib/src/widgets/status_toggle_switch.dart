import 'package:flutter/material.dart';

class StatusToggleSwitch extends StatelessWidget {
  const StatusToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.height = 26,
    this.indicatorSize = const Size(30, 20),
    this.activeColor = const Color(0xFF7A5B12),
    this.inactiveColor = Colors.teal,
    this.activeLabel = 'ON',
    this.inactiveLabel = 'OFF',
    this.activeIcon = Icons.coronavirus_rounded,
    this.inactiveIcon = Icons.tag_faces_rounded,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final double height;
  final Size indicatorSize;
  final Color activeColor;
  final Color inactiveColor;
  final String activeLabel;
  final String inactiveLabel;
  final IconData activeIcon;
  final IconData inactiveIcon;

  @override
  Widget build(BuildContext context) {
    final width = indicatorSize.width + 42;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: value ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(height),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, .5),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 10,
              right: 10,
              child: Text(
                value ? activeLabel : inactiveLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: indicatorSize.width,
                height: indicatorSize.height,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  value ? activeIcon : inactiveIcon,
                  size: indicatorSize.height * .75,
                  color: value ? activeColor : inactiveColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
