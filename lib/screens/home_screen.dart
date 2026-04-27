import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../utils/game_ctrl.dart';
import '../widgets/widgets.dart';
import 'game_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _introCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeIn  = CurvedAnimation(parent: _introCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
        begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _introCtrl, curve: Curves.easeOut));
    _introCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback(
            (_) => context.read<GameCtrl>().loadStats());
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    super.dispose();
  }

  void _start() {
    HapticFeedback.mediumImpact();
    context.read<GameCtrl>().newGame();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const GameScreen(),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
              begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _openHistory() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const HistoryScreen(),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
              begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameCtrl>(
        builder: (context, ctrl, _) => SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 16),
                        _topBar(),
                        const SizedBox(height: 36),
                        _heroSection(),
                        const SizedBox(height: 36),
                        _statsRow(ctrl),
                        const SizedBox(height: 32),
                        const SectionLabel('Choose Difficulty'),
                        _diffPicker(ctrl),
                        const SizedBox(height: 28),
                        GradBtn(
                          label: 'Start Game',
                          icon: '🚀',
                          gradient: ctrl.diff.gradient,
                          onTap: _start,
                        ),
                        const SizedBox(height: 14),
                        GhostBtn(
                          label: '📜  View History',
                          onTap: _openHistory,
                          color: C.violet,
                        ),
                        const SizedBox(height: 40),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: C.violet.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: C.violet.withOpacity(0.3)),
          ),
          child: const Text(
            'NumQuest',
            style: TextStyle(
              color: C.violet,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ),
        GestureDetector(
          onTap: _openHistory,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.cardBorder),
            ),
            child: const Icon(Icons.history_rounded,
                color: C.txtSecondary, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _heroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: C.violetGrad,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: C.violet.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2)
                ],
              ),
              child: const Center(
                  child: Text('🔢', style: TextStyle(fontSize: 28))),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Guess the\nNumber.', style: TS.heading),
        const SizedBox(height: 10),
        const Text(
          'Pick a difficulty, use your logic,\nand crack the secret number.',
          style: TS.body,
        ),
      ],
    );
  }

  Widget _statsRow(GameCtrl ctrl) {
    final s = ctrl.stats;
    return Row(
      children: [
        Expanded(
          child: StatTile(
            value: '${s.totalGames}',
            label: 'Played',
            emoji: '🎮',
            color: C.violet,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatTile(
            value: '${s.winRate}%',
            label: 'Win Rate',
            emoji: '🏆',
            color: C.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatTile(
            value: s.bestStr,
            label: 'Best',
            emoji: '⚡',
            color: C.amber,
          ),
        ),
      ],
    );
  }

  Widget _diffPicker(GameCtrl ctrl) {
    return Column(
      children: Difficulty.all.map((d) {
        final selected = ctrl.diff.id == d.id;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            ctrl.selectDifficulty(d);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: selected ? d.color.withOpacity(0.1) : C.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? d.color.withOpacity(0.5)
                    : C.cardBorder,
                width: selected ? 1.5 : 0.8,
              ),
              boxShadow: selected
                  ? [
                BoxShadow(
                    color: d.color.withOpacity(0.12),
                    blurRadius: 16)
              ]
                  : null,
            ),
            child: Row(
              children: [
                Text(d.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: selected ? d.color : C.txtPrimary,
                        ),
                      ),
                      Text(
                        '1 – ${d.max}  ·  ${d.lives} lives',
                        style: const TextStyle(
                          fontSize: 12,
                          color: C.txtSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? d.color : C.txtDim,
                      width: selected ? 0 : 2,
                    ),
                    color: selected ? d.color : Colors.transparent,
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14)
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}