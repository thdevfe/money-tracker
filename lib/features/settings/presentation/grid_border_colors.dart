import 'package:flutter/material.dart';

import '../domain/calendar_grid_settings.dart';

/// Border colors for calendar tiles, keyed for storage. "Auto" (no key)
/// uses the theme's accent.
const gridBorderColorChoices = <String, Color>{
  'red': Color(0xFFFF5F57),
  'orange': Color(0xFFFF9F3A),
  'yellow': Color(0xFFFFCC4D),
  'green': Color(0xFF4CD964),
  'cyan': Color(0xFF3FD8F5),
  'blue': Color(0xFF5B9BD5),
  'indigo': Color(0xFF6E6CF0),
  'purple': Color(0xFFB067DA),
  'pink': Color(0xFFFF6B9D),
  'white': Color(0xFFFFFFFF),
  'gray': Color(0xFF9E9E9E),
};

Color resolveGridBorderColor(
  CalendarGridSettings settings,
  ColorScheme scheme,
) => gridBorderColorChoices[settings.borderColorKey] ?? scheme.primary;
