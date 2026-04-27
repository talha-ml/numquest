import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../db/database_helper.dart';
import 'theme.dart'; // ✅ FIXED: was '../utils/theme.dart' (same folder)

enum Phase { menu, playing, won, lost }

class GameCtrl extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────
  Phase phase = Phase.menu;
  Difficulty diff = Difficulty.hunter;
  int target = 0;
  int livesLeft = 0;
  int attempts = 0;
  String sessionId = '';
  DateTime sessionStart = DateTime.now();
  List<GameAttempt> history = [];
  AppStats stats = AppStats.empty;

  // After each guess
  int? lastGuess;
  String? lastResult; // 'correct' | 'high' | 'low'

  // Range tracking for smart hint
  int rangeMin = 1;
  int rangeMax = 100;

  final _rng = Random();

  // ── Public API ─────────────────────────────────────────────────

  void selectDifficulty(Difficulty d) {
    diff = d;
    notifyListeners();
  }

  void newGame() {
    target       = _rng.nextInt(diff.max - diff.min + 1) + diff.min;
    livesLeft    = diff.lives;
    attempts     = 0;
    sessionId    = '${DateTime.now().millisecondsSinceEpoch}';
    sessionStart = DateTime.now();
    history      = [];
    lastGuess    = null;
    lastResult   = null;
    rangeMin     = diff.min;
    rangeMax     = diff.max;
    phase        = Phase.playing;
    notifyListeners();
  }

  Future<String> guess(int number) async {
    assert(phase == Phase.playing);
    attempts++;
    livesLeft--;
    lastGuess = number;

    String result;
    if (number == target) {
      result = 'correct';
    } else if (number > target) {
      result = 'high';
      if (number < rangeMax) rangeMax = number - 1;
    } else {
      result = 'low';
      if (number > rangeMin) rangeMin = number + 1;
    }
    lastResult = result;

    final attempt = GameAttempt(
      sessionId:   sessionId,
      attemptNo:   attempts,
      guessed:     number,
      target:      target,
      result:      result,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
    );
    history.add(attempt);
    await DB.instance.insertAttempt(attempt);

    if (result == 'correct') {
      phase = Phase.won;
      await _endSession(won: true);
    } else if (livesLeft <= 0) {
      phase = Phase.lost;
      await _endSession(won: false);
    }

    notifyListeners();
    return result;
  }

  Future<void> giveUp() async {
    if (phase != Phase.playing) return;
    phase = Phase.lost;
    await _endSession(won: false);
    notifyListeners();
  }

  void backToMenu() {
    phase = Phase.menu;
    notifyListeners();
  }

  Future<void> loadStats() async {
    stats = await DB.instance.getStats();
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────

  Future<void> _endSession({required bool won}) async {
    final session = GameSession(
      sessionId:     sessionId,
      target:        target,
      totalAttempts: attempts,
      won:           won,
      difficulty:    diff.label,
      startMs:       sessionStart.millisecondsSinceEpoch,
      endMs:         DateTime.now().millisecondsSinceEpoch,
    );
    await DB.instance.upsertSession(session);
    await loadStats();
  }

  // ── Derived ────────────────────────────────────────────────────

  double get livesRatio =>
      diff.lives == 0 ? 0 : livesLeft / diff.lives;

  String get smartRange => '$rangeMin – $rangeMax';

  String get hintText {
    if (lastResult == null) return 'Enter your first guess below';
    if (lastResult == 'high') return 'Too High! Try lower 📉';
    if (lastResult == 'low')  return 'Too Low! Try higher 📈';
    return 'Perfect! 🎯';
  }

  int get score {
    if (phase != Phase.won) return 0;
    final base    = diff.max * 10;
    final bonus   = (livesLeft + 1) * 50;
    final penalty = attempts * 20;
    return (base + bonus - penalty).clamp(100, 999999);
  }

  String get grade {
    final r = attempts / diff.lives;
    if (r <= 0.3) return 'S';
    if (r <= 0.5) return 'A';
    if (r <= 0.7) return 'B';
    if (r <= 0.9) return 'C';
    return 'D';
  }
}