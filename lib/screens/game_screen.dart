import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../utils/game_ctrl.dart';
import '../widgets/widgets.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  final _ctrl  = TextEditingController();
  final _focus = FocusNode();
  bool _loading = false;

  // Shake animation
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  // Hint pulse
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10),  weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -6),  weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6),   weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0),    weight: 1),
    ]).animate(_shakeCtrl);

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _pulseAnim = Tween<double>(begin: 1, end: 1.06)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _shakeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _shake() {
    HapticFeedback.mediumImpact();
    _shakeCtrl.forward(from: 0);
  }

  void _pulse() {
    _pulseCtrl.forward(from: 0).then((_) => _pulseCtrl.reverse());
  }

  Future<void> _submit() async {
    if (_loading) return;
    final game = context.read<GameCtrl>();
    final text = _ctrl.text.trim();

    if (text.isEmpty) { _shake(); _snack('Enter a number first!', C.amber); return; }
    final n = int.tryParse(text);
    if (n == null) { _shake(); _snack('Numbers only!', C.red); return; }
    if (n < game.diff.min || n > game.diff.max) {
      _shake();
      _snack('Must be ${game.diff.min}–${game.diff.max}', C.amber);
      return;
    }

    setState(() => _loading = true);
    HapticFeedback.lightImpact();
    final result = await game.guess(n);
    _ctrl.clear();
    setState(() => _loading = false);

    if (!mounted) return;

    if (result == 'correct' || game.phase == Phase.lost) {
      _focus.unfocus();
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) => const ResultScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1)
                  .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      _pulse();
      HapticFeedback.selectionClick();
      _focus.requestFocus();
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(msg,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        backgroundColor: color.withOpacity(0.92),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ));
  }

  void _confirmQuit() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: C.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Give Up?',
            style: TextStyle(color: C.txtPrimary, fontWeight: FontWeight.w800)),
        content: const Text(
            'You\'ll lose this round. The number was hidden!\nStill want to quit?',
            style: TextStyle(color: C.txtSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Playing',
                style: TextStyle(color: C.violet, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<GameCtrl>().giveUp();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ResultScreen()),
                );
              }
            },
            child: const Text('Give Up',
                style: TextStyle(color: C.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameCtrl>(
      builder: (context, game, _) {
        final d = game.diff;
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(game, d),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        _buildRangeDisplay(game, d),
                        const SizedBox(height: 20),
                        _buildHintCard(game, d),
                        const SizedBox(height: 24),
                        _buildInputSection(game, d),
                        const SizedBox(height: 20),
                        if (game.history.isNotEmpty) ...[
                          const SectionLabel('Your Guesses'),
                          _buildGuessList(game),
                          const SizedBox(height: 16),
                        ],
                        GhostBtn(
                          label: '🏳️  Give Up',
                          color: C.red,
                          onTap: _confirmQuit,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(GameCtrl game, Difficulty d) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      decoration: BoxDecoration(
        color: C.surface,
        border: const Border(bottom: BorderSide(color: C.cardBorder, width: 0.8)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _confirmQuit,
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: C.txtSecondary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(d.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      '${d.label}  ·  1–${d.max}',
                      style: const TextStyle(
                          color: C.txtPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LivesRow(
                  total:     d.lives,
                  remaining: game.livesLeft,
                  color:     d.color,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: d.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: d.color.withOpacity(0.3)),
            ),
            child: Text(
              '#${game.attempts + 1}',
              style: TextStyle(
                color: d.color,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeDisplay(GameCtrl game, Difficulty d) {
    return ScaleTransition(
      scale: _pulseAnim,
      child: NeonCard(
        glowColor: d.color,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '💡 Smart Range',
                  style: TextStyle(
                    color: C.txtSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                game.smartRange,
                key: ValueKey(game.smartRange),
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: d.color,
                  letterSpacing: -1,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${game.livesLeft} lives left  ·  ${game.attempts} guess${game.attempts != 1 ? 'es' : ''}',
              style: const TextStyle(fontSize: 12, color: C.txtSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintCard(GameCtrl game, Difficulty d) {
    final hasHint = game.lastResult != null;
    final bgColor = hasHint
        ? (game.lastResult == 'high'
        ? C.red
        : game.lastResult == 'low'
        ? C.violet
        : C.green)
        : C.violet;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      transitionBuilder: (child, anim) => SlideTransition(
        position: Tween<Offset>(
            begin: const Offset(0, -0.3), end: Offset.zero)
            .animate(anim),
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: NeonCard(
        key: ValueKey(game.lastResult ?? 'init'),
        glowColor: bgColor,
        gradient: LinearGradient(
          colors: [bgColor.withOpacity(0.18), bgColor.withOpacity(0.05)],
        ),
        child: Row(
          children: [
            Text(
              hasHint
                  ? (game.lastResult == 'high'
                  ? '📉'
                  : game.lastResult == 'low'
                  ? '📈'
                  : '🎯')
                  : '🎲',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.hintText,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: bgColor,
                    ),
                  ),
                  if (game.lastGuess != null)
                    Text(
                      'Your guess: ${game.lastGuess}',
                      style: const TextStyle(
                          fontSize: 12, color: C.txtSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(GameCtrl game, Difficulty d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Your Guess'),
        AnimatedBuilder(
          animation: _shakeAnim,
          builder: (_, child) => Transform.translate(
            offset: Offset(_shakeAnim.value, 0),
            child: child,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: C.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _focus.hasFocus
                          ? d.color.withOpacity(0.6)
                          : C.cardBorder,
                      width: _focus.hasFocus ? 1.5 : 0.8,
                    ),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: C.txtPrimary,
                      letterSpacing: -0.5,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '?',
                      hintStyle: TextStyle(
                        fontSize: 32,
                        color: C.txtDim,
                        fontWeight: FontWeight.w300,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 18),
                    ),
                    onSubmitted: (_) => _submit(),
                    onTap: () => setState(() {}),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _submit,
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: d.gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: d.color.withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 5))
                    ],
                  ),
                  child: _loading
                      ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    ),
                  )
                      : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 26),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuessList(GameCtrl game) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      // ✅ FIXED: added <Widget> type to .map() to fix List<dynamic> error
      children: game.history
          .map<Widget>((a) => GuessBubble(
        number: a.guessed,
        result: a.result,
        no:     a.attemptNo,
      ))
          .toList(),
    );
  }
}