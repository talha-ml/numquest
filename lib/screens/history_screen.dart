import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  List<GameSession> _sessions = [];
  AppStats _stats = AppStats.empty;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final s  = await DB.instance.getSessions();
    final st = await DB.instance.getStats();
    setState(() {
      _sessions = s;
      _stats    = st;
      _loading  = false;
    });
  }

  void _askClearAll() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: C.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Data?',
            style: TextStyle(color: C.txtPrimary, fontWeight: FontWeight.w800)),
        content: const Text(
            'This permanently deletes all game history and stats.',
            style: TextStyle(color: C.txtSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: C.violet, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () async {
              await DB.instance.clearAll();
              Navigator.pop(context);
              _load();
            },
            child: const Text('Delete All',
                style: TextStyle(color: C.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _tabBar(),
            Expanded(
              child: _loading
                  ? const Center(
                  child: CircularProgressIndicator(
                      color: C.violet, strokeWidth: 2.5))
                  : TabBarView(
                controller: _tab,
                children: [
                  _sessionsTab(),
                  _statsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      decoration: const BoxDecoration(
        color: C.surface,
        border: Border(bottom: BorderSide(color: C.cardBorder, width: 0.8)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: C.txtSecondary, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text('History',
                style: TextStyle(
                  color: C.txtPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                )),
          ),
          if (_sessions.isNotEmpty)
            GestureDetector(
              onTap: _askClearAll,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: C.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: C.red.withOpacity(0.3)),
                ),
                child: const Text('Clear',
                    style: TextStyle(
                        color: C.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      height: 42,
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.cardBorder, width: 0.8),
      ),
      child: TabBar(
        controller: _tab,
        indicator: BoxDecoration(
          gradient: C.violetGrad,
          borderRadius: BorderRadius.circular(10),
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: C.txtSecondary,
        padding: const EdgeInsets.all(4),
        labelStyle:
        const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        tabs: const [
          Tab(text: '🎮  Sessions'),
          Tab(text: '📊  Stats'),
        ],
      ),
    );
  }

  Widget _sessionsTab() {
    if (_sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('🎲', style: TextStyle(fontSize: 56)),
            SizedBox(height: 16),
            Text('No Games Yet',
                style: TextStyle(
                    color: C.txtPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('Play your first game to see history here.',
                style: TextStyle(color: C.txtSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: C.violet,
      backgroundColor: C.card,
      onRefresh: _load,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
        itemCount: _sessions.length,
        itemBuilder: (_, i) => _sessionCard(_sessions[i], i),
      ),
    );
  }

  Widget _sessionCard(GameSession s, int i) {
    final color = s.won ? C.green : C.red;
    final date  = DateFormat('MMM d, yyyy  h:mm a').format(s.startTime);

    return Dismissible(
      key: Key(s.sessionId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: C.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.red.withOpacity(0.3)),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        child: const Icon(Icons.delete_outline_rounded,
            color: C.red, size: 24),
      ),
      confirmDismiss: (_) async {
        bool confirm = false;
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: C.card,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18)),
            title: const Text('Delete Session?',
                style: TextStyle(
                    color: C.txtPrimary, fontWeight: FontWeight.w800)),
            actions: [
              TextButton(
                onPressed: () {
                  confirm = false;
                  Navigator.pop(context);
                },
                child: const Text('Cancel',
                    style: TextStyle(color: C.violet)),
              ),
              TextButton(
                onPressed: () {
                  confirm = true;
                  Navigator.pop(context);
                },
                child: const Text('Delete',
                    style: TextStyle(
                        color: C.red, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
        return confirm;
      },
      onDismissed: (_) async {
        await DB.instance.deleteSession(s.sessionId);
        _load();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.cardBorder, width: 0.8),
        ),
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            childrenPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 14),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Center(
                child: Text(s.won ? '🏆' : '💀',
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    s.won ? 'Victory' : 'Game Over',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: C.violet.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: C.violet.withOpacity(0.3)),
                  ),
                  child: Text(
                    s.difficulty,
                    style: const TextStyle(
                      fontSize: 10,
                      color: C.violet,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${s.totalAttempts} attempts',
                      style: const TextStyle(
                          fontSize: 12, color: C.txtSecondary),
                    ),
                    const Text('  ·  ',
                        style: TextStyle(color: C.txtDim)),
                    Text(
                      'Target: ${s.target}',
                      style: const TextStyle(
                          fontSize: 12, color: C.txtSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(date,
                    style:
                    const TextStyle(fontSize: 11, color: C.txtDim)),
              ],
            ),
            iconColor: C.txtSecondary,
            collapsedIconColor: C.txtDim,
            children: [
              const Divider(color: C.cardBorder, height: 1),
              const SizedBox(height: 12),
              s.attempts.isEmpty
                  ? const Text('No detailed records.',
                  style: TextStyle(color: C.txtDim, fontSize: 13))
                  : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: s.attempts
                    .map<Widget>((a) => GuessBubble(
                  number: a.guessed,
                  result: a.result,
                  no:     a.attemptNo,
                ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statsTab() {
    if (_stats.totalGames == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('📊', style: TextStyle(fontSize: 56)),
            SizedBox(height: 16),
            Text('No Stats Yet',
                style: TextStyle(
                    color: C.txtPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('Stats will appear after your first game.',
                style: TextStyle(color: C.txtSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Win Rate Card ──────────────────────────────────────
          NeonCard(
            glowColor: _stats.winRate >= 50 ? C.green : C.red,
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _stats.winRate / 100,
                        strokeWidth: 7,
                        backgroundColor: C.cardBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _stats.winRate >= 50 ? C.green : C.red,
                        ),
                      ),
                      Text(
                        '${_stats.winRate}%',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: _stats.winRate >= 50 ? C.green : C.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Overall Win Rate', style: TS.title),
                      const SizedBox(height: 4),
                      Text(
                        '${_stats.wins} wins · ${_stats.losses} losses',
                        style: const TextStyle(
                            color: C.txtSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Stat Tiles (IntrinsicHeight — no overflow ever) ────
          _statRow(
            _tile('${_stats.totalGames}', 'Total Games', '🎮', C.violet),
            _tile('${_stats.wins}',        'Wins',        '🏆', C.green),
          ),
          const SizedBox(height: 12),
          _statRow(
            _tile('${_stats.losses}', 'Losses',    '💀', C.red),
            _tile(_stats.bestStr,      'Best Game', '⚡', C.amber),
          ),
          const SizedBox(height: 12),
          _statRow(
            _tile(_stats.avgStr,                 'Avg Attempts', '📊', C.cyan),
            _tile('${_stats.currentStreak}',     'Win Streak',   '🔥', C.pink),
          ),

          const SizedBox(height: 14),

          // ── Performance Bars ───────────────────────────────────
          NeonCard(
            glowColor: C.violet,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Performance'),
                _bar('Wins',   _stats.wins,   _stats.totalGames, C.green),
                const SizedBox(height: 12),
                _bar('Losses', _stats.losses, _stats.totalGames, C.red),
                const SizedBox(height: 12),
                _bar('Best Streak', _stats.bestStreak,
                    _stats.totalGames.clamp(1, 999999), C.amber),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  /// Single StatTile wrapped in Expanded
  Widget _tile(String value, String label, String emoji, Color color) {
    return Expanded(
      child: StatTile(
        value: value,
        label: label,
        emoji: emoji,
        color: color,
      ),
    );
  }

  /// Row of 2 tiles — IntrinsicHeight lets each card grow to fit content
  Widget _statRow(Widget left, Widget right) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          left,
          const SizedBox(width: 12),
          right,
        ],
      ),
    );
  }

  Widget _bar(String label, int val, int max, Color color) {
    final ratio = max == 0 ? 0.0 : (val / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    color: C.txtSecondary,
                    fontWeight: FontWeight.w500)),
            Text('$val',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: C.cardBorder,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}