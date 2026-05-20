import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF14B8A6);
  static const Color accent = Color(0xFFFFB020);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  static const Color bg = Color(0xFFF6F8FC);
  static const Color bgDark = Color(0xFF0F172A);
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF172033);
  static const Color surfaceAlt = Color(0xFFF1F4F9);
  static const Color surfaceAltDark = Color(0xFF212B40);
  static const Color ink = Color(0xFF111827);
  static const Color inkDark = Color(0xFFF8FAFC);
  static const Color muted = Color(0xFF6B7280);
  static const Color mutedDark = Color(0xFFCBD5E1);
  static const Color lightText = Color(0xFF9CA3AF);
  static const Color stroke = Color(0xFFE5E7EB);
  static const Color strokeDark = Color(0xFF27344A);

  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8FAFF), Color(0xFFF2F6FD), Color(0xFFEFF3FA)],
  );

  static const LinearGradient darkPageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F172A), Color(0xFF111C31), Color(0xFF0B1120)],
  );

  static List<BoxShadow> get softShadow => [
        BoxShadow(color: const Color(0xFF1F2937).withOpacity(.11), blurRadius: 28, offset: const Offset(0, 14)),
      ];

  static List<BoxShadow> get smallShadow => [
        BoxShadow(color: const Color(0xFF1F2937).withOpacity(.055), blurRadius: 18, offset: const Offset(0, 8)),
      ];

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bgColor = isDark ? bgDark : bg;
    final surfaceColor = isDark ? surfaceDark : surface;
    final surfaceAltColor = isDark ? surfaceAltDark : surfaceAlt;
    final inkColor = isDark ? inkDark : ink;
    final mutedColor = isDark ? mutedDark : muted;
    final strokeColor = isDark ? strokeDark : stroke;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        secondary: secondary,
        surface: surfaceColor,
        error: danger,
      ),
    );
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(bodyColor: inkColor, displayColor: inkColor);

    return base.copyWith(
      scaffoldBackgroundColor: bgColor,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: inkColor,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 16,
        iconTheme: IconThemeData(color: inkColor),
        actionsIconTheme: IconThemeData(color: inkColor),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: inkColor, fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: -.3),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceColor,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: strokeColor)),
      ),
      dividerTheme: DividerThemeData(color: strokeColor, thickness: 1, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primary.withOpacity(isDark ? .22 : .12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 11.5,
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
              color: states.contains(WidgetState.selected) ? primary : mutedColor,
            )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(size: 22, color: states.contains(WidgetState.selected) ? primary : mutedColor)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        labelStyle: TextStyle(color: mutedColor, fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: isDark ? mutedDark : lightText, fontWeight: FontWeight.w500),
        prefixIconColor: mutedColor,
        suffixIconColor: mutedColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: strokeColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: strokeColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: danger, width: 1.3)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: danger, width: 1.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, disabledBackgroundColor: primary.withOpacity(.35), elevation: 0, minimumSize: const Size(48, 52), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15))),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, elevation: 0, minimumSize: const Size(48, 52), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: primary, backgroundColor: surfaceColor, side: BorderSide(color: strokeColor), minimumSize: const Size(48, 52), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15))),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: const TextStyle(fontWeight: FontWeight.w800))),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)))),
      chipTheme: ChipThemeData(backgroundColor: surfaceColor, selectedColor: primary.withOpacity(.14), disabledColor: surfaceAltColor, labelStyle: TextStyle(color: inkColor, fontWeight: FontWeight.w700), secondaryLabelStyle: const TextStyle(color: primary, fontWeight: FontWeight.w800), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: strokeColor))),
      popupMenuTheme: PopupMenuThemeData(color: surfaceColor, surfaceTintColor: Colors.transparent, elevation: 8, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), textStyle: TextStyle(color: inkColor, fontWeight: FontWeight.w600)),
      dialogTheme: DialogThemeData(backgroundColor: surfaceColor, surfaceTintColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)), titleTextStyle: textTheme.titleLarge?.copyWith(color: inkColor, fontWeight: FontWeight.w900), contentTextStyle: textTheme.bodyMedium?.copyWith(color: mutedColor, height: 1.35)),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: surfaceColor, surfaceTintColor: Colors.transparent, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28)))),
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, backgroundColor: isDark ? inkDark : ink, contentTextStyle: TextStyle(color: isDark ? ink : Colors.white, fontWeight: FontWeight.w700), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      listTileTheme: ListTileThemeData(iconColor: mutedColor, textColor: inkColor, titleTextStyle: TextStyle(color: inkColor, fontSize: 15, fontWeight: FontWeight.w800), subtitleTextStyle: TextStyle(color: mutedColor, fontSize: 13, fontWeight: FontWeight.w500)),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? primary : Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? primary.withOpacity(.35) : strokeColor),
      ),
    );
  }

  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
  static Color pageBg(BuildContext context) => isDark(context) ? bgDark : bg;
  static Color card(BuildContext context) => isDark(context) ? surfaceDark : surface;
  static Color alt(BuildContext context) => isDark(context) ? surfaceAltDark : surfaceAlt;
  static Color text(BuildContext context) => isDark(context) ? inkDark : ink;
  static Color subtext(BuildContext context) => isDark(context) ? mutedDark : muted;
  static Color line(BuildContext context) => isDark(context) ? strokeDark : stroke;
  static Gradient pageGradientOf(BuildContext context) => isDark(context) ? darkPageGradient : pageGradient;
}
