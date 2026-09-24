// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Qima';

  @override
  String get watchlistAdd => 'Añadir instrumento';

  @override
  String get watchlistEmptyTitle => 'Tu lista de seguimiento está vacía';

  @override
  String get watchlistEmptyMessage =>
      'Añade metales, criptomonedas, acciones o divisas para empezar a seguir precios.';

  @override
  String get watchlistFilterAll => 'Todos';

  @override
  String get addTitle => 'Añadir instrumento';

  @override
  String get addSearchHint => 'Buscar instrumentos';

  @override
  String addSearchCustomTickerTitle(String query) {
    return 'Añadir “$query” como símbolo personalizado';
  }

  @override
  String get addSearchCustomTickerSubtitle =>
      'Para acciones, ETFs o índices que no aparecen aquí';

  @override
  String addSearchNoResultsTitle(String query) {
    return 'Sin resultados para “$query”';
  }

  @override
  String get addSearchNoResultsMessage =>
      'Nada en el catálogo coincide con eso. Aún puedes añadirlo como símbolo personalizado.';

  @override
  String addSearchNoResultsButton(String query) {
    return 'Añadir $query como símbolo personalizado';
  }

  @override
  String addedToWatchlist(String name) {
    return '$name añadido a la lista de seguimiento';
  }

  @override
  String alreadyInWatchlist(String name) {
    return '$name ya está en tu lista de seguimiento';
  }

  @override
  String get addCustomTickerTitle => 'Añadir símbolo personalizado';

  @override
  String get addCustomTickerSymbol => 'Símbolo bursátil';

  @override
  String get addCustomTickerName => 'Nombre para mostrar (opcional)';

  @override
  String get addCustomTickerHint => 'p. ej. AAPL, TSLA, VOO';

  @override
  String get addCustomTickerSymbolRequired => 'Introduce un símbolo bursátil.';

  @override
  String get addCustomTickerError =>
      'No se pudo verificar este símbolo. Comprueba el símbolo e inténtalo de nuevo.';

  @override
  String get addCustomTickerSubmit => 'Añadir símbolo';

  @override
  String get cardConfigAddToWatchlist => 'Añadir a la lista de seguimiento';

  @override
  String get commonCurrency => 'Moneda';

  @override
  String get currencyPickerSearchHint => 'Buscar moneda';

  @override
  String get detailHoldings => 'Posiciones';

  @override
  String get detailHistory => 'Historial';

  @override
  String get detailLoadHistory => 'Cargar historial';

  @override
  String get detailNoHistoryTitle => 'Aún no hay historial';

  @override
  String get detailNoHistoryMessage =>
      'Carga el historial para ver el gráfico de precios completo.';

  @override
  String get detailKeyStats => 'Estadísticas clave';

  @override
  String get detailPricePerUnit => 'Precio por unidad';

  @override
  String detailUpdatedAt(String time) {
    return 'Actualizado $time';
  }

  @override
  String get errorRefreshFailed =>
      'No se pudieron actualizar los precios. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get detailChangeCurrency => 'Cambiar moneda';

  @override
  String detailShowPerUnit(String unit) {
    return 'Mostrar por $unit';
  }

  @override
  String get holdingsEmpty =>
      'Añade tu primer lote para empezar a seguir esta posición.';

  @override
  String get holdingsValue => 'Valor';

  @override
  String get holdingsCost => 'Coste';

  @override
  String get holdingsGain => 'Ganancia';

  @override
  String get holdingsGainPercent => '% de ganancia';

  @override
  String get holdingsNew => 'Nuevo lote';

  @override
  String get holdingsEdit => 'Editar lote';

  @override
  String get holdingsQuantity => 'Cantidad';

  @override
  String get holdingsCostModePerUnit => 'Por unidad';

  @override
  String get holdingsCostModeTotal => 'Total';

  @override
  String get holdingsUnitCost => 'Coste unitario';

  @override
  String holdingsUnitCostWithUnit(String unit) {
    return 'Coste unitario (por $unit)';
  }

  @override
  String holdingsUnitCostWithKarat(String unit, String karat) {
    return 'Coste unitario (por $unit · $karat)';
  }

  @override
  String holdingsUnitCostPreview(String value) {
    return 'Por unidad: $value';
  }

  @override
  String get holdingsTotalCost => 'Coste total';

  @override
  String holdingsTotalCostPreview(String value) {
    return 'Total: $value';
  }

  @override
  String get holdingsDate => 'Fecha';

  @override
  String get holdingsSave => 'Guardar';

  @override
  String get holdingsTotalHeld => 'Total en posesión';

  @override
  String get holdingsAverageCost => 'Coste medio';

  @override
  String holdingsAverageCostPerUnit(String value, String unit) {
    return '$value por $unit';
  }

  @override
  String holdingsAverageCostPerUnitKarat(
    String value,
    String unit,
    String karat,
  ) {
    return '$value por $unit · $karat';
  }

  @override
  String holdingsMixedNote(String karat) {
    return 'Quilates mixtos calculados por contenido de oro, mostrados como $karat.';
  }

  @override
  String get holdingsMixedUnitsNote =>
      'Unidades mixtas calculadas por contenido de oro.';

  @override
  String holdingsHeldLine(String quantity, String average) {
    return 'En posesión $quantity · media $average';
  }

  @override
  String get portfolioTitle => 'Cartera';

  @override
  String get portfolioValue => 'Valor total';

  @override
  String get portfolioEmpty =>
      'Aún no hay valor de cartera — añade un lote para empezar.';

  @override
  String get portfolioNoChange =>
      'Aún no hay suficiente historial para este período';

  @override
  String get portfolioNoHistory =>
      'Añade una posición para ver el gráfico de tu cartera';

  @override
  String portfolioLotCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lotes',
      one: '1 lote',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsAppearanceSystem => 'Sistema';

  @override
  String get settingsAppearanceLight => 'Claro';

  @override
  String get settingsAppearanceDark => 'Oscuro';

  @override
  String get settingsBaseCurrency => 'Moneda base';

  @override
  String get settingsPortfolioCurrency => 'Moneda de la cartera';

  @override
  String get settingsUnit => 'Unidad';

  @override
  String get settingsKarat => 'Quilate';

  @override
  String get settingsBaseCurrencyFooter =>
      'Se usa para totalizar el valor de tu cartera.';

  @override
  String get settingsDefaultRange => 'Rango de gráfico predeterminado';

  @override
  String get settingsDefaultRangeFooter =>
      'Se usa al abrir un instrumento por primera vez.';

  @override
  String get settingsWidgetRefresh => 'Intervalo de actualización del widget';

  @override
  String get settingsWidgetRefreshFooter =>
      'Con qué frecuencia los widgets en segundo plano obtienen nuevos precios.';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsLanguageSystem => 'Seguir el sistema';

  @override
  String get settingsDataSource =>
      'finance.yahoo.com · gold-api.com · er-api.com';

  @override
  String get settingsPrivacy => 'Privacidad y seguridad';

  @override
  String get settingsHideBalances => 'Ocultar saldos';

  @override
  String get settingsHideBalancesFooter =>
      'Oculta los importes de la cartera, las posiciones y los lotes en toda la app.';

  @override
  String get settingsAppLock => 'Bloqueo de la app';

  @override
  String get settingsAppLockFooter =>
      'Requiere Face ID, Touch ID o el código del dispositivo para abrir Qima.';

  @override
  String get settingsAppLockUnavailable =>
      'Configura Face ID, Touch ID o un código de dispositivo primero.';

  @override
  String get settingsAppLockFailed =>
      'No se pudo verificar tu identidad — el bloqueo de la app sigue desactivado.';

  @override
  String get settingsLockAfter => 'Bloquear después de';

  @override
  String get lockGraceImmediately => 'Inmediatamente';

  @override
  String get lockGrace1m => '1 minuto';

  @override
  String get lockGrace5m => '5 minutos';

  @override
  String get lockGrace15m => '15 minutos';

  @override
  String get privacyHideBalances => 'Ocultar saldos';

  @override
  String get privacyShowBalances => 'Mostrar saldos';

  @override
  String get appLockAuthReason => 'Desbloquea Qima para ver tu cartera';

  @override
  String get appLockLockedTitle => 'Qima está bloqueada';

  @override
  String get appLockLockedMessage =>
      'Desbloquea para ver tu cartera y tus posiciones.';

  @override
  String get appLockUnlockFaceID => 'Desbloquear con Face ID';

  @override
  String get appLockUnlockTouchID => 'Desbloquear con Touch ID';

  @override
  String get appLockUnlockGeneric => 'Desbloquear';

  @override
  String get appLockUseDevicePasscode => 'Usar el código del dispositivo';

  @override
  String get statChange => 'Cambio';

  @override
  String get statHigh => 'Máximo';

  @override
  String get statLow => 'Mínimo';

  @override
  String get statPoints => 'Puntos';

  @override
  String get pricePullToRefresh => 'Desliza para actualizar';

  @override
  String get assetClassMetal => 'Metales';

  @override
  String get assetClassCrypto => 'Cripto';

  @override
  String get assetClassStock => 'Acciones';

  @override
  String get assetClassIndex => 'Índices';

  @override
  String get assetClassFiat => 'Divisas';

  @override
  String get assetGold => 'Oro';

  @override
  String get assetSilver => 'Plata';

  @override
  String get assetPlatinum => 'Platino';

  @override
  String get assetPalladium => 'Paladio';

  @override
  String get assetBitcoin => 'Bitcoin';

  @override
  String get assetEthereum => 'Ethereum';

  @override
  String get assetApple => 'Apple';

  @override
  String get assetMicrosoft => 'Microsoft';

  @override
  String get assetNvidia => 'Nvidia';

  @override
  String get assetAmazon => 'Amazon';

  @override
  String get assetTesla => 'Tesla';

  @override
  String get assetAlphabet => 'Alphabet';

  @override
  String get assetSp500 => 'S&P 500';

  @override
  String get assetDowJones => 'Dow Jones';

  @override
  String get assetNasdaq => 'Nasdaq';

  @override
  String get assetRussell2000 => 'Russell 2000';

  @override
  String get assetFtse100 => 'FTSE 100';

  @override
  String get assetNikkei225 => 'Nikkei 225';

  @override
  String get assetDax => 'DAX';

  @override
  String get assetUsDollar => 'Dólar estadounidense';

  @override
  String get assetEuro => 'Euro';

  @override
  String get assetBritishPound => 'Libra esterlina';

  @override
  String get assetEgyptianPound => 'Libra egipcia';

  @override
  String get assetSaudiRiyal => 'Riyal saudí';

  @override
  String get assetEmiratiDirham => 'Dirham de EAU';

  @override
  String get assetQatariRiyal => 'Riyal catarí';

  @override
  String get assetKuwaitiDinar => 'Dinar kuwaití';

  @override
  String get assetOmaniRial => 'Rial omaní';

  @override
  String get assetBahrainiDinar => 'Dinar bareiní';

  @override
  String get assetJordanianDinar => 'Dinar jordano';

  @override
  String get unitTroyOunce => 'Onza troy';

  @override
  String get unitGram => 'Gramo';

  @override
  String get unitKilogram => 'Kilogramo';

  @override
  String get unitEach => 'Unidad';

  @override
  String get unitAbbrTroyOunce => 'oz t';

  @override
  String get unitAbbrGram => 'g';

  @override
  String get unitAbbrKilogram => 'kg';

  @override
  String get karatShort24 => '24K';

  @override
  String get karatShort22 => '22K';

  @override
  String get karatShort21 => '21K';

  @override
  String get karatShort18 => '18K';

  @override
  String get range1D => '1D';

  @override
  String get range3D => '3D';

  @override
  String get range7D => '7D';

  @override
  String get range1W => '1S';

  @override
  String get range1M => '1M';

  @override
  String get range3M => '3M';

  @override
  String get range6M => '6M';

  @override
  String get rangeYtd => 'AAF';

  @override
  String get range1Y => '1A';

  @override
  String get range5Y => '5A';

  @override
  String get rangeAll => 'Todo';

  @override
  String get refresh15m => '15 minutos';

  @override
  String get refresh30m => '30 minutos';

  @override
  String get refresh1h => '1 hora';

  @override
  String get refresh3h => '3 horas';

  @override
  String get refresh6h => '6 horas';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonRemove => 'Quitar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonUndo => 'Deshacer';

  @override
  String confirmRemoveCardTitle(String name) {
    return '¿Quitar $name de tu lista de seguimiento?';
  }

  @override
  String get confirmRemoveCardMessage =>
      'Tus posiciones de este instrumento se conservan.';

  @override
  String get confirmDeleteLotTitle => '¿Eliminar este lote?';

  @override
  String confirmDeleteLotMessage(String details) {
    return '$details. No se puede deshacer.';
  }

  @override
  String confirmRemoveTickerTitle(String symbol) {
    return '¿Quitar el símbolo personalizado $symbol?';
  }

  @override
  String get confirmRemoveTickerMessage =>
      'También se quitarán sus tarjetas de la lista de seguimiento.';

  @override
  String get alertKindAbove => 'Sube por encima de';

  @override
  String get alertKindBelow => 'Baja por debajo de';

  @override
  String get alertKindPercentMove => 'Variación %';

  @override
  String get alertDirectionUp => 'Sube';

  @override
  String get alertDirectionDown => 'Baja';

  @override
  String get alertDirectionEither => 'Cualquiera';

  @override
  String get alertWindowWithin24h => 'En 24 horas';

  @override
  String get alertWindowWithin7d => 'En 7 días';

  @override
  String get alertWindow24h => '24 horas';

  @override
  String get alertWindow7d => '7 días';

  @override
  String get alertBellTooltip => 'Alertas de precio';

  @override
  String get alertsCardTitle => 'Alertas';

  @override
  String get alertsCardEmpty => 'Aún no hay alertas para este instrumento.';

  @override
  String get alertsCardAdd => 'Añadir alerta';

  @override
  String get alertEditorNewTitle => 'Nueva alerta';

  @override
  String get alertEditorEditTitle => 'Editar alerta';

  @override
  String get alertEditorTypePrice => 'Precio';

  @override
  String get alertEditorTypePercent => 'Variación %';

  @override
  String get alertEditorGoesAbove => 'Sube por encima de';

  @override
  String get alertEditorGoesBelow => 'Baja por debajo de';

  @override
  String get alertEditorTargetLabel => 'Precio objetivo';

  @override
  String get alertEditorTargetRequired =>
      'Introduce un precio objetivo mayor que cero.';

  @override
  String alertEditorHelperAbove(String delta, String percent) {
    return '+$delta · $percent% por encima del precio actual';
  }

  @override
  String alertEditorHelperBelow(String delta, String percent) {
    return '−$delta · $percent% por debajo del precio actual';
  }

  @override
  String get alertEditorDirection => 'Dirección';

  @override
  String get alertEditorWindow => 'Ventana';

  @override
  String alertEditorPercentSummary(String low, String high) {
    return 'Se activa por debajo de $low o por encima de $high';
  }

  @override
  String alertEditorPercentSummaryUp(String high) {
    return 'Se activa por encima de $high';
  }

  @override
  String alertEditorPercentSummaryDown(String low) {
    return 'Se activa por debajo de $low';
  }

  @override
  String get alertEditorRepeat => 'Repetir';

  @override
  String get alertEditorRepeatFooter =>
      'Sigue vigilando después de activarse, en lugar de desactivarse.';

  @override
  String get alertEditorCreate => 'Crear alerta';

  @override
  String get alertEditorSave => 'Guardar';

  @override
  String get alertEditorDelete => 'Eliminar';

  @override
  String get alertsScreenTitle => 'Alertas';

  @override
  String get alertsScreenInfo =>
      'Las alertas se comprueban aproximadamente cada 15 minutos en segundo plano, y en tiempo real mientras Qima está abierta.';

  @override
  String get alertsScreenEmptyTitle => 'Aún no hay alertas';

  @override
  String get alertsScreenEmptyMessage =>
      'Abre un instrumento y toca la campana para configurar una alerta de precio.';

  @override
  String alertsScreenFiredToday(String time) {
    return 'Activada hoy a las $time · desactivada';
  }

  @override
  String get alertsScreenNotificationsOff =>
      'Las notificaciones están desactivadas';

  @override
  String get alertsScreenNotificationsOffMessage =>
      'Activa las notificaciones de Qima para que te avisemos cuando se alcance un precio objetivo.';

  @override
  String get alertsScreenOpenSettings => 'Abrir ajustes';

  @override
  String get confirmDeleteAlertTitle => '¿Eliminar esta alerta?';

  @override
  String get confirmDeleteAlertMessage =>
      'No volverás a recibir avisos de ella.';

  @override
  String get settingsAlerts => 'Alertas';

  @override
  String get settingsAlertsPriceAlerts => 'Alertas de precio';

  @override
  String settingsAlertsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alertas',
      one: '1 alerta',
      zero: 'Sin alertas',
    );
    return '$_temp0';
  }

  @override
  String get settingsAlertsNotifications => 'Notificaciones';

  @override
  String get settingsAlertsNotificationsOn => 'Activadas';

  @override
  String get settingsAlertsNotificationsOff => 'Desactivadas';

  @override
  String get settingsAlertsDeliverOnDevice =>
      'Entregar alertas en este dispositivo';

  @override
  String get settingsAlertsDeliverOnDeviceFooter =>
      'Desactívalo si no quieres que este dispositivo te avise cuando se active una alerta.';

  @override
  String alertNotificationTitleAbove(String name, String target) {
    return '$name está por encima de $target';
  }

  @override
  String alertNotificationTitleBelow(String name, String target) {
    return '$name está por debajo de $target';
  }

  @override
  String alertNotificationTitlePercent(
    String name,
    String percent,
    String window,
  ) {
    return '$name varió un $percent% en $window';
  }

  @override
  String alertNotificationBodyOneOff(String price, String unit) {
    return 'Ahora $price por $unit. Esta alerta se ha desactivado.';
  }

  @override
  String alertNotificationBodyRepeat(String price, String unit) {
    return 'Ahora $price por $unit. Te avisaremos de nuevo la próxima vez que ocurra.';
  }

  @override
  String get settingsBackup => 'Copia de seguridad y restauración';

  @override
  String get settingsBackupSubtitleNever =>
      'Nunca se ha hecho una copia de seguridad';

  @override
  String settingsBackupSubtitle(String date, int instruments, int lots) {
    return 'Última copia $date · $instruments instrumentos, $lots lotes';
  }

  @override
  String get settingsICloudSync => 'Sincronización de iCloud';

  @override
  String get settingsICloudSyncSwitch => 'Sincronizar con iCloud';

  @override
  String get settingsICloudSyncFooter =>
      'Mantiene tu lista de seguimiento, posiciones, tickers personalizados y alertas de precio actualizados en todos tus dispositivos.';

  @override
  String settingsICloudSyncStatusUpToDate(String time) {
    return 'Actualizado · $time';
  }

  @override
  String get settingsICloudSyncStatusSyncing => 'Sincronizando…';

  @override
  String get settingsICloudSyncStatusNotSignedIn =>
      'No has iniciado sesión en iCloud';

  @override
  String get settingsICloudSyncStatusStorageFull =>
      'El almacenamiento de iCloud para Qima está lleno';

  @override
  String get backupTitle => 'Copia de seguridad y restauración';

  @override
  String get backupStatusTitle => 'Guardado solo en este teléfono';

  @override
  String get backupStatusMessage =>
      'Tus datos solo existen en este dispositivo. Haz una copia de seguridad para poder restaurarlos aquí o en otro dispositivo.';

  @override
  String backupLastBackup(String date) {
    return 'Última copia $date';
  }

  @override
  String get backupLastBackupNever =>
      'Nunca se ha hecho una copia de seguridad';

  @override
  String get backupReminderCardTitle => 'Es hora de una copia de seguridad';

  @override
  String get backupReminderCardMessage =>
      'Han pasado más de 30 días desde tu última copia de seguridad y tus datos han cambiado.';

  @override
  String get backupReminderCardAction => 'Hacer copia ahora';

  @override
  String get backupReminderNotificationTitle =>
      'Es hora de una copia de seguridad';

  @override
  String get backupReminderNotificationBody =>
      'Ha pasado un tiempo desde tu última copia de seguridad de Qima y tus datos han cambiado. Toca para hacerla ahora.';

  @override
  String get backupExportSection => 'Exportar';

  @override
  String get backupExportFullTitle => 'Copia de seguridad completa';

  @override
  String get backupExportFullSubtitle =>
      'Lista de seguimiento, posiciones, tickers personalizados, alertas y ajustes (.json)';

  @override
  String get backupExportCsvTitle => 'Hoja de cálculo de posiciones';

  @override
  String get backupExportCsvSubtitle =>
      'Tus lotes como hoja de cálculo, para tus registros (.csv)';

  @override
  String get backupRestoreSection => 'Restaurar';

  @override
  String get backupRestoreTitle => 'Importar una copia de seguridad';

  @override
  String get backupRestoreSubtitle =>
      'Restaurar desde un archivo de copia completa (.json)';

  @override
  String get backupReminderSection => 'Recordatorio';

  @override
  String get backupReminderToggleTitle =>
      'Recordarme hacer copias de seguridad';

  @override
  String get backupReminderToggleSubtitle =>
      'Recibe un recordatorio mensual si no has hecho una copia recientemente y tus datos han cambiado.';

  @override
  String get backupExportSheetTitle => 'Exportar copia de seguridad';

  @override
  String get backupExportSheetFileName => 'Nombre del archivo';

  @override
  String get backupExportSheetFileSize => 'Tamaño';

  @override
  String get backupExportSheetFileContents => 'Contenido';

  @override
  String backupExportSheetContentsSummary(
    int cards,
    int lots,
    int customTickers,
  ) {
    return '$cards tarjetas de seguimiento · $lots lotes · $customTickers tickers personalizados';
  }

  @override
  String get backupExportSheetProtectTitle => 'Proteger con contraseña';

  @override
  String get backupExportSheetProtectSubtitle =>
      'Cifra el archivo con AES-256. Si olvidas esta contraseña, la copia de seguridad no se podrá recuperar.';

  @override
  String get backupExportSheetPasswordLabel => 'Contraseña';

  @override
  String get backupExportSheetPasswordConfirmLabel => 'Confirmar contraseña';

  @override
  String get backupExportSheetPasswordTooShort => 'Usa al menos 8 caracteres.';

  @override
  String get backupExportSheetPasswordMismatch =>
      'Las contraseñas no coinciden.';

  @override
  String get backupExportSheetUnprotectedWarning =>
      'Cualquiera que tenga este archivo puede leer tus datos. Protégelo con una contraseña si planeas guardarlo o enviarlo a un lugar menos privado.';

  @override
  String get backupExportSheetAction => 'Guardar o compartir…';

  @override
  String get backupExportSheetWorking => 'Preparando tu copia de seguridad…';

  @override
  String get backupExportSheetFailed =>
      'No se pudo crear la copia de seguridad. Inténtalo de nuevo.';

  @override
  String get backupImportPreviewTitle => 'Restaurar copia de seguridad';

  @override
  String backupImportFileCreated(String date) {
    return 'Creada el $date';
  }

  @override
  String backupImportFileAppVersion(String version) {
    return 'Creada con Qima $version';
  }

  @override
  String get backupImportCountCards => 'Tarjetas de seguimiento';

  @override
  String get backupImportCountLots => 'Lotes';

  @override
  String get backupImportCountCustomTickers => 'Tickers personalizados';

  @override
  String get backupImportCountSettings => 'Ajustes incluidos';

  @override
  String get backupImportPasswordPrompt =>
      'Esta copia de seguridad está protegida. Introduce la contraseña para continuar.';

  @override
  String get backupImportPasswordLabel => 'Contraseña';

  @override
  String get backupImportPasswordIncorrect =>
      'Esa contraseña no funcionó. Inténtalo de nuevo.';

  @override
  String get backupImportUnlock => 'Desbloquear';

  @override
  String get backupImportModeMerge => 'Combinar';

  @override
  String get backupImportModeReplace => 'Reemplazar';

  @override
  String get backupImportModeMergeFooter =>
      'Mantiene lo que hay en este teléfono y añade lo nuevo o más reciente de la copia de seguridad.';

  @override
  String get backupImportModeReplaceFooter =>
      'Reemplaza todo lo de este teléfono con el contenido de la copia de seguridad.';

  @override
  String backupImportDiff(int added, int updated, int removed) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: '+$added añadidos',
      one: '+1 añadido',
      zero: '',
    );
    return '$_temp0 · $updated actualizados · $removed eliminados';
  }

  @override
  String get backupImportRestoreButton => 'Restaurar';

  @override
  String get backupImportReplaceConfirmTitle =>
      '¿Reemplazar todo en este teléfono?';

  @override
  String get backupImportReplaceConfirmMessage =>
      'Tu lista de seguimiento, posiciones, tickers personalizados y alertas actuales se reemplazarán con el contenido de la copia de seguridad. Esto no se puede deshacer.';

  @override
  String get backupImportReplaceConfirmAction => 'Reemplazar';

  @override
  String get backupImportSuccessSnackbar => 'Copia de seguridad restaurada';

  @override
  String get backupImportFailedTitle =>
      'No se pudo restaurar esta copia de seguridad';

  @override
  String get backupImportCsvErrorTitle =>
      'Esto es una hoja de cálculo, no una copia de seguridad';

  @override
  String get backupImportCsvErrorMessage =>
      'Una hoja de cálculo de posiciones (.csv) solo tiene tus lotes y no se puede restaurar. Elige un archivo de copia de seguridad completa (.json) en su lugar.';

  @override
  String get backupErrorNotQimaFile =>
      'Esto no parece un archivo de copia de seguridad de Qima.';

  @override
  String get backupErrorNewerVersion =>
      'Esta copia de seguridad se creó con una versión más reciente de Qima. Actualiza la app para restaurarla.';

  @override
  String get backupErrorWrongPassword => 'Esa contraseña no funcionó.';

  @override
  String get backupErrorCorrupted =>
      'Este archivo de copia de seguridad está dañado y no se puede restaurar.';

  @override
  String get backupCsvHeaderInstrument => 'Instrumento';

  @override
  String get backupCsvHeaderSymbol => 'Símbolo';

  @override
  String get backupCsvHeaderQuantity => 'Cantidad';

  @override
  String get backupCsvHeaderUnit => 'Unidad';

  @override
  String get backupCsvHeaderKarat => 'Quilate';

  @override
  String get backupCsvHeaderUnitCost => 'Coste unitario';

  @override
  String get backupCsvHeaderCostCurrency => 'Moneda del coste';

  @override
  String get backupCsvHeaderTotalCost => 'Coste total';

  @override
  String get backupCsvHeaderDate => 'Fecha';

  @override
  String get commonContinue => 'Continuar';
}
