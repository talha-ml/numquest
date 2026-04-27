import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../utils/game_ctrl.dart';
import '../widgets/widgets.dart';
import 'game_screen.dart';
import 'history_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final AnimationController _floatCtrl;
  late final Animation<double> _scaleBounce;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  final _rng = Random();
  late final List<_Dot> _dots;

  @override
  void initState() {
    super.initState();
    final won = context.read<GameCtrl>().phase == Phase.won;

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();

    _scaleBounce = Tween<double>(begin: 0.4, end: 1).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut),
    );
    _fadeIn = CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.4, 1, curve: Curves.easeOut));
    _slideUp = Tween<Offset>(
        begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.4, 1, curve: Curves.easeOut)));

    _entryCtrl.forward();
    _dots = List.generate(won ? 24 : 0, (_) => _Dot(_rng));

    if (won) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameCtrl>(
      builder: (context, game, _) {
        final won = game.phase == Phase.won;
        final mainColor = won ? C.green : C.red;
        final grad = won ? C.greenGrad : C.redGrad;

        return Scaffold(
          body: Stack(
            children: [
              // Floating dots (win only)
              if (won)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _floatCtrl,
                    builder: (_, __) => CustomPaint(
                      painter: _DotPainter(_dots, _floatCtrl.value),
                    ),
                  ),
                ),

              // Radial glow bg
              Positioned(
                top: -60,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        mainColor.withOpacity(0.12),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    children: [
                      const SizedBox(height: 36),
                      // Trophy / skull
                      ScaleTransition(
                        scale: _scaleBounce,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: grad,
                            boxShadow: [
                              BoxShadow(
                                  color: mainColor.withOpacity(0.45),
                                  blurRadius: 40,
                                  spreadRadius: 6)
                            ],
                          ),
                          child: Center(
                            child: Text(
                              won ? '🏆' : '💀',
                              style: const TextStyle(fontSize: 60),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Title + sub
                      FadeTransition(
                        opacity: _fadeIn,
                        child: SlideTransition(
                          position: _slideUp,
                          child: Column(
                            children: [
                              Text(
                                won ? 'You Nailed It!' : 'Better Luck\nNext Time',
                                style: TS.title.copyWith(
                                  fontSize: 30,
                                  color: mainColor,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                won
                                    ? 'The number was ${game.target} — found in ${game.attempts} guesses!'
                                    : 'The number was ${game.target}.\nYou used all ${game.attempts} attempts.',
                                style: TS.body,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Stats row
                      FadeTransition(
                        opacity: _fadeIn,
                        child: SlideTransition(
                          position: _slideUp,
                          child: Row(
                            children: [
                              Expanded(
                                child: StatTile(
                                  value: '${game.attempts}',
                                  label: 'Guesses',
                                  emoji: '🎯',
                                  color: mainColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (won) ...[
                                Expanded(
                                  child: StatTile(
                                    value: game.grade,
                                    label: 'Grade',
                                    emoji: '📊',
                                    color: C.amber,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: StatTile(
                                    value: '${game.score}',
                                    label: 'Score',
                                    emoji: '⚡',
                                    color: C.cyan,
                                  ),
                                ),
                              ] else ...[
                                Expanded(
                                  child: StatTile(
                                    value: '${game.target}',
                                    label: 'Answer',
                                    emoji: '🔢',
                                    color: C.violet,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: StatTile(
                                    value: '${game.stats.winRate}%',
                                    label: 'Win Rate',
                                    emoji: '📈',
                                    color: C.amber,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      // Guess timeline
                      if (game.history.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        FadeTransition(
                          opacity: _fadeIn,
                          child: NeonCard(
                            glowColor: mainColor,
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('GUESS TRAIL',
                                    style: TS.label),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 40,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: game.history.length,
                                    separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                    itemBuilder: (_, i) {
                                      final a = game.history[i];
                                      return GuessBubble(
                                        number: a.guessed,
                                        result: a.result,
                                        no: a.attemptNo,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Buttons
                      FadeTransition(
                        opacity: _fadeIn,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GradBtn(
                              label: 'Play Again',
                              icon: '🔄',
                              gradient: game.diff.gradient,
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                game.newGame();
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, a, __) =>
                                    const GameScreen(),
                                    transitionsBuilder: (_, anim, __, child) =>
                                        FadeTransition(
                                            opacity: anim, child: child),
                                    transitionDuration:
                                    const Duration(milliseconds: 300),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: GhostBtn(
                                    label: '🏠  Menu',
                                    color: C.txtSecondary,
                                    onTap: () {
                                      game.backToMenu();
                                      Navigator.popUntil(
                                          context, (r) => r.isFirst);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GhostBtn(
                                    label: '📜  History',
                                    color: C.violet,
                                    onTap: () {
                                      game.backToMenu();
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                            const HistoryScreen()),
                                            (r) => r.isFirst,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Dot Particle ─────────────────────────────────────────────────
class _Dot {
  final double x;
  final double speed;
  final double size;
  final Color color;
  final double offset;

  _Dot(Random rng)
      : x = rng.nextDouble(),
        speed = 0.2 + rng.nextDouble() * 0.6,
        size = 3 + rng.nextDouble() * 6,
        color = [C.green, C.cyan, C.violet, C.amber, C.pink][
        rng.nextInt(5)],
        offset = rng.nextDouble();
}

class _DotPainter extends CustomPainter {
  final List<_Dot> dots;
  final double t;
  _DotPainter(this.dots, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final d in dots) {
      final p = ((t * d.speed + d.offset) % 1.0);
      final y = size.height * (1 - p);
      final x = d.x * size.width;
      final opacity = p < 0.1 ? p * 10 : p > 0.85 ? (1 - p) / 0.15 : 1.0;
      canvas.drawCircle(
        Offset(x, y),
        d.size,
        Paint()..color = d.color.withOpacity(opacity.clamp(0, 1) * 0.65),
      );
    }
  }

  @override
  bool shouldRepaint(_DotPainter old) => old.t != t;
}