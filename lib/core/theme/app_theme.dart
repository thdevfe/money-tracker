import 'package:flutter/material.dart';

/// Spacing scale (4-point grid).
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
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
    income: Color(0xFF159957),
    expense: Color(0xFFE5484D),
    transfer: Color(0xFF3984D6),
    border: Color(0xFFE3E8E5),
    textSecondary: Color(0xFF667085),
    elevatedSurface: Color(0xFFF0F3F1),
  );

  static const dark = AppColors(
    income: Color(0xFF4ADE9A),
    expense: Color(0xFFFF7278),
    transfer: Color(0xFF75B5FF),
    border: Color(0xFF303D36),
    textSecondary: Color(0xFFA8B5AE),
    elevatedSurface: Color(0xFF202B26),
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
      primary: Color(0xFF16A36A),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDDF4E8),
      onPrimaryContainer: Color(0xFF128354),
      secondary: Color(0xFF128354),
      onSecondary: Colors.white,
      error: Color(0xFFE5484D),
      onError: Colors.white,
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF17212B),
      onSurfaceVariant: Color(0xFF667085),
      surfaceContainerLowest: Color(0xFFF6F8F7),
      surfaceContainerHighest: Color(0xFFEFF2F0),
      outline: Color(0xFFE3E8E5),
      outlineVariant: Color(0xFFE3E8E5),
    );
    return _build(
      scheme,
      background: const Color(0xFFF6F8F7),
      colors: AppColors.light,
    );
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF4ADE9A),
      onPrimary: Color(0xFF0B2A1C),
      primaryContainer: Color(0xFF1C3D2E),
      onPrimaryContainer: Color(0xFF4ADE9A),
      secondary: Color(0xFF4ADE9A),
      onSecondary: Color(0xFF0B2A1C),
      error: Color(0xFFFF7278),
      onError: Color(0xFF2B0A0B),
      surface: Color(0xFF19211E),
      onSurface: Color(0xFFF3F7F4),
      onSurfaceVariant: Color(0xFFA8B5AE),
      surfaceContainerLowest: Color(0xFF101614),
      surfaceContainerHighest: Color(0xFF202B26),
      outline: Color(0xFF303D36),
      outlineVariant: Color(0xFF303D36),
    );
    return _build(
      scheme,
      background: const Color(0xFF101614),
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
