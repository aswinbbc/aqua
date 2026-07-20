import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/theme.dart';

class ControlsOverlay extends StatelessWidget {
  final int fishCount;
  final int activeRipplesCount;
  final int activeFoodCount;
  final AquariumThemePreset currentPreset;
  final bool enableCaustics;
  final bool isControlsVisible;
  final ValueChanged<int> onFishCountChanged;
  final VoidCallback onDropFood;
  final ValueChanged<AquariumThemePreset> onThemeChanged;
  final ValueChanged<bool> onToggleCaustics;
  final VoidCallback onResetAquarium;
  final VoidCallback onToggleControlsVisibility;

  const ControlsOverlay({
    super.key,
    required this.fishCount,
    required this.activeRipplesCount,
    required this.activeFoodCount,
    required this.currentPreset,
    required this.enableCaustics,
    required this.isControlsVisible,
    required this.onFishCountChanged,
    required this.onDropFood,
    required this.onThemeChanged,
    required this.onToggleCaustics,
    required this.onResetAquarium,
    required this.onToggleControlsVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Full Controls Panel (Animated Opacity & IgnorePointer)
          IgnorePointer(
            ignoring: !isControlsVisible,
            child: AnimatedOpacity(
              opacity: isControlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  children: [
                    // Top Header Bar
                    _buildTopBar(context),
                    const Spacer(),
                    // Bottom Glass Floating Toolbar
                    _buildBottomControlPanel(context),
                  ],
                ),
              ),
            ),
          ),

          // Floating Show-Controls Toggle Pill (Visible ONLY when controls are hidden)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            top: 16.0,
            right: isControlsVisible ? -80.0 : 16.0,
            child: AnimatedOpacity(
              opacity: isControlsVisible ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: _buildShowControlsButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowControlsButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggleControlsVisibility,
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tune, color: Colors.cyanAccent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Show Controls',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.water_drop, color: Colors.cyanAccent, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'AQUA SIMULATOR',
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Touch water to create wave ripples',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Status Pill Indicators & Hide Controls Button
              Row(
                children: [
                  _buildPill(Icons.phishing, '$fishCount Fish'),
                  const SizedBox(width: 6),
                  _buildPill(Icons.waves, '$activeRipplesCount Waves'),
                  const SizedBox(width: 10),
                  // Hide Controls Button
                  IconButton(
                    onPressed: onToggleControlsVisibility,
                    tooltip: 'Hide Controls',
                    icon: const Icon(Icons.visibility_off, color: Colors.white70, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      padding: const EdgeInsets.all(6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControlPanel(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(28.0),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Quick Action Buttons (Feed, Add Fish, Remove Fish, Reset)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.set_meal,
                    label: 'Feed Fish',
                    color: Colors.amberAccent,
                    onTap: onDropFood,
                  ),
                  _buildActionButton(
                    icon: Icons.remove,
                    label: 'Less Fish',
                    color: Colors.redAccent,
                    onTap: () {
                      if (fishCount > 1) onFishCountChanged(fishCount - 1);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.add,
                    label: 'More Fish',
                    color: Colors.greenAccent,
                    onTap: () {
                      if (fishCount < 25) onFishCountChanged(fishCount + 1);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.refresh,
                    label: 'Reset',
                    color: Colors.lightBlueAccent,
                    onTap: onResetAquarium,
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 12),

              // Row 2: Theme Preset Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: AquariumThemePreset.values.map((preset) {
                    final themeData = AquariumThemeData.getPreset(preset);
                    final isSelected = preset == currentPreset;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        showCheckmark: false,
                        label: Text(
                          themeData.name,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        avatar: CircleAvatar(
                          backgroundColor: themeData.shallowWaterColor,
                          radius: 8,
                        ),
                        selectedColor: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        side: BorderSide(
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
                        ),
                        onSelected: (_) => onThemeChanged(preset),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
