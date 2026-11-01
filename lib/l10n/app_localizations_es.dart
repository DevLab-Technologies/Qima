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
  String get navWatchlist => 'Seguimiento';

  @override
  String get watchlistAdd => 'Añadir activo';

  @override
  String get watchlistEmptyTitle => 'Tu lista de seguimiento está vacía';

  @override
  String get watchlistEmptyMessage =>
      'Añade metales, criptomonedas, acciones o divisas para empezar a seguir precios.';

  @override
  String get watchlistFilterAll => 'Todos';

  @override
  String get addTitle => 'Añadir activo';

  @override
  String get addSearchHint => 'Busca o describe una compra';

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
      'Aún no hay transacciones. Añade una compra para empezar a seguir esta tenencia.';

  @override
  String get holdingsValue => 'Valor';

  @override
  String get holdingsCost => 'Coste';

  @override
  String get holdingsGain => 'Ganancia';

  @override
  String get holdingsGainPercent => '% de ganancia';

  @override
  String get holdingsQuantity => 'Cantidad';

  @override
  String get holdingsCostModePerUnit => 'Por unidad';

  @override
  String get holdingsCostModeTotal => 'Total';

  @override
  String get holdingsTotalCost => 'Coste total';

  @override
  String get holdingsDate => 'Fecha';

  @override
  String get holdingsSave => 'Guardar';

  @override
  String get holdingsTotalHeld => 'Total en posesión';

  @override
  String get holdingsAverageCost => 'Coste medio';

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
      'Aún no hay valor de cartera — añade una compra a cualquier activo para empezar.';

  @override
  String get portfolioNoChange =>
      'Aún no hay suficiente historial para este período';

  @override
  String get portfolioNoHistory =>
      'Añade una compra para ver el gráfico de tu cartera';

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
      'Se usa al abrir un activo por primera vez.';

  @override
  String get settingsWidgetRefresh => 'Intervalo de actualización del widget';

  @override
  String get settingsWidgetRefreshFooter =>
      'Con qué frecuencia los widgets en segundo plano obtienen nuevos precios.';

  @override
  String get settingsLanguage => 'Idioma';

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
      'Oculta los importes de la cartera, las posiciones y las transacciones en toda la app.';

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
      'Tus posiciones de este activo se conservan.';

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
  String get alertsCardEmpty => 'Aún no hay alertas para este activo.';

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
  String get alertsScreenEmptyTitle => 'Aún no hay alertas';

  @override
  String get alertsScreenEmptyMessage =>
      'Abre un activo y toca la campana para configurar una alerta de precio.';

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
  String settingsBackupSubtitle(
    String date,
    int instruments,
    int transactions,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      transactions,
      locale: localeName,
      other: '$transactions transacciones',
      one: '1 transacción',
    );
    return 'Última copia $date · $instruments activos, $_temp0';
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
      'Todas las transacciones en una hoja de cálculo (.csv), que también se puede volver a importar';

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
    int transactions,
    int customTickers,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      transactions,
      locale: localeName,
      other: '$transactions transacciones',
      one: '1 transacción',
    );
    return '$cards tarjetas de seguimiento · $_temp0 · $customTickers tickers personalizados';
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
      'Es una hoja de cálculo, no una copia de seguridad de Qima. Puedes importar sus filas como transacciones.';

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
  String get backupCsvHeaderInstrument => 'Activo';

  @override
  String get backupCsvHeaderSymbol => 'Símbolo';

  @override
  String get backupCsvHeaderQuantity => 'Cantidad';

  @override
  String get backupCsvHeaderUnit => 'Unidad';

  @override
  String get backupCsvHeaderKarat => 'Quilate';

  @override
  String get backupCsvHeaderUnitCost => 'Precio por unidad';

  @override
  String get backupCsvHeaderCostCurrency => 'Moneda';

  @override
  String get backupCsvHeaderTotalCost => 'Total';

  @override
  String get backupCsvHeaderDate => 'Fecha';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingGetStarted => 'Empezar';

  @override
  String get onboardingStep1Title => 'Todo lo que tienes, en un número';

  @override
  String get onboardingStep1Body =>
      'Oro, plata, cripto, acciones, índices y divisas, sumados en tu moneda.';

  @override
  String get onboardingStep2Title => 'Precios como los compras';

  @override
  String get onboardingStep2Body =>
      'Precios en vivo por gramo, onza o kilogramo, de 24K a 18K, en cualquier moneda. Toca + para añadir, toca una tarjeta para ver su gráfico.';

  @override
  String get onboardingStep3Title => 'Sabe lo que tienes';

  @override
  String get onboardingStep3Body =>
      'Registra cada compra: cantidad, unidad, quilate, coste y fecha. Consulta lo que tienes, tu coste medio, valor y ganancia.';

  @override
  String get onboardingStep4Title => 'No te pierdas ningún movimiento';

  @override
  String get onboardingStep4Body =>
      'Recibe un aviso cuando un precio cruce un nivel o se mueva un porcentaje. Pon los precios en tu pantalla de inicio y de bloqueo.';

  @override
  String get onboardingStep5Title => 'Privado por diseño';

  @override
  String get onboardingStep5Body =>
      'Sin cuenta. Tus datos permanecen en este dispositivo, con sincronización opcional con iCloud, bloqueo por Face ID y copias de seguridad en archivo.';

  @override
  String get onboardingStep5BodyAndroid =>
      'Sin cuenta. Tus datos permanecen en este dispositivo, con desbloqueo por huella o rostro y copias de seguridad en archivo.';

  @override
  String get onboardingStep5BodyMac =>
      'Sin cuenta. Tus datos permanecen en este Mac, con sincronización opcional con iCloud, bloqueo por Touch ID y copias de seguridad en archivo.';

  @override
  String get onboardingStep5PillNoAccount => 'Sin cuenta';

  @override
  String get onboardingStep5PillOnDevice => 'En este dispositivo';

  @override
  String get onboardingStep5ICloudTitle => 'Sincronización con iCloud';

  @override
  String get onboardingStep5ICloudSubtitle =>
      'Opcional · mantiene los dispositivos sincronizados';

  @override
  String get onboardingStep5AppLockTitle => 'Bloqueo de la app';

  @override
  String get onboardingStep5AppLockSubtitleApple => 'Face ID o huella dactilar';

  @override
  String get onboardingStep5AppLockSubtitleGeneric =>
      'Huella dactilar o desbloqueo facial';

  @override
  String get onboardingStep5AppLockSubtitleMac =>
      'Touch ID o la contraseña del Mac';

  @override
  String get onboardingStep5HideBalancesTitle => 'Ocultar saldos';

  @override
  String get onboardingStep5HideBalancesSubtitle =>
      'Mostrar •••• en lugar de los importes';

  @override
  String get onboardingBaseCurrencyTitle => 'Moneda base';

  @override
  String get onboardingBaseCurrencySubtitle =>
      'Según tu región · cámbiala en Ajustes';

  @override
  String onboardingSemanticStepOf(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String get onboardingReplayTour => 'Repetir el recorrido';

  @override
  String get helpButtonTooltip => 'Ayuda';

  @override
  String get helpSheetAboutHeader => 'ACERCA DE ESTA PÁGINA';

  @override
  String get helpSheetHowToHeader => 'CÓMO USARLA';

  @override
  String get helpSheetIndexHeader => 'AYUDA';

  @override
  String get helpSheetWidgetsHeader => 'AYUDA · AJUSTES';

  @override
  String get helpSheetCloseTooltip => 'Cerrar';

  @override
  String get helpIndexIntro =>
      'Elige una página para ver qué hace y cómo usarla.';

  @override
  String get helpWatchlistTitle => 'Lista de seguimiento';

  @override
  String get helpWatchlistSummary =>
      'Precios en vivo de todo lo que sigues, con el total de tu cartera arriba.';

  @override
  String get helpWatchlistStep1Title => 'Abre una tarjeta';

  @override
  String get helpWatchlistStep1Body =>
      'Toca cualquier tarjeta para ver su gráfico, estadísticas clave y tus posiciones.';

  @override
  String get helpWatchlistStep2Title => 'Añade un activo';

  @override
  String get helpWatchlistStep2Body => 'Toca + y busca por nombre o símbolo.';

  @override
  String get helpWatchlistStep3Title => 'Filtra la lista';

  @override
  String get helpWatchlistStep3Body =>
      'Muestra solo Metales, Cripto, Acciones, Índices o Divisas.';

  @override
  String get helpWatchlistStep4Title => 'Cambia el rango del gráfico';

  @override
  String get helpWatchlistStep4Body =>
      'Elige de 1S a Todo debajo del gráfico de la cartera.';

  @override
  String get helpWatchlistStep5Title => 'Actualiza los precios';

  @override
  String get helpWatchlistStep5Body =>
      'Toca actualizar para obtener los precios más recientes ahora.';

  @override
  String get helpAssetDetailTitle => 'Detalle del activo';

  @override
  String get helpAssetDetailSummary =>
      'El precio, gráfico y estadísticas de un activo, además de lo que tienes de él.';

  @override
  String get helpAssetDetailStep1Title => 'Elige un rango';

  @override
  String get helpAssetDetailStep1Body =>
      'Cambia entre 1D y Todo debajo del gráfico.';

  @override
  String get helpAssetDetailStep2Title =>
      'Cambia la unidad, el quilate o la moneda';

  @override
  String get helpAssetDetailStep2Body =>
      'Toca el icono de ajustes en la parte superior de la página.';

  @override
  String get helpAssetDetailStep3Title => 'Compara unidades';

  @override
  String get helpAssetDetailStep3Body =>
      'El precio por unidad muestra la onza, el kilogramo y cada quilate lado a lado.';

  @override
  String get helpAssetDetailStep4Title => 'Configura una alerta';

  @override
  String get helpAssetDetailStep4Body =>
      'Toca + en la tarjeta Alertas para que te avisen cuando el precio cruce un nivel o se mueva un porcentaje.';

  @override
  String get helpAssetDetailStep5Title => 'Registra lo que tienes';

  @override
  String get helpAssetDetailStep5Body =>
      'Toca Posiciones para ver tus transacciones o añadir una compra o venta.';

  @override
  String get helpPortfolioTitle => 'Cartera';

  @override
  String get helpPortfolioSummary =>
      'Todo lo que tienes, sumado en tu moneda base, con la parte y la ganancia de cada activo.';

  @override
  String get helpPortfolioStep1Title => 'Lee el gráfico circular';

  @override
  String get helpPortfolioStep1Body =>
      'Cada porción representa la parte de un activo en tu valor total.';

  @override
  String get helpPortfolioStep2Title => 'Abre un activo';

  @override
  String get helpPortfolioStep2Body =>
      'Toca una fila para ver sus transacciones, coste medio y ganancia.';

  @override
  String get helpPortfolioStep3Title => 'Añade una compra';

  @override
  String get helpPortfolioStep3Body => 'Abre un activo y toca +.';

  @override
  String get helpPortfolioStep4Title => 'Cambia la moneda';

  @override
  String get helpPortfolioStep4Body =>
      'Los totales usan tu moneda base, definida en Ajustes.';

  @override
  String get helpPortfolioStep5Title => 'Oculta los importes';

  @override
  String get helpPortfolioStep5Body =>
      'Activa Ocultar saldos en Ajustes para enmascarar todos los valores.';

  @override
  String get helpLotEditorTitle => 'Transacción';

  @override
  String get helpLotEditorSummary =>
      'Registra una compra, venta, traspaso o comisión. Tu tenencia, coste medio y ganancias se calculan a partir de ellas.';

  @override
  String get helpLotEditorStep1Title => 'Tipo';

  @override
  String get helpLotEditorStep1Body =>
      'Compra añade a un coste. Venta retira y realiza una ganancia o pérdida. Traspaso mueve cantidad hacia dentro o fuera. Comisión registra un cargo.';

  @override
  String get helpLotEditorStep2Title => 'Quilate';

  @override
  String get helpLotEditorStep2Body =>
      'Para el oro por gramo o kilo, elige 24K, 22K, 21K o 18K. Todo se cuenta por contenido de oro, así que los quilates se combinan bien.';

  @override
  String get helpLotEditorStep3Title => 'Precio y comisión';

  @override
  String get helpLotEditorStep3Body =>
      'Introduce el precio por unidad o el total, y cualquier comisión. Una venta muestra lo que realiza antes de guardar.';

  @override
  String get helpLotEditorStep4Title => 'Fecha';

  @override
  String get helpLotEditorStep4Body =>
      'El día en que ocurrió. Una venta no puede tener fecha anterior a cuando tenías suficiente.';

  @override
  String get helpLotEditorStep5Title => 'Guarda';

  @override
  String get helpLotEditorStep5Body =>
      'Edita o elimina una transacción cuando quieras desde el registro de la tenencia.';

  @override
  String get helpAddAssetTitle => 'Añadir activo';

  @override
  String get helpAddAssetSummary =>
      'Encuentra algo que seguir y añádelo a tu lista de seguimiento.';

  @override
  String get helpAddAssetStep1Title => 'Busca';

  @override
  String get helpAddAssetStep1Body =>
      'Escribe un nombre o símbolo, como oro, BTC o AAPL.';

  @override
  String get helpAddAssetStep2Title => 'Elige un resultado';

  @override
  String get helpAddAssetStep2Body =>
      'Se añade a tu lista de seguimiento y se abre su página.';

  @override
  String get helpAddAssetStep3Title => '¿No está en la lista?';

  @override
  String get helpAddAssetStep3Body =>
      'Añade el símbolo como ticker personalizado. Qima lo comprueba primero con el proveedor de precios.';

  @override
  String get helpAddAssetStep4Title => '¿Cambiaste de opinión?';

  @override
  String get helpAddAssetStep4Body =>
      'Toca Deshacer en la confirmación de abajo.';

  @override
  String get helpPriceAlertsTitle => 'Alertas de precio';

  @override
  String get helpPriceAlertsSummary =>
      'Todas las alertas que has creado, agrupadas por activo.';

  @override
  String get helpPriceAlertsStep1Title => 'Nueva alerta';

  @override
  String get helpPriceAlertsStep1Body =>
      'Toca +, o abre un activo y toca la campana.';

  @override
  String get helpPriceAlertsStep2Title => 'Pausa o reanuda';

  @override
  String get helpPriceAlertsStep2Body =>
      'Usa el interruptor. Las alertas de una sola vez se desactivan solas tras dispararse.';

  @override
  String get helpPriceAlertsStep3Title => 'Cambia o elimina';

  @override
  String get helpPriceAlertsStep3Body =>
      'Toca una alerta para editarla o eliminarla.';

  @override
  String get helpPriceAlertsStep4Title => 'Cuándo llegan las alertas';

  @override
  String get helpPriceAlertsStep4Body =>
      'Los precios se comprueban cada 15 minutos aproximadamente en segundo plano, así que una alerta puede llegar con unos minutos de retraso.';

  @override
  String get helpPriceAlertsStep5Title => '¿No recibes notificaciones?';

  @override
  String get helpPriceAlertsStep5Body =>
      'Permite las notificaciones de Qima en los ajustes del sistema, o las alertas no podrán llegarte.';

  @override
  String get helpAlertEditorTitle => 'Editor de alertas';

  @override
  String get helpAlertEditorSummary =>
      'Elige cuándo debe avisarte Qima sobre este activo.';

  @override
  String get helpAlertEditorStep1Title => 'Precio';

  @override
  String get helpAlertEditorStep1Body =>
      'Avisa cuando el precio suba o baje de tu objetivo.';

  @override
  String get helpAlertEditorStep2Title => '% de movimiento';

  @override
  String get helpAlertEditorStep2Body =>
      'Avisa cuando suba, baje o se mueva en cualquier dirección entre un 1% y un 10% en 24 horas o 7 días.';

  @override
  String get helpAlertEditorStep3Title => 'Comprueba el disparador';

  @override
  String get helpAlertEditorStep3Body =>
      'La línea bajo tu elección muestra exactamente qué precios la activarán.';

  @override
  String get helpAlertEditorStep4Title => 'Repetir';

  @override
  String get helpAlertEditorStep4Body =>
      'Desactivado: la alerta se dispara una vez y se apaga. Activado: se dispara cada vez.';

  @override
  String get helpSettingsTitle => 'Ajustes';

  @override
  String get helpSettingsSummary => 'Opciones que se aplican a toda la app.';

  @override
  String get helpSettingsStep1Title => 'Apariencia';

  @override
  String get helpSettingsStep1Body => 'Sistema, Claro u Oscuro.';

  @override
  String get helpSettingsStep2Title => 'Privacidad y seguridad';

  @override
  String get helpSettingsStep2Body =>
      'Oculta saldos y bloquea Qima con Face ID o huella dactilar.';

  @override
  String get helpSettingsStep3Title => 'Alertas';

  @override
  String get helpSettingsStep3Body =>
      'Consulta todas las alertas de precio y comprueba que las notificaciones estén permitidas.';

  @override
  String get helpSettingsStep4Title => 'Copia de seguridad';

  @override
  String get helpSettingsStep4Body =>
      'Guarda todo en un archivo y restáuralo más tarde.';

  @override
  String get helpSettingsStep5Title => 'Valores predeterminados';

  @override
  String get helpSettingsStep5Body =>
      'Moneda base, rango del gráfico, actualización del widget e idioma.';

  @override
  String get helpBackupTitle => 'Copia de seguridad y restauración';

  @override
  String get helpBackupSummary =>
      'Qima no tiene cuenta, así que un archivo de copia de seguridad es cómo conservas tus datos si este teléfono se pierde o se restablece.';

  @override
  String get helpBackupStep1Title => 'Copia de seguridad completa';

  @override
  String get helpBackupStep1Body =>
      'Guarda tu lista de seguimiento, posiciones, tickers personalizados y ajustes como un archivo .json.';

  @override
  String get helpBackupStep2Title => 'Añade una contraseña';

  @override
  String get helpBackupStep2Body =>
      'Opcional. La necesitarás para restaurar y no se puede recuperar.';

  @override
  String get helpBackupStep3Title => 'Guarda o comparte';

  @override
  String get helpBackupStep3Body =>
      'Guarda el archivo en Archivos o iCloud Drive, o envíatelo a ti mismo.';

  @override
  String get helpBackupStep4Title => 'Restaurar';

  @override
  String get helpBackupStep4Body =>
      'Importa una copia de seguridad .json. Combinar añade lo que falta y no borra nada; Reemplazar cambia todo por el archivo.';

  @override
  String get helpBackupStep5Title => 'Hojas de cálculo';

  @override
  String get helpBackupStep5Body =>
      'Exporta todas las transacciones como .csv o importa uno de Qima, una hoja de cálculo o un bróker. Añade transacciones; no restaura ajustes.';

  @override
  String get helpWidgetsTitle => 'Widgets';

  @override
  String get helpWidgetsSummary =>
      'Pon precios en vivo y tu cartera en la pantalla de inicio y de bloqueo.';

  @override
  String get helpWidgetsStep1Title => 'Mantén pulsada la pantalla de inicio';

  @override
  String get helpWidgetsStep1Body =>
      'Cuando las apps se muevan, toca Editar y luego Añadir widget.';

  @override
  String get helpWidgetsStep2Title => 'Encuentra Qima';

  @override
  String get helpWidgetsStep2Body =>
      'Busca Qima, elige Precio o Cartera, elige un tamaño y toca Añadir widget.';

  @override
  String get helpWidgetsStep3Title => 'Elige qué muestra';

  @override
  String get helpWidgetsStep3Body =>
      'Mantén pulsado el widget, toca Editar widget y elige activo, unidad, quilate, moneda y rango del gráfico.';

  @override
  String get helpWidgetsStep4Title => 'Pantalla de bloqueo';

  @override
  String get helpWidgetsStep4Body =>
      'Mantén pulsada la pantalla de bloqueo, toca Personalizar y añade un widget de Qima.';

  @override
  String get helpWidgetsNote =>
      'Los widgets se actualizan cada 15 minutos de forma predeterminada. Cámbialo en Ajustes, en Intervalo de actualización del widget.';

  @override
  String get helpHoldingsTitle => 'Posiciones';

  @override
  String get helpHoldingsSummary =>
      'Todas las transacciones de este activo (compras, ventas, traspasos y comisiones) y su resultado.';

  @override
  String get helpHoldingsStep1Title => 'Lee los totales';

  @override
  String get helpHoldingsStep1Body =>
      'Lo que tienes, tu coste medio, su valor y ganancia, y lo realizado con las ventas.';

  @override
  String get helpHoldingsStep2Title => 'Añadir una transacción';

  @override
  String get helpHoldingsStep2Body =>
      'Toca Añadir para registrar una compra, una venta, un traspaso o una comisión.';

  @override
  String get helpHoldingsStep3Title => 'Editar o eliminar';

  @override
  String get helpHoldingsStep3Body =>
      'Toca una fila para cambiarla o deslízala para eliminarla. Qima no permite que un cambio haga que una venta supere lo que tenías.';

  @override
  String get helpCardConfigTitle => 'Ajustes del activo';

  @override
  String get helpCardConfigSummary =>
      'Elige la moneda, unidad y quilate que mostrará esta tarjeta antes de añadirla.';

  @override
  String get helpCardConfigStep1Title => 'Moneda';

  @override
  String get helpCardConfigStep1Body =>
      'Los precios se muestran en esta moneda en la tarjeta y su gráfico.';

  @override
  String get helpCardConfigStep2Title => 'Unidad';

  @override
  String get helpCardConfigStep2Body =>
      'Para metales, elige onza troy, gramo o kilogramo.';

  @override
  String get helpCardConfigStep3Title => 'Quilate';

  @override
  String get helpCardConfigStep3Body =>
      'Para el oro por peso, elige la pureza que quieres cotizar.';

  @override
  String get helpCardConfigStep4Title => 'Añádelo';

  @override
  String get helpCardConfigStep4Body =>
      'Puedes cambiar cualquiera de estos ajustes más tarde desde la pantalla de detalle del activo.';

  @override
  String get helpCustomTickerTitle => 'Ticker personalizado';

  @override
  String get helpCustomTickerSummary =>
      'Sigue una acción, ETF o índice que no está en el catálogo de Qima por su símbolo.';

  @override
  String get helpCustomTickerStep1Title => 'Introduce el símbolo';

  @override
  String get helpCustomTickerStep1Body =>
      'Escribe el símbolo exacto del ticker, como TSLA o VOO.';

  @override
  String get helpCustomTickerStep2Title => 'Qima lo comprueba';

  @override
  String get helpCustomTickerStep2Body =>
      'Se comprueba primero con el proveedor de precios, así se detecta un error tipográfico antes de añadirlo.';

  @override
  String get helpCustomTickerStep3Title => 'Añádelo';

  @override
  String get helpCustomTickerStep3Body =>
      'Se añade a tu lista de seguimiento con su nombre y precio reales.';

  @override
  String get helpCurrencyPickerTitle => 'Selector de moneda';

  @override
  String get helpCurrencyPickerSummary =>
      'Elige la moneda en la que se mostrarán los precios y totales.';

  @override
  String get helpCurrencyPickerStep1Title => 'Busca';

  @override
  String get helpCurrencyPickerStep1Body =>
      'Escribe un código ISO o el nombre de una moneda, como EUR o dírham.';

  @override
  String get helpCurrencyPickerStep2Title => 'Elige una';

  @override
  String get helpCurrencyPickerStep2Body =>
      'Toca una moneda para usarla de inmediato.';

  @override
  String get helpImportPreviewTitle => 'Vista previa de restauración';

  @override
  String get helpImportPreviewSummary =>
      'Consulta qué contiene un archivo de copia de seguridad antes de que cambie nada en este teléfono.';

  @override
  String get helpImportPreviewStep1Title => 'Comprueba el contenido';

  @override
  String get helpImportPreviewStep1Body =>
      'Mira cuántas tarjetas, transacciones y alertas contiene el archivo antes de restaurar.';

  @override
  String get helpImportPreviewStep2Title => 'Combinar o Reemplazar';

  @override
  String get helpImportPreviewStep2Body =>
      'Combinar añade lo que falta y no borra nada. Reemplazar cambia todo por el archivo.';

  @override
  String get helpImportPreviewStep3Title => 'Confirma';

  @override
  String get helpImportPreviewStep3Body =>
      'Un archivo protegido con contraseña la pedirá primero.';

  @override
  String get settingsHelpGroup => 'Ayuda';

  @override
  String get settingsHelpReplayTour => 'Repetir el recorrido';

  @override
  String get settingsHelpReplayTourSubtitle =>
      'Vuelve a ver la introducción de cinco pasos';

  @override
  String get settingsHelpHowQimaWorks => 'Cómo funciona Qima';

  @override
  String get settingsHelpHowQimaWorksSubtitle =>
      'Una breve guía de cada página';

  @override
  String get settingsHelpAddWidget => 'Añade un widget';

  @override
  String get settingsHelpAddWidgetSubtitle => 'Pantalla de inicio y de bloqueo';

  @override
  String get commonDone => 'Listo';

  @override
  String get zakatTitle => 'Zakat';

  @override
  String get zakatSettingsTitle => 'Ajustes de zakat';

  @override
  String get settingsZakatSubtitle =>
      'Base del nisab, qué cuenta, fecha del hawl y recordatorio';

  @override
  String get zakatEmptyTitle => 'Aún no hay nada que calcular';

  @override
  String get zakatEmptyMessage =>
      'El zakat se calcula a partir de tus tenencias. Añade una compra a cualquier activo y aparecerá aquí, con lo que cuenta para el nisab.';

  @override
  String get zakatNisabSection => 'Nisab';

  @override
  String get zakatWhatCountsSection => 'Qué cuenta';

  @override
  String get zakatStatusAbove => 'Por encima del nisab';

  @override
  String get zakatStatusBelow => 'Por debajo del nisab';

  @override
  String get zakatStatusUnknown => 'Nisab aún sin precio';

  @override
  String zakatDueLabel(String rate) {
    return 'Zakat a pagar · $rate';
  }

  @override
  String zakatExplainAboveNoHawl(String base) {
    return 'Sobre una base zakatable de $base. Indica la fecha de tu hawl para saber cuándo vence.';
  }

  @override
  String zakatExplainAboveToday(String base) {
    return 'Sobre una base zakatable de $base. Tu hawl se cumple hoy.';
  }

  @override
  String zakatExplainAboveUpcoming(String base, String date, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'en $days días',
      one: 'en 1 día',
    );
    return 'Sobre una base zakatable de $base. Vence cuando tu hawl se cumpla el $date ($_temp0), si tu patrimonio sigue por encima del nisab.';
  }

  @override
  String zakatExplainBelow(String base, String threshold) {
    return 'Tu base zakatable de $base está por debajo del nisab de hoy, $threshold, así que no hay zakat a pagar.';
  }

  @override
  String zakatExplainUnknown(String metal) {
    return 'El precio de hoy del $metal no se ha cargado, así que aún no se puede comprobar el nisab.';
  }

  @override
  String get zakatRetry => 'Reintentar';

  @override
  String get zakatUnpricedNote =>
      'Algunos activos aún no tienen precio y no se cuentan. Contarán en cuanto cargue su precio.';

  @override
  String get zakatBasisRow => 'Base';

  @override
  String zakatBasisValue(String metal, String grams) {
    return '$metal · $grams g';
  }

  @override
  String zakatOtherBasisLine(String metal, String amount) {
    return 'Con base en $metal sería $amount';
  }

  @override
  String get zakatThresholdToday => 'Umbral hoy';

  @override
  String get zakatYourBase => 'Tu base zakatable';

  @override
  String get zakatHawlStart => 'Inicio del hawl';

  @override
  String get zakatHawlSet => 'Fijar fecha';

  @override
  String get zakatHawlNotSetSubtitle =>
      'El día en que tu patrimonio alcanzó el nisab por primera vez';

  @override
  String get zakatHawlCompletesToday => 'se cumple hoy';

  @override
  String zakatHawlNext(String date) {
    return 'el próximo se cumple el $date';
  }

  @override
  String get zakatWhatCountsFooter =>
      'Desactiva un activo para excluirlo; por ejemplo, joyas de uso diario si sigues la opinión de que están exentas.';

  @override
  String zakatExcludedClass(String cls) {
    return '$cls desactivado';
  }

  @override
  String get zakatExcludedHolding => 'excluido';

  @override
  String get zakatExcludedNoPrice => 'aún sin precio';

  @override
  String zakatLineTitle(String name, String quantity) {
    return '$name · $quantity';
  }

  @override
  String get zakatDisclaimer =>
      'Qima calcula; no dictamina. La base y lo que cuenta los decides tú; consulta a un sabio de confianza si tienes dudas.';

  @override
  String get assetGroupMetals => 'Metales';

  @override
  String get assetGroupCrypto => 'Cripto';

  @override
  String get assetGroupEquities => 'Acciones';

  @override
  String get assetGroupCash => 'Efectivo y divisas';

  @override
  String get zakatClassMetalsSubtitle => 'Oro, plata, platino, paladio';

  @override
  String get zakatClassCryptoSubtitle => 'Tratadas como activo negociable';

  @override
  String get zakatClassEquitiesSubtitle =>
      'Desactivado por defecto: las opiniones sobre acciones a largo plazo difieren';

  @override
  String get zakatClassCashSubtitle => 'Las divisas que tienes';

  @override
  String zakatOverridesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activos ajustados individualmente',
      one: '1 activo ajustado individualmente',
    );
    return '$_temp0';
  }

  @override
  String get zakatOverridesSubtitle =>
      'Elegidos en la pantalla de zakat, por encima de su clase';

  @override
  String get zakatOverridesReset => 'Restablecer';

  @override
  String get zakatNisabBasisSection => 'Base del nisab';

  @override
  String get zakatClassesSection => 'Clases zakatables';

  @override
  String get zakatHawlSection => 'Hawl';

  @override
  String get zakatBasisPriceMissing => 'Precio aún no cargado';

  @override
  String zakatBasisToday(String amount) {
    return '$amount hoy';
  }

  @override
  String zakatBasisHigher(String amount) {
    return 'Umbral más alto · $amount hoy';
  }

  @override
  String zakatBasisLower(String amount) {
    return 'Umbral más bajo · $amount hoy · más personas deben pagar';
  }

  @override
  String get zakatCalendar => 'Calendario';

  @override
  String get zakatCalendarHijri => 'Hégira';

  @override
  String get zakatCalendarGregorian => 'Gregoriano';

  @override
  String zakatGregorianNote(String solarRate, String rate) {
    return 'Un año gregoriano dura unos 11 días más que uno lunar. Algunos sabios suben el porcentaje al $solarRate por ello; Qima mantiene el $rate.';
  }

  @override
  String get zakatHawlClear => 'Borrar fecha del hawl';

  @override
  String get zakatRemind => 'Recordármelo';

  @override
  String get zakatRemindSubtitle =>
      'Una notificación el día en que se cumple tu hawl';

  @override
  String get zakatRemindNeedsStart =>
      'Primero indica la fecha de inicio del hawl';

  @override
  String get zakatRemindNotificationsOff =>
      'Las notificaciones de Qima están desactivadas; actívalas en los ajustes del sistema para recibir este recordatorio';

  @override
  String get zakatHawlPickerTitle => 'Inicio del hawl';

  @override
  String get zakatHawlPickerDay => 'Día';

  @override
  String get zakatHawlPickerMonth => 'Mes';

  @override
  String get zakatHawlPickerYear => 'Año';

  @override
  String get zakatHawlPickerFuture => 'Un hawl no puede empezar en el futuro';

  @override
  String zakatHawlPickerGregorian(String date) {
    return 'Gregoriano: $date';
  }

  @override
  String zakatEntryDue(String amount) {
    return '$amount a pagar · por encima del nisab';
  }

  @override
  String get zakatEntryCalculate => 'Ver lo que corresponde';

  @override
  String get zakatReminderNotificationTitle => 'Tu hawl se ha cumplido';

  @override
  String get zakatReminderNotificationBody =>
      'Tu año de zakat se ha cumplido hoy. Abre Qima para ver lo que corresponde.';

  @override
  String get hijriMonth1 => 'Muharram';

  @override
  String get hijriMonth2 => 'Safar';

  @override
  String get hijriMonth3 => 'Rabi al-Awwal';

  @override
  String get hijriMonth4 => 'Rabi al-Thani';

  @override
  String get hijriMonth5 => 'Yumada al-Ula';

  @override
  String get hijriMonth6 => 'Yumada al-Ajira';

  @override
  String get hijriMonth7 => 'Rayab';

  @override
  String get hijriMonth8 => 'Shaabán';

  @override
  String get hijriMonth9 => 'Ramadán';

  @override
  String get hijriMonth10 => 'Shawwal';

  @override
  String get hijriMonth11 => 'Dhu al-Qada';

  @override
  String get hijriMonth12 => 'Dhu al-Hiyya';

  @override
  String hijriDate(int day, String month, int year) {
    return '$day de $month de $year H';
  }

  @override
  String get helpZakatTitle => 'Zakat';

  @override
  String get helpZakatSummary =>
      'Qima calcula el zakat a partir de tus tenencias a precios de hoy. Calcula; las decisiones detrás del cálculo son tuyas.';

  @override
  String get helpZakatStep1Title => 'Nisab';

  @override
  String get helpZakatStep1Body =>
      'El umbral son 85 g de oro fino o 595 g de plata, a precio actual. Elige la base en los ajustes de zakat; la plata es más baja, así que más personas deben pagar.';

  @override
  String get helpZakatStep2Title => 'Qué cuenta';

  @override
  String get helpZakatStep2Body =>
      'Metales, cripto y efectivo cuentan por defecto; las acciones no. El oro con quilates cuenta por su contenido de oro. Desactiva cualquier activo en la pantalla de zakat.';

  @override
  String get helpZakatStep3Title => 'Hawl';

  @override
  String get helpZakatStep3Body =>
      'Indica el día en que tu patrimonio alcanzó el nisab por primera vez. El zakat vence cada año lunar desde entonces, y Qima puede recordártelo ese día.';

  @override
  String get helpZakatStep4Title => 'Una calculadora, no una fetua';

  @override
  String get helpZakatStep4Body =>
      'Los sabios difieren sobre la base, las acciones y las joyas. Todo valor por defecto se puede cambiar; si dudas, consulta a un sabio de confianza.';

  @override
  String get allocationTitle => 'Distribución';

  @override
  String get allocationDetails => 'Detalles';

  @override
  String get allocationByGroup => 'Por grupo';

  @override
  String get allocationMetalsByForm => 'Metales · por quilate y tipo';

  @override
  String allocationMetalForm(String metal, String karat) {
    return '$metal $karat';
  }

  @override
  String get allocationDriftTitle => 'Variación';

  @override
  String allocationDriftSince(String date) {
    return 'Variación · desde el $date';
  }

  @override
  String allocationDriftChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get allocationDriftPendingTitle => 'Antes de tener historial';

  @override
  String allocationDriftPending(String date) {
    return 'La evolución de tu distribución aparecerá cuando tus tenencias tengan 14 días, el $date. Hasta entonces, esta es la distribución de hoy; no se inventa ninguna tendencia.';
  }

  @override
  String get allocationDriftNoHistory =>
      'Aún no hay suficientes precios guardados para saber cómo era tu distribución entonces. Se completará a medida que cargue el historial de precios.';

  @override
  String allocationSingleGroup(String group) {
    return 'Todo en $group';
  }

  @override
  String get backupImportCountTransactions => 'Transacciones';

  @override
  String portfolioTransactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transacciones',
      one: '1 transacción',
    );
    return '$_temp0';
  }

  @override
  String get portfolioClosedPositions => 'Posiciones cerradas';

  @override
  String ledgerTitleWithKarat(String name, String karat) {
    return '$name · $karat';
  }

  @override
  String get ledgerAdd => 'Añadir';

  @override
  String get ledgerAddFirst => 'Añadir transacción';

  @override
  String get ledgerHolding => 'Tenencia';

  @override
  String get ledgerNothingHeld => 'Nada en cartera ahora';

  @override
  String ledgerPerUnit(String amount, String unit) {
    return '$amount / $unit';
  }

  @override
  String get ledgerMarketValue => 'Valor de mercado';

  @override
  String get ledgerUnrealised => 'No realizado';

  @override
  String get ledgerRealised => 'Realizado';

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
    return '$date · $price · comisión $fee';
  }

  @override
  String get ledgerNoCostBasis => 'sin coste base';

  @override
  String get ledgerCostCarried => 'con coste trasladado';

  @override
  String get ledgerFootnote =>
      'El coste base se calcula a partir de este registro, no se guarda. Editar cualquier fila recalcula la tenencia.';

  @override
  String get ledgerOverdrawnBanner =>
      'Aquí hay una venta de más de lo que se tenía en su fecha, normalmente por editar en dos dispositivos a la vez. Cuenta como vender lo que quedaba; edítala o elimínala para corregir los totales.';

  @override
  String ledgerClosedLine(String amount) {
    return 'Nada en cartera · realizado $amount';
  }

  @override
  String get ledgerConflictSaveTitle => 'Eso vendería de más';

  @override
  String get ledgerConflictDeleteTitle => 'Aún no se puede eliminar';

  @override
  String ledgerConflictMessage(String kind, String date) {
    return 'Entonces la operación de $kind del $date vendería más de lo que se tenía. Edítala o elimínala primero.';
  }

  @override
  String get confirmDeleteTransactionTitle => '¿Eliminar esta transacción?';

  @override
  String confirmDeleteTransactionMessage(String details) {
    return '$details. La tenencia se recalculará sin ella. No se puede deshacer.';
  }

  @override
  String get transactionNewTitle => 'Nueva transacción';

  @override
  String get transactionEditTitle => 'Editar transacción';

  @override
  String get transactionKindBuy => 'Compra';

  @override
  String get transactionKindSell => 'Venta';

  @override
  String get transactionKindTransfer => 'Traspaso';

  @override
  String get transactionKindTransferIn => 'Traspaso de entrada';

  @override
  String get transactionKindTransferOut => 'Traspaso de salida';

  @override
  String get transactionKindFee => 'Comisión';

  @override
  String get transactionTransferInLabel => 'Entrada';

  @override
  String get transactionTransferOutLabel => 'Salida';

  @override
  String transactionFineHint(String quantity) {
    return '= $quantity de oro fino';
  }

  @override
  String transactionPerUnitKarat(String unit, String karat) {
    return '$unit · $karat';
  }

  @override
  String transactionBuyPrice(String unit) {
    return 'Precio pagado (por $unit)';
  }

  @override
  String transactionSalePrice(String unit) {
    return 'Precio de venta (por $unit)';
  }

  @override
  String transactionCarriedCost(String unit) {
    return 'Coste original (por $unit, opcional)';
  }

  @override
  String get transactionTotalProceeds => 'Importe total de la venta';

  @override
  String get transactionTotalCarriedCost => 'Coste total original (opcional)';

  @override
  String get transactionTransferCostHelper =>
      'Lo que costó originalmente, si lo sabes. Si lo dejas vacío, se añade sin coste base.';

  @override
  String get transactionFee => 'Comisión (opcional)';

  @override
  String get transactionFeeAmount => 'Importe de la comisión';

  @override
  String get transactionFeeLabel => 'Concepto (opcional)';

  @override
  String get transactionNote => 'Nota (opcional)';

  @override
  String get transactionNeedsQuantity => 'Introduce una cantidad.';

  @override
  String get transactionNeedsPrice => 'Introduce un precio.';

  @override
  String get transactionNeedsFee => 'Introduce el importe de la comisión.';

  @override
  String transactionMoreThanHeld(String held) {
    return 'Es más de lo que tenías en esa fecha ($held).';
  }

  @override
  String get transactionPreviewTitle => 'Vista previa de la ganancia realizada';

  @override
  String get transactionProceeds => 'Ingresos';

  @override
  String get transactionBasisReleased => 'Coste base liberado';

  @override
  String get transactionRealisedGain => 'Ganancia realizada';

  @override
  String transactionPreviewRemaining(String quantity, String average) {
    return 'Base de coste medio ponderado. Seguirás teniendo: $quantity a $average.';
  }

  @override
  String get transactionPreviewClosesPosition =>
      'Base de coste medio ponderado. Esto vende todo lo que tienes.';

  @override
  String get backupCsvHeaderType => 'Tipo';

  @override
  String get backupCsvHeaderFee => 'Comisión';

  @override
  String get backupCsvHeaderNote => 'Nota';

  @override
  String get csvImportTitle => 'Importar desde una hoja de cálculo';

  @override
  String get csvImportEntryTitle => 'Importar transacciones desde CSV';

  @override
  String get csvImportEntrySubtitle =>
      'Desde una hoja de cálculo, un bróker u otra app';

  @override
  String get csvImportFromBackupError => 'Importarlas como transacciones';

  @override
  String csvImportRowCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filas',
      one: '1 fila',
    );
    return '$_temp0';
  }

  @override
  String get csvImportEmptyFile =>
      'Este archivo tiene una fila de encabezados pero ningún dato.';

  @override
  String get csvImportColumnsSection => 'Columnas';

  @override
  String get csvImportColumnsFooter =>
      'Emparejadas con la fila de encabezados cuando ha sido posible. Basta un precio o un total; el activo puede ser un símbolo o un nombre. * obligatorio.';

  @override
  String get csvImportNotInFile => 'No está en el archivo';

  @override
  String get csvImportOptionsSection => 'Lectura del archivo';

  @override
  String get csvImportFallbackCurrency => 'Moneda';

  @override
  String get csvImportFallbackCurrencySubtitle =>
      'Para las filas que no indican ninguna';

  @override
  String get csvImportDateOrder => 'Fechas como 03/04/2026 significan';

  @override
  String get csvImportDayFirst => '3 de abril';

  @override
  String get csvImportMonthFirst => '4 de marzo';

  @override
  String get csvImportDecimalComma => 'La coma es el separador decimal';

  @override
  String get csvImportDecimalCommaSubtitle =>
      'Leer 1.234,56 como mil doscientos…';

  @override
  String get csvImportNeedsColumns =>
      'Elige al menos el activo, la fecha y la cantidad.';

  @override
  String get csvImportReview => 'Revisar filas';

  @override
  String get csvImportReadyCount => 'Listas';

  @override
  String get csvImportDuplicateCount => 'Ya en Qima';

  @override
  String get csvImportProblemCount => 'No se pueden importar';

  @override
  String get csvImportSkipNote =>
      'Las filas que no se pueden leer o que ya están en Qima se omiten. No se adivina nada.';

  @override
  String get csvImportShowAll => 'Todas';

  @override
  String get csvImportShowProblems => 'Solo omitidas';

  @override
  String get csvImportSkipped => 'Omitida';

  @override
  String get csvImportDuplicate => 'Duplicada';

  @override
  String get csvImportBackToColumns => 'Columnas';

  @override
  String csvImportConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importar $count transacciones',
      one: 'Importar 1 transacción',
      zero: 'Nada que importar',
    );
    return '$_temp0';
  }

  @override
  String csvImportDoneTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transacciones importadas',
      one: '1 transacción importada',
    );
    return '$_temp0';
  }

  @override
  String get csvImportDoneMessage =>
      'Ya están en el registro de cada activo. Si algo no cuadra, deshacer elimina exactamente lo que añadió esta importación.';

  @override
  String get csvImportUndo => 'Deshacer esta importación';

  @override
  String csvImportUndone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se eliminaron $count transacciones importadas',
      one: 'Se eliminó 1 transacción importada',
    );
    return '$_temp0';
  }

  @override
  String get csvFieldType => 'Tipo';

  @override
  String get csvFieldAsset => 'Nombre del activo';

  @override
  String get csvFieldSymbol => 'Símbolo';

  @override
  String get csvFieldQuantity => 'Cantidad';

  @override
  String get csvFieldUnit => 'Unidad';

  @override
  String get csvFieldKarat => 'Quilates';

  @override
  String get csvFieldUnitPrice => 'Precio por unidad';

  @override
  String get csvFieldTotal => 'Total';

  @override
  String get csvFieldFee => 'Comisión';

  @override
  String get csvFieldCurrency => 'Moneda';

  @override
  String get csvFieldDate => 'Fecha';

  @override
  String get csvFieldNote => 'Nota';

  @override
  String get csvProblemUnknownAsset => 'activo desconocido';

  @override
  String get csvProblemMissingQuantity => 'sin cantidad';

  @override
  String get csvProblemBadNumber => 'un número no se puede leer';

  @override
  String get csvProblemMissingPrice => 'sin precio';

  @override
  String get csvProblemMissingDate => 'sin fecha';

  @override
  String get csvProblemBadDate => 'fecha ilegible';

  @override
  String get csvProblemFutureDate => 'fecha futura';

  @override
  String get csvProblemUnknownType => 'tipo desconocido';

  @override
  String get csvProblemUnknownCurrency => 'moneda desconocida';

  @override
  String get csvProblemUnsupportedUnit => 'unidad no válida para este activo';

  @override
  String get csvProblemUnsupportedKarat =>
      'quilates no válidos para este activo';

  @override
  String get csvProblemOversell => 'vende más de lo que se tenía';

  @override
  String get csvProblemDuplicate => 'ya está en Qima';

  @override
  String get transactionBuyPricePlain => 'Precio pagado';

  @override
  String get transactionSalePricePlain => 'Precio de venta';

  @override
  String get transactionCarriedCostPlain => 'Coste original (opcional)';

  @override
  String settingsVersion(String version, String build) {
    return 'Versión $version ($build)';
  }

  @override
  String get watchlistEditOrder => 'Editar orden';

  @override
  String get watchlistSortBy => 'Ordenar por';

  @override
  String get watchlistSortName => 'Nombre';

  @override
  String get watchlistSortChange => 'Mejor rendimiento';

  @override
  String get watchlistSortAssetClass => 'Tipo de activo';

  @override
  String watchlistDragHandle(String name) {
    return 'Mover $name';
  }

  @override
  String get watchlistEditOrderHint =>
      'Arrastra los controles para reordenar. Ordenar fija un nuevo orden que puedes seguir ajustando.';

  @override
  String get shareAction => 'Compartir';

  @override
  String shareTitle(String name) {
    return 'Compartir $name';
  }

  @override
  String get shareToWhatsappMessage => 'Mensaje de WhatsApp';

  @override
  String get shareToWhatsappStatus => 'Estado de WhatsApp';

  @override
  String get shareToInstagramPost => 'Publicación de Instagram';

  @override
  String get shareToInstagramStory => 'Historia de Instagram';

  @override
  String get shareToFacebookPost => 'Publicación de Facebook';

  @override
  String get shareToFacebookStory => 'Historia de Facebook';

  @override
  String get shareToLinkedinPost => 'Publicación de LinkedIn';

  @override
  String shareCaption(String name, String price) {
    return '$name está a $price.';
  }

  @override
  String shareCaptionWithChange(
    String name,
    String price,
    String change,
    String range,
  ) {
    return '$name está a $price ($change, $range).';
  }

  @override
  String shareCaptionFooter(String url) {
    return 'Seguido con Qima: $url';
  }

  @override
  String get shareCaptionCopied =>
      'Texto copiado. Pégalo si la app no lo incluye.';

  @override
  String get shareFailed => 'No se pudo crear la imagen. Inténtalo de nuevo.';

  @override
  String get helpWatchlistStep6Title => 'Cambia el orden';

  @override
  String get helpWatchlistStep6Body =>
      'Toca las flechas de arriba para arrastrar las tarjetas por sus controles u ordenarlas por nombre, rendimiento o tipo de activo. También puedes mantener pulsada una tarjeta para arrastrarla.';

  @override
  String get helpAssetDetailStep6Title => 'Compártelo';

  @override
  String get helpAssetDetailStep6Body =>
      'Toca compartir para publicar el precio y el gráfico como una imagen a la medida de WhatsApp, Instagram, Facebook o LinkedIn, con un texto listo.';

  @override
  String get captureRecordThis => 'Registrar esto';

  @override
  String get captureCheckTitle => 'Revisa esto';

  @override
  String get captureYouWrote => 'Escribiste';

  @override
  String get captureRead => 'Entendido como';

  @override
  String get captureFieldType => 'Tipo';

  @override
  String get captureFieldAsset => 'Activo';

  @override
  String get captureFieldQuantity => 'Cantidad';

  @override
  String get captureFieldPrice => 'Precio';

  @override
  String get captureFieldFee => 'Comisión';

  @override
  String get captureFieldDate => 'Fecha';

  @override
  String captureFrom(String words) {
    return 'de «$words»';
  }

  @override
  String get captureBaseCurrency => 'tu moneda base';

  @override
  String get captureTotalDivided => 'total ÷ cantidad';

  @override
  String get captureAssumed => 'supuesto';

  @override
  String get captureToday => 'hoy';

  @override
  String get captureCheck => 'revisar';

  @override
  String get captureConfirm => 'Confirmar';

  @override
  String get captureEditFields => 'Editar campos';

  @override
  String get captureFootnote =>
      'Cada campo indica de dónde salió, y no se guarda nada hasta que confirmes.';

  @override
  String get captureOnDevice => 'En el dispositivo';

  @override
  String get captureNothingSent =>
      'Se lee en este dispositivo. No se envía nada a ningún sitio.';

  @override
  String get captureNeedsPrice =>
      'No se encontró un precio. Edita los campos para añadirlo.';

  @override
  String captureRecorded(String summary) {
    return 'Registrado: $summary';
  }
}
