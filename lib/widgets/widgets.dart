import 'package:flutter/material.dart';
import '../utils/theme.dart'; // ✅ FIXED: was 'theme.dart'

// ─── Neon Card ────────────────────────────────────────────────────
class NeonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? glowColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double radius;

  const NeonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.glowColor,
    this.gradient,
    this.onTap,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    final glow = glowColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: gradient == null ? C.card : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: glow != null
                ? glow.withOpacity(0.35)
                : C.cardBorder,
            width: glow != null ? 1.2 : 0.8,
          ),
          boxShadow: glow != null
              ? [
            BoxShadow(
                color: glow.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2)
          ]
              : null,
        ),
        child: child,
      ),
    );
  }
}

// ─── Gradient Button ─────────────────────────────────────────────
class GradBtn extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final LinearGradient gradient;
  final String? icon;
  final double height;
  final bool loading;

  const GradBtn({
    super.key,
    required this.label,
    this.onTap,
    this.gradient = C.violetGrad,
    this.icon,
    this.height = 56,
    this.loading = false,
  });

  @override
  State<GradBtn> createState() => _GradBtnState();
}

class _GradBtnState extends State<GradBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 80));
  late final Animation<double> _scale =
  Tween<double>(begin: 1, end: 0.96).animate(_c);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) {
        _c.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.loading
                ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Text(widget.icon!,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Ghost Button ────────────────────────────────────────────────
class GhostBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;

  const GhostBtn({
    super.key,
    required this.label,
    this.onTap,
    this.color = C.txtSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
          color: color.withOpacity(0.05),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section Label ───────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text.toUpperCase(), style: TS.label),
  );
}

// ─── Stat Tile ───────────────────────────────────────────────────
class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final String emoji;
  final Color color;

  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      glowColor: color,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.8,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(label, style: TS.label),
        ],
      ),
    );
  }
}

// ─── Animated Number Bubble ──────────────────────────────────────
class GuessBubble extends StatelessWidget {
  final int number;
  final String result;
  final int no;

  const GuessBubble({
    super.key,
    required this.number,
    required this.result,
    required this.no,
  });

  Color get _color {
    switch (result) {
      case 'correct':
        return C.green;
      case 'high':
        return C.red;
      case 'low':
        return C.violet;
      default:
        return C.txtSecondary;
    }
  }

  String get _icon {
    switch (result) {
      case 'correct':
        return '✓';
      case 'high':
        return '↓';
      case 'low':
        return '↑';
      default:
        return '?';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$no',
            style: TextStyle(
              fontSize: 10,
              color: _color.withOpacity(0.6),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$number',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            _icon,
            style: TextStyle(
              fontSize: 13,
              color: _color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Lives Row ───────────────────────────────────────────────────
class LivesRow extends StatelessWidget {
  final int total;
  final int remaining;
  final Color color;

  const LivesRow({
    super.key,
    required this.total,
    required this.remaining,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 4,
      children: List.generate(total, (i) {
        final alive = i < remaining;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: alive ? color : C.txtDim,
            boxShadow: alive
                ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)]
                : null,
          ),
        );
      }),
    );
  }
}