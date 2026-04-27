import 'package:flutter/material.dart';

// ─── Color Palette ───────────────────────────────────────────────
class C {
  C._();
  static const bg         = Color(0xFF0D0D14);
  static const surface    = Color(0xFF16161F);
  static const card       = Color(0xFF1E1E2A);
  static const cardBorder = Color(0xFF2A2A3A);

  static const violet     = Color(0xFF7C6BFF);
  static const violetDim  = Color(0xFF4A3FBF);
  static const pink       = Color(0xFFFF6B9D);
  static const cyan       = Color(0xFF00D4FF);
  static const green      = Color(0xFF00E676);
  static const amber      = Color(0xFFFFBF00);
  static const red        = Color(0xFFFF4757);

  static const txtPrimary   = Color(0xFFF0F0FF);
  static const txtSecondary = Color(0xFF8080A0);
  static const txtDim       = Color(0xFF404058);

  static const LinearGradient violetGrad = LinearGradient(
    colors: [Color(0xFF7C6BFF), Color(0xFFBB86FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient greenGrad = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF1DE9B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient redGrad = LinearGradient(
    colors: [Color(0xFFFF4757), Color(0xFFFF6B9D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient amberGrad = LinearGradient(
    colors: [Color(0xFFFFBF00), Color(0xFFFF6B00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient cyanGrad = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF7C6BFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─── Difficulty Model ─────────────────────────────────────────────
class Difficulty {
  final String id;
  final String label;
  final String emoji;
  final int min;
  final int max;
  final int lives;
  final Color color;
  final LinearGradient gradient;

  const Difficulty({
    required this.id,
    required this.label,
    required this.emoji,
    required this.min,
    required this.max,
    required this.lives,
    required this.color,
    required this.gradient,
  });

  static const rookie = Difficulty(
    id: 'rookie',
    label: 'Rookie',
    emoji: '🌱',
    min: 1, max: 50, lives: 10,
    color: C.green,
    gradient: C.greenGrad,
  );
  static const hunter = Difficulty(
    id: 'hunter',
    label: 'Hunter',
    emoji: '🎯',
    min: 1, max: 100, lives: 7,
    color: C.violet,
    gradient: C.violetGrad,
  );
  static const legend = Difficulty(
    id: 'legend',
    label: 'Legend',
    emoji: '🔥',
    min: 1, max: 999, lives: 5,
    color: C.red,
    gradient: C.redGrad,
  );

  static const all = [rookie, hunter, legend];
}

// ─── Theme ────────────────────────────────────────────────────────
final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: C.bg,
  colorScheme: const ColorScheme.dark(
    primary: C.violet,
    surface: C.surface,
    error: C.red,
  ),
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    foregroundColor: C.txtPrimary,
    titleTextStyle: TextStyle(
      color: C.txtPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
  ),
);

// ─── Text Styles ──────────────────────────────────────────────────
class TS {
  TS._();
  static const heading = TextStyle(
    fontSize: 36, fontWeight: FontWeight.w900,
    color: C.txtPrimary, letterSpacing: -1.0, height: 1.1,
  );
  static const title = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w800,
    color: C.txtPrimary, letterSpacing: -0.5,
  );
  static const body = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: C.txtSecondary,
  );
  static const label = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w700,
    color: C.txtSecondary, letterSpacing: 1.4,
  );
  static const mono = TextStyle(
    fontSize: 42, fontWeight: FontWeight.w900,
    color: C.txtPrimary, letterSpacing: -2.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}