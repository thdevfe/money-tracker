import 'package:flutter/material.dart';

/// Spacing scale (4-point grid).
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  /// Bottom padding for tab content so it clears the floating nav bar.
  static const double navClearance = 128;
}

class AppRadii {
  static const double card = 16;
  static const double input = 14;
  static const double thumbnail = 6;
  static const double listThumbnail = 10;
}

/// Semantic colors that [ColorScheme] has no slot for.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color income;
  final Color expense;
  final Color transfer;
  final Color border;
  final Color textSecondary;
  final Color elevatedSurface;

  const AppColors({
    required this.income,
    required this.expense,
    required this.transfer,
    required this.border,
    required this.textSecondary,
    required this.elevatedSurface,
  });

  static const light = AppColors(
    income: Color(0xFF1F9D5C),
    expense: Color(0xFFE5484D),
    transfer: Color(0xFF8B5CF6),
    border: Color(0xFFE4E6EB),
    textSecondary: Color(0xFF6B7080),
    elevatedSurface: Color(0xFFEFF1F5),
  );

  static const dark = AppColors(
    income: Color(0xFF5BD68E),
    expense: Color(0xFFFF7A7F),
    transfer: Color(0xFFB59CFF),
    border: Color(0xFF2E3038),
    textSecondary: Color(0xFF9EA2AE),
    elevatedSurface: Color(0xFF22232A),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? income,
    Color? expense,
    Color? transfer,
    Color? border,
    Color? textSecondary,
    Color? elevatedSurface,
  }) {
    return AppColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      transfer: transfer ?? this.transfer,
      border: border ?? this.border,
      textSecondary: textSecondary ?? this.textSecondary,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      transfer: Color.lerp(transfer, other.transfer, t)!,
      border: Color.lerp(border, other.border, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
    );
  }
}

class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF3D7BF0),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE3ECFF),
      onPrimaryContainer: Color(0xFF1F5BD0),
      secondary: Color(0xFF1F5BD0),
      onSecondary: Colors.white,
      error: Color(0xFFE5484D),
      onError: Colors.white,
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF181A20),
      onSurfaceVariant: Color(0xFF6B7080),
      surfaceContainerLowest: Color(0xFFF5F6F9),
      surfaceContainerHighest: Color(0xFFEFF1F5),
      outline: Color(0xFFE4E6EB),
      outlineVariant: Color(0xFFE4E6EB),
    );
    return _build(
      scheme,
      background: const Color(0xFFF5F6F9),
      colors: AppColors.light,
    );
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF7FA8F8),
      onPrimary: Color(0xFF0C1A33),
      primaryContainer: Color(0xFF243352),
      onPrimaryContainer: Color(0xFFA9C6FF),
      secondary: Color(0xFF7FA8F8),
      onSecondary: Color(0xFF0C1A33),
      error: Color(0xFFFF7A7F),
      onError: Color(0xFF2B0A0B),
      surface: Color(0xFF1B1C22),
      onSurface: Color(0xFFF2F3F7),
      onSurfaceVariant: Color(0xFF9EA2AE),
      surfaceContainerLowest: Color(0xFF131418),
      surfaceContainerHighest: Color(0xFF22232A),
      outline: Color(0xFF2E3038),
      outlineVariant: Color(0xFF2E3038),
    );
    return _build(
      scheme,
      background: const Color(0xFF131418),
      colors: AppColors.dark,
    );
  }

  static ThemeData _build(
    ColorScheme scheme, {
    required Color background,
    required AppColors colors,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      extensions: [colors],
    );
    final inputRadius = BorderRadius.circular(AppRadii.input);
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: colors.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.border, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(44, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.input),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 44),
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.input),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(color: colors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
        selectedColor: scheme.primaryContainer,
        backgroundColor: scheme.surface,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurface,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          side: BorderSide(color: colors.border),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
