// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'قيمة';

  @override
  String get navWatchlist => 'قائمة المتابعة';

  @override
  String get watchlistAdd => 'إضافة أصل';

  @override
  String get watchlistEmptyTitle => 'قائمة المتابعة فارغة';

  @override
  String get watchlistEmptyMessage =>
      'أضف معادن أو عملات رقمية أو أسهمًا أو عملات لبدء تتبع الأسعار.';

  @override
  String get watchlistFilterAll => 'الكل';

  @override
  String get addTitle => 'إضافة أصل';

  @override
  String get addSearchHint => 'ابحث عن أصل';

  @override
  String addSearchCustomTickerTitle(String query) {
    return 'إضافة ”$query“ كرمز مخصص';
  }

  @override
  String get addSearchCustomTickerSubtitle =>
      'للأسهم أو الصناديق المتداولة أو المؤشرات غير المدرجة هنا';

  @override
  String addSearchNoResultsTitle(String query) {
    return 'لا نتائج لـ ”$query“';
  }

  @override
  String get addSearchNoResultsMessage =>
      'لا شيء في القائمة يطابق هذا البحث. يمكنك إضافته كرمز مخصص.';

  @override
  String addSearchNoResultsButton(String query) {
    return 'إضافة $query كرمز مخصص';
  }

  @override
  String addedToWatchlist(String name) {
    return 'أُضيف $name إلى قائمة المتابعة';
  }

  @override
  String alreadyInWatchlist(String name) {
    return '$name موجود بالفعل في قائمة المتابعة';
  }

  @override
  String get addCustomTickerTitle => 'إضافة رمز مخصص';

  @override
  String get addCustomTickerSymbol => 'رمز التداول';

  @override
  String get addCustomTickerName => 'اسم العرض (اختياري)';

  @override
  String get addCustomTickerHint => 'مثال: AAPL, TSLA, VOO';

  @override
  String get addCustomTickerSymbolRequired => 'أدخل رمز تداول.';

  @override
  String get addCustomTickerError =>
      'تعذّر التحقق من هذا الرمز. تحقق منه وحاول مرة أخرى.';

  @override
  String get addCustomTickerSubmit => 'إضافة الرمز';

  @override
  String get cardConfigAddToWatchlist => 'إضافة إلى قائمة المتابعة';

  @override
  String get commonCurrency => 'العملة';

  @override
  String get currencyPickerSearchHint => 'البحث عن عملة';

  @override
  String get detailHoldings => 'المقتنيات';

  @override
  String get detailHistory => 'السجل';

  @override
  String get detailLoadHistory => 'تحميل السجل';

  @override
  String get detailNoHistoryTitle => 'لا يوجد سجل بعد';

  @override
  String get detailNoHistoryMessage =>
      'حمّل السجل لعرض الرسم البياني الكامل للسعر.';

  @override
  String get detailKeyStats => 'أهم الإحصاءات';

  @override
  String get detailPricePerUnit => 'السعر لكل وحدة';

  @override
  String detailUpdatedAt(String time) {
    return 'آخر تحديث $time';
  }

  @override
  String get errorRefreshFailed =>
      'تعذّر تحديث الأسعار. تحقّق من اتصالك وحاول مرة أخرى.';

  @override
  String get detailChangeCurrency => 'تغيير العملة';

  @override
  String detailShowPerUnit(String unit) {
    return 'عرض السعر لكل $unit';
  }

  @override
  String get holdingsEmpty => 'أضف أول دفعة لبدء تتبع هذه المقتنيات.';

  @override
  String get holdingsValue => 'القيمة';

  @override
  String get holdingsCost => 'التكلفة';

  @override
  String get holdingsGain => 'الربح';

  @override
  String get holdingsGainPercent => 'نسبة الربح';

  @override
  String get holdingsNew => 'دفعة جديدة';

  @override
  String get holdingsEdit => 'تعديل الدفعة';

  @override
  String get holdingsQuantity => 'الكمية';

  @override
  String get holdingsCostModePerUnit => 'لكل وحدة';

  @override
  String get holdingsCostModeTotal => 'الإجمالي';

  @override
  String get holdingsUnitCost => 'تكلفة الوحدة';

  @override
  String holdingsUnitCostWithUnit(String unit) {
    return 'تكلفة الوحدة (لكل $unit)';
  }

  @override
  String holdingsUnitCostWithKarat(String unit, String karat) {
    return 'تكلفة الوحدة (لكل $unit · $karat)';
  }

  @override
  String holdingsUnitCostPreview(String value) {
    return 'لكل وحدة: $value';
  }

  @override
  String get holdingsTotalCost => 'التكلفة الإجمالية';

  @override
  String holdingsTotalCostPreview(String value) {
    return 'الإجمالي: $value';
  }

  @override
  String get holdingsDate => 'التاريخ';

  @override
  String get holdingsSave => 'حفظ';

  @override
  String get holdingsTotalHeld => 'إجمالي المملوك';

  @override
  String get holdingsAverageCost => 'متوسط التكلفة';

  @override
  String holdingsAverageCostPerUnit(String value, String unit) {
    return '$value لكل $unit';
  }

  @override
  String holdingsAverageCostPerUnitKarat(
    String value,
    String unit,
    String karat,
  ) {
    return '$value لكل $unit · $karat';
  }

  @override
  String holdingsMixedNote(String karat) {
    return 'تم احتساب العيارات المختلطة حسب محتوى الذهب، ويُعرض كـ $karat.';
  }

  @override
  String get holdingsMixedUnitsNote =>
      'تم احتساب الوحدات المختلطة حسب محتوى الذهب.';

  @override
  String holdingsHeldLine(String quantity, String average) {
    return 'المملوك $quantity · بمتوسط $average';
  }

  @override
  String get portfolioTitle => 'المحفظة';

  @override
  String get portfolioValue => 'القيمة الإجمالية';

  @override
  String get portfolioEmpty =>
      'لا توجد قيمة للمحفظة بعد — أضف دفعة مقتنيات للبدء.';

  @override
  String get portfolioNoChange => 'لا يوجد سجل كافٍ لهذه الفترة بعد';

  @override
  String get portfolioNoHistory =>
      'أضف دفعة مقتنيات لعرض الرسم البياني لمحفظتك';

  @override
  String portfolioLotCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دفعة',
      many: '$count دفعة',
      few: '$count دفعات',
      two: 'دفعتان',
      one: 'دفعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsAppearanceSystem => 'النظام';

  @override
  String get settingsAppearanceLight => 'فاتح';

  @override
  String get settingsAppearanceDark => 'داكن';

  @override
  String get settingsBaseCurrency => 'العملة الأساسية';

  @override
  String get settingsPortfolioCurrency => 'عملة المحفظة';

  @override
  String get settingsUnit => 'الوحدة';

  @override
  String get settingsKarat => 'القيراط';

  @override
  String get settingsBaseCurrencyFooter => 'تُستخدم لحساب إجمالي قيمة محفظتك.';

  @override
  String get settingsDefaultRange => 'النطاق الزمني الافتراضي';

  @override
  String get settingsDefaultRangeFooter => 'يُستخدم عند فتح أصل لأول مرة.';

  @override
  String get settingsWidgetRefresh => 'فاصل تحديث الودجة';

  @override
  String get settingsWidgetRefreshFooter =>
      'عدد مرات جلب الودجات في الخلفية للأسعار الجديدة.';

  @override
  String get settingsAbout => 'حول';

  @override
  String get settingsLanguageSystem => 'اتباع لغة النظام';

  @override
  String get settingsDataSource =>
      'finance.yahoo.com · gold-api.com · er-api.com';

  @override
  String get settingsPrivacy => 'الخصوصية والأمان';

  @override
  String get settingsHideBalances => 'إخفاء الأرصدة';

  @override
  String get settingsHideBalancesFooter =>
      'إخفاء مبالغ المحفظة والممتلكات والصفقات في جميع أنحاء التطبيق.';

  @override
  String get settingsAppLock => 'قفل التطبيق';

  @override
  String get settingsAppLockFooter =>
      'طلب بصمة الوجه أو بصمة الإصبع أو رمز مرور الجهاز لفتح Qima.';

  @override
  String get settingsAppLockUnavailable =>
      'يرجى إعداد بصمة الوجه أو بصمة الإصبع أو رمز مرور للجهاز أولاً.';

  @override
  String get settingsAppLockFailed =>
      'تعذر التحقق من هويتك — سيبقى قفل التطبيق متوقفًا.';

  @override
  String get settingsLockAfter => 'القفل بعد';

  @override
  String get lockGraceImmediately => 'فورًا';

  @override
  String get lockGrace1m => 'دقيقة واحدة';

  @override
  String get lockGrace5m => '5 دقائق';

  @override
  String get lockGrace15m => '15 دقيقة';

  @override
  String get privacyHideBalances => 'إخفاء الأرصدة';

  @override
  String get privacyShowBalances => 'إظهار الأرصدة';

  @override
  String get appLockAuthReason => 'افتح قفل Qima لرؤية محفظتك';

  @override
  String get appLockLockedTitle => 'Qima مقفل';

  @override
  String get appLockLockedMessage => 'افتح القفل لرؤية محفظتك وممتلكاتك.';

  @override
  String get appLockUnlockFaceID => 'فتح القفل باستخدام Face ID';

  @override
  String get appLockUnlockTouchID => 'فتح القفل باستخدام Touch ID';

  @override
  String get appLockUnlockGeneric => 'فتح القفل';

  @override
  String get appLockUseDevicePasscode => 'استخدام رمز مرور الجهاز';

  @override
  String get statChange => 'التغير';

  @override
  String get statHigh => 'الأعلى';

  @override
  String get statLow => 'الأدنى';

  @override
  String get statPoints => 'النقاط';

  @override
  String get pricePullToRefresh => 'اسحب للتحديث';

  @override
  String get assetClassMetal => 'المعادن';

  @override
  String get assetClassCrypto => 'العملات الرقمية';

  @override
  String get assetClassStock => 'الأسهم';

  @override
  String get assetClassIndex => 'المؤشرات';

  @override
  String get assetClassFiat => 'العملات';

  @override
  String get assetGold => 'الذهب';

  @override
  String get assetSilver => 'الفضة';

  @override
  String get assetPlatinum => 'البلاتين';

  @override
  String get assetPalladium => 'البلاديوم';

  @override
  String get assetBitcoin => 'بيتكوين';

  @override
  String get assetEthereum => 'إيثيريوم';

  @override
  String get assetApple => 'أبل';

  @override
  String get assetMicrosoft => 'مايكروسوفت';

  @override
  String get assetNvidia => 'إنفيديا';

  @override
  String get assetAmazon => 'أمازون';

  @override
  String get assetTesla => 'تسلا';

  @override
  String get assetAlphabet => 'ألفابت';

  @override
  String get assetSp500 => 'إس آند بي 500';

  @override
  String get assetDowJones => 'داو جونز';

  @override
  String get assetNasdaq => 'ناسداك';

  @override
  String get assetRussell2000 => 'راسل 2000';

  @override
  String get assetFtse100 => 'فوتسي 100';

  @override
  String get assetNikkei225 => 'نيكاي 225';

  @override
  String get assetDax => 'داكس';

  @override
  String get assetUsDollar => 'الدولار الأمريكي';

  @override
  String get assetEuro => 'اليورو';

  @override
  String get assetBritishPound => 'الجنيه الإسترليني';

  @override
  String get assetEgyptianPound => 'الجنيه المصري';

  @override
  String get assetSaudiRiyal => 'الريال السعودي';

  @override
  String get assetEmiratiDirham => 'الدرهم الإماراتي';

  @override
  String get assetQatariRiyal => 'الريال القطري';

  @override
  String get assetKuwaitiDinar => 'الدينار الكويتي';

  @override
  String get assetOmaniRial => 'الريال العماني';

  @override
  String get assetBahrainiDinar => 'الدينار البحريني';

  @override
  String get assetJordanianDinar => 'الدينار الأردني';

  @override
  String get unitTroyOunce => 'أونصة تروي';

  @override
  String get unitGram => 'جرام';

  @override
  String get unitKilogram => 'كيلوجرام';

  @override
  String get unitEach => 'الوحدة';

  @override
  String get unitAbbrTroyOunce => 'أونصة';

  @override
  String get unitAbbrGram => 'جم';

  @override
  String get unitAbbrKilogram => 'كجم';

  @override
  String get karatShort24 => '٢٤ قيراط';

  @override
  String get karatShort22 => '٢٢ قيراط';

  @override
  String get karatShort21 => '٢١ قيراط';

  @override
  String get karatShort18 => '١٨ قيراط';

  @override
  String get range1D => 'يوم';

  @override
  String get range3D => '٣ أيام';

  @override
  String get range7D => '٧ أيام';

  @override
  String get range1W => 'أسبوع';

  @override
  String get range1M => 'شهر';

  @override
  String get range3M => '٣ أشهر';

  @override
  String get range6M => '٦ أشهر';

  @override
  String get rangeYtd => 'منذ بداية العام';

  @override
  String get range1Y => 'سنة';

  @override
  String get range5Y => '٥ سنوات';

  @override
  String get rangeAll => 'الكل';

  @override
  String get refresh15m => '١٥ دقيقة';

  @override
  String get refresh30m => '٣٠ دقيقة';

  @override
  String get refresh1h => 'ساعة واحدة';

  @override
  String get refresh3h => '٣ ساعات';

  @override
  String get refresh6h => '٦ ساعات';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonRemove => 'إزالة';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonUndo => 'تراجع';

  @override
  String confirmRemoveCardTitle(String name) {
    return 'إزالة $name من قائمة المتابعة؟';
  }

  @override
  String get confirmRemoveCardMessage => 'ستبقى مقتنياتك من هذا الأصل محفوظة.';

  @override
  String get confirmDeleteLotTitle => 'حذف هذه الدفعة؟';

  @override
  String confirmDeleteLotMessage(String details) {
    return '$details. لا يمكن التراجع عن ذلك.';
  }

  @override
  String confirmRemoveTickerTitle(String symbol) {
    return 'إزالة الرمز المخصص $symbol؟';
  }

  @override
  String get confirmRemoveTickerMessage =>
      'ستُزال أيضًا بطاقاته من قائمة المتابعة.';

  @override
  String get alertKindAbove => 'يتجاوز';

  @override
  String get alertKindBelow => 'ينخفض عن';

  @override
  String get alertKindPercentMove => 'تغيّر %';

  @override
  String get alertDirectionUp => 'صعود';

  @override
  String get alertDirectionDown => 'هبوط';

  @override
  String get alertDirectionEither => 'أي منهما';

  @override
  String get alertWindowWithin24h => 'خلال ٢٤ ساعة';

  @override
  String get alertWindowWithin7d => 'خلال ٧ أيام';

  @override
  String get alertWindow24h => '٢٤ ساعة';

  @override
  String get alertWindow7d => '٧ أيام';

  @override
  String get alertBellTooltip => 'تنبيهات السعر';

  @override
  String get alertsCardTitle => 'التنبيهات';

  @override
  String get alertsCardEmpty => 'لا توجد تنبيهات بعد لهذا الأصل.';

  @override
  String get alertsCardAdd => 'إضافة تنبيه';

  @override
  String get alertEditorNewTitle => 'تنبيه جديد';

  @override
  String get alertEditorEditTitle => 'تعديل التنبيه';

  @override
  String get alertEditorTypePrice => 'السعر';

  @override
  String get alertEditorTypePercent => 'تغيّر %';

  @override
  String get alertEditorGoesAbove => 'يتجاوز';

  @override
  String get alertEditorGoesBelow => 'ينخفض عن';

  @override
  String get alertEditorTargetLabel => 'السعر المستهدف';

  @override
  String get alertEditorTargetRequired => 'أدخل سعرًا مستهدفًا أكبر من صفر.';

  @override
  String alertEditorHelperAbove(String delta, String percent) {
    return '‏+$delta · أعلى بنسبة $percent٪ من السعر الحالي';
  }

  @override
  String alertEditorHelperBelow(String delta, String percent) {
    return '‏−$delta · أقل بنسبة $percent٪ من السعر الحالي';
  }

  @override
  String get alertEditorDirection => 'الاتجاه';

  @override
  String get alertEditorWindow => 'المدة';

  @override
  String alertEditorPercentSummary(String low, String high) {
    return 'يُطلق عند الانخفاض دون $low أو الارتفاع فوق $high';
  }

  @override
  String alertEditorPercentSummaryUp(String high) {
    return 'يُطلق عند الارتفاع فوق $high';
  }

  @override
  String alertEditorPercentSummaryDown(String low) {
    return 'يُطلق عند الانخفاض دون $low';
  }

  @override
  String get alertEditorRepeat => 'تكرار';

  @override
  String get alertEditorRepeatFooter =>
      'يستمر المراقبة بعد إطلاقه بدلاً من إيقاف التشغيل.';

  @override
  String get alertEditorCreate => 'إنشاء تنبيه';

  @override
  String get alertEditorSave => 'حفظ';

  @override
  String get alertEditorDelete => 'حذف';

  @override
  String get alertsScreenTitle => 'التنبيهات';

  @override
  String get alertsScreenInfo =>
      'تُفحص التنبيهات تقريبًا كل ١٥ دقيقة في الخلفية، وباستمرار أثناء فتح قيمة.';

  @override
  String get alertsScreenEmptyTitle => 'لا توجد تنبيهات بعد';

  @override
  String get alertsScreenEmptyMessage =>
      'افتح أصلًا ما واضغط على الجرس لضبط تنبيه سعر.';

  @override
  String alertsScreenFiredToday(String time) {
    return 'أُطلق اليوم $time · تم إيقاف التشغيل';
  }

  @override
  String get alertsScreenNotificationsOff => 'الإشعارات متوقفة';

  @override
  String get alertsScreenNotificationsOffMessage =>
      'فعّل إشعارات قيمة لتصلك تنبيهات عند بلوغ سعر مستهدف.';

  @override
  String get alertsScreenOpenSettings => 'فتح الإعدادات';

  @override
  String get confirmDeleteAlertTitle => 'حذف هذا التنبيه؟';

  @override
  String get confirmDeleteAlertMessage => 'لن تصلك إشعارات بشأنه مرة أخرى.';

  @override
  String get settingsAlerts => 'التنبيهات';

  @override
  String get settingsAlertsPriceAlerts => 'تنبيهات السعر';

  @override
  String settingsAlertsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تنبيه',
      many: '$count تنبيهًا',
      few: '$count تنبيهات',
      two: 'تنبيهان',
      one: 'تنبيه واحد',
      zero: 'لا تنبيهات',
    );
    return '$_temp0';
  }

  @override
  String get settingsAlertsNotifications => 'الإشعارات';

  @override
  String get settingsAlertsNotificationsOn => 'مفعّلة';

  @override
  String get settingsAlertsNotificationsOff => 'متوقفة';

  @override
  String get settingsAlertsDeliverOnDevice => 'تسليم التنبيهات على هذا الجهاز';

  @override
  String get settingsAlertsDeliverOnDeviceFooter =>
      'أوقف التشغيل إذا كنت لا تريد أن يُنبّهك هذا الجهاز عند إطلاق تنبيه.';

  @override
  String alertNotificationTitleAbove(String name, String target) {
    return '$name تجاوز $target';
  }

  @override
  String alertNotificationTitleBelow(String name, String target) {
    return '$name انخفض عن $target';
  }

  @override
  String alertNotificationTitlePercent(
    String name,
    String percent,
    String window,
  ) {
    return '$name تحرك بنسبة $percent٪ خلال $window';
  }

  @override
  String alertNotificationBodyOneOff(String price, String unit) {
    return 'الآن $price لكل $unit. تم إيقاف هذا التنبيه.';
  }

  @override
  String alertNotificationBodyRepeat(String price, String unit) {
    return 'الآن $price لكل $unit. سنُعلمك مرة أخرى في المرة القادمة.';
  }

  @override
  String get settingsBackup => 'النسخ الاحتياطي والاستعادة';

  @override
  String get settingsBackupSubtitleNever => 'لم يتم النسخ الاحتياطي مطلقًا';

  @override
  String settingsBackupSubtitle(String date, int instruments, int lots) {
    return 'آخر نسخة احتياطية $date · $instruments أصل، $lots دفعة';
  }

  @override
  String get settingsICloudSync => 'مزامنة iCloud';

  @override
  String get settingsICloudSyncSwitch => 'المزامنة مع iCloud';

  @override
  String get settingsICloudSyncFooter =>
      'تُبقي قائمة المتابعة والمقتنيات والرموز المخصصة وتنبيهات الأسعار محدّثة عبر أجهزتك.';

  @override
  String settingsICloudSyncStatusUpToDate(String time) {
    return 'محدّثة · $time';
  }

  @override
  String get settingsICloudSyncStatusSyncing => 'جارٍ المزامنة…';

  @override
  String get settingsICloudSyncStatusNotSignedIn =>
      'لم يتم تسجيل الدخول إلى iCloud';

  @override
  String get settingsICloudSyncStatusStorageFull =>
      'مساحة تخزين iCloud الخاصة بـQima ممتلئة';

  @override
  String get backupTitle => 'النسخ الاحتياطي والاستعادة';

  @override
  String get backupStatusTitle => 'محفوظة على هذا الهاتف فقط';

  @override
  String get backupStatusMessage =>
      'بياناتك موجودة على هذا الجهاز فقط. أنشئ نسخة احتياطية لتتمكن من استعادتها هنا أو على جهاز آخر.';

  @override
  String backupLastBackup(String date) {
    return 'آخر نسخة احتياطية $date';
  }

  @override
  String get backupLastBackupNever => 'لم يتم النسخ الاحتياطي مطلقًا';

  @override
  String get backupReminderCardTitle => 'حان وقت النسخ الاحتياطي';

  @override
  String get backupReminderCardMessage =>
      'مرّ أكثر من 30 يومًا منذ آخر نسخة احتياطية وتغيّرت بياناتك.';

  @override
  String get backupReminderCardAction => 'انسخ احتياطيًا الآن';

  @override
  String get backupReminderNotificationTitle => 'حان وقت النسخ الاحتياطي';

  @override
  String get backupReminderNotificationBody =>
      'مرّ وقت منذ آخر نسخة احتياطية لتطبيق قيمة وتغيّرت بياناتك. اضغط للنسخ الاحتياطي الآن.';

  @override
  String get backupExportSection => 'تصدير';

  @override
  String get backupExportFullTitle => 'نسخة احتياطية كاملة';

  @override
  String get backupExportFullSubtitle =>
      'قائمة المتابعة، الممتلكات، الرموز المخصصة، التنبيهات والإعدادات (.json)';

  @override
  String get backupExportCsvTitle => 'جدول بيانات الممتلكات';

  @override
  String get backupExportCsvSubtitle => 'دفعاتك كجدول بيانات، لسجلاتك (.csv)';

  @override
  String get backupRestoreSection => 'استعادة';

  @override
  String get backupRestoreTitle => 'استيراد نسخة احتياطية';

  @override
  String get backupRestoreSubtitle =>
      'استعد من ملف نسخة احتياطية كاملة (.json)';

  @override
  String get backupReminderSection => 'تذكير';

  @override
  String get backupReminderToggleTitle => 'ذكّرني بالنسخ الاحتياطي';

  @override
  String get backupReminderToggleSubtitle =>
      'احصل على تذكير شهري إذا لم تنسخ احتياطيًا مؤخرًا وتغيّرت بياناتك.';

  @override
  String get backupExportSheetTitle => 'تصدير النسخة الاحتياطية';

  @override
  String get backupExportSheetFileName => 'اسم الملف';

  @override
  String get backupExportSheetFileSize => 'الحجم';

  @override
  String get backupExportSheetFileContents => 'المحتويات';

  @override
  String backupExportSheetContentsSummary(
    int cards,
    int lots,
    int customTickers,
  ) {
    return '$cards بطاقة متابعة · $lots دفعة · $customTickers رمز مخصص';
  }

  @override
  String get backupExportSheetProtectTitle => 'الحماية بكلمة مرور';

  @override
  String get backupExportSheetProtectSubtitle =>
      'يشفّر الملف باستخدام AES-256. إذا نسيت كلمة المرور هذه، لا يمكن استعادة النسخة الاحتياطية.';

  @override
  String get backupExportSheetPasswordLabel => 'كلمة المرور';

  @override
  String get backupExportSheetPasswordConfirmLabel => 'تأكيد كلمة المرور';

  @override
  String get backupExportSheetPasswordTooShort => 'استخدم 8 أحرف على الأقل.';

  @override
  String get backupExportSheetPasswordMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get backupExportSheetUnprotectedWarning =>
      'يمكن لأي شخص يملك هذا الملف قراءة بياناتك. احمِه بكلمة مرور إذا كنت تخطط لتخزينه أو إرساله في مكان أقل خصوصية.';

  @override
  String get backupExportSheetAction => 'حفظ أو مشاركة…';

  @override
  String get backupExportSheetWorking => 'جارٍ تجهيز نسختك الاحتياطية…';

  @override
  String get backupExportSheetFailed =>
      'تعذّر إنشاء النسخة الاحتياطية. حاول مرة أخرى.';

  @override
  String get backupImportPreviewTitle => 'استعادة نسخة احتياطية';

  @override
  String backupImportFileCreated(String date) {
    return 'أُنشئت في $date';
  }

  @override
  String backupImportFileAppVersion(String version) {
    return 'أُنشئت بواسطة قيمة $version';
  }

  @override
  String get backupImportCountCards => 'بطاقات المتابعة';

  @override
  String get backupImportCountLots => 'الدفعات';

  @override
  String get backupImportCountCustomTickers => 'الرموز المخصصة';

  @override
  String get backupImportCountSettings => 'الإعدادات المضمّنة';

  @override
  String get backupImportPasswordPrompt =>
      'هذه النسخة الاحتياطية محمية. أدخل كلمة المرور للمتابعة.';

  @override
  String get backupImportPasswordLabel => 'كلمة المرور';

  @override
  String get backupImportPasswordIncorrect =>
      'كلمة المرور هذه لم تنجح. حاول مرة أخرى.';

  @override
  String get backupImportUnlock => 'فتح';

  @override
  String get backupImportModeMerge => 'دمج';

  @override
  String get backupImportModeReplace => 'استبدال';

  @override
  String get backupImportModeMergeFooter =>
      'يحتفظ بما هو موجود على هذا الهاتف ويضيف كل ما هو جديد أو أحدث من النسخة الاحتياطية.';

  @override
  String get backupImportModeReplaceFooter =>
      'يستبدل كل شيء على هذا الهاتف بمحتويات النسخة الاحتياطية.';

  @override
  String backupImportDiff(int added, int updated, int removed) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: '+$added مُضاف',
      one: '+1 مُضاف',
      zero: '',
    );
    return '$_temp0 · $updated محدّث · $removed محذوف';
  }

  @override
  String get backupImportRestoreButton => 'استعادة';

  @override
  String get backupImportReplaceConfirmTitle =>
      'استبدال كل شيء على هذا الهاتف؟';

  @override
  String get backupImportReplaceConfirmMessage =>
      'سيتم استبدال قائمة المتابعة والممتلكات والرموز المخصصة والتنبيهات الحالية بمحتويات النسخة الاحتياطية. لا يمكن التراجع عن هذا.';

  @override
  String get backupImportReplaceConfirmAction => 'استبدال';

  @override
  String get backupImportSuccessSnackbar => 'تمت استعادة النسخة الاحتياطية';

  @override
  String get backupImportFailedTitle => 'تعذّرت استعادة هذه النسخة الاحتياطية';

  @override
  String get backupImportCsvErrorTitle => 'هذا جدول بيانات، وليس نسخة احتياطية';

  @override
  String get backupImportCsvErrorMessage =>
      'جدول بيانات الممتلكات (.csv) يحتوي على دفعاتك فقط، ولا يمكن استعادته. اختر ملف نسخة احتياطية كاملة (.json) بدلاً من ذلك.';

  @override
  String get backupErrorNotQimaFile =>
      'هذا لا يبدو كملف نسخة احتياطية من قيمة.';

  @override
  String get backupErrorNewerVersion =>
      'أُنشئت هذه النسخة الاحتياطية بإصدار أحدث من قيمة. حدّث التطبيق لاستعادتها.';

  @override
  String get backupErrorWrongPassword => 'كلمة المرور هذه لم تنجح.';

  @override
  String get backupErrorCorrupted =>
      'ملف النسخة الاحتياطية تالف ولا يمكن استعادته.';

  @override
  String get backupCsvHeaderInstrument => 'الأصل';

  @override
  String get backupCsvHeaderSymbol => 'الرمز';

  @override
  String get backupCsvHeaderQuantity => 'الكمية';

  @override
  String get backupCsvHeaderUnit => 'الوحدة';

  @override
  String get backupCsvHeaderKarat => 'العيار';

  @override
  String get backupCsvHeaderUnitCost => 'تكلفة الوحدة';

  @override
  String get backupCsvHeaderCostCurrency => 'عملة التكلفة';

  @override
  String get backupCsvHeaderTotalCost => 'التكلفة الإجمالية';

  @override
  String get backupCsvHeaderDate => 'التاريخ';

  @override
  String get commonContinue => 'متابعة';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String get onboardingStep1Title => 'كل ما تملكه في رقم واحد';

  @override
  String get onboardingStep1Body =>
      'الذهب والفضة والعملات الرقمية والأسهم والمؤشرات والعملات، مجموعةً بعملتك.';

  @override
  String get onboardingStep2Title => 'الأسعار بالطريقة التي تشتري بها';

  @override
  String get onboardingStep2Body =>
      'أسعار مباشرة بالجرام أو الأونصة أو الكيلوغرام، من عيار 24 إلى 18، بأي عملة. اضغط + للإضافة، واضغط على بطاقة لعرض مخططها.';

  @override
  String get onboardingStep3Title => 'اعرف ما تملكه';

  @override
  String get onboardingStep3Body =>
      'سجّل كل عملية شراء: الكمية والوحدة والعيار والتكلفة والتاريخ. اطّلع على ما تملكه ومتوسط تكلفتك وقيمتك وأرباحك.';

  @override
  String get onboardingStep4Title => 'لا تفوّت أي تحرك';

  @override
  String get onboardingStep4Body =>
      'احصل على إشعار عند تجاوز السعر لمستوى معيّن أو تحرّكه بنسبة مئوية. أضف الأسعار إلى الشاشة الرئيسية وشاشة القفل.';

  @override
  String get onboardingStep5Title => 'خاص بتصميمه';

  @override
  String get onboardingStep5Body =>
      'بلا حساب. تبقى بياناتك على هذا الجهاز، مع مزامنة اختيارية عبر iCloud، وقفل بمعرّف الوجه، ونسخ احتياطية كملفات.';

  @override
  String get onboardingStep5BodyAndroid =>
      'بلا حساب. تبقى بياناتك على هذا الجهاز، مع فتح ببصمة الإصبع أو الوجه، ونسخ احتياطية كملفات.';

  @override
  String get onboardingStep5BodyMac =>
      'بلا حساب. تبقى بياناتك على هذا الـMac، مع مزامنة اختيارية عبر iCloud، وقفل بـTouch ID، ونسخ احتياطية كملفات.';

  @override
  String get onboardingStep5PillNoAccount => 'بلا حساب';

  @override
  String get onboardingStep5PillOnDevice => 'على هذا الجهاز';

  @override
  String get onboardingStep5ICloudTitle => 'مزامنة iCloud';

  @override
  String get onboardingStep5ICloudSubtitle => 'اختياري · يبقي أجهزتك متزامنة';

  @override
  String get onboardingStep5AppLockTitle => 'قفل التطبيق';

  @override
  String get onboardingStep5AppLockSubtitleApple =>
      'معرّف الوجه أو بصمة الإصبع';

  @override
  String get onboardingStep5AppLockSubtitleGeneric =>
      'بصمة الإصبع أو فتح بالوجه';

  @override
  String get onboardingStep5AppLockSubtitleMac => 'Touch ID أو كلمة سر الـMac';

  @override
  String get onboardingStep5HideBalancesTitle => 'إخفاء الأرصدة';

  @override
  String get onboardingStep5HideBalancesSubtitle => 'عرض •••• بدلاً من المبالغ';

  @override
  String get onboardingBaseCurrencyTitle => 'العملة الأساسية';

  @override
  String get onboardingBaseCurrencySubtitle =>
      'حسب منطقتك · غيّرها من الإعدادات';

  @override
  String onboardingSemanticStepOf(int step, int total) {
    return 'الخطوة $step من $total';
  }

  @override
  String get onboardingReplayTour => 'إعادة عرض الجولة';

  @override
  String get helpButtonTooltip => 'مساعدة';

  @override
  String get helpSheetAboutHeader => 'حول هذه الصفحة';

  @override
  String get helpSheetHowToHeader => 'كيفية الاستخدام';

  @override
  String get helpSheetIndexHeader => 'مساعدة';

  @override
  String get helpSheetWidgetsHeader => 'مساعدة · الإعدادات';

  @override
  String get helpSheetCloseTooltip => 'إغلاق';

  @override
  String get helpIndexIntro => 'اختر صفحة لمعرفة وظيفتها وكيفية استخدامها.';

  @override
  String get helpWatchlistTitle => 'قائمة المتابعة';

  @override
  String get helpWatchlistSummary =>
      'أسعار مباشرة لكل ما تتابعه، مع إجمالي محفظتك في الأعلى.';

  @override
  String get helpWatchlistStep1Title => 'افتح بطاقة';

  @override
  String get helpWatchlistStep1Body =>
      'اضغط على أي بطاقة لعرض مخططها وأهم إحصاءاتها وممتلكاتك منها.';

  @override
  String get helpWatchlistStep2Title => 'أضف أصلًا';

  @override
  String get helpWatchlistStep2Body => 'اضغط على + وابحث بالاسم أو الرمز.';

  @override
  String get helpWatchlistStep3Title => 'صفِّ القائمة';

  @override
  String get helpWatchlistStep3Body =>
      'اعرض المعادن أو العملات الرقمية أو الأسهم أو المؤشرات أو العملات فقط.';

  @override
  String get helpWatchlistStep4Title => 'غيّر مدى المخطط';

  @override
  String get helpWatchlistStep4Body =>
      'اختر من أسبوع إلى الكل أسفل مخطط المحفظة.';

  @override
  String get helpWatchlistStep5Title => 'حدّث الأسعار';

  @override
  String get helpWatchlistStep5Body =>
      'اضغط على التحديث لجلب أحدث الأسعار الآن.';

  @override
  String get helpAssetDetailTitle => 'تفاصيل الأصل';

  @override
  String get helpAssetDetailSummary =>
      'سعر أصل واحد ومخططه وإحصاءاته، بالإضافة إلى ما تملكه منه.';

  @override
  String get helpAssetDetailStep1Title => 'اختر مدى';

  @override
  String get helpAssetDetailStep1Body => 'بدّل بين يوم واحد والكل أسفل المخطط.';

  @override
  String get helpAssetDetailStep2Title => 'غيّر الوحدة أو العيار أو العملة';

  @override
  String get helpAssetDetailStep2Body => 'اضغط على أيقونة الضبط أعلى الصفحة.';

  @override
  String get helpAssetDetailStep3Title => 'قارن الوحدات';

  @override
  String get helpAssetDetailStep3Body =>
      'يعرض السعر لكل وحدة الأونصة والكيلوغرام وكل عيار جنبًا إلى جنب.';

  @override
  String get helpAssetDetailStep4Title => 'اضبط تنبيهًا';

  @override
  String get helpAssetDetailStep4Body =>
      'اضغط على الجرس لتصلك إشعارات عند تجاوز السعر لمستوى أو تحرّكه بنسبة مئوية.';

  @override
  String get helpAssetDetailStep5Title => 'تابع ما تملكه';

  @override
  String get helpAssetDetailStep5Body =>
      'اضغط على الممتلكات لعرض دفعاتك أو إضافة عملية شراء.';

  @override
  String get helpPortfolioTitle => 'المحفظة';

  @override
  String get helpPortfolioSummary =>
      'كل ما تملكه، مجموعًا بعملتك الأساسية، مع حصة كل أصل وأرباحه.';

  @override
  String get helpPortfolioStep1Title => 'اقرأ الرسم الدائري';

  @override
  String get helpPortfolioStep1Body =>
      'كل قطاع يمثل حصة أصل واحد من قيمتك الإجمالية.';

  @override
  String get helpPortfolioStep2Title => 'افتح أصلًا';

  @override
  String get helpPortfolioStep2Body =>
      'اضغط على صف لعرض دفعاته ومتوسط تكلفته وأرباحه.';

  @override
  String get helpPortfolioStep3Title => 'أضف عملية شراء';

  @override
  String get helpPortfolioStep3Body => 'افتح أصلًا، ثم اضغط على +.';

  @override
  String get helpPortfolioStep4Title => 'غيّر العملة';

  @override
  String get helpPortfolioStep4Body =>
      'تُحسب الإجماليات بعملتك الأساسية، المحددة في الإعدادات.';

  @override
  String get helpPortfolioStep5Title => 'أخفِ المبالغ';

  @override
  String get helpPortfolioStep5Body =>
      'فعّل إخفاء الأرصدة في الإعدادات لإخفاء كل القيم.';

  @override
  String get helpLotEditorTitle => 'محرر الدفعة';

  @override
  String get helpLotEditorSummary =>
      'سجّل عملية شراء واحدة ليتمكن Qima من حساب ما تملكه ومتوسط تكلفتك وأرباحك.';

  @override
  String get helpLotEditorStep1Title => 'الكمية والوحدة';

  @override
  String get helpLotEditorStep1Body =>
      'أدخل الكمية التي اشتريتها، بالأونصة التروي أو الجرام أو الكيلوغرام.';

  @override
  String get helpLotEditorStep2Title => 'العيار';

  @override
  String get helpLotEditorStep2Body =>
      'للذهب بالجرام أو الكيلوغرام، اختر عيار 24 أو 22 أو 21 أو 18. يبدأ عند عيار البطاقة.';

  @override
  String get helpLotEditorStep3Title => 'ما دفعته';

  @override
  String get helpLotEditorStep3Body =>
      'أدخل التكلفة لكل وحدة أو التكلفة الإجمالية، بالعملة التي دفعت بها.';

  @override
  String get helpLotEditorStep4Title => 'التاريخ';

  @override
  String get helpLotEditorStep4Body => 'يوم الشراء.';

  @override
  String get helpLotEditorStep5Title => 'احفظ';

  @override
  String get helpLotEditorStep5Body =>
      'يمكنك تعديل الدفعة أو حذفها في أي وقت من الممتلكات.';

  @override
  String get helpAddAssetTitle => 'إضافة أصل';

  @override
  String get helpAddAssetSummary =>
      'ابحث عن شيء لمتابعته وأضفه إلى قائمة متابعتك.';

  @override
  String get helpAddAssetStep1Title => 'ابحث';

  @override
  String get helpAddAssetStep1Body =>
      'اكتب اسمًا أو رمزًا، مثل الذهب أو BTC أو AAPL.';

  @override
  String get helpAddAssetStep2Title => 'اختر نتيجة';

  @override
  String get helpAddAssetStep2Body =>
      'تتم إضافته إلى قائمة متابعتك وتُفتح صفحته.';

  @override
  String get helpAddAssetStep3Title => 'غير موجود في القائمة؟';

  @override
  String get helpAddAssetStep3Body =>
      'أضف الرمز كتيكر مخصص. يتحقق Qima منه أولاً مع مزود الأسعار.';

  @override
  String get helpAddAssetStep4Title => 'غيّرت رأيك؟';

  @override
  String get helpAddAssetStep4Body =>
      'اضغط على تراجع في رسالة التأكيد أسفل الشاشة.';

  @override
  String get helpPriceAlertsTitle => 'تنبيهات الأسعار';

  @override
  String get helpPriceAlertsSummary => 'كل تنبيه ضبطته، مصنّف حسب الأصل.';

  @override
  String get helpPriceAlertsStep1Title => 'تنبيه جديد';

  @override
  String get helpPriceAlertsStep1Body =>
      'اضغط على +، أو افتح أصلًا واضغط على الجرس.';

  @override
  String get helpPriceAlertsStep2Title => 'إيقاف مؤقت أو استئناف';

  @override
  String get helpPriceAlertsStep2Body =>
      'استخدم المفتاح. تُطفئ التنبيهات لمرة واحدة نفسها بعد تفعيلها.';

  @override
  String get helpPriceAlertsStep3Title => 'تغيير أو حذف';

  @override
  String get helpPriceAlertsStep3Body => 'اضغط على تنبيه لتعديله أو حذفه.';

  @override
  String get helpPriceAlertsStep4Title => 'وقت وصول التنبيهات';

  @override
  String get helpPriceAlertsStep4Body =>
      'تُفحص الأسعار كل 15 دقيقة تقريبًا في الخلفية، لذا قد يصل التنبيه متأخرًا بضع دقائق.';

  @override
  String get helpPriceAlertsStep5Title => 'لا تصلك إشعارات؟';

  @override
  String get helpPriceAlertsStep5Body =>
      'اسمح بالإشعارات لتطبيق Qima من إعدادات النظام، وإلا فلن تصلك التنبيهات.';

  @override
  String get helpAlertEditorTitle => 'محرر التنبيه';

  @override
  String get helpAlertEditorSummary =>
      'اختر متى يجب أن يُعلمك Qima بشأن هذا الأصل.';

  @override
  String get helpAlertEditorStep1Title => 'السعر';

  @override
  String get helpAlertEditorStep1Body =>
      'أعلمني عندما يتجاوز السعر هدفك أو ينخفض عنه.';

  @override
  String get helpAlertEditorStep2Title => 'نسبة التحرك';

  @override
  String get helpAlertEditorStep2Body =>
      'أعلمني عند تحركه صعودًا أو هبوطًا أو بأي اتجاه بنسبة 1-10% خلال 24 ساعة أو 7 أيام.';

  @override
  String get helpAlertEditorStep3Title => 'تحقق من المُشغّل';

  @override
  String get helpAlertEditorStep3Body =>
      'يعرض السطر أسفل اختيارك الأسعار التي ستُفعّل التنبيه بالضبط.';

  @override
  String get helpAlertEditorStep4Title => 'التكرار';

  @override
  String get helpAlertEditorStep4Body =>
      'إيقاف: يُفعّل التنبيه مرة واحدة ثم يُطفأ. تشغيل: يُفعّل في كل مرة.';

  @override
  String get helpSettingsTitle => 'الإعدادات';

  @override
  String get helpSettingsSummary => 'خيارات تنطبق على التطبيق بأكمله.';

  @override
  String get helpSettingsStep1Title => 'المظهر';

  @override
  String get helpSettingsStep1Body => 'النظام أو الفاتح أو الداكن.';

  @override
  String get helpSettingsStep2Title => 'الخصوصية والأمان';

  @override
  String get helpSettingsStep2Body =>
      'إخفِ الأرصدة، واقفل Qima بمعرّف الوجه أو بصمة الإصبع.';

  @override
  String get helpSettingsStep3Title => 'التنبيهات';

  @override
  String get helpSettingsStep3Body =>
      'اطّلع على كل تنبيهات الأسعار وتحقق من السماح بالإشعارات.';

  @override
  String get helpSettingsStep4Title => 'النسخ الاحتياطي';

  @override
  String get helpSettingsStep4Body => 'احفظ كل شيء في ملف واستعده لاحقًا.';

  @override
  String get helpSettingsStep5Title => 'الإعدادات الافتراضية';

  @override
  String get helpSettingsStep5Body =>
      'العملة الأساسية ومدى المخطط وتحديث الودجت واللغة.';

  @override
  String get helpBackupTitle => 'النسخ الاحتياطي والاستعادة';

  @override
  String get helpBackupSummary =>
      'لا يملك Qima حسابًا، لذا ملف النسخ الاحتياطي هو طريقتك للحفاظ على بياناتك إذا فُقد هذا الهاتف أو أُعيد ضبطه.';

  @override
  String get helpBackupStep1Title => 'نسخة احتياطية كاملة';

  @override
  String get helpBackupStep1Body =>
      'يحفظ قائمة متابعتك وممتلكاتك والتيكرات المخصصة وإعداداتك كملف ‎.json.';

  @override
  String get helpBackupStep2Title => 'أضف كلمة مرور';

  @override
  String get helpBackupStep2Body =>
      'اختياري. ستحتاجه للاستعادة، ولا يمكن استرجاعه.';

  @override
  String get helpBackupStep3Title => 'احفظ أو شارك';

  @override
  String get helpBackupStep3Body =>
      'احتفظ بالملف في تطبيق الملفات أو iCloud Drive، أو أرسله لنفسك.';

  @override
  String get helpBackupStep4Title => 'استعادة';

  @override
  String get helpBackupStep4Body =>
      'استورد نسخة احتياطية بصيغة ‎.json. يضيف الدمج ما ينقص ولا يحذف شيئًا؛ ويستبدل الاستبدال كل شيء بمحتوى الملف.';

  @override
  String get helpBackupStep5Title => 'جدول بيانات الممتلكات';

  @override
  String get helpBackupStep5Body => 'ملف ‎.csv للمحاسبة. لا يمكن استعادته.';

  @override
  String get helpWidgetsTitle => 'الودجت';

  @override
  String get helpWidgetsSummary =>
      'أضف الأسعار المباشرة ومحفظتك إلى الشاشة الرئيسية وشاشة القفل.';

  @override
  String get helpWidgetsStep1Title => 'المس مع الاستمرار على الشاشة الرئيسية';

  @override
  String get helpWidgetsStep1Body =>
      'عندما تهتز التطبيقات، اضغط على تعديل، ثم أضف ودجت.';

  @override
  String get helpWidgetsStep2Title => 'ابحث عن Qima';

  @override
  String get helpWidgetsStep2Body =>
      'ابحث عن Qima، واختر السعر أو المحفظة، وحدد حجمًا، ثم اضغط على أضف ودجت.';

  @override
  String get helpWidgetsStep3Title => 'اختر ما يعرضه';

  @override
  String get helpWidgetsStep3Body =>
      'المس مع الاستمرار على الودجت، واضغط على تعديل الودجت، ثم اختر الأصل والوحدة والعيار والعملة ومدى المخطط.';

  @override
  String get helpWidgetsStep4Title => 'شاشة القفل';

  @override
  String get helpWidgetsStep4Body =>
      'المس مع الاستمرار على شاشة القفل، واضغط على تخصيص، ثم أضف ودجت Qima.';

  @override
  String get helpWidgetsNote =>
      'تتحدث الودجت كل 15 دقيقة افتراضيًا. غيّر ذلك من الإعدادات ضمن فاصل تحديث الودجت.';

  @override
  String get helpHoldingsTitle => 'الممتلكات';

  @override
  String get helpHoldingsSummary => 'كل دفعة اشتريتها من هذا الأصل، ومجموعها.';

  @override
  String get helpHoldingsStep1Title => 'اقرأ الإجماليات';

  @override
  String get helpHoldingsStep1Body =>
      'الكمية ومتوسط التكلفة والقيمة الحالية والأرباح عبر كل الدفعات.';

  @override
  String get helpHoldingsStep2Title => 'أضف دفعة';

  @override
  String get helpHoldingsStep2Body => 'اضغط على + لتسجيل عملية شراء أخرى.';

  @override
  String get helpHoldingsStep3Title => 'عدّل دفعة أو احذفها';

  @override
  String get helpHoldingsStep3Body => 'اضغط على دفعة لتعديلها، أو مرر لحذفها.';

  @override
  String get helpCardConfigTitle => 'إعدادات الأصل';

  @override
  String get helpCardConfigSummary =>
      'اختر العملة والوحدة والعيار التي ستعرضها هذه البطاقة قبل إضافتها.';

  @override
  String get helpCardConfigStep1Title => 'العملة';

  @override
  String get helpCardConfigStep1Body =>
      'تُعرض الأسعار بهذه العملة على البطاقة ومخططها.';

  @override
  String get helpCardConfigStep2Title => 'الوحدة';

  @override
  String get helpCardConfigStep2Body =>
      'بالنسبة للمعادن، اختر الأونصة التروي أو الجرام أو الكيلوغرام.';

  @override
  String get helpCardConfigStep3Title => 'العيار';

  @override
  String get helpCardConfigStep3Body =>
      'بالنسبة للذهب بالوزن، اختر النقاء الذي تريد تسعيره.';

  @override
  String get helpCardConfigStep4Title => 'أضفه';

  @override
  String get helpCardConfigStep4Body =>
      'يمكنك تغيير أي من هذه الخيارات لاحقًا من شاشة تفاصيل الأصل.';

  @override
  String get helpCustomTickerTitle => 'تيكر مخصص';

  @override
  String get helpCustomTickerSummary =>
      'تابع سهمًا أو صندوق مؤشرات أو مؤشرًا غير موجود في كتالوج Qima عبر رمزه.';

  @override
  String get helpCustomTickerStep1Title => 'أدخل الرمز';

  @override
  String get helpCustomTickerStep1Body =>
      'اكتب رمز التيكر بالضبط، مثل TSLA أو VOO.';

  @override
  String get helpCustomTickerStep2Title => 'يتحقق منه Qima';

  @override
  String get helpCustomTickerStep2Body =>
      'يُتحقق منه أولاً مع مزود الأسعار، فيُكتشف أي خطأ إملائي قبل إضافته.';

  @override
  String get helpCustomTickerStep3Title => 'أضفه';

  @override
  String get helpCustomTickerStep3Body =>
      'يُضاف إلى قائمة متابعتك باسمه وسعره الحقيقيين.';

  @override
  String get helpCurrencyPickerTitle => 'منتقي العملة';

  @override
  String get helpCurrencyPickerSummary =>
      'اختر العملة التي ستُعرض بها الأسعار والإجماليات.';

  @override
  String get helpCurrencyPickerStep1Title => 'ابحث';

  @override
  String get helpCurrencyPickerStep1Body =>
      'اكتب رمز ISO أو اسم العملة، مثل EUR أو درهم.';

  @override
  String get helpCurrencyPickerStep2Title => 'اختر واحدة';

  @override
  String get helpCurrencyPickerStep2Body => 'اضغط على عملة لاستخدامها فورًا.';

  @override
  String get helpImportPreviewTitle => 'معاينة الاستعادة';

  @override
  String get helpImportPreviewSummary =>
      'اطّلع على محتوى ملف النسخة الاحتياطية قبل أن يغيّر أي شيء على هذا الهاتف.';

  @override
  String get helpImportPreviewStep1Title => 'تحقق من المحتوى';

  @override
  String get helpImportPreviewStep1Body =>
      'اطّلع على عدد البطاقات والدفعات والتنبيهات في الملف قبل الاستعادة.';

  @override
  String get helpImportPreviewStep2Title => 'دمج أو استبدال';

  @override
  String get helpImportPreviewStep2Body =>
      'يضيف الدمج ما ينقص ولا يحذف شيئًا. يستبدل الاستبدال كل شيء بمحتوى الملف.';

  @override
  String get helpImportPreviewStep3Title => 'تأكيد';

  @override
  String get helpImportPreviewStep3Body =>
      'يطلب الملف المحمي بكلمة مرور كلمة المرور أولاً.';

  @override
  String get settingsHelpGroup => 'المساعدة';

  @override
  String get settingsHelpReplayTour => 'إعادة عرض الجولة';

  @override
  String get settingsHelpReplayTourSubtitle =>
      'شاهد المقدمة المكونة من خمس خطوات مرة أخرى';

  @override
  String get settingsHelpHowQimaWorks => 'كيف يعمل Qima';

  @override
  String get settingsHelpHowQimaWorksSubtitle => 'دليل مختصر لكل صفحة';

  @override
  String get settingsHelpAddWidget => 'أضف ودجت';

  @override
  String get settingsHelpAddWidgetSubtitle => 'الشاشة الرئيسية وشاشة القفل';
}
