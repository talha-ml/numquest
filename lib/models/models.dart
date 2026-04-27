// ─── GameAttempt ─────────────────────────────────────────────────
class GameAttempt {
  final int? id;
  final String sessionId;
  final int attemptNo;
  final int guessed;
  final int target;
  final String result; // 'correct' | 'high' | 'low'
  final int timestampMs;

  const GameAttempt({
    this.id,
    required this.sessionId,
    required this.attemptNo,
    required this.guessed,
    required this.target,
    required this.result,
    required this.timestampMs,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'sessionId':   sessionId,
    'attemptNo':   attemptNo,
    'guessed':     guessed,
    'target':      target,
    'result':      result,
    'timestampMs': timestampMs,
  };

  factory GameAttempt.fromMap(Map<String, dynamic> m) => GameAttempt(
    id:          m['id'] as int?,
    sessionId:   m['sessionId'] as String,
    attemptNo:   m['attemptNo'] as int,
    guessed:     m['guessed'] as int,
    target:      m['target'] as int,
    result:      m['result'] as String,
    timestampMs: m['timestampMs'] as int,
  );

  DateTime get time => DateTime.fromMillisecondsSinceEpoch(timestampMs);
}

// ─── GameSession ─────────────────────────────────────────────────
class GameSession {
  final int? id;
  final String sessionId;
  final int target;
  final int totalAttempts;
  final bool won;
  final String difficulty;
  final int startMs;
  final int? endMs;
  final List<GameAttempt> attempts;

  const GameSession({
    this.id,
    required this.sessionId,
    required this.target,
    required this.totalAttempts,
    required this.won,
    required this.difficulty,
    required this.startMs,
    this.endMs,
    this.attempts = const [],
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'sessionId':     sessionId,
    'target':        target,
    'totalAttempts': totalAttempts,
    'won':           won ? 1 : 0,
    'difficulty':    difficulty,
    'startMs':       startMs,
    'endMs':         endMs,
  };

  factory GameSession.fromMap(Map<String, dynamic> m,
      {List<GameAttempt> attempts = const []}) =>
      GameSession(
        id:            m['id'] as int?,
        sessionId:     m['sessionId'] as String,
        target:        m['target'] as int,
        totalAttempts: m['totalAttempts'] as int,
        won:           (m['won'] as int) == 1,
        difficulty:    m['difficulty'] as String,
        startMs:       m['startMs'] as int,
        endMs:         m['endMs'] as int?,
        attempts:      attempts,
      );

  DateTime get startTime => DateTime.fromMillisecondsSinceEpoch(startMs);
}

// ─── AppStats ────────────────────────────────────────────────────
class AppStats {
  final int totalGames;
  final int wins;
  final int losses;
  final int bestAttempts;
  final double avgAttempts;
  final int currentStreak;
  final int bestStreak;

  const AppStats({
    required this.totalGames,
    required this.wins,
    required this.losses,
    required this.bestAttempts,
    required this.avgAttempts,
    required this.currentStreak,
    required this.bestStreak,
  });

  int get winRate =>
      totalGames == 0 ? 0 : (wins / totalGames * 100).round();

  String get bestStr => bestAttempts == 9999 ? '—' : '$bestAttempts';

  String get avgStr =>
      avgAttempts == 0 ? '—' : avgAttempts.toStringAsFixed(1);

  static const empty = AppStats(
    totalGames:    0,
    wins:          0,
    losses:        0,
    bestAttempts:  9999,
    avgAttempts:   0,
    currentStreak: 0,
    bestStreak:    0,
  );
}