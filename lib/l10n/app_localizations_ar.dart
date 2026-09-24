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
  String get watchlistAdd => 'إضافة أداة';

  @override
  String get watchlistEmptyTitle => 'قائمة المتابعة فارغة';

  @override
  String get watchlistEmptyMessage =>
      'أضف معادن أو عملات رقمية أو أسهمًا أو عملات لبدء تتبع الأسعار.';

  @override
  String get watchlistFilterAll => 'الكل';

  @override
  String get addTitle => 'إضافة أداة';

  @override
  String get addSearchHint => 'ابحث عن أداة';

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
  String get settingsDefaultRangeFooter => 'يُستخدم عند فتح أداة لأول مرة.';

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
  String get confirmRemoveCardMessage => 'ستبقى مقتنياتك من هذه الأداة محفوظة.';

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
  String get alertsCardEmpty => 'لا توجد تنبيهات بعد لهذه الأداة.';

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
      'افتح أداة ما واضغط على الجرس لضبط تنبيه سعر.';

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
    return 'آخر نسخة احتياطية $date · $instruments أداة، $lots دفعة';
  }

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
      'قائمة المتابعة، الممتلكات، الأدوات المخصصة، التنبيهات والإعدادات (.json)';

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
    return '$cards بطاقة متابعة · $lots دفعة · $customTickers أداة مخصصة';
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
  String get backupImportCountCustomTickers => 'الأدوات المخصصة';

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
      'سيتم استبدال قائمة المتابعة والممتلكات والأدوات المخصصة والتنبيهات الحالية بمحتويات النسخة الاحتياطية. لا يمكن التراجع عن هذا.';

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
  String get backupCsvHeaderInstrument => 'الأداة';

  @override
  String get backupCsvHeaderSymbol => 'الرمز';

  @override
  String get backupCsvHeaderQuantity => 'الكمية';

  @override
  String get backupCsvHeaderUnit => 'الوحدة';

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
}
