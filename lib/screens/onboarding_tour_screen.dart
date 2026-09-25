import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../services/cloud_kv_store.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';
import 'currency_picker.dart';
import 'onboarding_illustrations.dart';

/// First-launch onboarding tour (spec "Onboarding tour"): 5 swipeable pages,
/// page dots, and Next/Skip (steps 1-4) or Get started (step 5, final).
/// Pushed as a full-screen route both on first launch (before the home
/// shell, from `main.dart`) and whenever it's replayed from Settings or a
/// help sheet's footer link — either way, finishing or skipping just pops
/// this route; the caller decides what happens next.
///
/// [onFinished] additionally lets the very first, pre-home-shell showing
/// swap itself for [HomeShell] instead of popping to nothing (there's
/// nothing to pop to yet) — every other call site (replay) leaves it null
/// and a plain `pop()` is correct.
class OnboardingTourScreen extends StatefulWidget {
  final VoidCallback? onFinished;

  const OnboardingTourScreen({super.key, this.onFinished});

  @override
  State<OnboardingTourScreen> createState() => _OnboardingTourScreenState();
}

const int _stepCount = 5;

class _OnboardingTourScreenState extends State<OnboardingTourScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    _pageController.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  Future<void> _finish() async {
    await context.read<AppCubit>().completeOnboarding();
    if (!mounted) return;
    if (widget.onFinished != null) {
      widget.onFinished!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final isLastPage = _page == _stepCount - 1;

    return Scaffold(
      backgroundColor: colors.bg0,
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _page = index),
                  children: const [
                    _TourPage(
                      child: _IllustratedStep(
                        illustration: WelcomeIllustration(),
                        title: _step1Title,
                        body: _step1Body,
                      ),
                    ),
                    _TourPage(
                      child: _IllustratedStep(
                        illustration: WatchlistIllustration(),
                        title: _step2Title,
                        body: _step2Body,
                      ),
                    ),
                    _TourPage(
                      child: _IllustratedStep(
                        illustration: HoldingsIllustration(),
                        title: _step3Title,
                        body: _step3Body,
                      ),
                    ),
                    _TourPage(
                      child: _IllustratedStep(
                        illustration: AlertsWidgetsIllustration(),
                        title: _step4Title,
                        body: _step4Body,
                      ),
                    ),
                    _TourPage(child: _PrivacyIllustrationAndCurrency()),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: DS.spaceMD),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _stepCount; i++)
                      Semantics(
                        label: l10n.onboardingSemanticStepOf(i + 1, _stepCount),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _page ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _page ? colors.brand : colors.hairlineStrong,
                            borderRadius: BorderRadius.circular(DS.radiusPill),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(DS.spaceLG, 0, DS.spaceLG, DS.spaceLG),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isLastPage ? _finish : _next,
                        child: Text(isLastPage ? l10n.onboardingGetStarted : l10n.onboardingNext),
                      ),
                    ),
                    // The Skip button's own height is kept reserved (via an
                    // Opacity+IgnorePointer swap rather than removing the
                    // child) on the last step so the primary button never
                    // jumps vertically when Skip disappears (spec "keep the
                    // vertical space where Skip would be").
                    Opacity(
                      opacity: isLastPage ? 0 : 1,
                      child: IgnorePointer(
                        ignoring: isLastPage,
                        child: TextButton(onPressed: _finish, child: Text(l10n.onboardingSkip)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tear-off-able (and so `const`-usable) accessors for the steps' strings.
String _step1Title(AppLocalizations l10n) => l10n.onboardingStep1Title;
String _step1Body(AppLocalizations l10n) => l10n.onboardingStep1Body;
String _step2Title(AppLocalizations l10n) => l10n.onboardingStep2Title;
String _step2Body(AppLocalizations l10n) => l10n.onboardingStep2Body;
String _step3Title(AppLocalizations l10n) => l10n.onboardingStep3Title;
String _step3Body(AppLocalizations l10n) => l10n.onboardingStep3Body;
String _step4Title(AppLocalizations l10n) => l10n.onboardingStep4Title;
String _step4Body(AppLocalizations l10n) => l10n.onboardingStep4Body;

class _TourPage extends StatelessWidget {
  final Widget child;

  const _TourPage({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: DS.spaceLG, vertical: DS.spaceMD),
      child: Center(child: child),
    );
  }
}

/// Wraps an onboarding illustration with the step's title/body underneath,
/// matching the Figma frames' layout (illustration, then title, then body).
class _StepText extends StatelessWidget {
  final String title;
  final String body;

  const _StepText({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        const SizedBox(height: DS.spaceXL),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: DS.spaceSM),
        Text(
          body,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textSecondary, fontSize: 15, height: 1.4),
        ),
      ],
    );
  }
}

/// Steps 1-4: an illustration with the step's title and body underneath.
///
/// The illustration may take at most [_illustrationShare] of the screen
/// height and scales down to fit it, so on short phones the title and body
/// still show without scrolling (the illustrations are drawn for a ~850pt
/// tall screen and would otherwise push the text below the fold).
class _IllustratedStep extends StatelessWidget {
  final Widget illustration;
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) body;

  const _IllustratedStep({required this.illustration, required this.title, required this.body});

  static const double _illustrationShare = 0.36;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        LayoutBuilder(
          // FittedBox lays its child out unconstrained, and the
          // illustrations stretch to the available width, so pin that
          // width first; FittedBox then only scales the result down.
          builder: (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * _illustrationShare),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(width: constraints.maxWidth, child: illustration),
            ),
          ),
        ),
        _StepText(title: title(l10n), body: body(l10n)),
      ],
    );
  }
}

class _PrivacyIllustrationAndCurrency extends StatefulWidget {
  const _PrivacyIllustrationAndCurrency();

  @override
  State<_PrivacyIllustrationAndCurrency> createState() => _PrivacyIllustrationAndCurrencyState();
}

class _PrivacyIllustrationAndCurrencyState extends State<_PrivacyIllustrationAndCurrency> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final isMac = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final showICloudRow = platformSupportsICloud;

    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) => previous.baseCurrency != current.baseCurrency,
      builder: (context, state) {
        return Column(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(color: colors.tileTop, shape: BoxShape.circle),
                  child: Icon(Icons.shield_outlined, color: colors.brandText, size: 32),
                ),
                const SizedBox(height: DS.spaceMD),
                Wrap(
                  spacing: DS.spaceXS,
                  alignment: WrapAlignment.center,
                  children: [
                    _Pill(icon: Icons.no_accounts_outlined, label: l10n.onboardingStep5PillNoAccount),
                    _Pill(icon: Icons.smartphone, label: l10n.onboardingStep5PillOnDevice),
                  ],
                ),
                const SizedBox(height: DS.spaceMD),
                DSCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showICloudRow) ...[
                        _PrivacyRow(
                          icon: Icons.cloud_outlined,
                          title: l10n.onboardingStep5ICloudTitle,
                          subtitle: l10n.onboardingStep5ICloudSubtitle,
                          value: true,
                        ),
                        Divider(color: colors.hairline, height: DS.spaceLG),
                      ],
                      _PrivacyRow(
                        icon: Icons.fingerprint,
                        title: l10n.onboardingStep5AppLockTitle,
                        subtitle: isMac
                            ? l10n.onboardingStep5AppLockSubtitleMac
                            : isIOS
                            ? l10n.onboardingStep5AppLockSubtitleApple
                            : l10n.onboardingStep5AppLockSubtitleGeneric,
                        value: true,
                      ),
                      Divider(color: colors.hairline, height: DS.spaceLG),
                      _PrivacyRow(
                        icon: Icons.visibility_off_outlined,
                        title: l10n.onboardingStep5HideBalancesTitle,
                        subtitle: l10n.onboardingStep5HideBalancesSubtitle,
                        value: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _StepText(
              title: l10n.onboardingStep5Title,
              body: isMac
                  ? l10n.onboardingStep5BodyMac
                  : showICloudRow
                  ? l10n.onboardingStep5Body
                  : l10n.onboardingStep5BodyAndroid,
            ),
            const SizedBox(height: DS.spaceLG),
            DSCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: DS.spaceMD, vertical: DS.spaceXS),
                leading: Icon(Icons.payments_outlined, color: colors.textSecondary),
                title: Text(l10n.onboardingBaseCurrencyTitle, style: TextStyle(color: colors.textPrimary)),
                subtitle: Text(
                  l10n.onboardingBaseCurrencySubtitle,
                  style: TextStyle(color: colors.textTertiary, fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.baseCurrency,
                      style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    Icon(Icons.chevron_right, color: colors.textTertiary),
                  ],
                ),
                onTap: () async {
                  final cubit = context.read<AppCubit>();
                  final selected = await CurrencyPicker.show(
                    context,
                    selected: state.baseCurrency,
                    currencies: state.rates.availableCurrencies,
                  );
                  if (selected != null) await cubit.setBaseCurrency(selected);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DS.spaceSM, vertical: 6),
      decoration: BoxDecoration(color: colors.tileTop, borderRadius: BorderRadius.circular(DS.radiusPill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colors.textSecondary, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PrivacyRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;

  const _PrivacyRow({required this.icon, required this.title, required this.subtitle, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, color: colors.textSecondary, size: 20),
        const SizedBox(width: DS.spaceSM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(subtitle, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
            ],
          ),
        ),
        Switch(value: value, onChanged: null, activeThumbColor: colors.onBrand, activeTrackColor: colors.brand),
      ],
    );
  }
}
