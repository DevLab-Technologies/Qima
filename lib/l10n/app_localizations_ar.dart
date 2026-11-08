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
  String get watchlistAdd => 'أضف إلى قائمة المتابعة';

  @override
  String get watchlistEmptyTitle => 'قائمة المتابعة فارغة';

  @override
  String get watchlistEmptyMessage =>
      'أضف معادن أو عملات رقمية أو أسهمًا أو عملات لبدء تتبع الأسعار.';

  @override
  String get watchlistFilterAll => 'الكل';

  @override
  String get addTitle => 'أضف إلى قائمة المتابعة';

  @override
  String get addSearchHint => 'ابحث، أو صِف عملية شراء';

  @override
  String get addWatchSearchHint => 'ابحث عن الذهب أو بيتكوين أو AAPL…';

  @override
  String addSearchCustomTickerTitle(String query) {
    return 'إضافة ”$query“ كرمز مخصص';
  }

  @override
  String addSearchMatchedAlias(String alias) {
    return 'أو «$alias»';
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
  String get holdingsEmpty =>
      'لا توجد معاملات بعد. أضف عملية شراء لتبدأ تتبّع هذه الحيازة.';

  @override
  String get holdingsValue => 'القيمة';

  @override
  String get holdingsCost => 'التكلفة';

  @override
  String get holdingsGain => 'الربح';

  @override
  String get holdingsGainPercent => 'نسبة الربح';

  @override
  String get holdingsQuantity => 'الكمية';

  @override
  String get holdingsCostModePerUnit => 'لكل وحدة';

  @override
  String get holdingsCostModeTotal => 'الإجمالي';

  @override
  String get holdingsTotalCost => 'التكلفة الإجمالية';

  @override
  String get holdingsDate => 'التاريخ';

  @override
  String get holdingsSave => 'حفظ';

  @override
  String get holdingsTotalHeld => 'إجمالي المملوك';

  @override
  String get holdingsAverageCost => 'متوسط التكلفة';

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
      'لا توجد قيمة للمحفظة بعد — أضف عملية شراء لأي أصل للبدء.';

  @override
  String get portfolioNoChange => 'لا يوجد سجل كافٍ لهذه الفترة بعد';

  @override
  String get portfolioNoHistory => 'أضف عملية شراء لعرض الرسم البياني لمحفظتك';

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
  String get settingsLanguage => 'اللغة';

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
      'إخفاء مبالغ المحفظة والممتلكات والمعاملات في جميع أنحاء التطبيق.';

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
  String get karatShort24 => '24 قيراط';

  @override
  String get karatShort22 => '22 قيراط';

  @override
  String get karatShort21 => '21 قيراط';

  @override
  String get karatShort18 => '18 قيراط';

  @override
  String get range1D => 'يوم';

  @override
  String get range3D => '3 أيام';

  @override
  String get range7D => '7 أيام';

  @override
  String get range1W => 'أسبوع';

  @override
  String get range1M => 'شهر';

  @override
  String get range3M => '3 أشهر';

  @override
  String get range6M => '6 أشهر';

  @override
  String get rangeYtd => 'منذ بداية العام';

  @override
  String get range1Y => 'سنة';

  @override
  String get range5Y => '5 سنوات';

  @override
  String get rangeAll => 'الكل';

  @override
  String get refresh15m => '15 دقيقة';

  @override
  String get refresh30m => '30 دقيقة';

  @override
  String get refresh1h => 'ساعة واحدة';

  @override
  String get refresh3h => '3 ساعات';

  @override
  String get refresh6h => '6 ساعات';

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
  String get alertWindowWithin24h => 'خلال 24 ساعة';

  @override
  String get alertWindowWithin7d => 'خلال 7 أيام';

  @override
  String get alertWindow24h => '24 ساعة';

  @override
  String get alertWindow7d => '7 أيام';

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
  String settingsBackupSubtitle(
    String date,
    int instruments,
    int transactions,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      transactions,
      locale: localeName,
      other: '$transactions معاملة',
      many: '$transactions معاملة',
      few: '$transactions معاملات',
      two: 'معاملتان',
      one: 'معاملة واحدة',
    );
    return 'آخر نسخة احتياطية $date · $instruments أصل، $_temp0';
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
  String get backupExportCsvSubtitle =>
      'كل المعاملات في جدول بيانات (‎.csv)، ويمكن استيراده مجددًا';

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
    int transactions,
    int customTickers,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      transactions,
      locale: localeName,
      other: '$transactions معاملة',
      many: '$transactions معاملة',
      few: '$transactions معاملات',
      two: 'معاملتان',
      one: 'معاملة واحدة',
    );
    return '$cards بطاقة متابعة · $_temp0 · $customTickers رمز مخصص';
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
      'هذا جدول بيانات وليس نسخة احتياطية من Qima. يمكنك استيراد صفوفه كمعاملات بدلًا من ذلك.';

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
  String get backupCsvHeaderUnitCost => 'السعر للوحدة';

  @override
  String get backupCsvHeaderCostCurrency => 'العملة';

  @override
  String get backupCsvHeaderTotalCost => 'الإجمالي';

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
      'الذهب والفضة والعملات الرقمية والأسهم والمؤشرات والعملات، مجموعة بعملتك، مع ملخص واضح لكل شهر.';

  @override
  String get onboardingStep2Title => 'الأسعار بالطريقة التي تشتري بها';

  @override
  String get onboardingStep2Body =>
      'أسعار مباشرة بالجرام أو الأونصة أو الكيلوجرام، من عيار 24 إلى 18، بأي عملة. اضغط + لتضيف إلى قائمة المتابعة، واضغط أي بطاقة لترى رسمها البياني.';

  @override
  String get onboardingStep3Title => 'اعرف ما تملكه';

  @override
  String get onboardingStep3Body =>
      'اضغط +، ثم «أضف حيازة»، واكتب ما اشتريته، أو قُله أو امسح إيصالًا. يُقرأ على هذا الجهاز ولا يُحفظ إلا حين تؤكد. اعرف ما تملكه ومتوسط تكلفتك وقيمته وربحك.';

  @override
  String get onboardingStep4Title => 'لا تفوّت أي تحرك';

  @override
  String get onboardingStep4Body =>
      'احصل على إشعار عند تجاوز السعر لمستوى معيّن أو تحرّكه بنسبة مئوية. أضف الأسعار إلى الشاشة الرئيسية وشاشة القفل.';

  @override
  String get onboardingStep4BodyApple =>
      'تلقَّ تنبيهًا حين يتجاوز السعر مستوى معينًا أو يتحرك بنسبة ما. ضع الأسعار على الشاشة الرئيسية وشاشة القفل، أو اسأل Siri عن قيمة محفظتك.';

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
  String get helpHomeSummary =>
      'صافي ثروتك: كل ما تملكه ناقص كل ما عليك، مع البطاقات التي تستخدمها أكثر.';

  @override
  String get helpHomeStep1Title => 'صافي الثروة';

  @override
  String get helpHomeStep1Body =>
      'اضغط عليه لفتح الميزانية: ما تملكه وما عليك، بندًا بندًا.';

  @override
  String get helpHomeStep2Title => 'بطاقاتك';

  @override
  String get helpHomeStep2Body =>
      'تظهر الحسابات والمتبقي للإنفاق و«قادم» وغيرها عندما تستخدمها. اضغط على بطاقة لفتحها.';

  @override
  String get helpHomeStep3Title => 'تعديل الرئيسية';

  @override
  String get helpHomeStep3Body =>
      'حرّك البطاقات أو أخفِ ما لا تحتاجه. لا تعيد قيمة أي بطاقة أخفيتها.';

  @override
  String get helpHomeStep4Title => 'إخفاء الأرصدة';

  @override
  String get helpHomeStep4Body =>
      'اضغط على العين لإخفاء كل المبالغ عندما يكون أحد ينظر.';

  @override
  String get helpHomeStep5Title => 'أضف أي شيء';

  @override
  String get helpHomeStep5Body =>
      'اضغط + لإضافة معاملة أو كشف حساب أو استثمار، أو أي شيء تحت المزيد.';

  @override
  String get helpMoneySummary => 'أين ذهب مال هذا الشهر، وما دخل وما خرج.';

  @override
  String get helpMoneyStep1Title => 'اختر شهرًا';

  @override
  String get helpMoneyStep1Body => 'استخدم الأسهم في الأعلى لعرض شهر آخر.';

  @override
  String get helpMoneyStep2Title => 'المصروف والوتيرة';

  @override
  String get helpMoneyStep2Body =>
      'ما صرفته حتى الآن، وأين ستصل بنهاية الشهر بهذه الوتيرة.';

  @override
  String get helpMoneyStep3Title => 'أين ذهب المال';

  @override
  String get helpMoneyStep3Body => 'المصروفات حسب الفئة، الأكبر أولًا.';

  @override
  String get helpMoneyStep4Title => 'التدفق النقدي';

  @override
  String get helpMoneyStep4Body =>
      'المال الداخل والخارج وما تبقّى. التحويل بين حساباتك لا يُحتسب.';

  @override
  String get helpMoneyStep5Title => 'يستحق النظر';

  @override
  String get helpMoneyStep5Body =>
      'ملاحظات عن الميزانيات والمعاملات التي تحتاج فئة، عندما يكون هناك ما يستحق.';

  @override
  String get helpNewTransactionSummary =>
      'سجّل مالًا صرفته أو كسبته أو نقلته بين حساباتك.';

  @override
  String get helpNewTransactionStep1Title => 'اختر النوع';

  @override
  String get helpNewTransactionStep1Body =>
      'مصروف أو دخل أو تحويل. يبقى المبلغ والتاريخ عند التبديل.';

  @override
  String get helpNewTransactionStep2Title => 'قلها';

  @override
  String get helpNewTransactionStep2Body =>
      'اضغط على الميكروفون وقل مثلًا «دفعت 45 في بنده بالفيزا أمس». تملأ قيمة النموذج على هذا الجهاز؛ راجعه ثم اضغط حفظ.';

  @override
  String get helpNewTransactionStep3Title => 'الفئة';

  @override
  String get helpNewTransactionStep3Body =>
      'يُصنَّف المصروف والدخل في فئة. النقل بين حساباتك لا يُعدّ مصروفًا أبدًا.';

  @override
  String get helpNewTransactionStep4Title => 'مرفوضة';

  @override
  String get helpNewTransactionStep4Body =>
      'فعّل «مرفوضة» لمعاملة دفع لم تتم: تظهر مشطوبة ولا تُحتسب أبدًا.';

  @override
  String get helpTransactionsSummary =>
      'كل المعاملات، الأحدث أولًا، وما فعلته كل واحدة بحساباتك.';

  @override
  String get helpTransactionsStep1Title => 'افتح واحدة';

  @override
  String get helpTransactionsStep1Body =>
      'اضغط على معاملة لترى كل حساب تأثر بها وبكم.';

  @override
  String get helpTransactionsStep2Title => 'كيف تُحتسب';

  @override
  String get helpTransactionsStep2Body =>
      'توضّح كل معاملة إن كانت مصروفًا أو دخلًا أو نقلًا بين حساباتك أو تغيّرًا في القيمة.';

  @override
  String get helpTransactionsStep3Title => 'عدّل أو احذف';

  @override
  String get helpTransactionsStep3Body =>
      'افتحها ثم عدّلها أو احذفها. الحذف يعيد كل حساب كما كان.';

  @override
  String get helpAccountsSummary =>
      'الحسابات البنكية والنقد والبطاقات والقروض، مع رصيد كل منها اليوم.';

  @override
  String get helpAccountsStep1Title => 'أضف حسابًا';

  @override
  String get helpAccountsStep1Body =>
      'أعطه اسمًا ونوعًا ورصيده اليوم. تبدأ قيمة من هذا الرقم.';

  @override
  String get helpAccountsStep2Title => 'مطابقة الرصيد';

  @override
  String get helpAccountsStep2Body =>
      'افتح الحساب وأدخل ما يظهره بنكك. عند وجود فرق اختر: أضف معاملة به، أو عدّل الرصيد الافتتاحي فلا يُحسب إنفاقًا.';

  @override
  String get helpAccountsStep3Title => 'جرد النقد';

  @override
  String get helpAccountsStep3Body =>
      'للنقد، عُدّ ما في محفظتك وتضبط قيمة الرصيد عليه.';

  @override
  String get helpAccountsStep4Title => 'سدّد بطاقة أو قرضًا';

  @override
  String get helpAccountsStep4Body =>
      'افتح البطاقة أو القرض واضغط سداد لتسجيل دفعة من حساب آخر.';

  @override
  String get helpAccountsStep5Title => 'احذف حسابًا';

  @override
  String get helpAccountsStep5Body =>
      'الحساب الذي فيه معاملات يُؤرشف ليبقى سجله صحيحًا، والحساب غير المستخدم يُحذف.';

  @override
  String get helpBalanceSheetSummary =>
      'كل ما تملكه وكل ما عليك، وصولًا إلى صافي ثروتك.';

  @override
  String get helpBalanceSheetStep1Title => 'ما تملكه';

  @override
  String get helpBalanceSheetStep1Body =>
      'الحسابات، والاستثمارات بالأسعار الحية، والأصول بالقيمة التي تحددها.';

  @override
  String get helpBalanceSheetStep2Title => 'ما عليك';

  @override
  String get helpBalanceSheetStep2Body =>
      'البطاقات، والقروض (أصل الدين فقط)، والمال الذي تدين به للناس.';

  @override
  String get helpBalanceSheetStep3Title => 'كيف يُحسب الإجمالي';

  @override
  String get helpBalanceSheetStep3Body =>
      'افتحه لترى كل قاعدة، مثل السعر الحي المستخدم للعملات الأخرى.';

  @override
  String get helpBalanceSheetStep4Title => 'استبعد بندًا';

  @override
  String get helpBalanceSheetStep4Body =>
      'أوقف «احتسابه في صافي الثروة» لحساب أو أصل؛ ويبقى سجله صحيحًا.';

  @override
  String get helpAssetsSummary =>
      'منزل أو أرض أو سيارة أو حصة في شركة، بالقيمة التي تحددها.';

  @override
  String get helpAssetsStep1Title => 'أضف أصلًا';

  @override
  String get helpAssetsStep1Body =>
      'اختر النوع ثم أعطه قيمة وتاريخًا. الذهب والفضة بالوزن يُضافان كاستثمارات.';

  @override
  String get helpAssetsStep2Title => 'حدّث القيمة';

  @override
  String get helpAssetsStep2Body =>
      'لكل تحديث تاريخ. الأحدث هو المحتسب، والقيم الأقدم تبقى سجلًا.';

  @override
  String get helpAssetsStep3Title => 'قرض عليه';

  @override
  String get helpAssetsStep3Body =>
      'اربط القرض المضمون به لترى المتبقي بجانب قيمته.';

  @override
  String get helpAssetsStep4Title => 'تم البيع';

  @override
  String get helpAssetsStep4Body =>
      'سجّل البيع: يدخل المال في حساب ويخرج الأصل من ميزانيتك.';

  @override
  String get helpImportStatementSummary =>
      'أدخل المعاملات من ملف PDF أو Excel أو CSV من بنكك، أو لقطات شاشة، أو ملف منسوخ.';

  @override
  String get helpImportStatementStep1Title => 'اختر الملفات';

  @override
  String get helpImportStatementStep1Body =>
      'من الملفات أو الصور أو الحافظة، أو مشاركة › قيمة من أي تطبيق. تُقرأ على هذا الجهاز.';

  @override
  String get helpImportStatementStep2Title => 'راجع كل سطر';

  @override
  String get helpImportStatementStep2Body =>
      'اختر الحساب، وألغِ تحديد ما لا تريده، وصحّح أي فئة. الأسطر الموجودة في قيمة تبدأ غير محددة.';

  @override
  String get helpImportStatementStep3Title => 'طابق الرصيد';

  @override
  String get helpImportStatementStep3Body =>
      'عندما يُظهر الكشف رصيدًا، حدّد «اجعل الرصيد». ثم اختر: عدّل الرصيد الافتتاحي، أو أضف معاملة بالفرق.';

  @override
  String get helpImportStatementStep4Title => 'أضفها';

  @override
  String get helpImportStatementStep4Body =>
      'اضغط إضافة. تُحذف الملفات بعد الاستيراد.';

  @override
  String get helpBankMessagesSummary =>
      'أضف المشتريات من الرسائل التي يرسلها بنكك، بعد مراجعة كل واحدة.';

  @override
  String get helpBankMessagesStep1Title => 'على أندرويد';

  @override
  String get helpBankMessagesStep1Body =>
      'فعّل «قراءة رسائل البنك الجديدة» واسمح بالوصول. أحضر آخر 60 يومًا في المرة الأولى.';

  @override
  String get helpBankMessagesStep2Title => 'على آيفون';

  @override
  String get helpBankMessagesStep2Body =>
      'اضبط أتمتة في الاختصارات مرة واحدة، لتذهب كل رسالة بنك إلى إجراء «Add a bank message» في قيمة.';

  @override
  String get helpBankMessagesStep3Title => 'راجع قبل الإضافة';

  @override
  String get helpBankMessagesStep3Body =>
      'تنتظر الرسائل في مراجعة الاستيراد، وتُتجاهل الرموز والعروض والمكرر.';

  @override
  String get helpBankMessagesStep4Title => 'خاص';

  @override
  String get helpBankMessagesStep4Body =>
      'تُقرأ الرسائل على هذا الجهاز ولا تغادره.';

  @override
  String get helpCategoriesSummary =>
      'صنّف المصروفات في فئات، وعلّم قيمة أين يذهب كل اسم.';

  @override
  String get helpCategoriesStep1Title => 'بانتظار التصنيف';

  @override
  String get helpCategoriesStep1Body =>
      'اختر فئة مرة واحدة لكل اسم، وستستخدمها المعاملات المستوردة منه من الآن.';

  @override
  String get helpCategoriesStep2Title => 'المعاملات السابقة';

  @override
  String get helpCategoriesStep2Body =>
      'تعرض قيمة نقل المعاملات السابقة من الاسم نفسه أيضًا.';

  @override
  String get helpCategoriesStep3Title => 'فئاتك';

  @override
  String get helpCategoriesStep3Body =>
      'أضف الفئات أو أعد تسميتها أو احذفها. المعاملات في فئة محذوفة تحتفظ بها في سجلها.';

  @override
  String get helpCategoriesStep4Title => 'انسَ اسمًا';

  @override
  String get helpCategoriesStep4Body =>
      'انسَ ما تعلّمته قيمة لاسم ما، لتعود معاملاته المستوردة إلى التصنيف اليدوي.';

  @override
  String get helpBudgetSummary => 'مبلغ شهري لكل فئة تريد متابعتها.';

  @override
  String get helpBudgetStep1Title => 'حدّد مبلغًا';

  @override
  String get helpBudgetStep1Body =>
      'اضغط على فئة وأدخل مبلغها الشهري. الصفر يزيلها.';

  @override
  String get helpBudgetStep2Title => 'المتبقي للإنفاق';

  @override
  String get helpBudgetStep2Body =>
      'تعرض الرئيسية المتبقي هذا الشهر، وينبّه المال إلى الفئة التي تجاوزت وتيرتها.';

  @override
  String get helpBudgetStep3Title => 'ما يُحتسب';

  @override
  String get helpBudgetStep3Body =>
      'سداد البطاقات والتحويلات وأصل القروض لا تُحتسب أبدًا.';

  @override
  String get helpRecurringSummary =>
      'الإيجار والفواتير والأقساط والدخل، تظهر في «قادم» قبل موعدها.';

  @override
  String get helpRecurringStep1Title => 'أضف واحدًا';

  @override
  String get helpRecurringStep1Body =>
      'أعطها اسمًا ومبلغًا والحساب وموعدها: مرة واحدة، أو كل أسبوع أو شهر أو ٣ أشهر أو سنة. يمكن أن تنتهي خطة الأقساط بعد عدد من الدفعات.';

  @override
  String get helpRecurringStep2Title => 'قادم';

  @override
  String get helpRecurringStep2Body =>
      'تعرض الرئيسية المستحق قريبًا، الداخل والخارج، ويمكن أن يصلك تذكير قبلها بيوم.';

  @override
  String get helpRecurringStep3Title => 'عدّل أو احذف';

  @override
  String get helpRecurringStep3Body =>
      'اضغط على إحداها لتسجيلها أو تخطيها أو تعديلها أو حذفها.';

  @override
  String get helpPeopleSummary => 'من يدين لك، ولمن تدين، والسداد.';

  @override
  String get helpPeopleStep1Title => 'أقرضت أو اقترضت';

  @override
  String get helpPeopleStep1Body =>
      'اضغط + › المزيد › أقرضت أو اقترضت، واكتب اسم الشخص.';

  @override
  String get helpPeopleStep2Title => 'السداد';

  @override
  String get helpPeopleStep2Body =>
      'سجّل «سداد مستلم» أو «سداد مدفوع» لينخفض المبلغ المستحق.';

  @override
  String get helpPeopleStep3Title => 'تقسيم فاتورة';

  @override
  String get helpPeopleStep3Body =>
      'ادفع الفاتورة كاملة وقسّمها: حصتك فقط مصروف، والباقي دين لك.';

  @override
  String get helpFeaturesSummary =>
      'فعّل أجزاء من قيمة أو أوقفها. تعمل الميزات تلقائيًا أيضًا عند أول استخدام.';

  @override
  String get helpFeaturesStep1Title => 'أوقف ميزة';

  @override
  String get helpFeaturesStep1Body =>
      'تُخفى شاشاتها لا مالك: تبقى مبالغها محتسبة في الميزانية.';

  @override
  String get helpFeaturesStep2Title => 'تعمل عند الاستخدام';

  @override
  String get helpFeaturesStep2Body =>
      'سجّل أول سداد لقرض فتعمل ميزة القروض، مع خيار تراجع إن لم تردها.';

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
  String get helpWatchlistTitle => 'الأسعار';

  @override
  String get helpWatchlistSummary => 'أسعار حية لكل ما تتابعه.';

  @override
  String get helpWatchlistStep1Title => 'افتح بطاقة';

  @override
  String get helpWatchlistStep1Body =>
      'اضغط على أي بطاقة لعرض مخططها وأهم إحصاءاتها وممتلكاتك منها.';

  @override
  String get helpWatchlistStep2Title => 'أضف أصلًا';

  @override
  String get helpWatchlistStep2Body =>
      'اضغط + في الأسفل، ثم «أضف إلى قائمة المتابعة».';

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
      'اضغط على + في بطاقة التنبيهات لتصلك إشعارات عند تجاوز السعر لمستوى أو تحرّكه بنسبة مئوية.';

  @override
  String get helpAssetDetailStep5Title => 'تابع ما تملكه';

  @override
  String get helpAssetDetailStep5Body =>
      'اضغط على المقتنيات لعرض معاملاتك أو إضافة عملية شراء أو بيع.';

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
      'اضغط على صف لعرض معاملاته ومتوسط تكلفته وأرباحه.';

  @override
  String get helpPortfolioStep3Title => 'أضف عملية شراء';

  @override
  String get helpPortfolioStep3Body =>
      'اضغط + في الأسفل، ثم «أضف حيازة». أو افتح أصلًا واضغط المقتنيات.';

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
  String get helpPortfolioStep6Title => 'الشهر الماضي';

  @override
  String get helpPortfolioStep6Body =>
      'ملخص قصير لتحرّك مقتنياتك، محسوب من سجلاتك أنت. يمكنك إيقافه من الإعدادات.';

  @override
  String get helpPortfolioStep7Title => 'اسأل Siri';

  @override
  String get helpPortfolioStep7Body =>
      'اسأل Siri أو استخدم الاختصارات لتعرف قيمة محفظتك أو سعرًا ما دون فتح Qima.';

  @override
  String get helpLotEditorTitle => 'المعاملة';

  @override
  String get helpLotEditorSummary =>
      'سجّل شراء أو بيعًا أو تحويلًا أو رسومًا. تُحسب حيازتك ومتوسط تكلفتك وأرباحك منها.';

  @override
  String get helpLotEditorStep1Title => 'النوع';

  @override
  String get helpLotEditorStep1Body =>
      'الشراء يضيف بتكلفة، والبيع يُنقص ويحقق ربحًا أو خسارة، والتحويل ينقل كمية للداخل أو الخارج، والرسوم تسجّل تكلفة.';

  @override
  String get helpLotEditorStep2Title => 'العيار';

  @override
  String get helpLotEditorStep2Body =>
      'للذهب بالغرام أو الكيلوغرام اختر 24 أو 22 أو 21 أو 18 قيراطًا. يُحتسب كل شيء بمحتوى الذهب، فتختلط الأعيرة بشكل صحيح.';

  @override
  String get helpLotEditorStep3Title => 'السعر والرسوم';

  @override
  String get helpLotEditorStep3Body =>
      'أدخل السعر لكل وحدة أو الإجمالي وأي عمولة. يعرض البيع ما سيحققه قبل الحفظ.';

  @override
  String get helpLotEditorStep4Title => 'التاريخ';

  @override
  String get helpLotEditorStep4Body =>
      'يوم حدوثها. لا يمكن تأريخ بيع قبل أن تملك ما يكفي.';

  @override
  String get helpLotEditorStep5Title => 'احفظ';

  @override
  String get helpLotEditorStep5Body =>
      'عدّل أي معاملة أو احذفها في أي وقت من سجل الحيازة.';

  @override
  String get helpAddAssetTitle => 'أضف إلى المتابعة أو حيازة';

  @override
  String get helpAddAssetSummary =>
      'تابع سعرًا في قائمة المتابعة، أو سجّل شيئًا اشتريته.';

  @override
  String get helpAddAssetStep1Title => 'ابحث';

  @override
  String get helpAddAssetStep1Body =>
      'اضغط +، ثم «أضف إلى قائمة المتابعة». ابحث بالاسم أو الرمز بأي لغة من لغات التطبيق، مثل ذهب أو gold أو BTC.';

  @override
  String get helpAddAssetStep2Title => 'اختر نتيجة';

  @override
  String get helpAddAssetStep2Body =>
      'اختر العملة والوحدة التي يُعرض بها سعره، ثم أضفه إلى قائمة المتابعة.';

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
  String get helpSettingsStep6Title => 'الذكاء على الجهاز';

  @override
  String get helpSettingsStep6Body =>
      'يمكنك أن تسمح لنموذج اللغة في هذا الجهاز بالمساعدة في قراءة المشتريات وصياغة الملخص. يعمل هنا فقط، ولا يقدّم نصيحة، ولا يضع أي رقم.';

  @override
  String get helpBackupTitle => 'النسخ الاحتياطي والاستعادة';

  @override
  String get helpBackupSummary =>
      'لا يملك Qima حسابًا، لذا ملف النسخ الاحتياطي هو طريقتك للحفاظ على بياناتك إذا فُقد هذا الهاتف أو أُعيد ضبطه.';

  @override
  String get helpBackupStep1Title => 'نسخة احتياطية كاملة';

  @override
  String get helpBackupStep1Body =>
      'تحفظ حساباتك ومعاملاتك وأصولك وقائمة المتابعة والاستثمارات والإعدادات في ملف ‎.json.';

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
  String get helpBackupStep5Title => 'جداول البيانات';

  @override
  String get helpBackupStep5Body =>
      'صدّر كل المعاملات كملف ‎.csv أو استورد واحدًا من Qima أو جدول بيانات أو وسيط. الاستيراد يضيف معاملات ولا يستعيد الإعدادات.';

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
  String get helpHoldingsSummary =>
      'كل معاملات هذا الأصل، من شراء وبيع وتحويل ورسوم، وما تصل إليه مجتمعة.';

  @override
  String get helpHoldingsStep1Title => 'اقرأ الإجماليات';

  @override
  String get helpHoldingsStep1Body =>
      'ما تملكه ومتوسط تكلفته وقيمته وربحه، إضافة إلى ما حققته المبيعات.';

  @override
  String get helpHoldingsStep2Title => 'أضف معاملة';

  @override
  String get helpHoldingsStep2Body =>
      'اضغط إضافة لتسجيل شراء أو بيع أو تحويل أو رسوم.';

  @override
  String get helpHoldingsStep3Title => 'عدّل أو احذف';

  @override
  String get helpHoldingsStep3Body =>
      'اضغط صفًا لتعديله أو اسحبه لحذفه. لن يسمح Qima بتغيير يجعل بيعًا يتجاوز ما كنت تملكه.';

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
      'اطّلع على عدد البطاقات والمعاملات والتنبيهات في الملف قبل الاستعادة.';

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

  @override
  String get commonDone => 'تم';

  @override
  String get zakatTitle => 'الزكاة';

  @override
  String get zakatSettingsTitle => 'إعدادات الزكاة';

  @override
  String get settingsZakatSubtitle =>
      'أساس النصاب، وما يُحتسب، وتاريخ الحول، والتذكير';

  @override
  String get zakatEmptyTitle => 'لا شيء لحسابه بعد';

  @override
  String get zakatEmptyMessage =>
      'تُحسب الزكاة من ممتلكاتك. أضف عملية شراء لأي أصل وسيظهر هنا مع ما يُحتسب ضمن النصاب.';

  @override
  String get zakatNisabSection => 'النصاب';

  @override
  String get zakatWhatCountsSection => 'ما يُحتسب';

  @override
  String get zakatStatusAbove => 'فوق النصاب';

  @override
  String get zakatStatusBelow => 'دون النصاب';

  @override
  String get zakatStatusUnknown => 'لم يُسعَّر النصاب بعد';

  @override
  String zakatDueLabel(String rate) {
    return 'الزكاة المستحقة · $rate';
  }

  @override
  String zakatExplainAboveNoHawl(String base) {
    return 'على وعاء زكوي قدره $base. حدّد تاريخ حولك لتعرف موعد وجوبها.';
  }

  @override
  String zakatExplainAboveToday(String base) {
    return 'على وعاء زكوي قدره $base. يكتمل حولك اليوم.';
  }

  @override
  String zakatExplainAboveUpcoming(String base, String date, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'بعد $days يوم',
      many: 'بعد $days يومًا',
      few: 'بعد $days أيام',
      two: 'بعد يومين',
      one: 'بعد يوم واحد',
    );
    return 'على وعاء زكوي قدره $base. تجب عند اكتمال حولك في $date ($_temp0)، إن بقي مالك فوق النصاب حينها.';
  }

  @override
  String zakatExplainBelow(String base, String threshold) {
    return 'وعاؤك الزكوي البالغ $base دون نصاب اليوم البالغ $threshold، فلا زكاة عليك.';
  }

  @override
  String zakatExplainUnknown(String metal) {
    return 'لم يُحمَّل سعر $metal اليوم بعد، لذا لا يمكن التحقق من النصاب الآن.';
  }

  @override
  String get zakatRetry => 'حاول مجددًا';

  @override
  String get zakatUnpricedNote =>
      'بعض الأصول بلا سعر بعد فلم تُحتسب، وستُحتسب فور تحميل سعرها.';

  @override
  String get zakatBasisRow => 'الأساس';

  @override
  String zakatBasisValue(String metal, String grams) {
    return '$metal · $grams غ';
  }

  @override
  String zakatOtherBasisLine(String metal, String amount) {
    return 'أساس $metal سيكون $amount';
  }

  @override
  String get zakatThresholdToday => 'النصاب اليوم';

  @override
  String get zakatYourBase => 'وعاؤك الزكوي';

  @override
  String get zakatHawlStart => 'بداية الحول';

  @override
  String get zakatHawlSet => 'حدّد التاريخ';

  @override
  String get zakatHawlNotSetSubtitle =>
      'اليوم الذي بلغ فيه مالك النصاب أول مرة';

  @override
  String get zakatHawlCompletesToday => 'يكتمل اليوم';

  @override
  String zakatHawlNext(String date) {
    return 'يكتمل التالي في $date';
  }

  @override
  String get zakatWhatCountsFooter =>
      'أوقف أصلًا لاستبعاده، كالحُلي المستعمل يوميًا إن كنت تأخذ بالرأي القائل بإعفائه.';

  @override
  String zakatExcludedClass(String cls) {
    return '$cls غير محتسبة';
  }

  @override
  String get zakatExcludedHolding => 'مستبعد';

  @override
  String get zakatExcludedNoPrice => 'بلا سعر بعد';

  @override
  String zakatLineTitle(String name, String quantity) {
    return '$name · $quantity';
  }

  @override
  String get zakatDisclaimer =>
      'Qima يحسب ولا يُفتي. الأساس وما يُحتسب قرارك أنت، فاسأل عالمًا تثق به عند الشك.';

  @override
  String get assetGroupMetals => 'المعادن';

  @override
  String get assetGroupCrypto => 'العملات المشفرة';

  @override
  String get assetGroupEquities => 'الأسهم';

  @override
  String get assetGroupCash => 'النقد والعملات';

  @override
  String get zakatClassMetalsSubtitle => 'الذهب والفضة والبلاتين والبلاديوم';

  @override
  String get zakatClassCryptoSubtitle => 'تُعامل كأصل قابل للتداول';

  @override
  String get zakatClassEquitiesSubtitle =>
      'غير محتسبة افتراضيًا، فالآراء في الأسهم طويلة الأجل مختلفة';

  @override
  String get zakatClassCashSubtitle => 'العملات التي تملكها';

  @override
  String zakatOverridesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أصل محدد يدويًا',
      many: '$count أصلًا محددًا يدويًا',
      few: '$count أصول محددة يدويًا',
      two: 'أصلان محددان يدويًا',
      one: 'أصل واحد محدد يدويًا',
    );
    return '$_temp0';
  }

  @override
  String get zakatOverridesSubtitle =>
      'اختيرت من شاشة الزكاة وتتجاوز إعداد فئتها';

  @override
  String get zakatOverridesReset => 'إعادة ضبط';

  @override
  String get zakatNisabBasisSection => 'أساس النصاب';

  @override
  String get zakatClassesSection => 'الفئات الزكوية';

  @override
  String get zakatHawlSection => 'الحول';

  @override
  String get zakatBasisPriceMissing => 'لم يُحمَّل السعر بعد';

  @override
  String zakatBasisToday(String amount) {
    return '$amount اليوم';
  }

  @override
  String zakatBasisHigher(String amount) {
    return 'نصاب أعلى · $amount اليوم';
  }

  @override
  String zakatBasisLower(String amount) {
    return 'نصاب أدنى · $amount اليوم · تجب على عدد أكبر';
  }

  @override
  String get zakatCalendar => 'التقويم';

  @override
  String get zakatCalendarHijri => 'هجري';

  @override
  String get zakatCalendarGregorian => 'ميلادي';

  @override
  String get zakatGregorianNote =>
      'تظهر التواريخ بالتقويم الميلادي. يبقى الحول سنة قمرية، لذا يكتمل قبل موعده الميلادي بنحو 11 يومًا كل سنة.';

  @override
  String get zakatHawlClear => 'مسح تاريخ الحول';

  @override
  String get zakatRemind => 'ذكّرني';

  @override
  String get zakatRemindSubtitle => 'إشعار في يوم اكتمال حولك';

  @override
  String get zakatRemindNeedsStart => 'حدّد تاريخ بداية الحول أولًا';

  @override
  String get zakatRemindNotificationsOff =>
      'الإشعارات متوقفة لـ Qima، فعّلها من إعدادات النظام لتصلك هذه التذكرة';

  @override
  String get zakatHawlPickerTitle => 'بداية الحول';

  @override
  String get zakatHawlPickerDay => 'اليوم';

  @override
  String get zakatHawlPickerMonth => 'الشهر';

  @override
  String get zakatHawlPickerYear => 'السنة';

  @override
  String get zakatHawlPickerFuture => 'لا يمكن أن يبدأ الحول في المستقبل';

  @override
  String zakatHawlPickerGregorian(String date) {
    return 'بالميلادي: $date';
  }

  @override
  String zakatEntryDue(String amount) {
    return '$amount مستحقة · فوق النصاب';
  }

  @override
  String get zakatEntryCalculate => 'اعرف ما يستحق';

  @override
  String get zakatReminderNotificationTitle => 'اكتمل حولك';

  @override
  String get zakatReminderNotificationBody =>
      'اكتمل عامك الزكوي اليوم. افتح Qima لترى ما يستحق.';

  @override
  String get hijriMonth1 => 'محرم';

  @override
  String get hijriMonth2 => 'صفر';

  @override
  String get hijriMonth3 => 'ربيع الأول';

  @override
  String get hijriMonth4 => 'ربيع الآخر';

  @override
  String get hijriMonth5 => 'جمادى الأولى';

  @override
  String get hijriMonth6 => 'جمادى الآخرة';

  @override
  String get hijriMonth7 => 'رجب';

  @override
  String get hijriMonth8 => 'شعبان';

  @override
  String get hijriMonth9 => 'رمضان';

  @override
  String get hijriMonth10 => 'شوال';

  @override
  String get hijriMonth11 => 'ذو القعدة';

  @override
  String get hijriMonth12 => 'ذو الحجة';

  @override
  String hijriDate(int day, String month, int year) {
    return '$day $month $year هـ';
  }

  @override
  String get helpZakatTitle => 'الزكاة';

  @override
  String get helpZakatSummary =>
      'تحسب قيمة الزكاة مما تملكه بأسعار اليوم. هي تحسب، والاختيارات وراء الحساب لك.';

  @override
  String get helpZakatStep1Title => 'النصاب';

  @override
  String get helpZakatStep1Body =>
      'النصاب 85 غرامًا من الذهب الخالص أو 595 غرامًا من الفضة، بسعر اللحظة. اختر الأساس من إعدادات الزكاة؛ نصاب الفضة أدنى فتجب على عدد أكبر.';

  @override
  String get helpZakatStep2Title => 'ما يُحتسب';

  @override
  String get helpZakatStep2Body =>
      'يُحتسب النقد والمعادن والعملات الرقمية افتراضيًا، والأصول المعدّة للبيع بقيمتها، أما الأسهم فلا. تُخصم أرصدة البطاقات والديون التي عليك للناس. يمكنك استبعاد أي بند.';

  @override
  String get helpZakatStep3Title => 'الحول';

  @override
  String get helpZakatStep3Body =>
      'حدّد اليوم الذي بلغ فيه مالك النصاب أول مرة. تجب الزكاة كل سنة قمرية بعده، ويمكن لـ Qima تذكيرك في يومها.';

  @override
  String get helpZakatStep4Title => 'حاسبة لا فتوى';

  @override
  String get helpZakatStep4Body =>
      'يختلف العلماء في الأساس وفي الأسهم والحُلي. كل خيار افتراضي هنا قابل للتغيير، فاسأل عالمًا تثق به عند الشك.';

  @override
  String get allocationTitle => 'التوزيع';

  @override
  String get allocationDetails => 'التفاصيل';

  @override
  String get allocationByGroup => 'حسب الفئة';

  @override
  String get allocationMetalsByForm => 'المعادن · حسب العيار والنوع';

  @override
  String allocationMetalForm(String metal, String karat) {
    return '$metal $karat';
  }

  @override
  String get allocationDriftTitle => 'التحوّل';

  @override
  String allocationDriftSince(String date) {
    return 'التحوّل · منذ $date';
  }

  @override
  String allocationDriftChange(String from, String to) {
    return '$from ← $to';
  }

  @override
  String get allocationDriftPendingTitle => 'قبل أن يتوفر سجل';

  @override
  String allocationDriftPending(String date) {
    return 'يظهر تحوّل توزيعك بمرور الوقت عندما يمضي على ممتلكاتك 14 يومًا، في $date. حتى ذلك الحين هذا هو توزيع اليوم، دون اختلاق أي اتجاه.';
  }

  @override
  String get allocationDriftNoHistory =>
      'لا توجد أسعار محفوظة كافية بعد لمعرفة توزيعك في ذلك الوقت، وسيكتمل مع تحميل سجل الأسعار.';

  @override
  String allocationSingleGroup(String group) {
    return 'الكل في $group';
  }

  @override
  String get backupImportCountTransactions => 'المعاملات';

  @override
  String portfolioTransactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count معاملة',
      many: '$count معاملة',
      few: '$count معاملات',
      two: 'معاملتان',
      one: 'معاملة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get portfolioClosedPositions => 'مراكز مُغلقة';

  @override
  String ledgerTitleWithKarat(String name, String karat) {
    return '$name · $karat';
  }

  @override
  String get ledgerAdd => 'إضافة';

  @override
  String get ledgerAddFirst => 'أضف معاملة';

  @override
  String get ledgerHolding => 'الحيازة';

  @override
  String get ledgerNothingHeld => 'لا شيء محتفظ به الآن';

  @override
  String ledgerPerUnit(String amount, String unit) {
    return '$amount / $unit';
  }

  @override
  String get ledgerMarketValue => 'القيمة السوقية';

  @override
  String get ledgerUnrealised => 'غير محقق';

  @override
  String get ledgerRealised => 'محقق';

  @override
  String ledgerGainWithPercent(String amount, String percent) {
    return '$amount ($percent)';
  }

  @override
  String ledgerDetail(String date, String detail) {
    return '$date · $detail';
  }

  @override
  String ledgerDetailWithFee(String date, String price, String fee) {
    return '$date · $price · رسوم $fee';
  }

  @override
  String get ledgerNoCostBasis => 'بلا أساس تكلفة';

  @override
  String get ledgerCostCarried => 'بتكلفة منقولة';

  @override
  String get ledgerFootnote =>
      'يُحسب أساس التكلفة من هذا السجل ولا يُخزَّن، وتعديل أي صف يعيد حساب الحيازة.';

  @override
  String get ledgerOverdrawnBanner =>
      'هناك عملية بيع تتجاوز ما كان محتفظًا به في تاريخها، غالبًا بسبب التعديل على جهازين معًا. تُحتسب كبيع ما تبقى؛ عدّلها أو احذفها لتصحيح الإجماليات.';

  @override
  String ledgerClosedLine(String amount) {
    return 'لا شيء محتفظ به الآن · محقق $amount';
  }

  @override
  String get ledgerConflictSaveTitle => 'هذا سيتجاوز الكمية';

  @override
  String get ledgerConflictDeleteTitle => 'لا يمكن الحذف الآن';

  @override
  String ledgerConflictMessage(String kind, String date) {
    return 'عندها ستتجاوز عملية $kind بتاريخ $date ما كان محتفظًا به. عدّلها أو احذفها أولًا.';
  }

  @override
  String get confirmDeleteTransactionTitle => 'حذف هذه المعاملة؟';

  @override
  String confirmDeleteTransactionMessage(String details) {
    return '$details. ستُحسب الحيازة من جديد بدونها، ولا يمكن التراجع عن ذلك.';
  }

  @override
  String get transactionNewTitle => 'معاملة جديدة';

  @override
  String get transactionEditTitle => 'تعديل المعاملة';

  @override
  String get transactionKindBuy => 'شراء';

  @override
  String get transactionKindSell => 'بيع';

  @override
  String get transactionKindTransfer => 'تحويل';

  @override
  String get transactionKindTransferIn => 'تحويل وارد';

  @override
  String get transactionKindTransferOut => 'تحويل صادر';

  @override
  String get transactionKindFee => 'رسوم';

  @override
  String get transactionTransferInLabel => 'وارد';

  @override
  String get transactionTransferOutLabel => 'صادر';

  @override
  String transactionFineHint(String quantity) {
    return '= $quantity من الذهب الخالص';
  }

  @override
  String transactionPerUnitKarat(String unit, String karat) {
    return '$unit · $karat';
  }

  @override
  String transactionBuyPrice(String unit) {
    return 'السعر المدفوع (لكل $unit)';
  }

  @override
  String transactionSalePrice(String unit) {
    return 'سعر البيع (لكل $unit)';
  }

  @override
  String transactionCarriedCost(String unit) {
    return 'التكلفة الأصلية (لكل $unit، اختياري)';
  }

  @override
  String get transactionTotalProceeds => 'إجمالي مبلغ البيع';

  @override
  String get transactionTotalCarriedCost => 'إجمالي التكلفة الأصلية (اختياري)';

  @override
  String get transactionTransferCostHelper =>
      'تكلفتها الأصلية إن كنت تعرفها. إن تُركت فارغة تُضاف بلا أساس تكلفة.';

  @override
  String get transactionFee => 'الرسوم (اختياري)';

  @override
  String get transactionFeeAmount => 'قيمة الرسوم';

  @override
  String get transactionFeeLabel => 'سببها (اختياري)';

  @override
  String get transactionNote => 'ملاحظة (اختياري)';

  @override
  String get transactionNeedsQuantity => 'أدخل الكمية.';

  @override
  String get transactionNeedsPrice => 'أدخل السعر.';

  @override
  String get transactionNeedsFee => 'أدخل قيمة الرسوم.';

  @override
  String transactionMoreThanHeld(String held) {
    return 'هذا أكثر مما كنت تملكه في ذلك التاريخ ($held).';
  }

  @override
  String get transactionPreviewTitle => 'معاينة الربح المحقق';

  @override
  String get transactionProceeds => 'العائد';

  @override
  String get transactionBasisReleased => 'أساس التكلفة المُحرَّر';

  @override
  String get transactionRealisedGain => 'الربح المحقق';

  @override
  String transactionPreviewRemaining(String quantity, String average) {
    return 'على أساس المتوسط المرجّح. المتبقي بعدها: $quantity بمتوسط $average.';
  }

  @override
  String get transactionPreviewClosesPosition =>
      'على أساس المتوسط المرجّح. هذا يبيع كل ما تملكه.';

  @override
  String get backupCsvHeaderType => 'النوع';

  @override
  String get backupCsvHeaderFee => 'الرسوم';

  @override
  String get backupCsvHeaderNote => 'ملاحظة';

  @override
  String get csvImportTitle => 'استيراد من جدول بيانات';

  @override
  String get csvImportEntryTitle => 'استيراد المعاملات من CSV';

  @override
  String get csvImportEntrySubtitle =>
      'من جدول بيانات أو ملف وسيط أو تطبيق آخر';

  @override
  String get csvImportFromBackupError => 'استيرادها كمعاملات';

  @override
  String csvImportRowCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صف',
      many: '$count صفًا',
      few: '$count صفوف',
      two: 'صفان',
      one: 'صف واحد',
    );
    return '$_temp0';
  }

  @override
  String get csvImportEmptyFile =>
      'يحتوي هذا الملف على صف عناوين بلا بيانات تحته.';

  @override
  String get csvImportColumnsSection => 'الأعمدة';

  @override
  String get csvImportColumnsFooter =>
      'طابقها Qima من صف العناوين حيثما أمكن. يكفي السعر أو الإجمالي، ويمكن أن يكون الأصل رمزًا أو اسمًا. * مطلوب.';

  @override
  String get csvImportNotInFile => 'غير موجود في الملف';

  @override
  String get csvImportOptionsSection => 'قراءة الملف';

  @override
  String get csvImportFallbackCurrency => 'العملة';

  @override
  String get csvImportFallbackCurrencySubtitle => 'للصفوف التي لا تذكر عملة';

  @override
  String get csvImportDateOrder => 'التواريخ مثل 03/04/2026 تعني';

  @override
  String get csvImportDayFirst => '3 أبريل';

  @override
  String get csvImportMonthFirst => '4 مارس';

  @override
  String get csvImportDecimalComma => 'الفاصلة هي العلامة العشرية';

  @override
  String get csvImportDecimalCommaSubtitle =>
      'قراءة 1.234,56 على أنها ألف ومئتان…';

  @override
  String get csvImportNeedsColumns => 'اختر على الأقل الأصل والتاريخ والكمية.';

  @override
  String get csvImportReview => 'مراجعة الصفوف';

  @override
  String get csvImportReadyCount => 'جاهزة';

  @override
  String get csvImportDuplicateCount => 'موجودة في Qima';

  @override
  String get csvImportProblemCount => 'لا يمكن استيرادها';

  @override
  String get csvImportSkipNote =>
      'تُتخطى الصفوف غير المقروءة أو الموجودة مسبقًا في Qima، ولا يُخمَّن شيء.';

  @override
  String get csvImportShowAll => 'كل الصفوف';

  @override
  String get csvImportShowProblems => 'المتخطاة فقط';

  @override
  String get csvImportSkipped => 'متخطاة';

  @override
  String get csvImportDuplicate => 'مكررة';

  @override
  String get csvImportBackToColumns => 'الأعمدة';

  @override
  String csvImportConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'استيراد $count معاملة',
      many: 'استيراد $count معاملة',
      few: 'استيراد $count معاملات',
      two: 'استيراد معاملتين',
      one: 'استيراد معاملة واحدة',
      zero: 'لا شيء للاستيراد',
    );
    return '$_temp0';
  }

  @override
  String csvImportDoneTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم استيراد $count معاملة',
      many: 'تم استيراد $count معاملة',
      few: 'تم استيراد $count معاملات',
      two: 'تم استيراد معاملتين',
      one: 'تم استيراد معاملة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get csvImportDoneMessage =>
      'أصبحت في سجل كل أصل. إن بدا شيء غير صحيح فالتراجع يزيل ما أضافه هذا الاستيراد فقط.';

  @override
  String get csvImportUndo => 'التراجع عن هذا الاستيراد';

  @override
  String csvImportUndone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أُزيلت $count معاملة مستوردة',
      many: 'أُزيلت $count معاملة مستوردة',
      few: 'أُزيلت $count معاملات مستوردة',
      two: 'أُزيلت معاملتان مستوردتان',
      one: 'أُزيلت معاملة مستوردة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get csvFieldType => 'النوع';

  @override
  String get csvFieldAsset => 'اسم الأصل';

  @override
  String get csvFieldSymbol => 'الرمز';

  @override
  String get csvFieldQuantity => 'الكمية';

  @override
  String get csvFieldUnit => 'الوحدة';

  @override
  String get csvFieldKarat => 'العيار';

  @override
  String get csvFieldUnitPrice => 'السعر للوحدة';

  @override
  String get csvFieldTotal => 'الإجمالي';

  @override
  String get csvFieldFee => 'الرسوم';

  @override
  String get csvFieldCurrency => 'العملة';

  @override
  String get csvFieldDate => 'التاريخ';

  @override
  String get csvFieldNote => 'ملاحظة';

  @override
  String get csvProblemUnknownAsset => 'أصل غير معروف';

  @override
  String get csvProblemMissingQuantity => 'بلا كمية';

  @override
  String get csvProblemBadNumber => 'رقم غير مقروء';

  @override
  String get csvProblemMissingPrice => 'بلا سعر';

  @override
  String get csvProblemMissingDate => 'بلا تاريخ';

  @override
  String get csvProblemBadDate => 'تاريخ غير مقروء';

  @override
  String get csvProblemFutureDate => 'تاريخ في المستقبل';

  @override
  String get csvProblemUnknownType => 'نوع غير معروف';

  @override
  String get csvProblemUnknownCurrency => 'عملة غير معروفة';

  @override
  String get csvProblemUnsupportedUnit => 'وحدة لا تناسب هذا الأصل';

  @override
  String get csvProblemUnsupportedKarat => 'عيار لا يناسب هذا الأصل';

  @override
  String get csvProblemOversell => 'تبيع أكثر مما كان محتفظًا به';

  @override
  String get csvProblemDuplicate => 'موجودة في Qima';

  @override
  String get transactionBuyPricePlain => 'السعر المدفوع';

  @override
  String get transactionSalePricePlain => 'سعر البيع';

  @override
  String get transactionCarriedCostPlain => 'التكلفة الأصلية (اختياري)';

  @override
  String settingsVersion(String version, String build) {
    return 'الإصدار $version ($build)';
  }

  @override
  String get watchlistEditOrder => 'ترتيب القائمة';

  @override
  String get watchlistSortBy => 'الترتيب حسب';

  @override
  String get watchlistSortName => 'الاسم';

  @override
  String get watchlistSortChange => 'الأفضل أداءً';

  @override
  String get watchlistSortAssetClass => 'فئة الأصل';

  @override
  String watchlistDragHandle(String name) {
    return 'نقل $name';
  }

  @override
  String get watchlistEditOrderHint =>
      'اسحب المقابض لإعادة الترتيب. الفرز يضع ترتيبًا جديدًا يمكنك تعديله لاحقًا.';

  @override
  String get shareAction => 'مشاركة';

  @override
  String shareTitle(String name) {
    return 'مشاركة $name';
  }

  @override
  String get shareToWhatsappMessage => 'رسالة واتساب';

  @override
  String get shareToWhatsappStatus => 'حالة واتساب';

  @override
  String get shareToInstagramPost => 'منشور إنستغرام';

  @override
  String get shareToInstagramStory => 'قصة إنستغرام';

  @override
  String get shareToFacebookPost => 'منشور فيسبوك';

  @override
  String get shareToFacebookStory => 'قصة فيسبوك';

  @override
  String get shareToLinkedinPost => 'منشور لينكدإن';

  @override
  String shareCaption(String name, String price) {
    return 'سعر $name الآن $price.';
  }

  @override
  String shareCaptionWithChange(
    String name,
    String price,
    String change,
    String range,
  ) {
    return 'سعر $name الآن $price ($change، $range).';
  }

  @override
  String shareCaptionFooter(String url) {
    return 'من تطبيق قيمة: $url';
  }

  @override
  String get shareCaptionCopied => 'نُسخ النص. الصقه إن لم يظهر في التطبيق.';

  @override
  String get shareFailed => 'تعذّر إنشاء الصورة. حاول مرة أخرى.';

  @override
  String get helpWatchlistStep6Title => 'غيّر الترتيب';

  @override
  String get helpWatchlistStep6Body =>
      'اضغط على الأسهم في الأعلى لسحب البطاقات من مقابضها، أو رتّبها حسب الاسم أو الأداء أو فئة الأصل. ويمكنك أيضًا الضغط مطولًا على بطاقة لسحبها.';

  @override
  String get helpAssetDetailStep6Title => 'شاركه';

  @override
  String get helpAssetDetailStep6Body =>
      'اضغط على المشاركة لنشر السعر والرسم البياني كصورة بمقاس واتساب أو إنستغرام أو فيسبوك أو لينكدإن، مع نص جاهز.';

  @override
  String get captureRecordThis => 'سجّل هذه العملية';

  @override
  String get captureCheckTitle => 'راجِع العملية';

  @override
  String get captureYouWrote => 'كتبت';

  @override
  String get captureRead => 'فُهمت هكذا';

  @override
  String get captureFieldType => 'النوع';

  @override
  String get captureFieldAsset => 'الأصل';

  @override
  String get captureFieldQuantity => 'الكمية';

  @override
  String get captureFieldPrice => 'السعر';

  @override
  String get captureFieldFee => 'الرسوم';

  @override
  String get captureFieldDate => 'التاريخ';

  @override
  String captureFrom(String words) {
    return 'من «$words»';
  }

  @override
  String get captureBaseCurrency => 'عملتك الأساسية';

  @override
  String get captureTotalDivided => 'الإجمالي ÷ الكمية';

  @override
  String get captureAssumed => 'افتراض';

  @override
  String get captureToday => 'اليوم';

  @override
  String get captureCheck => 'تحقّق';

  @override
  String get captureConfirm => 'تأكيد';

  @override
  String get captureEditFields => 'تعديل الحقول';

  @override
  String get captureFootnote =>
      'كل حقل يوضّح من أين جاء، ولا يُحفظ شيء حتى تؤكّد.';

  @override
  String get captureOnDevice => 'على الجهاز';

  @override
  String get captureNothingSent =>
      'تُقرأ على هذا الجهاز. لا يُرسل أي شيء إلى أي مكان.';

  @override
  String get captureNeedsPrice => 'لم يُعثر على سعر. عدّل الحقول لإضافته.';

  @override
  String captureRecorded(String summary) {
    return 'سُجّلت: $summary';
  }

  @override
  String get settingsSummaries => 'الملخصات';

  @override
  String get settingsPlainSummaries => 'الشهر في جملة';

  @override
  String get settingsPlainSummariesFooter =>
      'يعرض في المحفظة جملة واحدة عمّا حرّك مقتنياتك خلال الشهر الماضي. تُكتب على هذا الجهاز من أرقامك أنت.';

  @override
  String get summaryTitle => 'الشهر الماضي';

  @override
  String summaryUp(String amount, String percent) {
    return 'خلال الشهر الماضي ربحت مقتنياتك $amount ($percent).';
  }

  @override
  String summaryDown(String amount, String percent) {
    return 'خلال الشهر الماضي خسرت مقتنياتك $amount ($percent).';
  }

  @override
  String get summaryFlat => 'لم تتحرك مقتنياتك تقريبًا خلال الشهر الماضي.';

  @override
  String summaryTopMover(String asset, String amount) {
    return 'كان $asset الأكثر تأثيرًا، $amount.';
  }

  @override
  String summaryTransactions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سجّلت $count معاملة.',
      few: 'سجّلت $count معاملات.',
      two: 'سجّلت معاملتين.',
      one: 'سجّلت معاملة واحدة.',
    );
    return '$_temp0';
  }

  @override
  String chartDescription(
    String from,
    String to,
    String start,
    String end,
    String change,
    String high,
    String highDate,
    String low,
    String lowDate,
  ) {
    return 'من $from إلى $to: من $start إلى $end، $change. الأعلى $high في $highDate، والأدنى $low في $lowDate.';
  }

  @override
  String chartDescriptionHidden(String from, String to, String change) {
    return 'من $from إلى $to: $change.';
  }

  @override
  String get dictationStart => 'قل عملية الشراء';

  @override
  String get dictationLanguage => 'اللغة التي تتحدث بها';

  @override
  String get dictationStop => 'إيقاف الاستماع';

  @override
  String get dictationUnsupported =>
      'الإدخال الصوتي بهذه اللغة غير متاح على هذا الجهاز. قيمة تستمع على الجهاز فقط، ولا تستخدم أي خادم.';

  @override
  String get dictationDenied =>
      'الميكروفون أو التعرّف على الكلام متوقف لقيمة. فعّلهما من الإعدادات لتقول عملية الشراء.';

  @override
  String get settingsIntelligence => 'الذكاء على الجهاز';

  @override
  String get settingsUseModel => 'استخدام النموذج على الجهاز';

  @override
  String get settingsUseModelFooter =>
      'يساعد في قراءة عمليات الشراء التي لا تستطيع قيمة فهمها وحدها، ويصوغ ملخص الشهر. يعمل على هذا الجهاز فقط، ولا يقدّم نصائح، ولا يضع أي رقم: كل رقم يأتي من سجلاتك أنت.';

  @override
  String get modelReady => 'جاهز على هذا الجهاز';

  @override
  String get modelUnsupported => 'غير متاح على هذا الجهاز';

  @override
  String get modelTurnedOff =>
      'فعّل Apple Intelligence من إعدادات النظام لاستخدامه';

  @override
  String get modelNotReady => 'ما زال النموذج يُنزَّل';

  @override
  String get modelUnsupportedLanguage => 'غير متاح بهذه اللغة بعد';

  @override
  String get receiptScan => 'مسح إيصال';

  @override
  String get receiptTakePhoto => 'التقاط صورة';

  @override
  String get receiptChoosePhoto => 'اختيار صورة';

  @override
  String get receiptNoText =>
      'لم يُعثر على نص في هذه الصورة. حاول مرة أخرى من مسافة أقرب، والإيصال مسطّح وفي إضاءة جيدة.';

  @override
  String get addButton => 'إضافة';

  @override
  String get addSheetWatch => 'أضف إلى قائمة المتابعة';

  @override
  String get addSheetWatchSubtitle => 'تابع سعرًا دون الحاجة إلى شراء.';

  @override
  String get addHoldingTitle => 'أضف حيازة';

  @override
  String get addSheetHoldingSpeakScan => 'تحدّث أو امسح إيصالًا أو اكتبه.';

  @override
  String get addSheetHoldingSpeak => 'تحدّث أو اكتب ما اشتريته.';

  @override
  String get addSheetHoldingScan => 'امسح إيصالًا أو اكتبه.';

  @override
  String get addSheetHoldingType => 'اكتب ما اشتريته.';

  @override
  String get addSheetSiriTip => 'اسأل Siri: «كم قيمة محفظتي في Qima»';

  @override
  String get addTypeExample =>
      'مثال: اشتريت ٢٠ جرام ذهب عيار ٢١ بسعر ٤١٠٠ جنيه';

  @override
  String get currencyFieldShowIn => 'اعرض الأسعار بعملة';

  @override
  String get currencyFieldTransaction => 'عملة العملية';

  @override
  String currencyFieldCount(int count) {
    return '$count عملة متاحة';
  }

  @override
  String get currencyFieldMore => 'المزيد';

  @override
  String get helpAddAssetStep5Title => 'أضف حيازة';

  @override
  String get helpAddAssetStep5Body =>
      'اضغط +، ثم «أضف حيازة». اكتب ما اشتريته، أو قُله أو امسح إيصالًا إن كان جهازك يدعم ذلك. راجع ما قُرئ ثم أكّد.';

  @override
  String get helpAddAssetStep6Title => 'يُقرأ على هذا الجهاز';

  @override
  String get helpAddAssetStep6Body =>
      'يُقرأ الكلام والإيصالات على هذا الجهاز ولا يُرسل شيء منها. لا يُحفظ شيء حتى تؤكد، وكل رقم يأتي مما كتبته أو قلته أو مسحته.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navMoney => 'المال';

  @override
  String get navPrices => 'الأسعار';

  @override
  String get netWorth => 'صافي الثروة';

  @override
  String get balanceSheet => 'الميزانية';

  @override
  String get youOwn => 'ما تملكه';

  @override
  String get youOweSide => 'ما عليك';

  @override
  String ownOweLine(String own, String owe) {
    return 'تملك $own · عليك $owe';
  }

  @override
  String get sheetHoldings => 'الاستثمارات';

  @override
  String get sheetHoldingsLive => 'بالأسعار الحالية';

  @override
  String get sheetCash => 'النقد والبنوك';

  @override
  String get sheetOwedToYou => 'أموال لك عند الآخرين';

  @override
  String get sheetAssets => 'عقارات وغيرها';

  @override
  String get sheetCards => 'البطاقات';

  @override
  String get sheetLoans => 'القروض';

  @override
  String get sheetYouOwe => 'أموال عليك للآخرين';

  @override
  String get sheetNothingOwed =>
      'لا ديون. تظهر هنا البطاقات والقروض وما عليك للآخرين بعد إضافتها.';

  @override
  String sheetMissingRates(String codes) {
    return 'لا يوجد سعر صرف بعد لـ $codes، لذا لم تُحسب هذه المبالغ في الإجمالي.';
  }

  @override
  String get acctCash => 'نقد';

  @override
  String get acctDebit => 'حساب بنكي';

  @override
  String get acctCredit => 'بطاقة';

  @override
  String get acctLoan => 'قرض';

  @override
  String get acctReceivable => 'مدين لك';

  @override
  String get acctPayable => 'دائن لك';

  @override
  String get acctAsset => 'أصل';

  @override
  String get acctCategory => 'فئة';

  @override
  String get assetKindProperty => 'عقار';

  @override
  String get assetKindVehicle => 'مركبة';

  @override
  String get assetKindBusiness => 'نشاط تجاري';

  @override
  String get assetKindValuables => 'مقتنيات ثمينة';

  @override
  String get assetKindOther => 'أخرى';

  @override
  String get assetKindPropertyHint => 'منزل، أرض، محل';

  @override
  String get assetKindVehicleHint => 'سيارة، دراجة نارية، قارب';

  @override
  String get assetKindBusinessHint => 'حصتك في نشاط تجاري';

  @override
  String get assetKindValuablesHint => 'ساعة، عمل فني، مجموعة';

  @override
  String get assetKindOtherHint => 'أي شيء آخر تملكه';

  @override
  String get tplOpening => 'رصيد افتتاحي';

  @override
  String get tplSpend => 'مصروف';

  @override
  String get tplIncome => 'دخل';

  @override
  String get tplTransfer => 'تحويل';

  @override
  String get tplAtm => 'سحب من الصراف';

  @override
  String get tplSwap => 'تبديل عملة';

  @override
  String get tplCardPayment => 'سداد البطاقة';

  @override
  String get tplLoanPayment => 'قسط القرض';

  @override
  String get tplLent => 'أقرضت';

  @override
  String get tplBorrowed => 'اقترضت';

  @override
  String get tplRepaymentIn => 'سداد مستلم';

  @override
  String get tplRepaymentOut => 'سداد مدفوع';

  @override
  String get tplRefund => 'استرداد';

  @override
  String get tplDeclined => 'مرفوضة';

  @override
  String get tplCashCount => 'جرد النقد';

  @override
  String get tplBillSplit => 'تقسيم فاتورة';

  @override
  String get tplValuation => 'قيمة جديدة';

  @override
  String get tplAssetSale => 'مُباع';

  @override
  String get tplAdjustment => 'تسوية';

  @override
  String get catGroceries => 'بقالة';

  @override
  String get catDining => 'مطاعم';

  @override
  String get catTransport => 'مواصلات';

  @override
  String get catBills => 'فواتير';

  @override
  String get catShopping => 'تسوق';

  @override
  String get catHealth => 'صحة';

  @override
  String get catHome => 'المنزل';

  @override
  String get catOther => 'أخرى';

  @override
  String get catSalary => 'راتب';

  @override
  String get catOtherIncome => 'دخل آخر';

  @override
  String get catInterestFees => 'أرباح ورسوم';

  @override
  String get sysOpening => 'الأرصدة الافتتاحية';

  @override
  String get sysChange => 'تغير القيمة';

  @override
  String get sysRounding => 'تقريب';

  @override
  String get featBudget => 'الميزانية الشهرية';

  @override
  String get featRecurring => 'المدفوعات المخطط لها';

  @override
  String get featPeople => 'السلف والديون';

  @override
  String get featLoans => 'القروض';

  @override
  String get featBillSplit => 'تقسيم الفاتورة';

  @override
  String get featZakat => 'الزكاة';

  @override
  String get featBudgetDetail => 'مبلغ شهري لكل فئة وما تبقى منه';

  @override
  String get featRecurringDetail => 'الفواتير والأقساط والدخل قبل موعدها';

  @override
  String get featPeopleDetail => 'من لك عنده مال ومن لك عليه';

  @override
  String get featLoansDetail => 'المتبقي من القرض وأرباح كل قسط';

  @override
  String get featBillSplitDetail => 'ادفع الفاتورة وقسّمها، ونصيبك وحده مصروف';

  @override
  String get featZakatDetail => 'الزكاة على استثماراتك ونقدك وديونك';

  @override
  String featureTurnedOn(String feature) {
    return 'تم تشغيل $feature';
  }

  @override
  String get featuresTitle => 'الميزات';

  @override
  String get featuresSubtitle => 'الميزانية والمتكررة والقروض وغيرها';

  @override
  String get featuresIntro =>
      'إيقاف ميزة يخفي شاشاتها فقط، أما أموالك فتبقى محسوبة وتظهر في الميزانية.';

  @override
  String get cardNeedsReview => 'يحتاج مراجعة';

  @override
  String get cardComingUp => 'قادم';

  @override
  String get cardLeftToSpend => 'المتبقي للإنفاق';

  @override
  String get cardAccounts => 'الحسابات';

  @override
  String get editHome => 'تعديل الرئيسية';

  @override
  String get editHomeIntro =>
      'حرّك البطاقات أو أخفِ ما لا تحتاجه. لن يعيد قيمة بطاقة أخفيتها.';

  @override
  String get editHomeTotalFixed => 'دائمًا في الأعلى: منه تُفتح الميزانية';

  @override
  String get editHomeCantHide => 'تظهر فقط عندما يحتاجك شيء';

  @override
  String get moveUp => 'تحريك لأعلى';

  @override
  String get moveDown => 'تحريك لأسفل';

  @override
  String get moveToTop => 'نقل إلى الأعلى';

  @override
  String get startTitle => 'ابدأ بما لديك';

  @override
  String get startMessage =>
      'أضف حسابًا بنكيًا أو استثمارًا أو عقارًا، وتجمعها قيمة في صافي ثروتك.';

  @override
  String holdingsGainLine(String amount) {
    return 'الربح $amount';
  }

  @override
  String reviewValue(String name) {
    return 'راجع قيمة $name';
  }

  @override
  String get accountAdd => 'إضافة حساب';

  @override
  String get accountEdit => 'تعديل الحساب';

  @override
  String get accountNameLabel => 'الاسم';

  @override
  String get accountCurrency => 'العملة';

  @override
  String get accountBalanceToday => 'الرصيد اليوم';

  @override
  String get accountOwedToday => 'المستحق عليها اليوم';

  @override
  String get accountLoanLeft => 'المتبقي من أصل القرض';

  @override
  String get accountTheyOwe => 'المبلغ الذي لك';

  @override
  String get accountYouOwe => 'المبلغ الذي عليك';

  @override
  String get accountBalanceHelp =>
      'يبدأ قيمة من هذا الرقم، اتركه فارغًا ليكون صفرًا.';

  @override
  String get accountSince => 'بتاريخ';

  @override
  String get accountLimit => 'حد البطاقة';

  @override
  String get accountCounts => 'احتسابه في صافي الثروة';

  @override
  String get accountCountsHelp =>
      'عند الإيقاف لا يدخل في الإجمالي، ويبقى سجله متوازنًا.';

  @override
  String get accountErrorName => 'أدخل اسمًا.';

  @override
  String get accountLeftOut => 'غير محتسب في صافي الثروة';

  @override
  String accountAvailable(String amount) {
    return 'المتاح $amount';
  }

  @override
  String get accountCountCash => 'جرد النقد';

  @override
  String get accountCheckBalance => 'مطابقة الرصيد';

  @override
  String get accountPayCard => 'سداد البطاقة';

  @override
  String get accountPayLoan => 'سداد قسط';

  @override
  String get accountRemoveTitle => 'حذف الحساب';

  @override
  String get accountRemoveMessage =>
      'الحساب الذي له معاملات يُؤرشف ليبقى السجل متوازنًا، وغير المستخدم يُحذف.';

  @override
  String get accountsEmptyTitle => 'لا حسابات بعد';

  @override
  String get accountsEmptyMessage =>
      'أضف حسابًا بنكيًا أو نقدًا أو بطاقة أو قرضًا برصيده اليوم.';

  @override
  String reconcileTracked(String amount) {
    return 'المسجل في قيمة $amount.';
  }

  @override
  String get reconcileCounted => 'ما عددته';

  @override
  String get reconcileStatement => 'الرصيد في الكشف أو التطبيق';

  @override
  String get reconcileDone => 'سُجل الفرق تحت «أخرى» ليتطابق الرصيد.';

  @override
  String get entryAmount => 'المبلغ';

  @override
  String get entryPrincipal => 'أصل القسط';

  @override
  String get entryProfit => 'الربح أو الفائدة';

  @override
  String get entryProfitHelp =>
      'يُحسب مصروفًا في «أرباح ورسوم»، أما الأصل فلا.';

  @override
  String get entrySent => 'المرسل';

  @override
  String get entryClearsTheirs => 'يسدّد من دينه لك';

  @override
  String get entryClearsMine => 'يسدّد من دينك له';

  @override
  String entryClearsHelp(String amount) {
    return 'اتركه فارغًا لاستخدام سعر اليوم: $amount';
  }

  @override
  String get entryReceived => 'المستلم';

  @override
  String get entryPaidFrom => 'مدفوع من';

  @override
  String get entryFrom => 'من';

  @override
  String get entryTo => 'إلى';

  @override
  String get entryPerson => 'الشخص';

  @override
  String get entryCategory => 'الفئة';

  @override
  String get entryDate => 'التاريخ';

  @override
  String get entryMerchant => 'المكان';

  @override
  String get entryNote => 'ملاحظة';

  @override
  String get entryDeclined => 'مرفوضة';

  @override
  String get entryDeclinedHelp => 'تظهر مشطوبة ولا تدخل في أي رصيد.';

  @override
  String get entryEditTitle => 'تعديل المعاملة';

  @override
  String get entryDeleteTitle => 'حذف المعاملة؟';

  @override
  String get entryDeleteMessage =>
      'تعود كل الحسابات التي أثّرت عليها كما كانت.';

  @override
  String get entryErrorAmount => 'أدخل مبلغًا أكبر من صفر.';

  @override
  String get entryErrorAccount => 'اختر الحسابات.';

  @override
  String get entryErrorSameCurrency =>
      'يجب أن يكون الحسابان بنفس العملة. للعملات المختلفة استخدم تبديل عملة.';

  @override
  String get entryErrorSwap => 'اختر حسابين بعملتين مختلفتين.';

  @override
  String get entryErrorPerson => 'أدخل اسم الشخص.';

  @override
  String get entryErrorRate =>
      'لا يوجد سعر صرف لهذه العملة بعد. حاول بعد تحديث الأسعار.';

  @override
  String get entryNeedsAccountTitle => 'أضف حسابًا أولًا';

  @override
  String get entryNeedsAccountMessage =>
      'يحتاج هذا إلى حساب تخرج منه الأموال أو تدخل إليه. أضفه من الحسابات.';

  @override
  String get howItAddsUp => 'كيف تتوازن';

  @override
  String hiuUp(String name, String amount) {
    return '$name زاد $amount';
  }

  @override
  String hiuDown(String name, String amount) {
    return '$name نقص $amount';
  }

  @override
  String get hiuSpending => 'مصروف: يُحسب في ميزانيتك.';

  @override
  String get hiuIncome => 'دخل: يُحسب في تدفقك النقدي.';

  @override
  String get hiuRefund => 'الاسترداد يخفض المصروف في فئته.';

  @override
  String get hiuWorth =>
      'تغير القيمة يحرك صافي الثروة فقط، وليس دخلًا ولا مصروفًا.';

  @override
  String get hiuMove => 'نقل بين حساباتك: ليس مصروفًا، وصافي ثروتك لا يتغير.';

  @override
  String get hiuDeclined => 'مرفوضة: لم يتحرك شيء.';

  @override
  String get allTransactions => 'كل المعاملات';

  @override
  String get transactionsSearch => 'بحث';

  @override
  String get transactionsEmptyTitle => 'لا معاملات';

  @override
  String get transactionsEmptyMessage => 'أضف معاملة بزر +.';

  @override
  String get moneySpent => 'المصروف';

  @override
  String moneySpentOf(String spent, String budget) {
    return '$spent من $budget';
  }

  @override
  String moneySpentSoFar(String amount) {
    return 'صُرف $amount هذا الشهر';
  }

  @override
  String moneyPace(String amount) {
    return 'بهذا المعدل: $amount بنهاية الشهر';
  }

  @override
  String get moneyNothingSpent => 'لا مصروفات هذا الشهر.';

  @override
  String get moneyIn => 'الداخل';

  @override
  String get moneyOut => 'الخارج';

  @override
  String get moneyLeftOver => 'الفائض';

  @override
  String get moneyShort => 'العجز';

  @override
  String get moneyTrend => 'المصروف حسب الشهر';

  @override
  String get moneyTransactions => 'المعاملات';

  @override
  String get moneyStartMessage => 'أضف حسابًا أولًا ثم سجّل ما تصرفه.';

  @override
  String get whereItWent => 'أين ذهب المال';

  @override
  String get cashFlow => 'التدفق النقدي';

  @override
  String get worthALook => 'يستحق النظر';

  @override
  String aheadOfPace(String name) {
    return '$name تجاوزت وتيرة ميزانيتها';
  }

  @override
  String spareIn(String name, String amount) {
    return 'في $name فائض $amount';
  }

  @override
  String get previousMonth => 'الشهر السابق';

  @override
  String get nextMonth => 'الشهر التالي';

  @override
  String get ask => 'اسأل';

  @override
  String get askSpentMonth => 'كم صرفت هذا الشهر؟';

  @override
  String askSpentMonthAnswer(String amount) {
    return '$amount';
  }

  @override
  String get askTopCategory => 'أين ذهب معظمه؟';

  @override
  String askTopCategoryAnswer(String name, String amount) {
    return '$name: $amount';
  }

  @override
  String get askVsLastMonth => 'هل هو أكثر من الشهر الماضي؟';

  @override
  String askMore(String amount) {
    return 'أكثر بـ $amount من الشهر الماضي';
  }

  @override
  String askLess(String amount) {
    return 'أقل بـ $amount من الشهر الماضي';
  }

  @override
  String get askSame => 'تقريبًا مثل الشهر الماضي';

  @override
  String get askOwed => 'من عليه مال لي؟';

  @override
  String get askNobodyOwes => 'لا أحد عليه مال لك.';

  @override
  String get assetAdd => 'إضافة أصل';

  @override
  String get assetEdit => 'تعديل الأصل';

  @override
  String get assetGoldNote =>
      'الذهب والفضة بالوزن تبقى استثمارات لأن قيمة تسعّرها. أضفها من «إضافة استثمار».';

  @override
  String get assetValueToday => 'القيمة اليوم';

  @override
  String get assetCost => 'سعر الشراء';

  @override
  String get assetBought => 'تاريخ الشراء';

  @override
  String get optional => 'اختياري';

  @override
  String get assetLoan => 'قرض مرتبط به';

  @override
  String get assetNoLoan => 'لا يوجد';

  @override
  String get assetForSale => 'معروض للبيع';

  @override
  String get assetForSaleHelp => 'يُحسب في الزكاة بقيمته. أوقفه لما تستخدمه.';

  @override
  String get assetErrorValue => 'أدخل القيمة اليوم.';

  @override
  String get assetsTotal => 'القيمة الإجمالية';

  @override
  String get assetsTotalHelp => 'قيم تحددها بنفسك، كل منها بتاريخها';

  @override
  String get assetsEmptyTitle => 'لا أصول بعد';

  @override
  String get assetsEmptyMessage =>
      'أضف منزلًا أو أرضًا أو سيارة أو حصة في نشاط. أنت تحدد القيمة وقيمة تحفظ تاريخها.';

  @override
  String assetUpdated(String date) {
    return 'آخر تحديث $date';
  }

  @override
  String assetSinceBought(String amount) {
    return '$amount منذ الشراء';
  }

  @override
  String get assetUpdateValue => 'تحديث القيمة';

  @override
  String get assetUpdateHelp =>
      'كل تحديث مؤرخ. الأحدث هو المعتمد وتبقى القيم السابقة في السجل.';

  @override
  String get assetNewValue => 'القيمة الجديدة';

  @override
  String get assetValueSource => 'مصدر القيمة';

  @override
  String get assetSold => 'تم البيع';

  @override
  String assetSellTitle(String name) {
    return 'بيع $name';
  }

  @override
  String assetLastValue(String amount) {
    return 'آخر قيمة: $amount';
  }

  @override
  String get assetSoldInto => 'دخلت الأموال في';

  @override
  String get assetSoldFor => 'بيع بمبلغ';

  @override
  String assetGain(String amount) {
    return 'ربح $amount';
  }

  @override
  String assetLoss(String amount) {
    return 'خسارة $amount';
  }

  @override
  String get assetGainHelp =>
      'مقارنة بآخر قيمة، وهو تغير في القيمة وليس دخلًا.';

  @override
  String assetPayOff(String name) {
    return 'سدد البيع $name';
  }

  @override
  String assetPayOffHelp(String amount) {
    return '$amount متبقٍ، يُدفع من نفس الحساب';
  }

  @override
  String get assetYours => 'ما يخصك منه';

  @override
  String get assetValue => 'القيمة';

  @override
  String assetStillOwed(String name) {
    return 'المتبقي على $name';
  }

  @override
  String get assetYoursTotal => 'حصتك';

  @override
  String get assetYoursHelp =>
      'تبقى الميزانية تعرض الأصل ضمن ما تملكه والقرض ضمن ما عليك.';

  @override
  String get assetHistory => 'السجل';

  @override
  String get assetRemoveTitle => 'حذف الأصل';

  @override
  String get assetRemoveMessage =>
      'لتسجيل بيع استخدم «تم البيع». الحذف يؤرشفه مع سجله.';

  @override
  String get howTotalWorked => 'كيف يُحسب الإجمالي';

  @override
  String get howTotalIntro => 'صافي الثروة هو ما تملكه ناقص ما عليك.';

  @override
  String get howTotalHoldings =>
      'الاستثمارات بالأسعار الحالية كما في قائمة الأسعار.';

  @override
  String get howTotalAssets =>
      'الأصول التي تقيّمها تُحسب بآخر قيمة مع تاريخها، ويمكن استثناء أي منها.';

  @override
  String get howTotalLoans =>
      'القروض بأصلها فقط، والأرباح المستقبلية ليست دينًا حتى تستحق.';

  @override
  String get howTotalRates => 'العملات الأخرى بسعر الصرف الحالي.';

  @override
  String sheetAccountsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حساب',
      many: '$count حسابًا',
      few: '$count حسابات',
      two: 'حسابان',
      one: 'حساب واحد',
      zero: 'لا حسابات',
    );
    return '$_temp0';
  }

  @override
  String budgetFor(String name) {
    return 'ميزانية $name';
  }

  @override
  String get budgetIntro =>
      'حدد مبلغًا شهريًا للفئات التي تريد متابعتها. سداد البطاقات والتحويلات وأصل القروض لا تُحسب.';

  @override
  String get budgetMonthly => 'شهريًا';

  @override
  String get budgetZeroHelp => 'الصفر يحذفها.';

  @override
  String get budgetNone => 'بلا ميزانية';

  @override
  String budgetOf(String amount) {
    return 'الميزانية $amount';
  }

  @override
  String get budgetSet => 'حدد ميزانية';

  @override
  String get budgetTotal => 'ميزانية هذا الشهر';

  @override
  String get recurringAdd => 'إضافة دفعة مخطط لها';

  @override
  String get recurringDay => 'يوم الشهر';

  @override
  String get recurringEmptyTitle => 'لا مدفوعات مخطط لها';

  @override
  String get recurringEmptyMessage =>
      'أضف الإيجار والفواتير والأقساط أو راتبك لتراها في «قادم» قبل موعدها.';

  @override
  String recurringNext(String date) {
    return 'القادم $date';
  }

  @override
  String recurringRecord(String name, String date) {
    return 'تسجيل $name بتاريخ $date';
  }

  @override
  String get peopleEmptyTitle => 'لا أحد بعد';

  @override
  String get peopleEmptyMessage => 'سجّل ما تقرضه أو تقترضه والسداد.';

  @override
  String get splitTotal => 'إجمالي الفاتورة';

  @override
  String get splitWho => 'من شاركك';

  @override
  String get splitShare => 'النصيب';

  @override
  String get splitAddPerson => 'إضافة شخص';

  @override
  String get splitEvenly => 'قسمة بالتساوي';

  @override
  String get splitMine => 'نصيبك (مصروف)';

  @override
  String get splitOwedToYou => 'مستحق لك';

  @override
  String get splitHelp =>
      'يخرج المبلغ كاملًا من الحساب، ونصيبك وحده مصروف، وأنصبة الآخرين تصبح أموالًا لك عندهم.';

  @override
  String get splitErrorPerson => 'لكل شخص اسم ونصيب.';

  @override
  String get splitErrorShares =>
      'أضف شخصًا واحدًا على الأقل بأنصبة لا تتجاوز الإجمالي.';

  @override
  String get categoriesTitle => 'الفئات';

  @override
  String get categoriesSpending => 'المصروفات';

  @override
  String get categoriesIncome => 'الدخل';

  @override
  String get categoryRename => 'إعادة تسمية الفئة';

  @override
  String get categoryRemove => 'حذف الفئة';

  @override
  String get categoryRemoveMessage => 'تبقى في سجل المعاملات المرتبطة بها.';

  @override
  String get categoryAddSpending => 'فئة مصروف جديدة';

  @override
  String get categoryAddIncome => 'فئة دخل جديدة';

  @override
  String get valueReview => 'مراجعة قيم الأصول';

  @override
  String get valueReviewHelp => 'تذكير في «يحتاج مراجعة»';

  @override
  String get valueReviewOff => 'إيقاف';

  @override
  String valueReviewMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'كل $months شهر',
      many: 'كل $months شهرًا',
      few: 'كل $months أشهر',
      two: 'كل شهرين',
      one: 'كل شهر',
    );
    return '$_temp0';
  }

  @override
  String get addSheetTransaction => 'معاملة';

  @override
  String get addSheetTransactionSubtitle => 'مال صُرف أو دخل أو حُوّل';

  @override
  String get entryVoiceTitle => 'قلها بدلًا من الكتابة';

  @override
  String get entryVoiceListening => 'أستمع… اضغط للإيقاف';

  @override
  String get entryVoiceHint => 'قل ما حدث، مثل «دفعت 45 في بنده بالفيزا أمس»';

  @override
  String get entryVoiceNothing =>
      'لم أفهم مبلغًا أو اسمًا. حاول مرة أخرى أو اكتبه.';

  @override
  String get entryNewTitle => 'معاملة جديدة';

  @override
  String get addSheetMore => 'المزيد';

  @override
  String get addSheetMoreSubtitle => 'دخل، تحويلات، قروض، سلف، حسابات، أصول';

  @override
  String get whatsNewTitle => 'الجديد في قيمة';

  @override
  String get whatsNewTabs =>
      'ثلاث تبويبات: الرئيسية لوضعك، والمال لمصروفك، والأسعار للسوق.';

  @override
  String get whatsNewBalanceSheet =>
      'استثماراتك وحساباتك وبطاقاتك وقروضك تجتمع في ميزانية واحدة. اضغط الإجمالي لرؤيتها.';

  @override
  String get whatsNewAssets =>
      'أضف عقارًا أو سيارة أو نشاطًا وحدّث قيمته بنفسك.';

  @override
  String get whatsNewPick => 'ماذا تريد أن تستخدم؟';

  @override
  String get whatsNewLater => 'يمكنك تغييرها في أي وقت من الإعدادات › الميزات.';

  @override
  String get zakatDueTitle => 'الزكاة المستحقة';

  @override
  String zakatDueLine(String amount) {
    return 'المستحق $amount';
  }

  @override
  String get zakatBelowLine => 'دون النصاب';

  @override
  String zakatBaseLine(String amount) {
    return 'المحتسب: $amount';
  }

  @override
  String zakatAbove(String amount) {
    return 'فوق النصاب البالغ $amount';
  }

  @override
  String zakatBelow(String amount) {
    return 'دون النصاب البالغ $amount';
  }

  @override
  String get zakatNoThreshold => 'يظهر النصاب بعد تحميل أسعار الذهب والفضة.';

  @override
  String get zakatBase => 'المحتسب للزكاة';

  @override
  String get zakatHeldForSale => 'أصول معروضة للبيع';

  @override
  String get zakatDebtsDue => 'ديون مستحقة الآن';

  @override
  String get zakatBookHelp =>
      'الاستثمارات حسب إعدادات الزكاة. تُخصم أرصدة البطاقات وما عليك للآخرين، ولا تُخصم القروض لأن المستحق منها هو القسط الحالي فقط ولا تعرف قيمة جدولها.';

  @override
  String get zakatHoldingsDetail => 'تفاصيل الاستثمارات';

  @override
  String get importStatement => 'استيراد كشف حساب';

  @override
  String get importStatementSubtitle =>
      'PDF أو Excel أو CSV أو لقطات شاشة من بنكك';

  @override
  String get importFromFiles => 'من الملفات';

  @override
  String get importFromFilesHint => 'كشوف بصيغة PDF أو Excel أو CSV';

  @override
  String get importFromPhotos => 'لقطات شاشة من الصور';

  @override
  String get importFromPhotosHint => 'عمليات تطبيق بنكك';

  @override
  String get importFromClipboard => 'من الحافظة';

  @override
  String get importFromClipboardHint =>
      'كشف أو إيصال أو رسالة بنك أو لقطة شاشة منسوخة';

  @override
  String get importPastedName => 'ملصق';

  @override
  String get importShareTip =>
      'يمكنك أيضًا مشاركة الملفات مع قيمة من أي تطبيق.';

  @override
  String importReadingFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'جارٍ قراءة $count ملفًا…',
      few: 'جارٍ قراءة $count ملفات…',
      two: 'جارٍ قراءة ملفين…',
      one: 'جارٍ قراءة ملف واحد…',
    );
    return '$_temp0';
  }

  @override
  String importReadyRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عملية للمراجعة',
      few: '$count عمليات للمراجعة',
      two: 'عمليتان للمراجعة',
      one: 'عملية واحدة للمراجعة',
      zero: 'لم يُعثر على شيء لإضافته',
    );
    return '$_temp0';
  }

  @override
  String get importReadyBalance => 'رصيد للمراجعة';

  @override
  String get bankMessagesTitle => 'رسائل البنك النصية';

  @override
  String get bankMessagesEntry => 'رسائل البنك النصية';

  @override
  String get bankMessagesEntryHint => 'أضف المشتريات من رسائل بنكك';

  @override
  String get bankMessagesIntro =>
      'يرسل لك بنكك رسالة بكل شراء وتحويل وراتب. يمكن لقيمة قراءة هذه الرسائل واقتراحها كعمليات، وتراجع كل واحدة قبل إضافتها.';

  @override
  String get bankMessagesRead => 'قراءة رسائل البنك الجديدة';

  @override
  String get bankMessagesReadHint =>
      'الرسائل التي فيها مبلغ فقط، وتُتجاهل الرموز والرسائل الشخصية.';

  @override
  String get bankMessagesRecent => 'أحضر آخر 60 يومًا';

  @override
  String get bankMessagesRecentHint => 'تُتجاهل الرسائل الموجودة في قيمة';

  @override
  String get bankMessagesDenied =>
      'تحتاج قيمة إلى إذن قراءة الرسائل، ويمكنك السماح بذلك من الإعدادات.';

  @override
  String get bankMessagesSetUp => 'اضبطها مرة واحدة في الاختصارات';

  @override
  String get bankMessagesStep1 =>
      'افتح الاختصارات، ثم الأتمتة واضغط +، ثم اختر رسالة.';

  @override
  String get bankMessagesStep2 =>
      'اختر بنكك كمرسل، أو كلمة تظهر دائمًا في رسائله مثل ر.س.';

  @override
  String get bankMessagesStep3 => 'اختر التشغيل فورًا.';

  @override
  String get bankMessagesStep4 =>
      'أضف إجراء «Add a bank message» من قيمة ومرّر له الرسالة.';

  @override
  String get bankMessagesOpenShortcuts => 'افتح الاختصارات';

  @override
  String get bankMessagesUnavailable =>
      'يمكن إضافة رسائل البنك على آيفون وأندرويد.';

  @override
  String get bankMessagesPrivacy => 'تُقرأ الرسائل على هذا الجهاز ولا تغادره.';

  @override
  String bankMessagesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رسالة بنك للمراجعة',
      many: '$count رسالة بنك للمراجعة',
      few: '$count رسائل بنك للمراجعة',
      two: 'رسالتا بنك للمراجعة',
      one: 'رسالة بنك واحدة للمراجعة',
      zero: 'لم توجد رسائل بنك',
    );
    return '$_temp0';
  }

  @override
  String get importBannerTitle => 'مُشارك مع قيمة';

  @override
  String get importReviewTitle => 'مراجعة الاستيراد';

  @override
  String get importIntoAccount => 'كشف حساب';

  @override
  String get importNoAccountTitle => 'أضف الحساب أولًا';

  @override
  String get importNoAccountBody =>
      'أضف الحساب البنكي أو البطاقة التي يخصها هذا الكشف، ثم عد إلى هنا.';

  @override
  String importAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إضافة $count عملية',
      few: 'إضافة $count عمليات',
      two: 'إضافة عمليتين',
      one: 'إضافة عملية واحدة',
      zero: 'إضافة',
    );
    return '$_temp0';
  }

  @override
  String importAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أُضيفت $count عملية',
      few: 'أُضيفت $count عمليات',
      two: 'أُضيفت عمليتان',
      one: 'أُضيفت عملية واحدة',
    );
    return '$_temp0';
  }

  @override
  String get importDiscardAll => 'تجاهل الكل';

  @override
  String get importApplyBalance => 'تطبيق الرصيد';

  @override
  String get importDiscardConfirm => 'تجاهل هذه الملفات؟ لن يُضاف منها شيء.';

  @override
  String get importDiscard => 'تجاهل';

  @override
  String get importRemoveFile => 'إزالة الملف';

  @override
  String get importFlagInBook => 'موجودة في قيمة';

  @override
  String get importFlagRepeated => 'موجودة في ملف آخر';

  @override
  String importFlagCurrency(String currency) {
    return 'بعملة $currency وليست عملة الحساب';
  }

  @override
  String get importDateGuessed => 'لم يُعثر على تاريخ: استُخدم يوم المشاركة';

  @override
  String get importSignGuessed => 'تحقق: وارد أم صادر؟';

  @override
  String get importFlagNotTransaction => 'يبدو نصًا من البنك وليس عملية';

  @override
  String importRefCard(String last4) {
    return 'بطاقة •••• $last4';
  }

  @override
  String importRefAccount(String last4) {
    return 'حساب •••• $last4';
  }

  @override
  String importRefIban(String last4) {
    return 'آيبان •••• $last4';
  }

  @override
  String importBalances(String opening, String closing) {
    return 'الافتتاحي $opening ← الختامي $closing';
  }

  @override
  String get importAddsUp => 'المجموع مطابق: لم يفُت شيء';

  @override
  String importGap(String amount) {
    return '$amount غير محسوب: تحقق من عملية ناقصة';
  }

  @override
  String importOpeningBalance(String amount) {
    return 'أضف الرصيد الافتتاحي: $amount';
  }

  @override
  String importMatchBalance(String amount) {
    return 'اجعل الرصيد $amount';
  }

  @override
  String importBalanceDetail(String date, String tracked) {
    return 'كما يظهر في الكشف بتاريخ $date. وبدون ذلك سيكون الرصيد المسجّل $tracked.';
  }

  @override
  String get importStatusReading => 'جارٍ القراءة…';

  @override
  String get importStatusWaiting => 'في الانتظار';

  @override
  String get importStatusAlready => 'استُورد من قبل';

  @override
  String get importStatusUnsupported =>
      'لا تستطيع قيمة قراءة هذا النوع من الملفات';

  @override
  String get importStatusUnreadable => 'تعذرت قراءة هذا الملف';

  @override
  String get importStatusNothing => 'لم يُعثر على عمليات في هذا الملف';

  @override
  String importRowFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'وُجدت $count عملية',
      few: 'وُجدت $count عمليات',
      two: 'وُجدت عمليتان',
      one: 'وُجدت عملية',
    );
    return '$_temp0';
  }

  @override
  String get importEditRow => 'العملية';

  @override
  String get importCategory => 'الفئة';

  @override
  String get importNothingSelected => 'حدد العمليات التي تريد إضافتها.';

  @override
  String get importReadOnDevice =>
      'تُقرأ على هذا الجهاز، وتُحذف الملفات بعد الاستيراد.';

  @override
  String get importEmpty => 'لا شيء في الانتظار';

  @override
  String get catUncategorized => 'غير مصنّف';

  @override
  String get catUncategorizedIncome => 'دخل غير مصنّف';

  @override
  String get toCategorizeTitle => 'بانتظار التصنيف';

  @override
  String toCategorizeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عمليات بانتظار التصنيف',
      one: 'عملية بانتظار التصنيف',
    );
    return '$_temp0';
  }

  @override
  String get toCategorizeHint =>
      'اختر فئة مرة واحدة لكل اسم، وتستخدمها العمليات المستوردة من هذا الاسم من الآن.';

  @override
  String get toCategorizeEmpty => 'كل العمليات مصنّفة.';

  @override
  String toCategorizeAlso(
    int count,
    String name,
    String category,
    String from,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'هل تضع أيضًا $count عمليات سابقة من $name في $category؟ هي الآن في $from.',
      one: 'هل تضع أيضًا عملية سابقة من $name في $category؟ هي الآن في $from.',
    );
    return '$_temp0';
  }

  @override
  String get toCategorizeAlsoYes => 'انقلها';

  @override
  String get categoriesLearned => 'تعلّمتها من اختياراتك';

  @override
  String get categoriesForgetTitle => 'نسيان هذا الاختيار؟';

  @override
  String categoriesForgetMessage(String name, String category) {
    return 'لن تذهب العمليات المستوردة من $name إلى $category تلقائيًا بعد الآن. تبقى العمليات الموجودة كما هي.';
  }

  @override
  String get categoriesForget => 'نسيان';

  @override
  String get marketClosed => 'مغلق';

  @override
  String marketClosedOpens(String time) {
    return 'السوق مغلق · يفتح $time';
  }

  @override
  String marketOpenCloses(String time) {
    return 'السوق مفتوح · يغلق $time';
  }

  @override
  String get marketClosedLong => 'السوق مغلق';

  @override
  String holdingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أصل',
      many: '$count أصلًا',
      few: '$count أصول',
      two: 'أصلان',
      one: 'أصل واحد',
    );
    return '$_temp0';
  }

  @override
  String pricesAt(String time) {
    return 'الأسعار $time';
  }

  @override
  String get balanceWayTransaction => 'أضف معاملة';

  @override
  String balanceWayTransactionDetail(String other) {
    return 'يُحسب الفرق إنفاقًا أو دخلًا في $other';
  }

  @override
  String get balanceWayOpening => 'عدّل الرصيد الافتتاحي';

  @override
  String get balanceWayOpeningDetail => 'من يومه الأول، لا إنفاقًا ولا دخلًا';

  @override
  String get netLabel => 'الصافي';

  @override
  String get planOut => 'خارج';

  @override
  String get planIn => 'داخل';

  @override
  String get planRepeat => 'التكرار';

  @override
  String get planRepeatOnce => 'مرة واحدة';

  @override
  String get planRepeatWeekly => 'كل أسبوع';

  @override
  String get planRepeatMonthly => 'كل شهر';

  @override
  String get planRepeatQuarterly => 'كل ٣ أشهر';

  @override
  String get planRepeatYearly => 'كل سنة';

  @override
  String get planDate => 'موعدها';

  @override
  String get planTimes => 'عدد الدفعات';

  @override
  String get planTimesHelp =>
      'اتركه فارغًا لدفعات بلا نهاية، أو ٤ لقسط على ٤ دفعات.';

  @override
  String get planPaidInto => 'يُدفع إلى';

  @override
  String get planRemind => 'ذكّرني قبلها بيوم';

  @override
  String planLeft(int left, int total) {
    return 'بقي $left من $total';
  }

  @override
  String get planFinished => 'انتهت';

  @override
  String planOverdue(String date) {
    return 'متأخرة منذ $date';
  }

  @override
  String get planRecord => 'تسجيل';

  @override
  String get planSkip => 'تخطي هذه';

  @override
  String planDueTomorrow(String name) {
    return 'موعد $name غدًا';
  }

  @override
  String planExpectedTomorrow(String name) {
    return 'يُتوقع $name غدًا';
  }

  @override
  String get planReminderBody => 'افتح قيمة لتسجيلها عند حدوثها.';

  @override
  String plannedThisMonth(String amount) {
    return '$amount مخطط لها بقية هذا الشهر';
  }

  @override
  String get categoryNew => 'فئة جديدة…';

  @override
  String get categoryNewTitle => 'فئة جديدة';

  @override
  String get planEdit => 'تعديلها';

  @override
  String get accountNumberAccount => 'رقم الحساب';

  @override
  String get accountNumberIban => 'رقم الآيبان (IBAN)';

  @override
  String get accountNumberCard => 'رقم البطاقة';

  @override
  String get accountNumberHelp =>
      'تكفي آخر 4 أرقام. تحتفظ قيمة بآخر 4 أرقام فقط لتطابق كشوف الحساب ورسائل البنك مع هذا الحساب.';

  @override
  String get accountNumberShort => 'أدخل آخر 4 أرقام على الأقل';

  @override
  String get applePaySetUp => 'مدفوعات Apple Pay';

  @override
  String get applePayIntro =>
      'يمكن أن تصل كل عملية دفع بـ Apple Pay إلى قيمة لحظة الدفع، حتى من البطاقات التي لا ترسل رسائل.';

  @override
  String get applePayStep1 =>
      'في الاختصارات، افتح الأتمتة واضغط +، ثم اختر المحفظة.';

  @override
  String get applePayStep2 => 'اختر بطاقاتك، ثم اختر التشغيل فورًا.';

  @override
  String get applePayStep3 => 'أضف إجراء «Add an Apple Pay payment» من قيمة.';

  @override
  String get applePayStep4 =>
      'اجعل Amount وMerchant وCard فيه هي المبلغ والتاجر والبطاقة أو التذكرة من مُدخل الاختصار.';

  @override
  String get entryMarkAs => 'تحديدها كـ';

  @override
  String get splitByAmount => 'مبلغ';

  @override
  String get splitByEqually => 'بالتساوي';

  @override
  String get splitByPercent => 'نسبة';

  @override
  String get splitByShares => 'حصص';

  @override
  String get splitYou => 'أنت';
}
