import 'package:flutter/material.dart';

// ── Public API ─────────────────────────────────────────────────────────────────

enum IllustrationType {
  squat, pushUp, lunge, plank, deadlift, bicepCurl,
  shoulderPress, jumpingJack, mountainClimber, burpee,
  pullUp, crunch, run,
  genericUpper, genericLower, genericFull,
}

/// Maps a raw exercise string like "Push-ups — 3×12" to an illustration type.
IllustrationType matchIllustration(String rawName) {
  final n = rawName
      .split(RegExp(r'\s*[—–-]\s*'))
      .first
      .toLowerCase()
      .replaceAll('-', ' ')
      .trim();
  if (n.contains('squat')) { return IllustrationType.squat; }
  if (n.contains('push up') || n.contains('pushup')) { return IllustrationType.pushUp; }
  if (n.contains('lunge')) { return IllustrationType.lunge; }
  if (n.contains('plank') && !n.contains('mountain')) { return IllustrationType.plank; }
  if (n.contains('deadlift')) { return IllustrationType.deadlift; }
  if (n.contains('bicep') || (n.contains('curl') && !n.contains('leg'))) {
    return IllustrationType.bicepCurl;
  }
  if (n.contains('press') &&
      (n.contains('shoulder') || n.contains('overhead') || n.contains('military'))) {
    return IllustrationType.shoulderPress;
  }
  if (n.contains('jumping jack')) { return IllustrationType.jumpingJack; }
  if (n.contains('mountain')) { return IllustrationType.mountainClimber; }
  if (n.contains('burpee')) { return IllustrationType.burpee; }
  if (n.contains('pull up') || n.contains('pullup') || n.contains('chin')) {
    return IllustrationType.pullUp;
  }
  if (n.contains('crunch') || n.contains('sit up') ||
      n.contains('sit-up') || n.contains('ab crunch')) {
    return IllustrationType.crunch;
  }
  if (n.contains('run') || n.contains('jog') || n.contains('sprint') ||
      n.contains('high knee') || n.contains('box jump') || n.contains('jump')) {
    return IllustrationType.run;
  }
  // Keyword fallback
  if (_any(n, ['bench', 'row', 'fly', 'dip', 'raise', 'press', 'curl', 'extension'])) {
    return IllustrationType.genericUpper;
  }
  if (_any(n, ['leg', 'glute', 'calf', 'hip', 'hamstring', 'quad', 'step up'])) {
    return IllustrationType.genericLower;
  }
  return IllustrationType.genericFull;
}

bool _any(String s, List<String> ks) => ks.any(s.contains);

/// Rendered illustration widget — insert above exercise instructions.
class ExerciseIllustration extends StatelessWidget {
  final String rawName;
  final String muscles;

  const ExerciseIllustration({
    super.key,
    required this.rawName,
    this.muscles = '',
  });

  @override
  Widget build(BuildContext context) {
    final pose = _posesMap[matchIllustration(rawName)]!;
    return Container(
      height: 150,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C0A18), Color(0xFF070D1A)],
        ),
        border: Border.all(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.22),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _FigurePainter(pose: pose)),
            ),
            if (muscles.isNotEmpty)
              Positioned(
                bottom: 7,
                left: 10,
                right: 10,
                child: Text(
                  muscles,
                  style: TextStyle(
                    color: const Color(0xFF4DD0E1).withValues(alpha: 0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Joint model ────────────────────────────────────────────────────────────────

// Segments that can be highlighted (glow)
enum _Seg {
  armL, armR,
  forearmL, forearmR,
  torso,
  thighL, thighR,
  shinL, shinR,
}

// All joint positions in a 100×130 virtual coordinate space.
// The painter scales these to the actual canvas size.
class _JointSet {
  final Offset head;
  final double headR;   // head radius in virtual units
  final Offset neck;
  final Offset sL, sR;  // shoulders
  final Offset eL, eR;  // elbows
  final Offset wL, wR;  // wrists / hands
  final Offset hL, hR;  // hips
  final Offset kL, kR;  // knees
  final Offset fL, fR;  // feet
  final Set<_Seg> glow; // segments to highlight

  const _JointSet({
    required this.head,
    this.headR = 7.5,
    required this.neck,
    required this.sL, required this.sR,
    required this.eL, required this.eR,
    required this.wL, required this.wR,
    required this.hL, required this.hR,
    required this.kL, required this.kR,
    required this.fL, required this.fR,
    this.glow = const {},
  });
}

// ── Pose definitions ───────────────────────────────────────────────────────────

const Map<IllustrationType, _JointSet> _posesMap = {

  // ── SQUAT: knees bent wide, hips low, arms parallel to floor ──────────────
  IllustrationType.squat: _JointSet(
    head: Offset(50, 10), headR: 7.5,
    neck: Offset(50, 19),
    sL: Offset(38, 26), sR: Offset(62, 26),
    eL: Offset(34, 47), eR: Offset(66, 47),
    wL: Offset(39, 63), wR: Offset(61, 63),
    hL: Offset(33, 65), hR: Offset(67, 65),
    kL: Offset(22, 92), kR: Offset(78, 92),
    fL: Offset(18, 118), fR: Offset(82, 118),
    glow: {_Seg.thighL, _Seg.thighR, _Seg.shinL, _Seg.shinR},
  ),

  // ── PUSH-UP: side profile, horizontal body, arms bent ─────────────────────
  // L = near side, R = far side (slight offset for depth)
  IllustrationType.pushUp: _JointSet(
    head: Offset(10, 47), headR: 6.5,
    neck: Offset(18, 43),
    sL: Offset(25, 38), sR: Offset(27, 50),
    eL: Offset(38, 62), eR: Offset(40, 72),
    wL: Offset(48, 74), wR: Offset(50, 82),
    hL: Offset(67, 38), hR: Offset(69, 50),
    kL: Offset(83, 42), kR: Offset(85, 52),
    fL: Offset(96, 48), fR: Offset(97, 58),
    glow: {_Seg.armL, _Seg.armR, _Seg.forearmL, _Seg.forearmR},
  ),

  // ── LUNGE: front view, one leg forward deep, one leg back ─────────────────
  IllustrationType.lunge: _JointSet(
    head: Offset(50, 10), headR: 7.5,
    neck: Offset(50, 19),
    sL: Offset(40, 26), sR: Offset(60, 26),
    eL: Offset(34, 44), eR: Offset(66, 44),
    wL: Offset(32, 62), wR: Offset(68, 62),
    hL: Offset(44, 65), hR: Offset(56, 65),
    kL: Offset(34, 90), kR: Offset(65, 90),
    fL: Offset(26, 118), fR: Offset(72, 120),
    glow: {_Seg.thighL, _Seg.thighR},
  ),

  // ── PLANK: side profile, forearms on floor, body straight ─────────────────
  IllustrationType.plank: _JointSet(
    head: Offset(10, 42), headR: 6.5,
    neck: Offset(18, 38),
    sL: Offset(26, 32), sR: Offset(28, 44),
    eL: Offset(37, 72), eR: Offset(39, 80),  // elbows on floor
    wL: Offset(52, 72), wR: Offset(54, 80),  // forearms along floor
    hL: Offset(67, 32), hR: Offset(69, 44),
    kL: Offset(83, 36), kR: Offset(85, 46),
    fL: Offset(96, 40), fR: Offset(97, 50),
    glow: {_Seg.torso},
  ),

  // ── DEADLIFT: front view, torso hinged forward, arms hanging ──────────────
  IllustrationType.deadlift: _JointSet(
    head: Offset(50, 14), headR: 7.5,
    neck: Offset(50, 24),
    sL: Offset(37, 35), sR: Offset(63, 35),
    eL: Offset(37, 58), eR: Offset(63, 58),
    wL: Offset(37, 78), wR: Offset(63, 78),
    hL: Offset(43, 65), hR: Offset(57, 65),
    kL: Offset(42, 92), kR: Offset(58, 92),
    fL: Offset(40, 118), fR: Offset(60, 118),
    glow: {_Seg.torso, _Seg.thighL, _Seg.thighR},
  ),

  // ── BICEP CURL: standing, forearms raised toward shoulders ────────────────
  IllustrationType.bicepCurl: _JointSet(
    head: Offset(50, 10), headR: 7.5,
    neck: Offset(50, 19),
    sL: Offset(40, 26), sR: Offset(60, 26),
    eL: Offset(33, 43), eR: Offset(67, 43),
    wL: Offset(40, 28), wR: Offset(60, 28),  // hands up near shoulders
    hL: Offset(44, 65), hR: Offset(56, 65),
    kL: Offset(43, 90), kR: Offset(57, 90),
    fL: Offset(40, 118), fR: Offset(60, 118),
    glow: {_Seg.forearmL, _Seg.forearmR},
  ),

  // ── SHOULDER PRESS: arms pressed fully overhead ───────────────────────────
  IllustrationType.shoulderPress: _JointSet(
    head: Offset(50, 18), headR: 7.5,
    neck: Offset(50, 27),
    sL: Offset(40, 34), sR: Offset(60, 34),
    eL: Offset(34, 20), eR: Offset(66, 20),  // elbows at temple level
    wL: Offset(36, 8),  wR: Offset(64, 8),   // hands overhead
    hL: Offset(44, 73), hR: Offset(56, 73),
    kL: Offset(43, 98), kR: Offset(57, 98),
    fL: Offset(40, 124), fR: Offset(60, 124),
    glow: {_Seg.armL, _Seg.armR, _Seg.forearmL, _Seg.forearmR},
  ),

  // ── JUMPING JACKS: arms spread overhead, legs wide ────────────────────────
  IllustrationType.jumpingJack: _JointSet(
    head: Offset(50, 10), headR: 7.5,
    neck: Offset(50, 19),
    sL: Offset(28, 26), sR: Offset(72, 26),
    eL: Offset(18, 18), eR: Offset(82, 18),
    wL: Offset(12, 10), wR: Offset(88, 10),
    hL: Offset(38, 65), hR: Offset(62, 65),
    kL: Offset(30, 90), kR: Offset(70, 90),
    fL: Offset(22, 118), fR: Offset(78, 118),
    glow: {_Seg.armL, _Seg.armR, _Seg.forearmL, _Seg.forearmR,
           _Seg.thighL, _Seg.thighR, _Seg.shinL, _Seg.shinR},
  ),

  // ── MOUNTAIN CLIMBERS: side profile, high plank + knee drawn in ──────────
  IllustrationType.mountainClimber: _JointSet(
    head: Offset(10, 44), headR: 6.5,
    neck: Offset(18, 40),
    sL: Offset(27, 34), sR: Offset(29, 46),
    eL: Offset(27, 66), eR: Offset(29, 74),  // straight arms (high plank)
    wL: Offset(27, 76), wR: Offset(29, 84),  // hands on floor
    hL: Offset(67, 34), hR: Offset(69, 46),
    kL: Offset(46, 46), kR: Offset(84, 38),  // L knee drawn in, R straight back
    fL: Offset(30, 58), fR: Offset(97, 42),
    glow: {_Seg.thighL, _Seg.thighR, _Seg.torso},
  ),

  // ── BURPEE: mid-jump, arms overhead ───────────────────────────────────────
  IllustrationType.burpee: _JointSet(
    head: Offset(50, 9), headR: 7.5,
    neck: Offset(50, 18),
    sL: Offset(36, 25), sR: Offset(64, 25),
    eL: Offset(26, 16), eR: Offset(74, 16),
    wL: Offset(20, 8),  wR: Offset(80, 8),
    hL: Offset(43, 62), hR: Offset(57, 62),
    kL: Offset(40, 82), kR: Offset(60, 82),
    fL: Offset(38, 108), fR: Offset(62, 108),
    glow: {_Seg.armL, _Seg.armR, _Seg.forearmL, _Seg.forearmR,
           _Seg.thighL, _Seg.thighR},
  ),

  // ── PULL-UP: top position, arms overhead gripping bar ─────────────────────
  IllustrationType.pullUp: _JointSet(
    head: Offset(50, 22), headR: 7.5,
    neck: Offset(50, 32),
    sL: Offset(38, 38), sR: Offset(62, 38),
    eL: Offset(28, 24), eR: Offset(72, 24),  // elbows wide, above shoulders
    wL: Offset(34, 8),  wR: Offset(66, 8),   // hands on bar at top
    hL: Offset(44, 72), hR: Offset(56, 72),
    kL: Offset(44, 98), kR: Offset(56, 98),
    fL: Offset(42, 122), fR: Offset(58, 122),
    glow: {_Seg.armL, _Seg.armR, _Seg.forearmL, _Seg.forearmR, _Seg.torso},
  ),

  // ── CRUNCH: lying down, upper body curled up, knees bent ─────────────────
  IllustrationType.crunch: _JointSet(
    head: Offset(50, 28), headR: 7.5,
    neck: Offset(50, 37),
    sL: Offset(38, 44), sR: Offset(62, 44),
    eL: Offset(32, 42), eR: Offset(68, 42),  // elbows flared out (hands behind head)
    wL: Offset(40, 35), wR: Offset(60, 35),  // hands at back of head
    hL: Offset(44, 74), hR: Offset(56, 74),
    kL: Offset(40, 100), kR: Offset(60, 100),
    fL: Offset(38, 120), fR: Offset(62, 120),
    glow: {_Seg.torso},
  ),

  // ── RUN: mid-stride, opposite arm/leg coordination ────────────────────────
  IllustrationType.run: _JointSet(
    head: Offset(50, 10), headR: 7.5,
    neck: Offset(50, 19),
    sL: Offset(40, 26), sR: Offset(60, 26),
    eL: Offset(33, 36), eR: Offset(67, 46),
    wL: Offset(35, 24), wR: Offset(73, 58),  // L arm forward-up, R arm back-down
    hL: Offset(44, 65), hR: Offset(56, 65),
    kL: Offset(40, 96), kR: Offset(58, 80),  // R knee drives forward
    fL: Offset(28, 120), fR: Offset(66, 104),
    glow: {_Seg.thighL, _Seg.thighR, _Seg.shinL, _Seg.shinR},
  ),

  // ── GENERIC UPPER: standing, arms slightly active ─────────────────────────
  IllustrationType.genericUpper: _JointSet(
    head: Offset(50, 10), headR: 7.5,
    neck: Offset(50, 19),
    sL: Offset(40, 26), sR: Offset(60, 26),
    eL: Offset(32, 44), eR: Offset(68, 44),
    wL: Offset(30, 62), wR: Offset(70, 62),
    hL: Offset(44, 65), hR: Offset(56, 65),
    kL: Offset(43, 90), kR: Offset(57, 90),
    fL: Offset(40, 118), fR: Offset(60, 118),
    glow: {_Seg.armL, _Seg.armR, _Seg.forearmL, _Seg.forearmR},
  ),

  // ── GENERIC LOWER: standing, slight wide stance ───────────────────────────
  IllustrationType.genericLower: _JointSet(
    head: Offset(50, 10), headR: 7.5,
    neck: Offset(50, 19),
    sL: Offset(40, 26), sR: Offset(60, 26),
    eL: Offset(33, 44), eR: Offset(67, 44),
    wL: Offset(31, 62), wR: Offset(69, 62),
    hL: Offset(42, 65), hR: Offset(58, 65),
    kL: Offset(40, 92), kR: Offset(60, 92),
    fL: Offset(38, 120), fR: Offset(62, 120),
    glow: {_Seg.thighL, _Seg.thighR, _Seg.shinL, _Seg.shinR},
  ),

  // ── GENERIC FULL: standing power pose, everything glowing ─────────────────
  IllustrationType.genericFull: _JointSet(
    head: Offset(50, 10), headR: 7.5,
    neck: Offset(50, 19),
    sL: Offset(38, 26), sR: Offset(62, 26),
    eL: Offset(30, 44), eR: Offset(70, 44),
    wL: Offset(28, 62), wR: Offset(72, 62),
    hL: Offset(44, 65), hR: Offset(56, 65),
    kL: Offset(43, 90), kR: Offset(57, 90),
    fL: Offset(40, 118), fR: Offset(60, 118),
    glow: {_Seg.armL, _Seg.armR, _Seg.forearmL, _Seg.forearmR,
           _Seg.torso, _Seg.thighL, _Seg.thighR, _Seg.shinL, _Seg.shinR},
  ),
};

// ── CustomPainter ──────────────────────────────────────────────────────────────

class _FigurePainter extends CustomPainter {
  final _JointSet pose;
  const _FigurePainter({required this.pose});

  // Virtual canvas dimensions (arbitrary units, scaled to actual canvas)
  static const _vW = 100.0;
  static const _vH = 130.0;

  /// Scale a virtual-space point to actual canvas coordinates.
  Offset _s(Offset p, Size size) =>
      Offset(p.dx / _vW * size.width, p.dy / _vH * size.height);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Gradient shader: purple at top, cyan at bottom, applied across full canvas.
    // Each line segment is naturally colored by its Y position in the canvas.
    final shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFA78BFA), Color(0xFF4DD0E1)],
    ).createShader(rect);

    final bodyPaint = Paint()
      ..shader = shader
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Glow pass: wider cyan blur drawn BEHIND the gradient line for highlighted segments
    final glowPaint = Paint()
      ..color = const Color(0x994DD0E1)
      ..strokeWidth = 7.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    final p = pose;
    final hipCenter = Offset(
      (p.hL.dx + p.hR.dx) / 2,
      (p.hL.dy + p.hR.dy) / 2,
    );
    // Head bottom is the base of the head circle where neck attaches
    final headBottom = Offset(p.head.dx, p.head.dy + p.headR);

    // Draws glow pass then gradient pass for a body segment.
    void line(Offset a, Offset b, [_Seg? seg]) {
      final pa = _s(a, size);
      final pb = _s(b, size);
      if (seg != null && p.glow.contains(seg)) {
        canvas.drawLine(pa, pb, glowPaint);
      }
      canvas.drawLine(pa, pb, bodyPaint);
    }

    // ── Head ──────────────────────────────────────────────────────────────────
    final hc = _s(p.head, size);
    final hr = p.headR / _vW * size.width;

    // For core exercises, add a subtle glow aura around the head
    if (p.glow.contains(_Seg.torso)) {
      canvas.drawCircle(
        hc,
        hr + 2.0,
        Paint()
          ..color = const Color(0x554DD0E1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0,
      );
    }
    canvas.drawCircle(hc, hr, bodyPaint);

    // ── Skeleton ──────────────────────────────────────────────────────────────

    // Neck: head bottom → neck joint
    line(headBottom, p.neck);

    // Clavicles: neck → each shoulder
    line(p.neck, p.sL);
    line(p.neck, p.sR);

    // Spine: neck → hip center  (torso segment — glows for core exercises)
    line(p.neck, hipCenter, _Seg.torso);

    // Hip width lines: hip center → each hip
    line(hipCenter, p.hL);
    line(hipCenter, p.hR);

    // Upper arms
    line(p.sL, p.eL, _Seg.armL);
    line(p.sR, p.eR, _Seg.armR);

    // Forearms
    line(p.eL, p.wL, _Seg.forearmL);
    line(p.eR, p.wR, _Seg.forearmR);

    // Thighs
    line(p.hL, p.kL, _Seg.thighL);
    line(p.hR, p.kR, _Seg.thighR);

    // Shins
    line(p.kL, p.fL, _Seg.shinL);
    line(p.kR, p.fR, _Seg.shinR);
  }

  @override
  bool shouldRepaint(covariant _FigurePainter old) =>
      !identical(old.pose, pose);
}
