import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// Tuco's face, made of two frames that cross-fade: mouth closed and mouth
/// open. While [speaking] is true the mouth flaps on a syllable-like cadence,
/// so the avatar talks for exactly as long as the audio plays. Idle, it just
/// breathes gently.
class TalkingAvatar extends StatefulWidget {
  final bool speaking;
  final double size;

  /// Playback rate of the voice (1.0 = normal): the mouth flaps faster when
  /// the learner speeds Tuco up and slower when they slow him down.
  final double speed;

  const TalkingAvatar({
    super.key,
    required this.speaking,
    required this.size,
    this.speed = 1.0,
  });

  static const closedAsset = 'assets/logo.png';
  static const openAsset = 'assets/open_mouth.png';

  @override
  State<TalkingAvatar> createState() => _TalkingAvatarState();
}

class _TalkingAvatarState extends State<TalkingAvatar>
    with SingleTickerProviderStateMixin {
  // Mouth-open / mouth-closed spans at 1x, in ms — one cycle ≈ one syllable.
  // Randomised inside these ranges so the flapping reads as speech instead of
  // a metronome.
  static const _openMs = [80, 60]; // min, extra random
  static const _closedMs = [60, 80];

  final _random = Random();
  late final AnimationController _breath;

  Timer? _flap;
  bool _mouthOpen = false;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    if (widget.speaking) _scheduleFlap();
  }

  @override
  void didUpdateWidget(TalkingAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.speaking == oldWidget.speaking) return;
    widget.speaking ? _scheduleFlap() : _closeMouth();
  }

  /// Toggle the mouth, then queue the next toggle after a randomised delay.
  void _scheduleFlap() {
    final range = _mouthOpen ? _closedMs : _openMs;
    final ms = (range[0] + _random.nextInt(range[1])) / max(widget.speed, 0.25);
    _flap?.cancel();
    _flap = Timer(
      Duration(milliseconds: ms.round()),
      () {
        if (!mounted) return;
        setState(() => _mouthOpen = !_mouthOpen);
        _scheduleFlap();
      },
    );
  }

  void _closeMouth() {
    _flap?.cancel();
    _flap = null;
    if (_mouthOpen) setState(() => _mouthOpen = false);
  }

  @override
  void dispose() {
    _flap?.cancel();
    _breath.dispose();
    super.dispose();
  }

  /// One 1024px source frame, decoded at display resolution — two full-size
  /// bitmaps in memory would be wasteful for a 200pt avatar.
  Widget _frame(String asset) => Image.asset(
        asset,
        fit: BoxFit.contain,
        cacheWidth:
            (widget.size * MediaQuery.devicePixelRatioOf(context)).round(),
      );

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.98, end: 1.0)
          .animate(CurvedAnimation(parent: _breath, curve: Curves.easeInOut)),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        // Both frames stay mounted (so both are decoded from the first build);
        // only the top one's opacity animates, so the swap never flickers.
        child: Stack(
          fit: StackFit.expand,
          children: [
            _frame(TalkingAvatar.closedAsset),
            AnimatedOpacity(
              opacity: _mouthOpen ? 1 : 0,
              duration: const Duration(milliseconds: 60),
              child: _frame(TalkingAvatar.openAsset),
            ),
          ],
        ),
      ),
    );
  }
}
