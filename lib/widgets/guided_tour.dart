import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../l10n/app_localizations.dart';
import '../models/setup_answers.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';

/// Where the guided tour points. The home shell and its tabs hang these
/// keys on the real widgets, so the tour lights up the person's own screen
/// rather than a picture of one. Each key is on one widget at a time: the
/// shell builds either the tab bar or the rail, and Money and Prices exist
/// once, inside the shell.
class TourTargets {
  TourTargets._();

  static final tabs = GlobalKey(debugLabel: 'tour.tabs');
  static final add = GlobalKey(debugLabel: 'tour.add');
  static final money = GlobalKey(debugLabel: 'tour.money');
  static final prices = GlobalKey(debugLabel: 'tour.prices');

  static GlobalKey keyFor(TourStop stop) => switch (stop) {
        TourStop.tabs => tabs,
        TourStop.add => add,
        TourStop.money => money,
        TourStop.prices => prices,
      };

  /// The shell tab a stop is on.
  static int tabFor(TourStop stop) => switch (stop) {
        TourStop.tabs || TourStop.add => 0,
        TourStop.money => 1,
        TourStop.prices => 2,
      };
}

/// Replays the guided tour from a screen above the home shell (Settings, a
/// help sheet): the tour runs over the shell, so everything above it closes
/// first, and the shell starts the tour when it is asked to.
void replayTour(BuildContext context) {
  final app = context.read<AppCubit>();
  Navigator.of(context).popUntil((route) => route.isFirst);
  app.requestTour();
}

/// The guided tour: the screen dims, one thing stays lit, and a card says
/// what it is. Laid over the home shell, which it asks to change tab as the
/// stops move on. Next (or a tap anywhere outside the card) goes to the
/// next stop, Skip tour ends it, and the last stop's button says Done.
///
/// A stop whose target isn't on screen (an empty watchlist has no first
/// price) still shows its card, in the middle, with nothing lit.
class GuidedTourOverlay extends StatefulWidget {
  final List<TourStop> stops;
  final ValueChanged<int> onSelectTab;
  final VoidCallback onDone;

  const GuidedTourOverlay({super.key, required this.stops, required this.onSelectTab, required this.onDone});

  @override
  State<GuidedTourOverlay> createState() => _GuidedTourOverlayState();
}

class _GuidedTourOverlayState extends State<GuidedTourOverlay> {
  int _index = 0;

  /// The lit target in this overlay's coordinates; null until it has been
  /// measured, or when the stop has nothing to light.
  Rect? _target;
  bool _measured = false;

  TourStop get _stop => widget.stops[_index];

  @override
  void initState() {
    super.initState();
    _enter();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A rotation or a new text size moves the target; reading them here is
    // what brings this back when they change.
    MediaQuery.sizeOf(context);
    MediaQuery.textScalerOf(context);
    if (_measured) _measureSoon();
  }

  /// Runs [then] after the next frame, asking for that frame: nothing else
  /// may be about to draw (the tab is already showing, the list did not
  /// need to scroll), and a post-frame callback alone would wait forever.
  void _afterFrame(VoidCallback then) {
    WidgetsBinding.instance.addPostFrameCallback((_) => then());
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  /// Brings the current stop's tab forward and measures its target. After
  /// the frame, because changing tab rebuilds the shell this overlay is
  /// being built by.
  void _enter() {
    final stop = _stop;
    _afterFrame(() {
      if (!mounted || stop != _stop) return;
      widget.onSelectTab(TourTargets.tabFor(stop));
      _measureSoon();
    });
  }

  /// Measures after the tab has switched and laid out: the first frame
  /// brings the target into view if it is down the page, the second reads
  /// where it ended up.
  void _measureSoon() {
    final stop = _stop;
    _afterFrame(() {
      if (!mounted || stop != _stop) return;
      final targetContext = TourTargets.keyFor(stop).currentContext;
      if (targetContext != null && Scrollable.maybeOf(targetContext) != null) {
        Scrollable.ensureVisible(targetContext, alignment: 0.5, duration: Duration.zero);
      }
      _afterFrame(() {
        if (!mounted || stop != _stop) return;
        setState(() {
          _target = _rectOf(stop);
          _measured = true;
        });
      });
    });
  }

  Rect? _rectOf(TourStop stop) {
    final target = TourTargets.keyFor(stop).currentContext?.findRenderObject();
    final self = context.findRenderObject();
    if (target is! RenderBox || self is! RenderBox || !target.attached || !target.hasSize) return null;
    var rect = target.localToGlobal(Offset.zero, ancestor: self) & target.size;
    // A Money section's box includes the gap under its card; light the card.
    if (stop == TourStop.money) rect = Rect.fromLTRB(rect.left, rect.top, rect.right, rect.bottom - DS.spaceMD);
    // Off screen after all (a page that can't scroll that far): light nothing.
    return (Offset.zero & self.size).overlaps(rect) ? rect : null;
  }

  void _next() {
    if (_index >= widget.stops.length - 1) {
      widget.onDone();
      return;
    }
    setState(() {
      _index++;
      _target = null;
      _measured = false;
    });
    _enter();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final stop = _stop;
    final last = _index == widget.stops.length - 1;
    final (title, body) = switch (stop) {
      TourStop.tabs => (l10n.tourTabsTitle, l10n.tourTabsBody),
      TourStop.add => (l10n.tourAddTitle, l10n.tourAddBody),
      TourStop.money => (l10n.tourMoneyTitle, l10n.tourMoneyBody),
      TourStop.prices => (l10n.tourPricesTitle, l10n.tourPricesBody),
    };
    // The lit area: a little larger than the target, with the target's own
    // corners (a pill for the tab bar, a circle for +).
    final lit = _target?.inflate(6);
    final radius = lit == null
        ? Radius.zero
        : switch (stop) {
            TourStop.tabs || TourStop.add => Radius.circular(lit.shortestSide / 2),
            TourStop.money || TourStop.prices => const Radius.circular(DS.radiusCard),
          };

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        // The card sits above a target in the lower half and below one in
        // the upper half, so it never covers what it is about.
        final above = lit != null && lit.center.dy > size.height / 2;
        const gap = 14.0;
        // Where the card starts when it sits below its target, and the room
        // it has either way: with large text it scrolls inside that room
        // rather than running off the screen, and its buttons stay put.
        final insets = MediaQuery.paddingOf(context);
        final top = lit == null ? insets.top + DS.spaceMD : math.min(lit.bottom + gap, size.height - 160);
        final room = lit == null
            ? size.height - insets.vertical - DS.spaceMD * 2
            : above
                ? lit.top - gap - insets.top - DS.spaceMD
                : size.height - top - math.max(insets.bottom, DS.spaceMD);
        final cardWidth = math.min(size.width - DS.spaceMD * 2, 360.0);
        final left = lit == null ? (size.width - cardWidth) / 2 : (lit.center.dx - cardWidth / 2).clamp(DS.spaceMD, size.width - cardWidth - DS.spaceMD);

        final card = Semantics(
          container: true,
          liveRegion: true,
          scopesRoute: true,
          explicitChildNodes: true,
          child: Material(
            color: colors.overlay,
            elevation: 12,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceMD, DS.spaceMD, DS.spaceSM),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(title, style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
                          const SizedBox(height: DS.spaceXS),
                          Text(body, style: TextStyle(color: colors.textSecondary, fontSize: 14, height: 1.4)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: DS.spaceSM),
                  // A Wrap: with large text the buttons drop under the step
                  // count instead of being squeezed off the card.
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: DS.spaceXS,
                    children: [
                      Text(l10n.tourStepOf(_index + 1, widget.stops.length), style: TextStyle(color: colors.textTertiary, fontSize: 13)),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: DS.spaceXS,
                        children: [
                          if (!last) TextButton(onPressed: widget.onDone, child: Text(l10n.tourSkip)),
                          FilledButton(
                            style: FilledButton.styleFrom(minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 18)),
                            onPressed: _next,
                            child: Text(last ? l10n.commonDone : l10n.tourNext),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

        // BlockSemantics: a screen reader meets the card, not the dimmed
        // screen under it.
        return BlockSemantics(
          child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                // Nothing under the tour reacts while it runs; a tap outside
                // the card moves on, as the card's own button does.
                onTap: _measured ? _next : null,
                child: ExcludeSemantics(
                  child: CustomPaint(
                    painter: _SpotlightPainter(
                      lit: lit == null ? null : RRect.fromRectAndRadius(lit, radius),
                      scrim: Colors.black.withValues(alpha: 0.56),
                      ring: colors.brand,
                    ),
                  ),
                ),
              ),
            ),
            if (_measured)
              Positioned(
                left: left,
                width: cardWidth,
                top: lit != null && above ? null : top,
                bottom: lit != null && above ? size.height - lit.top + gap : null,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: math.max(room, 120)),
                  // With nothing lit the card sits in the middle of its room.
                  child: lit == null ? SizedBox(height: math.max(room, 120), child: Center(child: card)) : card,
                ),
              ),
          ],
          ),
        );
      },
    );
  }
}

/// The dimmed screen with the target cut out and ringed.
class _SpotlightPainter extends CustomPainter {
  final RRect? lit;
  final Color scrim;
  final Color ring;

  const _SpotlightPainter({required this.lit, required this.scrim, required this.ring});

  @override
  void paint(Canvas canvas, Size size) {
    final whole = Path()..addRect(Offset.zero & size);
    final lit = this.lit;
    if (lit == null) {
      canvas.drawPath(whole, Paint()..color = scrim);
      return;
    }
    final hole = Path()..addRRect(lit);
    canvas.drawPath(Path.combine(PathOperation.difference, whole, hole), Paint()..color = scrim);
    canvas.drawRRect(
      lit,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = ring,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.lit != lit || old.scrim != scrim || old.ring != ring;
}
