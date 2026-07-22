import 'package:flutter/material.dart';
import '../models/theme.dart';

class AquariumController extends ChangeNotifier {
  void Function(Offset position, double amplitude, double maxRadius)? _onAddRipple;
  void Function(Offset? position)? _onDropFood;
  void Function(int count)? _onSetFishCount;
  void Function(AquariumThemePreset preset)? _onSetTheme;
  void Function(bool enabled)? _onToggleCaustics;
  void Function(bool visible)? _onToggleControls;
  void Function()? _onStartLoading;
  void Function()? _onStopLoading;

  void attach({
    required void Function(Offset position, double amplitude, double maxRadius) onAddRipple,
    required void Function(Offset? position) onDropFood,
    required void Function(int count) onSetFishCount,
    required void Function(AquariumThemePreset preset) onSetTheme,
    required void Function(bool enabled) onToggleCaustics,
    required void Function(bool visible) onToggleControls,
    required void Function() onStartLoading,
    required void Function() onStopLoading,
  }) {
    _onAddRipple = onAddRipple;
    _onDropFood = onDropFood;
    _onSetFishCount = onSetFishCount;
    _onSetTheme = onSetTheme;
    _onToggleCaustics = onToggleCaustics;
    _onToggleControls = onToggleControls;
    _onStartLoading = onStartLoading;
    _onStopLoading = onStopLoading;
  }

  void detach() {
    _onAddRipple = null;
    _onDropFood = null;
    _onSetFishCount = null;
    _onSetTheme = null;
    _onToggleCaustics = null;
    _onToggleControls = null;
    _onStartLoading = null;
    _onStopLoading = null;
  }

  /// Trigger a water ripple wavefront at [position].
  void addRipple(Offset position, {double amplitude = 1.0, double maxRadius = 160.0}) {
    _onAddRipple?.call(position, amplitude, maxRadius);
  }

  /// Drop a food pellet at [position] (or random location if omitted).
  void dropFood([Offset? position]) {
    _onDropFood?.call(position);
  }

  /// Update the live fish population count.
  void setFishCount(int count) {
    _onSetFishCount?.call(count);
  }

  /// Change the aquatic water theme preset.
  void setTheme(AquariumThemePreset preset) {
    _onSetTheme?.call(preset);
  }

  /// Toggle water caustics light network.
  void toggleCaustics([bool? enabled]) {
    _onToggleCaustics?.call(enabled ?? true);
  }

  /// Toggle floating controls overlay visibility.
  void toggleControls([bool? visible]) {
    _onToggleControls?.call(visible ?? true);
  }

  /// Puts the aquarium into loading mode, attracting all fish to circle around the center.
  void startLoading() {
    _onStartLoading?.call();
  }

  /// Restores normal free-swimming behavior for all fish.
  void stopLoading() {
    _onStopLoading?.call();
  }
}
