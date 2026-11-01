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
  String get addSearchHint => 'ابحث، أو صِف عملية شراء';

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
  String zakatGregorianNote(String solarRate, String rate) {
    return 'السنة الميلادية أطول من القمرية بنحو 11 يومًا، ويرفع بعض العلماء النسبة إلى $solarRate لذلك، بينما يُبقي Qima على $rate.';
  }

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
      'يحسب Qima الزكاة من ممتلكاتك بأسعار اليوم. هو يحسب، والاختيارات وراء الحساب لك.';

  @override
  String get helpZakatStep1Title => 'النصاب';

  @override
  String get helpZakatStep1Body =>
      'النصاب 85 غرامًا من الذهب الخالص أو 595 غرامًا من الفضة، بسعر اللحظة. اختر الأساس من إعدادات الزكاة؛ نصاب الفضة أدنى فتجب على عدد أكبر.';

  @override
  String get helpZakatStep2Title => 'ما يُحتسب';

  @override
  String get helpZakatStep2Body =>
      'المعادن والعملات المشفرة والنقد تُحتسب افتراضيًا، والأسهم لا. يُحتسب الذهب بعياره حسب محتواه من الذهب الخالص. ويمكنك استبعاد أي أصل من شاشة الزكاة.';

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
}
