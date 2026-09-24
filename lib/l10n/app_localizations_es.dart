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
}
