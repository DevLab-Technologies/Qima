import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/models/transaction_capture.dart';
import 'package:qima/services/ai_assist_provider.dart';
import 'package:qima/services/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Wording implements AiAssistProvider {
  final String? wording;
  int calls = 0;
  _Wording(this.wording);

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ModelStatus> status(String localeTag) async => ModelStatus.ready;

  @override
  Future<CaptureSpans?> labelTransaction(String text, String localeTag) async => null;

  @override
  Future<String?> phrase(String sentence, String localeTag) async {
    calls++;
    return wording;
  }
}

void main() {
  const original = 'Over the past month your holdings gained 4,100 EGP (2.1%). Gold moved them most, +3,900 EGP.';

  group('acceptPhrasing', () {
    test('a rewording that keeps every number is accepted', () {
      expect(
        acceptPhrasing(original, 'Your holdings rose by 4,100 EGP (2.1%) this past month, with gold adding +3,900 EGP.'),
        isTrue,
      );
    });

    test('a changed, dropped or added number is refused', () {
      expect(acceptPhrasing(original, 'Your holdings gained 4,000 EGP (2.1%). Gold added +3,900 EGP.'), isFalse);
      expect(acceptPhrasing(original, 'Your holdings gained 4,100 EGP. Gold added +3,900 EGP.'), isFalse);
      expect(acceptPhrasing(original, 'Your holdings gained 4,100 EGP (2.1%) in 30 days. Gold added +3,900 EGP.'), isFalse);
    });

    test('Arabic-Indic digits count as the same numbers', () {
      expect(acceptPhrasing('ربحت 4100 ج.م (2.1%).', 'زادت مقتنياتك ٤١٠٠ ج.م (٢.١%).'), isTrue);
    });

    test('advice or a forecast is refused', () {
      expect(
        acceptPhrasing(original, 'Your holdings gained 4,100 EGP (2.1%); you should keep gold, up +3,900 EGP.'),
        isFalse,
      );
      expect(acceptPhrasing('ربحت 4100 ج.م.', 'ربحت 4100 ج.م، وننصح بالشراء.'), isFalse);
    });

    test('masked amounts must stay masked', () {
      expect(acceptPhrasing('Your holdings gained •••••• (2.1%).', 'Your holdings gained (2.1%).'), isFalse);
    });

    test('an empty or runaway reply is refused', () {
      expect(acceptPhrasing(original, '  '), isFalse);
      expect(acceptPhrasing(original, original * 4), isFalse);
    });
  });

  group('AppCubit.phrased', () {
    Future<AppCubit> cubitWith(AiAssistProvider provider, {required bool on}) async {
      SharedPreferences.setMockInitialValues({'onDeviceModel': on});
      final cubit = AppCubit(aiAssist: provider);
      cubit.preferences = await Preferences.create();
      cubit.emit(cubit.state.copyWith(onDeviceModel: on));
      return cubit;
    }

    test('off: the template sentence, and the model is never asked', () async {
      final model = _Wording('Your holdings rose by 4,100 EGP (2.1%), gold adding +3,900 EGP.');
      final cubit = await cubitWith(model, on: false);
      expect(await cubit.phrased(original, 'en'), original);
      expect(model.calls, 0);
      expect(cubit.assist, isA<NullAiAssistProvider>());
    });

    test('on: an accepted wording is used, and asked for once', () async {
      const wording = 'Your holdings rose by 4,100 EGP (2.1%), gold adding +3,900 EGP.';
      final model = _Wording(wording);
      final cubit = await cubitWith(model, on: true);
      expect(await cubit.phrased(original, 'en'), wording);
      expect(await cubit.phrased(original, 'en'), wording);
      expect(model.calls, 1);
      expect(cubit.assist, same(model));
    });

    test('on: a wording that invents a number falls back to the template', () async {
      final cubit = await cubitWith(_Wording('Your holdings rose by 5,000 EGP.'), on: true);
      expect(await cubit.phrased(original, 'en'), original);
    });
  });
}
