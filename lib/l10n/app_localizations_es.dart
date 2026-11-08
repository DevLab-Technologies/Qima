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
  String get watchlistAdd => 'Añadir a seguimiento';

  @override
  String get watchlistEmptyTitle => 'Tu lista de seguimiento está vacía';

  @override
  String get watchlistEmptyMessage =>
      'Añade metales, criptomonedas, acciones o divisas para empezar a seguir precios.';

  @override
  String get watchlistFilterAll => 'Todos';

  @override
  String get addTitle => 'Añadir a seguimiento';

  @override
  String get addSearchHint => 'Busca o describe una compra';

  @override
  String get addWatchSearchHint => 'Busca oro, Bitcoin, AAPL…';

  @override
  String addSearchCustomTickerTitle(String query) {
    return 'Añadir “$query” como símbolo personalizado';
  }

  @override
  String addSearchMatchedAlias(String alias) {
    return 'También «$alias»';
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
      'Oro, plata, cripto, acciones, índices y divisas, sumados en tu moneda, con un resumen claro de cada mes.';

  @override
  String get onboardingStep2Title => 'Precios como los compras';

  @override
  String get onboardingStep2Body =>
      'Precios en vivo por gramo, onza o kilo, de 24K a 18K, en cualquier moneda. Toca + para añadir a tu seguimiento y una tarjeta para ver su gráfico.';

  @override
  String get onboardingStep3Title => 'Sabe lo que tienes';

  @override
  String get onboardingStep3Body =>
      'Toca + y luego Añadir posición, y escribe lo que compraste, o díctalo o escanea un recibo. Se lee en este dispositivo y solo se guarda cuando confirmas. Ve lo que tienes, tu coste medio, valor y ganancia.';

  @override
  String get onboardingStep4Title => 'No te pierdas ningún movimiento';

  @override
  String get onboardingStep4Body =>
      'Recibe un aviso cuando un precio cruce un nivel o se mueva un porcentaje. Pon los precios en tu pantalla de inicio y de bloqueo.';

  @override
  String get onboardingStep4BodyApple =>
      'Recibe un aviso cuando un precio cruce un nivel o se mueva un porcentaje. Pon precios en tu pantalla de inicio y de bloqueo, o pregunta a Siri cuánto vale tu cartera.';

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
  String get helpHomeSummary =>
      'Tu patrimonio neto: todo lo que tienes menos todo lo que debes, con las tarjetas que más usas.';

  @override
  String get helpHomeStep1Title => 'Patrimonio neto';

  @override
  String get helpHomeStep1Body =>
      'Tócalo para abrir el balance: lo que tienes y lo que debes, partida por partida.';

  @override
  String get helpHomeStep2Title => 'Tus tarjetas';

  @override
  String get helpHomeStep2Body =>
      'Cuentas, Disponible para gastar, Próximamente y otras aparecen cuando las usas. Toca una tarjeta para abrirla.';

  @override
  String get helpHomeStep3Title => 'Editar inicio';

  @override
  String get helpHomeStep3Body =>
      'Mueve las tarjetas u oculta las que no necesites. Qima nunca vuelve a mostrar una tarjeta que ocultaste.';

  @override
  String get helpHomeStep4Title => 'Ocultar saldos';

  @override
  String get helpHomeStep4Body =>
      'Toca el ojo para ocultar todos los importes cuando alguien esté mirando.';

  @override
  String get helpHomeStep5Title => 'Añade lo que sea';

  @override
  String get helpHomeStep5Body =>
      'Toca + para un movimiento, un extracto, una inversión o cualquier cosa en Más.';

  @override
  String get helpMoneySummary =>
      'A dónde fue el dinero de este mes, y lo que entró y salió.';

  @override
  String get helpMoneyStep1Title => 'Elige un mes';

  @override
  String get helpMoneyStep1Body =>
      'Usa las flechas de arriba para ver otro mes.';

  @override
  String get helpMoneyStep2Title => 'Gastado y ritmo';

  @override
  String get helpMoneyStep2Body =>
      'Lo que llevas gastado y dónde acabarás el mes a este ritmo.';

  @override
  String get helpMoneyStep3Title => 'A dónde fue';

  @override
  String get helpMoneyStep3Body => 'El gasto por categoría, de mayor a menor.';

  @override
  String get helpMoneyStep4Title => 'Flujo de caja';

  @override
  String get helpMoneyStep4Body =>
      'Dinero que entra, que sale y lo que sobra. Los movimientos entre tus cuentas no cuentan.';

  @override
  String get helpMoneyStep5Title => 'Merece un vistazo';

  @override
  String get helpMoneyStep5Body =>
      'Notas sobre presupuestos y movimientos por clasificar, cuando hay algo que ver.';

  @override
  String get helpNewTransactionSummary =>
      'Registra dinero gastado, ganado o movido entre tus cuentas.';

  @override
  String get helpNewTransactionStep1Title => 'Elige el tipo';

  @override
  String get helpNewTransactionStep1Body =>
      'Gasto, Ingreso o Transferencia. El importe y la fecha se mantienen al cambiar.';

  @override
  String get helpNewTransactionStep2Title => 'Dilo';

  @override
  String get helpNewTransactionStep2Body =>
      'Toca el micrófono y di, por ejemplo, «Gasté 45 en Mercadona con la Visa ayer». Qima rellena el formulario en este dispositivo; revísalo y toca Guardar.';

  @override
  String get helpNewTransactionStep3Title => 'Categoría';

  @override
  String get helpNewTransactionStep3Body =>
      'El gasto y el ingreso van en una categoría. Mover dinero entre tus cuentas nunca es gasto.';

  @override
  String get helpNewTransactionStep4Title => 'Rechazado';

  @override
  String get helpNewTransactionStep4Body =>
      'Activa Rechazado para un pago que no se completó: aparece tachado y nunca cuenta.';

  @override
  String get helpTransactionsSummary =>
      'Todos los movimientos, del más reciente al más antiguo, y lo que hizo cada uno en tus cuentas.';

  @override
  String get helpTransactionsStep1Title => 'Abre uno';

  @override
  String get helpTransactionsStep1Body =>
      'Toca un movimiento para ver cada cuenta afectada y en cuánto.';

  @override
  String get helpTransactionsStep2Title => 'Cómo cuenta';

  @override
  String get helpTransactionsStep2Body =>
      'Cada uno indica si es gasto, ingreso, un movimiento entre tus cuentas o un cambio de valor.';

  @override
  String get helpTransactionsStep3Title => 'Editar o eliminar';

  @override
  String get helpTransactionsStep3Body =>
      'Ábrelo y edítalo o elimínalo. Eliminarlo deja cada cuenta como estaba.';

  @override
  String get helpAccountsSummary =>
      'Cuentas bancarias, efectivo, tarjetas y préstamos, con lo que hay en cada uno hoy.';

  @override
  String get helpAccountsStep1Title => 'Añadir una cuenta';

  @override
  String get helpAccountsStep1Body =>
      'Dale un nombre, un tipo y su saldo de hoy. Qima empieza desde esa cifra.';

  @override
  String get helpAccountsStep2Title => 'Comprobar el saldo';

  @override
  String get helpAccountsStep2Body =>
      'Abre una cuenta e introduce lo que muestra tu banco. Si hay diferencia, elige: añadir un movimiento, o cambiar el saldo inicial para que nada cuente como gasto.';

  @override
  String get helpAccountsStep3Title => 'Contar el efectivo';

  @override
  String get helpAccountsStep3Body =>
      'Para el efectivo, cuenta lo que hay en tu cartera y Qima ajusta el saldo.';

  @override
  String get helpAccountsStep4Title => 'Pagar una tarjeta o un préstamo';

  @override
  String get helpAccountsStep4Body =>
      'Abre la tarjeta o el préstamo y toca Pagar para registrar un pago desde otra cuenta.';

  @override
  String get helpAccountsStep5Title => 'Quitar una';

  @override
  String get helpAccountsStep5Body =>
      'Una cuenta con movimientos se archiva para que su historial cuadre. Una que nunca se usó se elimina.';

  @override
  String get helpBalanceSheetSummary =>
      'Todo lo que tienes y todo lo que debes, hasta llegar a tu patrimonio neto.';

  @override
  String get helpBalanceSheetStep1Title => 'Lo que tienes';

  @override
  String get helpBalanceSheetStep1Body =>
      'Cuentas, inversiones a precio en vivo y bienes al valor que tú fijas.';

  @override
  String get helpBalanceSheetStep2Title => 'Lo que debes';

  @override
  String get helpBalanceSheetStep2Body =>
      'Tarjetas, préstamos (solo el principal) y el dinero que debes a otras personas.';

  @override
  String get helpBalanceSheetStep3Title => 'Cómo se calcula el total';

  @override
  String get helpBalanceSheetStep3Body =>
      'Ábrelo para ver cada regla, como el tipo de cambio en vivo de otras monedas.';

  @override
  String get helpBalanceSheetStep4Title => 'Excluir una';

  @override
  String get helpBalanceSheetStep4Body =>
      'Desactiva Contar en el patrimonio en una cuenta o un bien; su historial sigue cuadrando.';

  @override
  String get helpAssetsSummary =>
      'Una vivienda, un terreno, un coche o una participación en un negocio, al valor que tú fijas.';

  @override
  String get helpAssetsStep1Title => 'Añadir un bien';

  @override
  String get helpAssetsStep1Body =>
      'Elige un tipo y dale un valor y una fecha. El oro y la plata al peso son inversiones.';

  @override
  String get helpAssetsStep2Title => 'Actualizar el valor';

  @override
  String get helpAssetsStep2Body =>
      'Cada actualización lleva fecha. Cuenta la última; las anteriores quedan como historial.';

  @override
  String get helpAssetsStep3Title => 'Un préstamo sobre él';

  @override
  String get helpAssetsStep3Body =>
      'Vincula el préstamo garantizado con él para ver lo que queda por pagar junto a su valor.';

  @override
  String get helpAssetsStep4Title => 'Lo vendí';

  @override
  String get helpAssetsStep4Body =>
      'Registra la venta: el dinero entra en una cuenta y el bien sale de tu balance.';

  @override
  String get helpImportStatementSummary =>
      'Trae movimientos del PDF, Excel o CSV de tu banco, de capturas de pantalla o de un archivo copiado.';

  @override
  String get helpImportStatementStep1Title => 'Elige los archivos';

  @override
  String get helpImportStatementStep1Body =>
      'Desde Archivos, Fotos, el portapapeles o Compartir › Qima desde cualquier app. Se leen en este dispositivo.';

  @override
  String get helpImportStatementStep2Title => 'Revisa cada fila';

  @override
  String get helpImportStatementStep2Body =>
      'Elige la cuenta, desmarca lo que no quieras y corrige las categorías. Las filas que ya están en Qima empiezan desmarcadas.';

  @override
  String get helpImportStatementStep3Title => 'Iguala el saldo';

  @override
  String get helpImportStatementStep3Body =>
      'Cuando el extracto muestre un saldo, marca Ajustar el saldo. Luego elige: cambiar el saldo inicial, o añadir un movimiento por la diferencia.';

  @override
  String get helpImportStatementStep4Title => 'Añádelos';

  @override
  String get helpImportStatementStep4Body =>
      'Toca Añadir. Los archivos se eliminan una vez importados.';

  @override
  String get helpBankMessagesSummary =>
      'Añade compras desde los mensajes que te envía tu banco, después de revisar cada uno.';

  @override
  String get helpBankMessagesStep1Title => 'En Android';

  @override
  String get helpBankMessagesStep1Body =>
      'Activa Leer los nuevos mensajes del banco y permite el acceso. Trae los últimos 60 días la primera vez.';

  @override
  String get helpBankMessagesStep2Title => 'En iPhone';

  @override
  String get helpBankMessagesStep2Body =>
      'Configura una vez una automatización de Atajos para que cada mensaje vaya a la acción «Add a bank message» de Qima.';

  @override
  String get helpBankMessagesStep3Title => 'Revisa antes de añadir';

  @override
  String get helpBankMessagesStep3Body =>
      'Los mensajes esperan en la revisión de importación. Se omiten códigos, ofertas y repetidos.';

  @override
  String get helpBankMessagesStep4Title => 'Privado';

  @override
  String get helpBankMessagesStep4Body =>
      'Los mensajes se leen en este dispositivo y nunca salen de él.';

  @override
  String get helpCategoriesSummary =>
      'Clasifica el gasto en categorías y enseña a Qima a dónde va cada nombre.';

  @override
  String get helpCategoriesStep1Title => 'Por clasificar';

  @override
  String get helpCategoriesStep1Body =>
      'Elige una categoría una vez por nombre. Las importaciones de ese nombre la usarán a partir de ahora.';

  @override
  String get helpCategoriesStep2Title => 'Movimientos anteriores';

  @override
  String get helpCategoriesStep2Body =>
      'Qima ofrece mover también los movimientos anteriores del mismo nombre.';

  @override
  String get helpCategoriesStep3Title => 'Tus categorías';

  @override
  String get helpCategoriesStep3Body =>
      'Añade, renombra o quita categorías. Los movimientos de una categoría quitada la conservan en su historial.';

  @override
  String get helpCategoriesStep4Title => 'Olvidar un nombre';

  @override
  String get helpCategoriesStep4Body =>
      'Olvida lo que Qima aprendió de un nombre y sus importaciones se clasificarán de nuevo a mano.';

  @override
  String get helpBudgetSummary =>
      'Un importe mensual para cada categoría que quieras vigilar.';

  @override
  String get helpBudgetStep1Title => 'Fija un importe';

  @override
  String get helpBudgetStep1Body =>
      'Toca una categoría e introduce su importe mensual. Cero lo quita.';

  @override
  String get helpBudgetStep2Title => 'Disponible para gastar';

  @override
  String get helpBudgetStep2Body =>
      'Inicio muestra lo que queda este mes y Dinero avisa de una categoría que va por delante de su ritmo.';

  @override
  String get helpBudgetStep3Title => 'Lo que cuenta';

  @override
  String get helpBudgetStep3Body =>
      'Los pagos de tarjeta, las transferencias y el principal de los préstamos nunca cuentan.';

  @override
  String get helpRecurringSummary =>
      'Alquiler, facturas, cuotas e ingresos, que aparecen en Próximamente antes de su fecha.';

  @override
  String get helpRecurringStep1Title => 'Añade uno';

  @override
  String get helpRecurringStep1Body =>
      'Dale un nombre, un importe, la cuenta y cuándo vence: una vez, o cada semana, mes, 3 meses o año. Un pago a plazos puede terminar tras un número de cuotas.';

  @override
  String get helpRecurringStep2Title => 'Próximamente';

  @override
  String get helpRecurringStep2Body =>
      'Inicio muestra los próximos, entradas y salidas, y puede llegar un aviso el día antes.';

  @override
  String get helpRecurringStep3Title => 'Cambiar o quitar';

  @override
  String get helpRecurringStep3Body =>
      'Toca uno para registrarlo, saltarlo, cambiarlo o quitarlo.';

  @override
  String get helpPeopleSummary =>
      'Quién te debe, a quién debes y las devoluciones.';

  @override
  String get helpPeopleStep1Title => 'Presté o pedí prestado';

  @override
  String get helpPeopleStep1Body =>
      'Toca + › Más › Presté o Pedí prestado y escribe el nombre de la persona.';

  @override
  String get helpPeopleStep2Title => 'Devoluciones';

  @override
  String get helpPeopleStep2Body =>
      'Registra Devolución recibida o Devolución hecha y lo que se debe baja.';

  @override
  String get helpPeopleStep3Title => 'Dividir una cuenta';

  @override
  String get helpPeopleStep3Body =>
      'Paga toda la cuenta y divídela: solo tu parte es gasto, el resto te lo deben.';

  @override
  String get helpFeaturesSummary =>
      'Activa o desactiva partes de Qima. Las funciones también se activan solas la primera vez que las usas.';

  @override
  String get helpFeaturesStep1Title => 'Desactiva una';

  @override
  String get helpFeaturesStep1Body =>
      'Se ocultan sus pantallas, nunca tu dinero: sus importes siguen contando en el balance.';

  @override
  String get helpFeaturesStep2Title => 'Se activa al usarla';

  @override
  String get helpFeaturesStep2Body =>
      'Registra tu primer pago de préstamo y se activa Préstamos, con Deshacer si no lo querías.';

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
  String get helpWatchlistTitle => 'Precios';

  @override
  String get helpWatchlistSummary => 'Precios en vivo de todo lo que sigues.';

  @override
  String get helpWatchlistStep1Title => 'Abre una tarjeta';

  @override
  String get helpWatchlistStep1Body =>
      'Toca cualquier tarjeta para ver su gráfico, estadísticas clave y tus posiciones.';

  @override
  String get helpWatchlistStep2Title => 'Añade un activo';

  @override
  String get helpWatchlistStep2Body =>
      'Toca + abajo y luego Añadir a seguimiento.';

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
  String get helpPortfolioStep3Body =>
      'Toca + abajo y luego Añadir posición. O abre un activo y toca Posiciones.';

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
  String get helpPortfolioStep6Title => 'Último mes';

  @override
  String get helpPortfolioStep6Body =>
      'Un breve resumen de cómo se movieron tus posiciones, calculado con tus propios registros. Desactívalo en Ajustes.';

  @override
  String get helpPortfolioStep7Title => 'Pregunta a Siri';

  @override
  String get helpPortfolioStep7Body =>
      'Pregunta a Siri o usa Atajos para saber cuánto vale tu cartera o consultar un precio sin abrir Qima.';

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
  String get helpAddAssetTitle => 'Añadir a seguimiento o posición';

  @override
  String get helpAddAssetSummary =>
      'Sigue un precio en tu lista de seguimiento o registra algo que compraste.';

  @override
  String get helpAddAssetStep1Title => 'Busca';

  @override
  String get helpAddAssetStep1Body =>
      'Toca + y luego Añadir a seguimiento. Busca por nombre o símbolo en cualquier idioma de la app, como oro, ذهب o BTC.';

  @override
  String get helpAddAssetStep2Title => 'Elige un resultado';

  @override
  String get helpAddAssetStep2Body =>
      'Elige la moneda y la unidad en que se muestra su precio y añádelo a tu lista.';

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
  String get helpSettingsStep6Title => 'Inteligencia en el dispositivo';

  @override
  String get helpSettingsStep6Body =>
      'Si quieres, deja que el modelo de lenguaje de este dispositivo ayude a leer compras y a redactar el resumen. Funciona solo aquí, nunca da consejos y nunca aporta un número.';

  @override
  String get helpBackupTitle => 'Copia de seguridad y restauración';

  @override
  String get helpBackupSummary =>
      'Qima no tiene cuenta, así que un archivo de copia de seguridad es cómo conservas tus datos si este teléfono se pierde o se restablece.';

  @override
  String get helpBackupStep1Title => 'Copia de seguridad completa';

  @override
  String get helpBackupStep1Body =>
      'Guarda tus cuentas, movimientos, bienes, lista de seguimiento, inversiones y ajustes en un archivo .json.';

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
  String get zakatGregorianNote =>
      'Las fechas se muestran en el calendario gregoriano. El hawl sigue siendo un año lunar, así que se cumple unos 11 días antes cada año gregoriano.';

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
      'Qima calcula el zakat a partir de lo que tienes a precios de hoy. Calcula; las decisiones detrás del cálculo son tuyas.';

  @override
  String get helpZakatStep1Title => 'Nisab';

  @override
  String get helpZakatStep1Body =>
      'El umbral son 85 g de oro fino o 595 g de plata, a precio actual. Elige la base en los ajustes de zakat; la plata es más baja, así que más personas deben pagar.';

  @override
  String get helpZakatStep2Title => 'Qué cuenta';

  @override
  String get helpZakatStep2Body =>
      'El efectivo, los metales y las criptomonedas cuentan por defecto, y los bienes a la venta por su valor; las acciones no. Se descuentan los saldos de tarjeta y lo que debes a otras personas. Desactiva cualquier partida.';

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

  @override
  String get settingsSummaries => 'Resúmenes';

  @override
  String get settingsPlainSummaries => 'El mes en una frase';

  @override
  String get settingsPlainSummariesFooter =>
      'Muestra en Cartera, en una frase, qué movió tus activos el último mes. Se escribe en este dispositivo con tus propios números.';

  @override
  String get summaryTitle => 'Último mes';

  @override
  String summaryUp(String amount, String percent) {
    return 'En el último mes tus activos ganaron $amount ($percent).';
  }

  @override
  String summaryDown(String amount, String percent) {
    return 'En el último mes tus activos perdieron $amount ($percent).';
  }

  @override
  String get summaryFlat => 'Tus activos apenas se movieron en el último mes.';

  @override
  String summaryTopMover(String asset, String amount) {
    return '$asset fue lo que más los movió, $amount.';
  }

  @override
  String summaryTransactions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Registraste $count transacciones.',
      one: 'Registraste 1 transacción.',
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
    return 'Del $from al $to: de $start a $end, $change. Máximo $high el $highDate, mínimo $low el $lowDate.';
  }

  @override
  String chartDescriptionHidden(String from, String to, String change) {
    return 'Del $from al $to: $change.';
  }

  @override
  String get dictationStart => 'Dicta una compra';

  @override
  String get dictationLanguage => 'Idioma en que hablas';

  @override
  String get dictationStop => 'Dejar de escuchar';

  @override
  String get dictationUnsupported =>
      'La entrada de voz en este idioma no está disponible en este dispositivo. Qima solo escucha en el dispositivo, nunca a través de un servidor.';

  @override
  String get dictationDenied =>
      'El micrófono o el reconocimiento de voz están desactivados para Qima. Actívalos en Ajustes para dictar una compra.';

  @override
  String get settingsIntelligence => 'Inteligencia en el dispositivo';

  @override
  String get settingsUseModel => 'Usar el modelo del dispositivo';

  @override
  String get settingsUseModelFooter =>
      'Ayuda a leer compras que Qima no puede entender por sí sola y redacta el resumen del mes. Funciona solo en este dispositivo, nunca da consejos y nunca aporta un número: cada cifra sale de tus propios registros.';

  @override
  String get modelReady => 'Listo en este dispositivo';

  @override
  String get modelUnsupported => 'No disponible en este dispositivo';

  @override
  String get modelTurnedOff =>
      'Activa Apple Intelligence en los Ajustes del sistema para usarlo';

  @override
  String get modelNotReady => 'El modelo aún se está descargando';

  @override
  String get modelUnsupportedLanguage => 'Aún no disponible en este idioma';

  @override
  String get receiptScan => 'Escanear un recibo';

  @override
  String get receiptTakePhoto => 'Hacer una foto';

  @override
  String get receiptChoosePhoto => 'Elegir una foto';

  @override
  String get receiptNoText =>
      'No se encontró texto en esa foto. Inténtalo de nuevo más cerca, con el recibo plano y bien iluminado.';

  @override
  String get addButton => 'Añadir';

  @override
  String get addSheetWatch => 'Añadir a seguimiento';

  @override
  String get addSheetWatchSubtitle => 'Sigue un precio. No hace falta comprar.';

  @override
  String get addHoldingTitle => 'Añadir posición';

  @override
  String get addSheetHoldingSpeakScan =>
      'Dicta, escanea un recibo o escríbelo.';

  @override
  String get addSheetHoldingSpeak => 'Dicta o escribe lo que compraste.';

  @override
  String get addSheetHoldingScan => 'Escanea un recibo o escríbelo.';

  @override
  String get addSheetHoldingType => 'Escribe lo que compraste.';

  @override
  String get addSheetSiriTip =>
      'Pregunta a Siri: «Cuánto vale mi cartera de Qima»';

  @override
  String get addTypeExample => 'Por ejemplo: compré 20 g de oro 21K a 4100 EGP';

  @override
  String get currencyFieldShowIn => 'Mostrar precios en';

  @override
  String get currencyFieldTransaction => 'Moneda de la operación';

  @override
  String currencyFieldCount(int count) {
    return '$count monedas disponibles';
  }

  @override
  String get currencyFieldMore => 'Más';

  @override
  String get helpAddAssetStep5Title => 'Añadir una posición';

  @override
  String get helpAddAssetStep5Body =>
      'Toca + y luego Añadir posición. Escribe lo que compraste, o díctalo o escanea un recibo si este dispositivo puede. Revisa lo leído y confirma.';

  @override
  String get helpAddAssetStep6Title => 'Leído en este dispositivo';

  @override
  String get helpAddAssetStep6Body =>
      'La voz y los recibos se leen en este dispositivo y nunca se envían. No se guarda nada hasta que confirmes, y cada número sale de lo que escribiste, dijiste o escaneaste.';

  @override
  String get navHome => 'Inicio';

  @override
  String get navMoney => 'Dinero';

  @override
  String get navPrices => 'Precios';

  @override
  String get netWorth => 'Patrimonio neto';

  @override
  String get balanceSheet => 'Balance';

  @override
  String get youOwn => 'Lo que tienes';

  @override
  String get youOweSide => 'Lo que debes';

  @override
  String ownOweLine(String own, String owe) {
    return 'Tienes $own · Debes $owe';
  }

  @override
  String get sheetHoldings => 'Inversiones';

  @override
  String get sheetHoldingsLive => 'A precios actuales';

  @override
  String get sheetCash => 'Efectivo y bancos';

  @override
  String get sheetOwedToYou => 'Te deben';

  @override
  String get sheetAssets => 'Propiedades y más';

  @override
  String get sheetCards => 'Tarjetas';

  @override
  String get sheetLoans => 'Préstamos';

  @override
  String get sheetYouOwe => 'Debes a otras personas';

  @override
  String get sheetNothingOwed =>
      'No debes nada. Las tarjetas, préstamos y deudas aparecen aquí cuando las añadas.';

  @override
  String sheetMissingRates(String codes) {
    return 'Aún no hay tipo de cambio para $codes; esos importes no cuentan en el total.';
  }

  @override
  String get acctCash => 'Efectivo';

  @override
  String get acctDebit => 'Cuenta bancaria';

  @override
  String get acctCredit => 'Tarjeta';

  @override
  String get acctLoan => 'Préstamo';

  @override
  String get acctReceivable => 'Te debe';

  @override
  String get acctPayable => 'Le debes';

  @override
  String get acctAsset => 'Activo';

  @override
  String get acctCategory => 'Categoría';

  @override
  String get assetKindProperty => 'Inmueble';

  @override
  String get assetKindVehicle => 'Vehículo';

  @override
  String get assetKindBusiness => 'Negocio';

  @override
  String get assetKindValuables => 'Objetos de valor';

  @override
  String get assetKindOther => 'Otro';

  @override
  String get assetKindPropertyHint => 'Una casa, un terreno, un local';

  @override
  String get assetKindVehicleHint => 'Un coche, una moto, un barco';

  @override
  String get assetKindBusinessHint => 'Tu parte de un negocio';

  @override
  String get assetKindValuablesHint => 'Un reloj, arte, una colección';

  @override
  String get assetKindOtherHint => 'Cualquier otra cosa que tengas';

  @override
  String get tplOpening => 'Saldo inicial';

  @override
  String get tplSpend => 'Gasto';

  @override
  String get tplIncome => 'Ingreso';

  @override
  String get tplTransfer => 'Transferencia';

  @override
  String get tplAtm => 'Retiro en cajero';

  @override
  String get tplSwap => 'Cambio de divisa';

  @override
  String get tplCardPayment => 'Pago de tarjeta';

  @override
  String get tplLoanPayment => 'Pago de préstamo';

  @override
  String get tplLent => 'Presté';

  @override
  String get tplBorrowed => 'Pedí prestado';

  @override
  String get tplRepaymentIn => 'Devolución recibida';

  @override
  String get tplRepaymentOut => 'Devolución hecha';

  @override
  String get tplRefund => 'Reembolso';

  @override
  String get tplDeclined => 'Rechazada';

  @override
  String get tplCashCount => 'Recuento de efectivo';

  @override
  String get tplBillSplit => 'Cuenta dividida';

  @override
  String get tplValuation => 'Nuevo valor';

  @override
  String get tplAssetSale => 'Vendido';

  @override
  String get tplAdjustment => 'Ajuste';

  @override
  String get catGroceries => 'Supermercado';

  @override
  String get catDining => 'Restaurantes';

  @override
  String get catTransport => 'Transporte';

  @override
  String get catBills => 'Facturas';

  @override
  String get catShopping => 'Compras';

  @override
  String get catHealth => 'Salud';

  @override
  String get catHome => 'Hogar';

  @override
  String get catOther => 'Otros';

  @override
  String get catSalary => 'Salario';

  @override
  String get catOtherIncome => 'Otros ingresos';

  @override
  String get catInterestFees => 'Intereses y comisiones';

  @override
  String get sysOpening => 'Saldos iniciales';

  @override
  String get sysChange => 'Cambio de valor';

  @override
  String get sysRounding => 'Redondeo';

  @override
  String get featBudget => 'Presupuesto';

  @override
  String get featRecurring => 'Pagos previstos';

  @override
  String get featPeople => 'Prestado y debido';

  @override
  String get featLoans => 'Préstamos';

  @override
  String get featBillSplit => 'Dividir cuentas';

  @override
  String get featZakat => 'Zakat';

  @override
  String get featBudgetDetail =>
      'Un importe mensual por categoría y lo que queda';

  @override
  String get featRecurringDetail =>
      'Facturas, cuotas e ingresos antes de su fecha';

  @override
  String get featPeopleDetail => 'Quién te debe y a quién debes';

  @override
  String get featLoansDetail =>
      'Lo que queda de un préstamo y los intereses de cada pago';

  @override
  String get featBillSplitDetail =>
      'Paga una cuenta y divídela; solo tu parte es gasto';

  @override
  String get featZakatDetail => 'Zakat sobre inversiones, efectivo y deudas';

  @override
  String featureTurnedOn(String feature) {
    return '$feature activado';
  }

  @override
  String get featuresTitle => 'Funciones';

  @override
  String get featuresSubtitle => 'Presupuesto, recurrentes, préstamos y más';

  @override
  String get featuresIntro =>
      'Desactivar una función oculta sus pantallas, nunca tu dinero: sus importes siguen contando en el balance.';

  @override
  String get cardNeedsReview => 'Para revisar';

  @override
  String get cardComingUp => 'Próximamente';

  @override
  String get cardLeftToSpend => 'Disponible para gastar';

  @override
  String get cardAccounts => 'Cuentas';

  @override
  String get editHome => 'Editar Inicio';

  @override
  String get editHomeIntro =>
      'Mueve tarjetas u oculta las que no necesites. Qima nunca vuelve a mostrar una tarjeta oculta.';

  @override
  String get editHomeTotalFixed =>
      'Siempre primero: desde aquí se abre el balance';

  @override
  String get editHomeCantHide =>
      'Solo aparece cuando algo requiere tu atención';

  @override
  String get moveUp => 'Subir';

  @override
  String get moveDown => 'Bajar';

  @override
  String get moveToTop => 'Mover arriba del todo';

  @override
  String get startTitle => 'Empieza con lo que tienes';

  @override
  String get startMessage =>
      'Añade una cuenta, una inversión o un inmueble. Qima los suma en tu patrimonio neto.';

  @override
  String holdingsGainLine(String amount) {
    return 'Ganancia $amount';
  }

  @override
  String reviewValue(String name) {
    return 'Revisa el valor de $name';
  }

  @override
  String get accountAdd => 'Añadir cuenta';

  @override
  String get accountEdit => 'Editar cuenta';

  @override
  String get accountNameLabel => 'Nombre';

  @override
  String get accountCurrency => 'Moneda';

  @override
  String get accountBalanceToday => 'Saldo hoy';

  @override
  String get accountOwedToday => 'Deuda hoy';

  @override
  String get accountLoanLeft => 'Capital pendiente';

  @override
  String get accountTheyOwe => 'Te debe';

  @override
  String get accountYouOwe => 'Le debes';

  @override
  String get accountBalanceHelp =>
      'Qima empieza desde esta cifra; déjalo vacío para cero.';

  @override
  String get accountSince => 'A fecha de';

  @override
  String get accountLimit => 'Límite de la tarjeta';

  @override
  String get accountCounts => 'Contar en el patrimonio';

  @override
  String get accountCountsHelp =>
      'Desactivado no cuenta en el total; su historial sigue cuadrando.';

  @override
  String get accountErrorName => 'Ponle un nombre.';

  @override
  String get accountLeftOut => 'No cuenta en el patrimonio';

  @override
  String accountAvailable(String amount) {
    return '$amount disponible';
  }

  @override
  String get accountCountCash => 'Contar efectivo';

  @override
  String get accountCheckBalance => 'Comprobar saldo';

  @override
  String get accountPayCard => 'Pagar la tarjeta';

  @override
  String get accountPayLoan => 'Pagar el préstamo';

  @override
  String get accountRemoveTitle => 'Eliminar cuenta';

  @override
  String get accountRemoveMessage =>
      'Una cuenta con movimientos se archiva para que su historial cuadre. Una sin uso se elimina.';

  @override
  String get accountsEmptyTitle => 'Aún no hay cuentas';

  @override
  String get accountsEmptyMessage =>
      'Añade una cuenta, efectivo, una tarjeta o un préstamo con su saldo de hoy.';

  @override
  String reconcileTracked(String amount) {
    return 'Qima tiene $amount.';
  }

  @override
  String get reconcileCounted => 'Lo que has contado';

  @override
  String get reconcileStatement => 'Saldo en el extracto o la app';

  @override
  String get reconcileDone =>
      'La diferencia se anota en Otros y el saldo cuadra.';

  @override
  String get entryAmount => 'Importe';

  @override
  String get entryPrincipal => 'Capital';

  @override
  String get entryProfit => 'Intereses';

  @override
  String get entryProfitHelp =>
      'Cuenta como gasto en Intereses y comisiones; el capital nunca.';

  @override
  String get entrySent => 'Enviado';

  @override
  String get entryClearsTheirs => 'Salda de lo que te debe';

  @override
  String get entryClearsMine => 'Salda de lo que debes';

  @override
  String entryClearsHelp(String amount) {
    return 'Déjalo vacío para usar el cambio de hoy: $amount';
  }

  @override
  String get entryReceived => 'Recibido';

  @override
  String get entryPaidFrom => 'Pagado con';

  @override
  String get entryFrom => 'Desde';

  @override
  String get entryTo => 'A';

  @override
  String get entryPerson => 'Persona';

  @override
  String get entryCategory => 'Categoría';

  @override
  String get entryDate => 'Fecha';

  @override
  String get entryMerchant => 'Dónde';

  @override
  String get entryNote => 'Nota';

  @override
  String get entryDeclined => 'Rechazada';

  @override
  String get entryDeclinedHelp =>
      'Se muestra tachada; nunca cuenta en un saldo.';

  @override
  String get entryEditTitle => 'Editar movimiento';

  @override
  String get entryDeleteTitle => '¿Eliminar movimiento?';

  @override
  String get entryDeleteMessage => 'Cada cuenta afectada vuelve a como estaba.';

  @override
  String get entryErrorAmount => 'Introduce un importe mayor que cero.';

  @override
  String get entryErrorAccount => 'Elige las cuentas.';

  @override
  String get entryErrorSameCurrency =>
      'Ambas cuentas deben tener la misma moneda. Para distintas, usa Cambio de divisa.';

  @override
  String get entryErrorSwap => 'Elige dos cuentas en monedas distintas.';

  @override
  String get entryErrorPerson => 'Indica quién es.';

  @override
  String get entryErrorRate =>
      'Aún no hay tipo de cambio para esta moneda. Inténtalo tras actualizar precios.';

  @override
  String get entryNeedsAccountTitle => 'Primero añade una cuenta';

  @override
  String get entryNeedsAccountMessage =>
      'Esto necesita una cuenta de origen o destino. Añádela en Cuentas.';

  @override
  String get howItAddsUp => 'Cómo cuadra';

  @override
  String hiuUp(String name, String amount) {
    return '$name sube $amount';
  }

  @override
  String hiuDown(String name, String amount) {
    return '$name baja $amount';
  }

  @override
  String get hiuSpending => 'Gasto: cuenta en tu presupuesto.';

  @override
  String get hiuIncome => 'Ingreso: cuenta en tu flujo de caja.';

  @override
  String get hiuRefund => 'Un reembolso reduce el gasto de su categoría.';

  @override
  String get hiuWorth =>
      'Un cambio de valor solo mueve el patrimonio; nunca es ingreso ni gasto.';

  @override
  String get hiuMove =>
      'Un movimiento entre tus cuentas: no es gasto y tu patrimonio no cambia.';

  @override
  String get hiuDeclined => 'Rechazada: no se movió nada.';

  @override
  String get allTransactions => 'Todos los movimientos';

  @override
  String get transactionsSearch => 'Buscar';

  @override
  String get transactionsEmptyTitle => 'Sin movimientos';

  @override
  String get transactionsEmptyMessage => 'Añade uno con el botón +.';

  @override
  String get moneySpent => 'Gastado';

  @override
  String moneySpentOf(String spent, String budget) {
    return '$spent de $budget';
  }

  @override
  String moneySpentSoFar(String amount) {
    return 'Gastado $amount este mes';
  }

  @override
  String moneyPace(String amount) {
    return 'A este ritmo: $amount a fin de mes';
  }

  @override
  String get moneyNothingSpent => 'Nada gastado este mes.';

  @override
  String get moneyIn => 'Entradas';

  @override
  String get moneyOut => 'Salidas';

  @override
  String get moneyLeftOver => 'Sobrante';

  @override
  String get moneyShort => 'Déficit';

  @override
  String get moneyTrend => 'Gasto por mes';

  @override
  String get moneyTransactions => 'Movimientos';

  @override
  String get moneyStartMessage =>
      'Añade una cuenta y luego anota lo que gastas.';

  @override
  String get whereItWent => 'En qué se fue';

  @override
  String get cashFlow => 'Flujo de caja';

  @override
  String get worthALook => 'Vale la pena revisar';

  @override
  String aheadOfPace(String name) {
    return '$name va por delante de su presupuesto';
  }

  @override
  String spareIn(String name, String amount) {
    return '$name tiene $amount de margen';
  }

  @override
  String get previousMonth => 'Mes anterior';

  @override
  String get nextMonth => 'Mes siguiente';

  @override
  String get ask => 'Pregunta';

  @override
  String get askSpentMonth => '¿Cuánto gasté este mes?';

  @override
  String askSpentMonthAnswer(String amount) {
    return '$amount';
  }

  @override
  String get askTopCategory => '¿En qué se fue la mayor parte?';

  @override
  String askTopCategoryAnswer(String name, String amount) {
    return '$name: $amount';
  }

  @override
  String get askVsLastMonth => '¿Es más que el mes pasado?';

  @override
  String askMore(String amount) {
    return '$amount más que el mes pasado';
  }

  @override
  String askLess(String amount) {
    return '$amount menos que el mes pasado';
  }

  @override
  String get askSame => 'Más o menos igual que el mes pasado';

  @override
  String get askOwed => '¿Quién me debe dinero?';

  @override
  String get askNobodyOwes => 'Nadie te debe dinero.';

  @override
  String get assetAdd => 'Añadir un bien';

  @override
  String get assetEdit => 'Editar bien';

  @override
  String get assetGoldNote =>
      'El oro y la plata por peso siguen siendo inversiones, porque Qima les pone precio. Añádelos con Añadir inversión.';

  @override
  String get assetValueToday => 'Valor hoy';

  @override
  String get assetCost => 'Precio pagado';

  @override
  String get assetBought => 'Fecha de compra';

  @override
  String get optional => 'Opcional';

  @override
  String get assetLoan => 'Préstamo asociado';

  @override
  String get assetNoLoan => 'Ninguno';

  @override
  String get assetForSale => 'En venta';

  @override
  String get assetForSaleHelp =>
      'Cuenta para el zakat por su valor. Desactívalo para lo que usas.';

  @override
  String get assetErrorValue => 'Introduce el valor de hoy.';

  @override
  String get assetsTotal => 'Valor total';

  @override
  String get assetsTotalHelp => 'Valores que fijas tú, cada uno con su fecha';

  @override
  String get assetsEmptyTitle => 'Aún no hay bienes';

  @override
  String get assetsEmptyMessage =>
      'Añade una casa, un terreno, un coche o parte de un negocio. Tú fijas el valor y Qima guarda su historial.';

  @override
  String assetUpdated(String date) {
    return 'Actualizado el $date';
  }

  @override
  String assetSinceBought(String amount) {
    return '$amount desde la compra';
  }

  @override
  String get assetUpdateValue => 'Actualizar valor';

  @override
  String get assetUpdateHelp =>
      'Cada actualización tiene fecha. Cuenta la última; las anteriores quedan en el historial.';

  @override
  String get assetNewValue => 'Nuevo valor';

  @override
  String get assetValueSource => 'De dónde sale el valor';

  @override
  String get assetSold => 'Lo vendí';

  @override
  String assetSellTitle(String name) {
    return 'Vender $name';
  }

  @override
  String assetLastValue(String amount) {
    return 'Último valor: $amount';
  }

  @override
  String get assetSoldInto => 'El dinero entró en';

  @override
  String get assetSoldFor => 'Vendido por';

  @override
  String assetGain(String amount) {
    return 'Ganancia de $amount';
  }

  @override
  String assetLoss(String amount) {
    return 'Pérdida de $amount';
  }

  @override
  String get assetGainHelp =>
      'Frente al último valor. Es un cambio de valor, nunca ingreso.';

  @override
  String assetPayOff(String name) {
    return 'La venta liquidó $name';
  }

  @override
  String assetPayOffHelp(String amount) {
    return 'Quedan $amount, pagados desde la misma cuenta';
  }

  @override
  String get assetYours => 'Lo que es tuyo';

  @override
  String get assetValue => 'Valor';

  @override
  String assetStillOwed(String name) {
    return 'Pendiente de $name';
  }

  @override
  String get assetYoursTotal => 'Tuyo';

  @override
  String get assetYoursHelp =>
      'El balance sigue mostrando el bien en lo que tienes y el préstamo en lo que debes.';

  @override
  String get assetHistory => 'Historial';

  @override
  String get assetRemoveTitle => 'Eliminar bien';

  @override
  String get assetRemoveMessage =>
      'Para registrar una venta usa Lo vendí. Eliminar lo archiva con su historial.';

  @override
  String get howTotalWorked => 'Cómo se calcula el total';

  @override
  String get howTotalIntro =>
      'El patrimonio neto es lo que tienes menos lo que debes.';

  @override
  String get howTotalHoldings =>
      'Las inversiones usan precios actuales, como en Precios.';

  @override
  String get howTotalAssets =>
      'Los bienes que valoras tú usan su último valor con fecha; cada uno puede excluirse.';

  @override
  String get howTotalLoans =>
      'Los préstamos cuentan solo el capital; los intereses futuros no son deuda hasta que vencen.';

  @override
  String get howTotalRates =>
      'Las demás monedas usan el tipo de cambio actual.';

  @override
  String sheetAccountsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cuentas',
      one: '1 cuenta',
      zero: 'Sin cuentas',
    );
    return '$_temp0';
  }

  @override
  String budgetFor(String name) {
    return 'Presupuesto de $name';
  }

  @override
  String get budgetIntro =>
      'Fija un importe mensual para las categorías que quieras vigilar. Los pagos de tarjeta, transferencias y capital nunca cuentan.';

  @override
  String get budgetMonthly => 'Cada mes';

  @override
  String get budgetZeroHelp => 'Cero lo elimina.';

  @override
  String get budgetNone => 'Sin presupuesto';

  @override
  String budgetOf(String amount) {
    return 'Presupuesto $amount';
  }

  @override
  String get budgetSet => 'Fijar presupuesto';

  @override
  String get budgetTotal => 'Presupuesto de este mes';

  @override
  String get recurringAdd => 'Añadir pago previsto';

  @override
  String get recurringDay => 'Día del mes';

  @override
  String get recurringEmptyTitle => 'Sin pagos previstos';

  @override
  String get recurringEmptyMessage =>
      'Añade alquiler, facturas, cuotas o tu sueldo para verlos en Próximamente antes de su fecha.';

  @override
  String recurringNext(String date) {
    return 'Próximo $date';
  }

  @override
  String recurringRecord(String name, String date) {
    return 'Registrar $name del $date';
  }

  @override
  String get peopleEmptyTitle => 'Nadie todavía';

  @override
  String get peopleEmptyMessage =>
      'Anota lo que prestas o pides prestado, y las devoluciones.';

  @override
  String get splitTotal => 'Total de la cuenta';

  @override
  String get splitWho => 'Quién más participó';

  @override
  String get splitShare => 'Parte';

  @override
  String get splitAddPerson => 'Añadir persona';

  @override
  String get splitEvenly => 'Dividir a partes iguales';

  @override
  String get splitMine => 'Tu parte (gasto)';

  @override
  String get splitOwedToYou => 'Te deben';

  @override
  String get splitHelp =>
      'Sale el importe total de la cuenta; solo tu parte es gasto y las demás pasan a deberse.';

  @override
  String get splitErrorPerson => 'Cada persona necesita nombre y parte.';

  @override
  String get splitErrorShares =>
      'Añade al menos una persona, con partes que no superen el total.';

  @override
  String get categoriesTitle => 'Categorías';

  @override
  String get categoriesSpending => 'Gastos';

  @override
  String get categoriesIncome => 'Ingresos';

  @override
  String get categoryRename => 'Renombrar categoría';

  @override
  String get categoryRemove => 'Eliminar categoría';

  @override
  String get categoryRemoveMessage =>
      'Los movimientos la conservan en su historial.';

  @override
  String get categoryAddSpending => 'Nueva categoría de gasto';

  @override
  String get categoryAddIncome => 'Nueva categoría de ingreso';

  @override
  String get valueReview => 'Revisar valores de bienes';

  @override
  String get valueReviewHelp => 'Un aviso en Para revisar';

  @override
  String get valueReviewOff => 'Desactivado';

  @override
  String valueReviewMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'Cada $months meses',
      one: 'Cada mes',
    );
    return '$_temp0';
  }

  @override
  String get addSheetTransaction => 'Movimiento';

  @override
  String get addSheetTransactionSubtitle => 'Dinero gastado, recibido o movido';

  @override
  String get entryVoiceTitle => 'Dilo en vez de escribir';

  @override
  String get entryVoiceListening => 'Escuchando… toca para parar';

  @override
  String get entryVoiceHint =>
      'Di lo que pasó, por ejemplo «Gasté 45 en Mercadona con la Visa ayer»';

  @override
  String get entryVoiceNothing =>
      'No se entendió un importe ni un nombre. Inténtalo de nuevo o escríbelo.';

  @override
  String get entryNewTitle => 'Nuevo movimiento';

  @override
  String get addSheetMore => 'Más';

  @override
  String get addSheetMoreSubtitle =>
      'Ingresos, transferencias, préstamos, cuentas, bienes';

  @override
  String get whatsNewTitle => 'Novedades de Qima';

  @override
  String get whatsNewTabs =>
      'Tres pestañas: Inicio para tu situación, Dinero para tus gastos, Precios para el mercado.';

  @override
  String get whatsNewBalanceSheet =>
      'Tus inversiones, cuentas, tarjetas y préstamos suman en un solo balance. Toca el total para verlo.';

  @override
  String get whatsNewAssets =>
      'Añade un inmueble, un coche o un negocio y actualiza su valor tú mismo.';

  @override
  String get whatsNewPick => '¿Qué te gustaría usar?';

  @override
  String get whatsNewLater => 'Puedes cambiarlas en Ajustes › Funciones.';

  @override
  String get zakatDueTitle => 'Zakat a pagar';

  @override
  String zakatDueLine(String amount) {
    return '$amount a pagar';
  }

  @override
  String get zakatBelowLine => 'Por debajo del nisab';

  @override
  String zakatBaseLine(String amount) {
    return 'Computado: $amount';
  }

  @override
  String zakatAbove(String amount) {
    return 'Por encima del nisab de $amount';
  }

  @override
  String zakatBelow(String amount) {
    return 'Por debajo del nisab de $amount';
  }

  @override
  String get zakatNoThreshold =>
      'El nisab aparece al cargar los precios del oro y la plata.';

  @override
  String get zakatBase => 'Computado para el zakat';

  @override
  String get zakatHeldForSale => 'Bienes en venta';

  @override
  String get zakatDebtsDue => 'Deudas vencidas';

  @override
  String get zakatBookHelp =>
      'Las inversiones siguen tus ajustes de zakat. Se descuentan las tarjetas y lo que debes a personas; los préstamos no, porque solo contaría la cuota vencida y Qima no conoce su calendario.';

  @override
  String get zakatHoldingsDetail => 'Inversiones en detalle';

  @override
  String get importStatement => 'Importar un extracto';

  @override
  String get importStatementSubtitle =>
      'PDF, Excel, CSV o capturas de tu banco';

  @override
  String get importFromFiles => 'Desde Archivos';

  @override
  String get importFromFilesHint => 'Extractos en PDF, Excel o CSV';

  @override
  String get importFromPhotos => 'Capturas desde Fotos';

  @override
  String get importFromPhotosHint => 'Los movimientos de tu app del banco';

  @override
  String get importFromClipboard => 'Desde el portapapeles';

  @override
  String get importFromClipboardHint =>
      'Un extracto, recibo, mensaje del banco o captura copiado';

  @override
  String get importPastedName => 'Pegado';

  @override
  String get importShareTip =>
      'También puedes compartir archivos con Qima desde cualquier app.';

  @override
  String importReadingFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Leyendo $count archivos…',
      one: 'Leyendo 1 archivo…',
    );
    return '$_temp0';
  }

  @override
  String importReadyRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movimientos por revisar',
      one: '1 movimiento por revisar',
      zero: 'No se encontró nada que añadir',
    );
    return '$_temp0';
  }

  @override
  String get importReadyBalance => 'Un saldo por revisar';

  @override
  String get bankMessagesTitle => 'Mensajes del banco';

  @override
  String get bankMessagesEntry => 'Mensajes del banco';

  @override
  String get bankMessagesEntryHint =>
      'Añade compras desde los mensajes de tu banco';

  @override
  String get bankMessagesIntro =>
      'Tu banco te envía un mensaje por cada compra, transferencia y nómina. Qima puede leer esos mensajes y proponerlos como movimientos. Revisas cada uno antes de añadirlo.';

  @override
  String get bankMessagesRead => 'Leer los nuevos mensajes del banco';

  @override
  String get bankMessagesReadHint =>
      'Solo mensajes con un importe. Se omiten los códigos y los mensajes personales.';

  @override
  String get bankMessagesRecent => 'Traer los últimos 60 días';

  @override
  String get bankMessagesRecentHint =>
      'Se omiten los mensajes que ya están en Qima';

  @override
  String get bankMessagesDenied =>
      'Qima necesita permiso para leer mensajes. Puedes darlo en Ajustes.';

  @override
  String get bankMessagesSetUp => 'Configúralo una vez en Atajos';

  @override
  String get bankMessagesStep1 =>
      'Abre Atajos, ve a Automatización y toca +, luego elige Mensaje.';

  @override
  String get bankMessagesStep2 =>
      'Elige tu banco como remitente, o una palabra que siempre aparece en sus mensajes, como EUR.';

  @override
  String get bankMessagesStep3 => 'Elige Ejecutar inmediatamente.';

  @override
  String get bankMessagesStep4 =>
      'Añade la acción «Add a bank message» de Qima y pásale el mensaje.';

  @override
  String get bankMessagesOpenShortcuts => 'Abrir Atajos';

  @override
  String get bankMessagesUnavailable =>
      'Los mensajes del banco se pueden añadir en iPhone y Android.';

  @override
  String get bankMessagesPrivacy =>
      'Los mensajes se leen en este dispositivo y nunca salen de él.';

  @override
  String bankMessagesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes del banco por revisar',
      one: '1 mensaje del banco por revisar',
      zero: 'No se encontraron mensajes del banco',
    );
    return '$_temp0';
  }

  @override
  String get importBannerTitle => 'Compartido con Qima';

  @override
  String get importReviewTitle => 'Revisar importación';

  @override
  String get importIntoAccount => 'Extracto de';

  @override
  String get importNoAccountTitle => 'Añade primero la cuenta';

  @override
  String get importNoAccountBody =>
      'Añade la cuenta bancaria o tarjeta de este extracto y vuelve aquí.';

  @override
  String importAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Añadir $count movimientos',
      one: 'Añadir 1 movimiento',
      zero: 'Añadir',
    );
    return '$_temp0';
  }

  @override
  String importAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movimientos añadidos',
      one: '1 movimiento añadido',
    );
    return '$_temp0';
  }

  @override
  String get importDiscardAll => 'Descartar todo';

  @override
  String get importApplyBalance => 'Aplicar el saldo';

  @override
  String get importDiscardConfirm =>
      '¿Descartar estos archivos? No se añadirá nada.';

  @override
  String get importDiscard => 'Descartar';

  @override
  String get importRemoveFile => 'Quitar archivo';

  @override
  String get importFlagInBook => 'Ya está en Qima';

  @override
  String get importFlagRepeated => 'También en otro archivo';

  @override
  String importFlagCurrency(String currency) {
    return 'En $currency, no en la moneda de la cuenta';
  }

  @override
  String get importDateGuessed =>
      'Sin fecha: se usó el día en que se compartió';

  @override
  String get importSignGuessed => 'Revisa: ¿entrada o salida?';

  @override
  String get importFlagNotTransaction =>
      'Parece texto del banco, no un movimiento';

  @override
  String importRefCard(String last4) {
    return 'Tarjeta •••• $last4';
  }

  @override
  String importRefAccount(String last4) {
    return 'Cuenta •••• $last4';
  }

  @override
  String importRefIban(String last4) {
    return 'IBAN •••• $last4';
  }

  @override
  String importBalances(String opening, String closing) {
    return 'Inicial $opening → final $closing';
  }

  @override
  String get importAddsUp => 'Cuadra: no falta nada';

  @override
  String importGap(String amount) {
    return '$amount sin explicar: revisa si falta un movimiento';
  }

  @override
  String importOpeningBalance(String amount) {
    return 'Añadir el saldo inicial: $amount';
  }

  @override
  String importMatchBalance(String amount) {
    return 'Ajustar el saldo a $amount';
  }

  @override
  String importBalanceDetail(String date, String tracked) {
    return 'Como muestra el extracto el $date. Sin esto, Qima tendría $tracked.';
  }

  @override
  String get importStatusReading => 'Leyendo…';

  @override
  String get importStatusWaiting => 'En espera';

  @override
  String get importStatusAlready => 'Ya importado';

  @override
  String get importStatusUnsupported =>
      'Qima no puede leer este tipo de archivo';

  @override
  String get importStatusUnreadable => 'No se pudo leer este archivo';

  @override
  String get importStatusNothing =>
      'No se encontraron movimientos en este archivo';

  @override
  String importRowFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count encontrados',
      one: '1 encontrado',
    );
    return '$_temp0';
  }

  @override
  String get importEditRow => 'Movimiento';

  @override
  String get importCategory => 'Categoría';

  @override
  String get importNothingSelected =>
      'Marca los movimientos que quieras añadir.';

  @override
  String get importReadOnDevice =>
      'Se lee en este dispositivo. Los archivos se borran al importarlos.';

  @override
  String get importEmpty => 'Nada pendiente';

  @override
  String get catUncategorized => 'Sin categoría';

  @override
  String get catUncategorizedIncome => 'Ingresos sin categoría';

  @override
  String get toCategorizeTitle => 'Por clasificar';

  @override
  String toCategorizeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count por clasificar',
      one: '1 por clasificar',
    );
    return '$_temp0';
  }

  @override
  String get toCategorizeHint =>
      'Elige una categoría una vez por nombre. Las importaciones de ese nombre la usarán desde ahora.';

  @override
  String get toCategorizeEmpty => 'Todo tiene categoría.';

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
          '¿Poner también $count movimientos anteriores de $name en $category? Ahora están en $from.',
      one:
          '¿Poner también 1 movimiento anterior de $name en $category? Ahora está en $from.',
    );
    return '$_temp0';
  }

  @override
  String get toCategorizeAlsoYes => 'Moverlos';

  @override
  String get categoriesLearned => 'Aprendido de tus elecciones';

  @override
  String get categoriesForgetTitle => '¿Olvidar esta elección?';

  @override
  String categoriesForgetMessage(String name, String category) {
    return 'Las importaciones de $name ya no irán solas a $category. Los movimientos que ya están allí se quedan.';
  }

  @override
  String get categoriesForget => 'Olvidar';

  @override
  String get marketClosed => 'Cerrado';

  @override
  String marketClosedOpens(String time) {
    return 'Mercado cerrado · abre $time';
  }

  @override
  String marketOpenCloses(String time) {
    return 'Mercado abierto · cierra $time';
  }

  @override
  String get marketClosedLong => 'Mercado cerrado';

  @override
  String holdingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count inversiones',
      one: '1 inversión',
    );
    return '$_temp0';
  }

  @override
  String pricesAt(String time) {
    return 'precios $time';
  }

  @override
  String get balanceWayTransaction => 'Añadir un movimiento';

  @override
  String balanceWayTransactionDetail(String other) {
    return 'La diferencia cuenta como gasto o ingreso en $other';
  }

  @override
  String get balanceWayOpening => 'Cambiar el saldo inicial';

  @override
  String get balanceWayOpeningDetail =>
      'Desde su primer día, ni gasto ni ingreso';

  @override
  String get netLabel => 'Neto';

  @override
  String get planOut => 'Sale';

  @override
  String get planIn => 'Entra';

  @override
  String get planRepeat => 'Se repite';

  @override
  String get planRepeatOnce => 'Una vez';

  @override
  String get planRepeatWeekly => 'Cada semana';

  @override
  String get planRepeatMonthly => 'Cada mes';

  @override
  String get planRepeatQuarterly => 'Cada 3 meses';

  @override
  String get planRepeatYearly => 'Cada año';

  @override
  String get planDate => 'Vence el';

  @override
  String get planTimes => 'Número de pagos';

  @override
  String get planTimesHelp =>
      'Déjalo vacío si no termina, o 4 para un pago a plazos en 4 cuotas.';

  @override
  String get planPaidInto => 'Se ingresa en';

  @override
  String get planRemind => 'Avisarme el día antes';

  @override
  String planLeft(int left, int total) {
    return 'Quedan $left de $total';
  }

  @override
  String get planFinished => 'Terminado';

  @override
  String planOverdue(String date) {
    return 'Vencido desde el $date';
  }

  @override
  String get planRecord => 'Registrar';

  @override
  String get planSkip => 'Saltar este';

  @override
  String planDueTomorrow(String name) {
    return '$name vence mañana';
  }

  @override
  String planExpectedTomorrow(String name) {
    return '$name llega mañana';
  }

  @override
  String get planReminderBody => 'Abre Qima para registrarlo cuando ocurra.';

  @override
  String plannedThisMonth(String amount) {
    return '$amount aún previstos este mes';
  }

  @override
  String get categoryNew => 'Nueva categoría…';

  @override
  String get categoryNewTitle => 'Nueva categoría';

  @override
  String get planEdit => 'Cambiar';

  @override
  String get accountNumberAccount => 'Número de cuenta';

  @override
  String get accountNumberIban => 'IBAN';

  @override
  String get accountNumberCard => 'Número de tarjeta';

  @override
  String get accountNumberHelp =>
      'Bastan los últimos 4 dígitos. Qima solo guarda esos 4, para asociar extractos y mensajes del banco a esta cuenta.';

  @override
  String get accountNumberShort => 'Escribe al menos los últimos 4 dígitos';

  @override
  String get applePaySetUp => 'Pagos con Apple Pay';

  @override
  String get applePayIntro =>
      'Cada pago con Apple Pay puede llegar a Qima al pagar, incluso de tarjetas que no envían mensajes.';

  @override
  String get applePayStep1 =>
      'En Atajos, ve a Automatización, toca + y elige Cartera.';

  @override
  String get applePayStep2 =>
      'Elige tus tarjetas y luego Ejecutar inmediatamente.';

  @override
  String get applePayStep3 => 'Añade la acción «Add a Wallet payment» de Qima.';

  @override
  String get applePayStep4 =>
      'Pon su Amount, Merchant y Card en Importe, Comercio y Tarjeta o pase de la entrada del atajo.';

  @override
  String get entryMarkAs => 'Marcar como';

  @override
  String get splitByAmount => 'Importe';

  @override
  String get splitByEqually => 'A partes iguales';

  @override
  String get splitByPercent => 'Porcentaje';

  @override
  String get splitByShares => 'Partes';

  @override
  String get splitYou => 'Tú';
}
