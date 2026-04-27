import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/models.dart';

class DB {
  DB._();
  static final DB instance = DB._();
  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'numquest_v2.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE attempts (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            sessionId   TEXT    NOT NULL,
            attemptNo   INTEGER NOT NULL,
            guessed     INTEGER NOT NULL,
            target      INTEGER NOT NULL,
            result      TEXT    NOT NULL,
            timestampMs INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE sessions (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            sessionId    TEXT    UNIQUE NOT NULL,
            target       INTEGER NOT NULL,
            totalAttempts INTEGER NOT NULL,
            won          INTEGER NOT NULL DEFAULT 0,
            difficulty   TEXT    NOT NULL,
            startMs      INTEGER NOT NULL,
            endMs        INTEGER
          )
        ''');
      },
    );
  }

  // ── Write ──────────────────────────────────────────────────────

  Future<void> insertAttempt(GameAttempt a) async {
    final db = await database;
    await db.insert('attempts', a.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> upsertSession(GameSession s) async {
    final db = await database;
    await db.insert('sessions', s.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ── Read ───────────────────────────────────────────────────────

  Future<List<GameSession>> getSessions() async {
    final db = await database;
    final rows =
    await db.query('sessions', orderBy: 'startMs DESC');
    final List<GameSession> result = [];
    for (final row in rows) {
      final attempts = await db.query(
        'attempts',
        where: 'sessionId = ?',
        whereArgs: [row['sessionId']],
        orderBy: 'attemptNo ASC',
      );
      result.add(GameSession.fromMap(row,
          attempts: attempts.map(GameAttempt.fromMap).toList()));
    }
    return result;
  }

  Future<AppStats> getStats() async {
    final db = await database;

    final total = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM sessions')) ??
        0;
    final wins = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM sessions WHERE won=1')) ??
        0;
    final losses = total - wins;

    final bestRow = await db.rawQuery(
        'SELECT MIN(totalAttempts) AS b FROM sessions WHERE won=1');
    final best = (bestRow.first['b'] as int?) ?? 9999;

    final avgRow = await db.rawQuery(
        'SELECT AVG(totalAttempts) AS a FROM sessions WHERE won=1');
    final avg =
    avgRow.first['a'] != null ? (avgRow.first['a'] as num).toDouble() : 0.0;

    // streak — count consecutive wins from latest
    final allRows = await db.query('sessions',
        columns: ['won'], orderBy: 'startMs DESC');
    int streak = 0;
    for (final r in allRows) {
      if ((r['won'] as int) == 1) {
        streak++;
      } else {
        break;
      }
    }

    // best streak
    int bestStreak = 0, cur = 0;
    for (final r in allRows.reversed.toList()) {
      if ((r['won'] as int) == 1) {
        cur++;
        if (cur > bestStreak) bestStreak = cur;
      } else {
        cur = 0;
      }
    }

    return AppStats(
      totalGames: total,
      wins: wins,
      losses: losses,
      bestAttempts: best,
      avgAttempts: avg,
      currentStreak: streak,
      bestStreak: bestStreak,
    );
  }

  // ── Delete ─────────────────────────────────────────────────────

  Future<void> deleteSession(String sessionId) async {
    final db = await database;
    await db.delete('sessions',
        where: 'sessionId = ?', whereArgs: [sessionId]);
    await db.delete('attempts',
        where: 'sessionId = ?', whereArgs: [sessionId]);
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('attempts');
    await db.delete('sessions');
  }
}