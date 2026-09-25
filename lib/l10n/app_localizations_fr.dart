// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Qima';

  @override
  String get navWatchlist => 'Suivi';

  @override
  String get watchlistAdd => 'Ajouter un instrument';

  @override
  String get watchlistEmptyTitle => 'Votre liste de suivi est vide';

  @override
  String get watchlistEmptyMessage =>
      'Ajoutez des métaux, cryptomonnaies, actions ou devises pour suivre leurs prix.';

  @override
  String get watchlistFilterAll => 'Tous';

  @override
  String get addTitle => 'Ajouter un instrument';

  @override
  String get addSearchHint => 'Rechercher un instrument';

  @override
  String addSearchCustomTickerTitle(String query) {
    return 'Ajouter « $query » comme symbole personnalisé';
  }

  @override
  String get addSearchCustomTickerSubtitle =>
      'Pour les actions, ETF ou indices non listés ici';

  @override
  String addSearchNoResultsTitle(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get addSearchNoResultsMessage =>
      'Rien dans le catalogue ne correspond à cette recherche. Vous pouvez tout de même l\'ajouter comme symbole personnalisé.';

  @override
  String addSearchNoResultsButton(String query) {
    return 'Ajouter $query comme symbole personnalisé';
  }

  @override
  String addedToWatchlist(String name) {
    return '$name ajouté à la liste de suivi';
  }

  @override
  String alreadyInWatchlist(String name) {
    return '$name est déjà dans votre liste de suivi';
  }

  @override
  String get addCustomTickerTitle => 'Ajouter un symbole personnalisé';

  @override
  String get addCustomTickerSymbol => 'Symbole boursier';

  @override
  String get addCustomTickerName => 'Nom affiché (facultatif)';

  @override
  String get addCustomTickerHint => 'p. ex. AAPL, TSLA, VOO';

  @override
  String get addCustomTickerSymbolRequired => 'Saisissez un symbole boursier.';

  @override
  String get addCustomTickerError =>
      'Impossible de vérifier ce symbole. Vérifiez-le et réessayez.';

  @override
  String get addCustomTickerSubmit => 'Ajouter le symbole';

  @override
  String get cardConfigAddToWatchlist => 'Ajouter à la liste de suivi';

  @override
  String get commonCurrency => 'Devise';

  @override
  String get currencyPickerSearchHint => 'Rechercher une devise';

  @override
  String get detailHoldings => 'Positions';

  @override
  String get detailHistory => 'Historique';

  @override
  String get detailLoadHistory => 'Charger l\'historique';

  @override
  String get detailNoHistoryTitle => 'Pas encore d\'historique';

  @override
  String get detailNoHistoryMessage =>
      'Chargez l\'historique pour voir le graphique de prix complet.';

  @override
  String get detailKeyStats => 'Statistiques clés';

  @override
  String get detailPricePerUnit => 'Prix par unité';

  @override
  String detailUpdatedAt(String time) {
    return 'Mis à jour à $time';
  }

  @override
  String get errorRefreshFailed =>
      'Impossible d\'actualiser les prix. Vérifiez votre connexion et réessayez.';

  @override
  String get detailChangeCurrency => 'Changer de devise';

  @override
  String detailShowPerUnit(String unit) {
    return 'Afficher par $unit';
  }

  @override
  String get holdingsEmpty =>
      'Ajoutez votre premier lot pour commencer à suivre cette position.';

  @override
  String get holdingsValue => 'Valeur';

  @override
  String get holdingsCost => 'Coût';

  @override
  String get holdingsGain => 'Gain';

  @override
  String get holdingsGainPercent => '% de gain';

  @override
  String get holdingsNew => 'Nouveau lot';

  @override
  String get holdingsEdit => 'Modifier le lot';

  @override
  String get holdingsQuantity => 'Quantité';

  @override
  String get holdingsCostModePerUnit => 'Par unité';

  @override
  String get holdingsCostModeTotal => 'Total';

  @override
  String get holdingsUnitCost => 'Coût unitaire';

  @override
  String holdingsUnitCostWithUnit(String unit) {
    return 'Coût unitaire (par $unit)';
  }

  @override
  String holdingsUnitCostWithKarat(String unit, String karat) {
    return 'Coût unitaire (par $unit · $karat)';
  }

  @override
  String holdingsUnitCostPreview(String value) {
    return 'Par unité : $value';
  }

  @override
  String get holdingsTotalCost => 'Coût total';

  @override
  String holdingsTotalCostPreview(String value) {
    return 'Total : $value';
  }

  @override
  String get holdingsDate => 'Date';

  @override
  String get holdingsSave => 'Enregistrer';

  @override
  String get holdingsTotalHeld => 'Total détenu';

  @override
  String get holdingsAverageCost => 'Coût moyen';

  @override
  String holdingsAverageCostPerUnit(String value, String unit) {
    return '$value par $unit';
  }

  @override
  String holdingsAverageCostPerUnitKarat(
    String value,
    String unit,
    String karat,
  ) {
    return '$value par $unit · $karat';
  }

  @override
  String holdingsMixedNote(String karat) {
    return 'Carats mixtes comptés selon la teneur en or, affichés en $karat.';
  }

  @override
  String get holdingsMixedUnitsNote =>
      'Unités mixtes comptées selon la teneur en or.';

  @override
  String holdingsHeldLine(String quantity, String average) {
    return 'Détenu $quantity · moy. $average';
  }

  @override
  String get portfolioTitle => 'Portefeuille';

  @override
  String get portfolioValue => 'Valeur totale';

  @override
  String get portfolioEmpty =>
      'Aucune valeur de portefeuille pour l\'instant — ajoutez un lot pour commencer.';

  @override
  String get portfolioNoChange =>
      'Pas encore assez d\'historique pour cette période';

  @override
  String get portfolioNoHistory =>
      'Ajoutez une position pour voir le graphique de votre portefeuille';

  @override
  String portfolioLotCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lots',
      one: '1 lot',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsAppearanceSystem => 'Système';

  @override
  String get settingsAppearanceLight => 'Clair';

  @override
  String get settingsAppearanceDark => 'Sombre';

  @override
  String get settingsBaseCurrency => 'Devise de base';

  @override
  String get settingsPortfolioCurrency => 'Devise du portefeuille';

  @override
  String get settingsUnit => 'Unité';

  @override
  String get settingsKarat => 'Carat';

  @override
  String get settingsBaseCurrencyFooter =>
      'Utilisée pour totaliser la valeur de votre portefeuille.';

  @override
  String get settingsDefaultRange => 'Période par défaut du graphique';

  @override
  String get settingsDefaultRangeFooter =>
      'Utilisée à la première ouverture d\'un instrument.';

  @override
  String get settingsWidgetRefresh => 'Intervalle d\'actualisation du widget';

  @override
  String get settingsWidgetRefreshFooter =>
      'Fréquence à laquelle les widgets en arrière-plan récupèrent de nouveaux prix.';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsLanguageSystem => 'Suivre le système';

  @override
  String get settingsDataSource =>
      'finance.yahoo.com · gold-api.com · er-api.com';

  @override
  String get settingsPrivacy => 'Confidentialité et sécurité';

  @override
  String get settingsHideBalances => 'Masquer les soldes';

  @override
  String get settingsHideBalancesFooter =>
      'Masque les montants du portefeuille, des positions et des lots dans toute l\'app.';

  @override
  String get settingsAppLock => 'Verrouillage de l\'app';

  @override
  String get settingsAppLockFooter =>
      'Exiger Face ID, Touch ID ou le code de l\'appareil pour ouvrir Qima.';

  @override
  String get settingsAppLockUnavailable =>
      'Configurez d\'abord Face ID, Touch ID ou un code sur cet appareil.';

  @override
  String get settingsAppLockFailed =>
      'Impossible de vous authentifier — le verrouillage reste désactivé.';

  @override
  String get settingsLockAfter => 'Verrouiller après';

  @override
  String get lockGraceImmediately => 'Immédiatement';

  @override
  String get lockGrace1m => '1 minute';

  @override
  String get lockGrace5m => '5 minutes';

  @override
  String get lockGrace15m => '15 minutes';

  @override
  String get privacyHideBalances => 'Masquer les soldes';

  @override
  String get privacyShowBalances => 'Afficher les soldes';

  @override
  String get appLockAuthReason =>
      'Déverrouillez Qima pour voir votre portefeuille';

  @override
  String get appLockLockedTitle => 'Qima est verrouillée';

  @override
  String get appLockLockedMessage =>
      'Déverrouillez pour voir votre portefeuille et vos positions.';

  @override
  String get appLockUnlockFaceID => 'Déverrouiller avec Face ID';

  @override
  String get appLockUnlockTouchID => 'Déverrouiller avec Touch ID';

  @override
  String get appLockUnlockGeneric => 'Déverrouiller';

  @override
  String get appLockUseDevicePasscode => 'Utiliser le code de l\'appareil';

  @override
  String get statChange => 'Variation';

  @override
  String get statHigh => 'Haut';

  @override
  String get statLow => 'Bas';

  @override
  String get statPoints => 'Points';

  @override
  String get pricePullToRefresh => 'Tirez pour actualiser';

  @override
  String get assetClassMetal => 'Métaux';

  @override
  String get assetClassCrypto => 'Cryptomonnaies';

  @override
  String get assetClassStock => 'Actions';

  @override
  String get assetClassIndex => 'Indices';

  @override
  String get assetClassFiat => 'Devises';

  @override
  String get assetGold => 'Or';

  @override
  String get assetSilver => 'Argent';

  @override
  String get assetPlatinum => 'Platine';

  @override
  String get assetPalladium => 'Palladium';

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
  String get assetUsDollar => 'Dollar américain';

  @override
  String get assetEuro => 'Euro';

  @override
  String get assetBritishPound => 'Livre sterling';

  @override
  String get assetEgyptianPound => 'Livre égyptienne';

  @override
  String get assetSaudiRiyal => 'Riyal saoudien';

  @override
  String get assetEmiratiDirham => 'Dirham des ÉAU';

  @override
  String get assetQatariRiyal => 'Riyal qatari';

  @override
  String get assetKuwaitiDinar => 'Dinar koweïtien';

  @override
  String get assetOmaniRial => 'Rial omanais';

  @override
  String get assetBahrainiDinar => 'Dinar bahreïni';

  @override
  String get assetJordanianDinar => 'Dinar jordanien';

  @override
  String get unitTroyOunce => 'Once troy';

  @override
  String get unitGram => 'Gramme';

  @override
  String get unitKilogram => 'Kilogramme';

  @override
  String get unitEach => 'Unité';

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
  String get range1D => '1J';

  @override
  String get range3D => '3J';

  @override
  String get range7D => '7J';

  @override
  String get range1W => '1S';

  @override
  String get range1M => '1M';

  @override
  String get range3M => '3M';

  @override
  String get range6M => '6M';

  @override
  String get rangeYtd => 'DDA';

  @override
  String get range1Y => '1A';

  @override
  String get range5Y => '5A';

  @override
  String get rangeAll => 'Tout';

  @override
  String get refresh15m => '15 minutes';

  @override
  String get refresh30m => '30 minutes';

  @override
  String get refresh1h => '1 heure';

  @override
  String get refresh3h => '3 heures';

  @override
  String get refresh6h => '6 heures';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonRemove => 'Retirer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonUndo => 'Annuler l\'action';

  @override
  String confirmRemoveCardTitle(String name) {
    return 'Retirer $name de votre liste de suivi ?';
  }

  @override
  String get confirmRemoveCardMessage =>
      'Vos positions pour cet instrument sont conservées.';

  @override
  String get confirmDeleteLotTitle => 'Supprimer ce lot ?';

  @override
  String confirmDeleteLotMessage(String details) {
    return '$details. Cette action est irréversible.';
  }

  @override
  String confirmRemoveTickerTitle(String symbol) {
    return 'Retirer le symbole personnalisé $symbol ?';
  }

  @override
  String get confirmRemoveTickerMessage =>
      'Ses cartes dans la liste de suivi seront aussi retirées.';

  @override
  String get alertKindAbove => 'Dépasse';

  @override
  String get alertKindBelow => 'Descend sous';

  @override
  String get alertKindPercentMove => 'Variation %';

  @override
  String get alertDirectionUp => 'Hausse';

  @override
  String get alertDirectionDown => 'Baisse';

  @override
  String get alertDirectionEither => 'Les deux';

  @override
  String get alertWindowWithin24h => 'En 24 heures';

  @override
  String get alertWindowWithin7d => 'En 7 jours';

  @override
  String get alertWindow24h => '24 heures';

  @override
  String get alertWindow7d => '7 jours';

  @override
  String get alertBellTooltip => 'Alertes de prix';

  @override
  String get alertsCardTitle => 'Alertes';

  @override
  String get alertsCardEmpty =>
      'Aucune alerte pour cet instrument pour l\'instant.';

  @override
  String get alertsCardAdd => 'Ajouter une alerte';

  @override
  String get alertEditorNewTitle => 'Nouvelle alerte';

  @override
  String get alertEditorEditTitle => 'Modifier l\'alerte';

  @override
  String get alertEditorTypePrice => 'Prix';

  @override
  String get alertEditorTypePercent => 'Variation %';

  @override
  String get alertEditorGoesAbove => 'Dépasse';

  @override
  String get alertEditorGoesBelow => 'Descend sous';

  @override
  String get alertEditorTargetLabel => 'Prix cible';

  @override
  String get alertEditorTargetRequired =>
      'Saisissez un prix cible supérieur à zéro.';

  @override
  String alertEditorHelperAbove(String delta, String percent) {
    return '+$delta · $percent % au-dessus du prix actuel';
  }

  @override
  String alertEditorHelperBelow(String delta, String percent) {
    return '−$delta · $percent % en dessous du prix actuel';
  }

  @override
  String get alertEditorDirection => 'Direction';

  @override
  String get alertEditorWindow => 'Période';

  @override
  String alertEditorPercentSummary(String low, String high) {
    return 'Se déclenche sous $low ou au-dessus de $high';
  }

  @override
  String alertEditorPercentSummaryUp(String high) {
    return 'Se déclenche au-dessus de $high';
  }

  @override
  String alertEditorPercentSummaryDown(String low) {
    return 'Se déclenche sous $low';
  }

  @override
  String get alertEditorRepeat => 'Répéter';

  @override
  String get alertEditorRepeatFooter =>
      'Continue de surveiller après le déclenchement, au lieu de se désactiver.';

  @override
  String get alertEditorCreate => 'Créer l\'alerte';

  @override
  String get alertEditorSave => 'Enregistrer';

  @override
  String get alertEditorDelete => 'Supprimer';

  @override
  String get alertsScreenTitle => 'Alertes';

  @override
  String get alertsScreenInfo =>
      'Les alertes sont vérifiées environ toutes les 15 minutes en arrière-plan, et en continu lorsque Qima est ouverte.';

  @override
  String get alertsScreenEmptyTitle => 'Aucune alerte pour l\'instant';

  @override
  String get alertsScreenEmptyMessage =>
      'Ouvrez un instrument et touchez la cloche pour définir une alerte de prix.';

  @override
  String alertsScreenFiredToday(String time) {
    return 'Déclenchée aujourd\'hui à $time · désactivée';
  }

  @override
  String get alertsScreenNotificationsOff =>
      'Les notifications sont désactivées';

  @override
  String get alertsScreenNotificationsOffMessage =>
      'Activez les notifications de Qima pour être averti quand un prix cible est atteint.';

  @override
  String get alertsScreenOpenSettings => 'Ouvrir les réglages';

  @override
  String get confirmDeleteAlertTitle => 'Supprimer cette alerte ?';

  @override
  String get confirmDeleteAlertMessage =>
      'Vous ne serez plus averti pour celle-ci.';

  @override
  String get settingsAlerts => 'Alertes';

  @override
  String get settingsAlertsPriceAlerts => 'Alertes de prix';

  @override
  String settingsAlertsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alertes',
      one: '1 alerte',
      zero: 'Aucune alerte',
    );
    return '$_temp0';
  }

  @override
  String get settingsAlertsNotifications => 'Notifications';

  @override
  String get settingsAlertsNotificationsOn => 'Activées';

  @override
  String get settingsAlertsNotificationsOff => 'Désactivées';

  @override
  String get settingsAlertsDeliverOnDevice =>
      'Recevoir les alertes sur cet appareil';

  @override
  String get settingsAlertsDeliverOnDeviceFooter =>
      'Désactivez si vous ne voulez pas que cet appareil vous avertisse quand une alerte se déclenche.';

  @override
  String alertNotificationTitleAbove(String name, String target) {
    return '$name dépasse $target';
  }

  @override
  String alertNotificationTitleBelow(String name, String target) {
    return '$name passe sous $target';
  }

  @override
  String alertNotificationTitlePercent(
    String name,
    String percent,
    String window,
  ) {
    return '$name a varié de $percent % en $window';
  }

  @override
  String alertNotificationBodyOneOff(String price, String unit) {
    return 'Actuellement $price par $unit. Cette alerte est maintenant désactivée.';
  }

  @override
  String alertNotificationBodyRepeat(String price, String unit) {
    return 'Actuellement $price par $unit. Vous serez averti à nouveau la prochaine fois.';
  }

  @override
  String get settingsBackup => 'Sauvegarde et restauration';

  @override
  String get settingsBackupSubtitleNever => 'Aucune sauvegarde effectuée';

  @override
  String settingsBackupSubtitle(String date, int instruments, int lots) {
    return 'Dernière sauvegarde $date · $instruments instruments, $lots lots';
  }

  @override
  String get settingsICloudSync => 'Synchronisation iCloud';

  @override
  String get settingsICloudSyncSwitch => 'Synchroniser avec iCloud';

  @override
  String get settingsICloudSyncFooter =>
      'Garde votre liste de suivi, vos avoirs, vos tickers personnalisés et vos alertes de prix à jour sur tous vos appareils.';

  @override
  String settingsICloudSyncStatusUpToDate(String time) {
    return 'À jour · $time';
  }

  @override
  String get settingsICloudSyncStatusSyncing => 'Synchronisation…';

  @override
  String get settingsICloudSyncStatusNotSignedIn => 'Non connecté à iCloud';

  @override
  String get settingsICloudSyncStatusStorageFull =>
      'Le stockage iCloud de Qima est plein';

  @override
  String get backupTitle => 'Sauvegarde et restauration';

  @override
  String get backupStatusTitle => 'Stocké uniquement sur ce téléphone';

  @override
  String get backupStatusMessage =>
      'Vos données existent uniquement sur cet appareil. Sauvegardez-les pour pouvoir les restaurer ici ou sur un autre appareil.';

  @override
  String backupLastBackup(String date) {
    return 'Dernière sauvegarde $date';
  }

  @override
  String get backupLastBackupNever => 'Aucune sauvegarde effectuée';

  @override
  String get backupReminderCardTitle => 'Il est temps de sauvegarder';

  @override
  String get backupReminderCardMessage =>
      'Cela fait plus de 30 jours depuis votre dernière sauvegarde et vos données ont changé.';

  @override
  String get backupReminderCardAction => 'Sauvegarder maintenant';

  @override
  String get backupReminderNotificationTitle => 'Il est temps de sauvegarder';

  @override
  String get backupReminderNotificationBody =>
      'Cela fait un moment depuis votre dernière sauvegarde Qima et vos données ont changé. Appuyez pour sauvegarder maintenant.';

  @override
  String get backupExportSection => 'Exporter';

  @override
  String get backupExportFullTitle => 'Sauvegarde complète';

  @override
  String get backupExportFullSubtitle =>
      'Liste de suivi, positions, tickers personnalisés, alertes et paramètres (.json)';

  @override
  String get backupExportCsvTitle => 'Tableur des positions';

  @override
  String get backupExportCsvSubtitle =>
      'Vos lots sous forme de tableur, pour vos archives (.csv)';

  @override
  String get backupRestoreSection => 'Restaurer';

  @override
  String get backupRestoreTitle => 'Importer une sauvegarde';

  @override
  String get backupRestoreSubtitle =>
      'Restaurer depuis un fichier de sauvegarde complète (.json)';

  @override
  String get backupReminderSection => 'Rappel';

  @override
  String get backupReminderToggleTitle => 'Me rappeler de sauvegarder';

  @override
  String get backupReminderToggleSubtitle =>
      'Recevez un rappel mensuel si vous n\'avez pas sauvegardé récemment et que vos données ont changé.';

  @override
  String get backupExportSheetTitle => 'Exporter la sauvegarde';

  @override
  String get backupExportSheetFileName => 'Nom du fichier';

  @override
  String get backupExportSheetFileSize => 'Taille';

  @override
  String get backupExportSheetFileContents => 'Contenu';

  @override
  String backupExportSheetContentsSummary(
    int cards,
    int lots,
    int customTickers,
  ) {
    return '$cards cartes de suivi · $lots lots · $customTickers tickers personnalisés';
  }

  @override
  String get backupExportSheetProtectTitle => 'Protéger par mot de passe';

  @override
  String get backupExportSheetProtectSubtitle =>
      'Chiffre le fichier avec AES-256. Si vous oubliez ce mot de passe, la sauvegarde ne pourra pas être récupérée.';

  @override
  String get backupExportSheetPasswordLabel => 'Mot de passe';

  @override
  String get backupExportSheetPasswordConfirmLabel =>
      'Confirmer le mot de passe';

  @override
  String get backupExportSheetPasswordTooShort =>
      'Utilisez au moins 8 caractères.';

  @override
  String get backupExportSheetPasswordMismatch =>
      'Les mots de passe ne correspondent pas.';

  @override
  String get backupExportSheetUnprotectedWarning =>
      'Toute personne possédant ce fichier peut lire vos données. Protégez-le par un mot de passe si vous comptez le stocker ou l\'envoyer dans un endroit moins privé.';

  @override
  String get backupExportSheetAction => 'Enregistrer ou partager…';

  @override
  String get backupExportSheetWorking => 'Préparation de votre sauvegarde…';

  @override
  String get backupExportSheetFailed =>
      'Impossible de créer la sauvegarde. Réessayez.';

  @override
  String get backupImportPreviewTitle => 'Restaurer la sauvegarde';

  @override
  String backupImportFileCreated(String date) {
    return 'Créée le $date';
  }

  @override
  String backupImportFileAppVersion(String version) {
    return 'Créée avec Qima $version';
  }

  @override
  String get backupImportCountCards => 'Cartes de suivi';

  @override
  String get backupImportCountLots => 'Lots';

  @override
  String get backupImportCountCustomTickers => 'Tickers personnalisés';

  @override
  String get backupImportCountSettings => 'Paramètres inclus';

  @override
  String get backupImportPasswordPrompt =>
      'Cette sauvegarde est protégée. Entrez le mot de passe pour continuer.';

  @override
  String get backupImportPasswordLabel => 'Mot de passe';

  @override
  String get backupImportPasswordIncorrect =>
      'Ce mot de passe n\'a pas fonctionné. Réessayez.';

  @override
  String get backupImportUnlock => 'Déverrouiller';

  @override
  String get backupImportModeMerge => 'Fusionner';

  @override
  String get backupImportModeReplace => 'Remplacer';

  @override
  String get backupImportModeMergeFooter =>
      'Conserve ce qui est sur ce téléphone et ajoute ce qui est nouveau ou plus récent dans la sauvegarde.';

  @override
  String get backupImportModeReplaceFooter =>
      'Remplace tout sur ce téléphone par le contenu de la sauvegarde.';

  @override
  String backupImportDiff(int added, int updated, int removed) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: '+$added ajoutés',
      one: '+1 ajouté',
      zero: '',
    );
    return '$_temp0 · $updated mis à jour · $removed supprimés';
  }

  @override
  String get backupImportRestoreButton => 'Restaurer';

  @override
  String get backupImportReplaceConfirmTitle =>
      'Tout remplacer sur ce téléphone ?';

  @override
  String get backupImportReplaceConfirmMessage =>
      'Votre liste de suivi, vos positions, vos tickers personnalisés et vos alertes actuels seront remplacés par le contenu de la sauvegarde. Cette action est irréversible.';

  @override
  String get backupImportReplaceConfirmAction => 'Remplacer';

  @override
  String get backupImportSuccessSnackbar => 'Sauvegarde restaurée';

  @override
  String get backupImportFailedTitle =>
      'Impossible de restaurer cette sauvegarde';

  @override
  String get backupImportCsvErrorTitle =>
      'Ceci est un tableur, pas une sauvegarde';

  @override
  String get backupImportCsvErrorMessage =>
      'Un tableur de positions (.csv) ne contient que vos lots et ne peut pas être restauré. Choisissez plutôt un fichier de sauvegarde complète (.json).';

  @override
  String get backupErrorNotQimaFile =>
      'Ce fichier ne ressemble pas à une sauvegarde Qima.';

  @override
  String get backupErrorNewerVersion =>
      'Cette sauvegarde a été créée avec une version plus récente de Qima. Mettez à jour l\'application pour la restaurer.';

  @override
  String get backupErrorWrongPassword => 'Ce mot de passe n\'a pas fonctionné.';

  @override
  String get backupErrorCorrupted =>
      'Ce fichier de sauvegarde est endommagé et ne peut pas être restauré.';

  @override
  String get backupCsvHeaderInstrument => 'Instrument';

  @override
  String get backupCsvHeaderSymbol => 'Symbole';

  @override
  String get backupCsvHeaderQuantity => 'Quantité';

  @override
  String get backupCsvHeaderUnit => 'Unité';

  @override
  String get backupCsvHeaderKarat => 'Carat';

  @override
  String get backupCsvHeaderUnitCost => 'Coût unitaire';

  @override
  String get backupCsvHeaderCostCurrency => 'Devise du coût';

  @override
  String get backupCsvHeaderTotalCost => 'Coût total';

  @override
  String get backupCsvHeaderDate => 'Date';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingGetStarted => 'Commencer';

  @override
  String get onboardingStep1Title => 'Tout ce que vous possédez, en un chiffre';

  @override
  String get onboardingStep1Body =>
      'Or, argent, cryptomonnaies, actions, indices et devises, additionnés dans votre devise.';

  @override
  String get onboardingStep2Title => 'Des prix comme vous achetez';

  @override
  String get onboardingStep2Body =>
      'Prix en direct au gramme, à l\'once ou au kilogramme, de 24 à 18 carats, dans n\'importe quelle devise. Appuyez sur + pour ajouter, appuyez sur une carte pour son graphique.';

  @override
  String get onboardingStep3Title => 'Sachez ce que vous détenez';

  @override
  String get onboardingStep3Body =>
      'Enregistrez chaque achat : quantité, unité, carat, coût et date. Consultez ce que vous détenez, votre coût moyen, la valeur et le gain.';

  @override
  String get onboardingStep4Title => 'Ne manquez plus aucun mouvement';

  @override
  String get onboardingStep4Body =>
      'Recevez une notification quand un prix franchit un niveau ou évolue d\'un pourcentage. Affichez les prix sur votre écran d\'accueil et de verrouillage.';

  @override
  String get onboardingStep5Title => 'Privé par conception';

  @override
  String get onboardingStep5Body =>
      'Pas de compte. Vos données restent sur cet appareil, avec synchronisation iCloud facultative, verrouillage Face ID et sauvegardes fichier.';

  @override
  String get onboardingStep5BodyAndroid =>
      'Pas de compte. Vos données restent sur cet appareil, avec déverrouillage par empreinte ou visage et sauvegardes fichier.';

  @override
  String get onboardingStep5BodyMac =>
      'Pas de compte. Vos données restent sur ce Mac, avec synchronisation iCloud facultative, verrouillage Touch ID et sauvegardes fichier.';

  @override
  String get onboardingStep5PillNoAccount => 'Aucun compte';

  @override
  String get onboardingStep5PillOnDevice => 'Sur cet appareil';

  @override
  String get onboardingStep5ICloudTitle => 'Synchronisation iCloud';

  @override
  String get onboardingStep5ICloudSubtitle =>
      'Facultatif · garde vos appareils synchronisés';

  @override
  String get onboardingStep5AppLockTitle => 'Verrouillage de l\'app';

  @override
  String get onboardingStep5AppLockSubtitleApple =>
      'Face ID ou empreinte digitale';

  @override
  String get onboardingStep5AppLockSubtitleGeneric =>
      'Empreinte digitale ou déverrouillage facial';

  @override
  String get onboardingStep5AppLockSubtitleMac =>
      'Touch ID ou le mot de passe du Mac';

  @override
  String get onboardingStep5HideBalancesTitle => 'Masquer les montants';

  @override
  String get onboardingStep5HideBalancesSubtitle =>
      'Afficher •••• à la place des montants';

  @override
  String get onboardingBaseCurrencyTitle => 'Devise de base';

  @override
  String get onboardingBaseCurrencySubtitle =>
      'Selon votre région · modifiable dans Réglages';

  @override
  String onboardingSemanticStepOf(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String get onboardingReplayTour => 'Revoir la visite';

  @override
  String get helpButtonTooltip => 'Aide';

  @override
  String get helpSheetAboutHeader => 'À PROPOS DE CETTE PAGE';

  @override
  String get helpSheetHowToHeader => 'COMMENT L\'UTILISER';

  @override
  String get helpSheetIndexHeader => 'AIDE';

  @override
  String get helpSheetWidgetsHeader => 'AIDE · RÉGLAGES';

  @override
  String get helpSheetCloseTooltip => 'Fermer';

  @override
  String get helpIndexIntro =>
      'Choisissez une page pour voir ce qu’elle fait et comment l’utiliser.';

  @override
  String get helpWatchlistTitle => 'Liste de suivi';

  @override
  String get helpWatchlistSummary =>
      'Prix en direct de tout ce que vous suivez, avec le total de votre portefeuille en haut.';

  @override
  String get helpWatchlistStep1Title => 'Ouvrez une carte';

  @override
  String get helpWatchlistStep1Body =>
      'Appuyez sur une carte pour son graphique, ses statistiques clés et vos avoirs.';

  @override
  String get helpWatchlistStep2Title => 'Ajoutez un actif';

  @override
  String get helpWatchlistStep2Body =>
      'Appuyez sur + et recherchez par nom ou symbole.';

  @override
  String get helpWatchlistStep3Title => 'Filtrez la liste';

  @override
  String get helpWatchlistStep3Body =>
      'Affichez uniquement les métaux, cryptos, actions, indices ou devises.';

  @override
  String get helpWatchlistStep4Title => 'Changez la période du graphique';

  @override
  String get helpWatchlistStep4Body =>
      'Choisissez de 1S à Tout sous le graphique du portefeuille.';

  @override
  String get helpWatchlistStep5Title => 'Actualisez les prix';

  @override
  String get helpWatchlistStep5Body =>
      'Appuyez sur actualiser pour récupérer les derniers prix maintenant.';

  @override
  String get helpAssetDetailTitle => 'Détail de l\'actif';

  @override
  String get helpAssetDetailSummary =>
      'Le prix, le graphique et les statistiques d\'un actif, plus ce que vous en détenez.';

  @override
  String get helpAssetDetailStep1Title => 'Choisissez une période';

  @override
  String get helpAssetDetailStep1Body =>
      'Basculez entre 1J et Tout sous le graphique.';

  @override
  String get helpAssetDetailStep2Title =>
      'Changez l\'unité, le carat ou la devise';

  @override
  String get helpAssetDetailStep2Body =>
      'Appuyez sur les réglages en haut de la page.';

  @override
  String get helpAssetDetailStep3Title => 'Comparez les unités';

  @override
  String get helpAssetDetailStep3Body =>
      'Le prix par unité affiche l\'once, le kilogramme et chaque carat côte à côte.';

  @override
  String get helpAssetDetailStep4Title => 'Configurez une alerte';

  @override
  String get helpAssetDetailStep4Body =>
      'Appuyez sur la cloche pour être averti quand le prix franchit un niveau ou évolue d’un pourcentage.';

  @override
  String get helpAssetDetailStep5Title => 'Suivez ce que vous détenez';

  @override
  String get helpAssetDetailStep5Body =>
      'Appuyez sur Avoirs pour voir vos lots ou ajouter un achat.';

  @override
  String get helpPortfolioTitle => 'Portefeuille';

  @override
  String get helpPortfolioSummary =>
      'Tout ce que vous détenez, additionné dans votre devise de base, avec la part et le gain de chaque actif.';

  @override
  String get helpPortfolioStep1Title => 'Lisez le donut';

  @override
  String get helpPortfolioStep1Body =>
      'Chaque portion représente la part d\'un actif dans votre valeur totale.';

  @override
  String get helpPortfolioStep2Title => 'Ouvrez un actif';

  @override
  String get helpPortfolioStep2Body =>
      'Appuyez sur une ligne pour voir ses lots, son coût moyen et son gain.';

  @override
  String get helpPortfolioStep3Title => 'Ajoutez un achat';

  @override
  String get helpPortfolioStep3Body => 'Ouvrez un actif, puis appuyez sur +.';

  @override
  String get helpPortfolioStep4Title => 'Changez la devise';

  @override
  String get helpPortfolioStep4Body =>
      'Les totaux utilisent votre devise de base, définie dans Réglages.';

  @override
  String get helpPortfolioStep5Title => 'Masquez les montants';

  @override
  String get helpPortfolioStep5Body =>
      'Activez Masquer les montants dans Réglages pour masquer toutes les valeurs.';

  @override
  String get helpLotEditorTitle => 'Éditeur de lot';

  @override
  String get helpLotEditorSummary =>
      'Enregistrez un achat pour que Qima calcule ce que vous détenez, votre coût moyen et votre gain.';

  @override
  String get helpLotEditorStep1Title => 'Quantité et unité';

  @override
  String get helpLotEditorStep1Body =>
      'Indiquez la quantité achetée, en onces troy, grammes ou kilogrammes.';

  @override
  String get helpLotEditorStep2Title => 'Carat';

  @override
  String get helpLotEditorStep2Body =>
      'Pour l\'or au gramme ou au kilogramme, choisissez 24, 22, 21 ou 18 carats. Il démarre au carat de la carte.';

  @override
  String get helpLotEditorStep3Title => 'Ce que vous avez payé';

  @override
  String get helpLotEditorStep3Body =>
      'Indiquez le coût par unité ou le total, dans la devise utilisée pour payer.';

  @override
  String get helpLotEditorStep4Title => 'Date';

  @override
  String get helpLotEditorStep4Body => 'Le jour de l\'achat.';

  @override
  String get helpLotEditorStep5Title => 'Enregistrez';

  @override
  String get helpLotEditorStep5Body =>
      'Modifiez ou supprimez un lot à tout moment depuis Avoirs.';

  @override
  String get helpAddAssetTitle => 'Ajouter un actif';

  @override
  String get helpAddAssetSummary =>
      'Trouvez un actif à suivre et ajoutez-le à votre liste de suivi.';

  @override
  String get helpAddAssetStep1Title => 'Recherchez';

  @override
  String get helpAddAssetStep1Body =>
      'Saisissez un nom ou un symbole, comme or, BTC ou AAPL.';

  @override
  String get helpAddAssetStep2Title => 'Choisissez un résultat';

  @override
  String get helpAddAssetStep2Body =>
      'Il est ajouté à votre liste de suivi et sa page s’ouvre.';

  @override
  String get helpAddAssetStep3Title => 'Absent de la liste ?';

  @override
  String get helpAddAssetStep3Body =>
      'Ajoutez le symbole comme ticker personnalisé. Qima le vérifie d’abord auprès du fournisseur de prix.';

  @override
  String get helpAddAssetStep4Title => 'Vous avez changé d\'avis ?';

  @override
  String get helpAddAssetStep4Body =>
      'Appuyez sur Annuler dans la confirmation en bas.';

  @override
  String get helpPriceAlertsTitle => 'Alertes de prix';

  @override
  String get helpPriceAlertsSummary =>
      'Toutes vos alertes, groupées par actif.';

  @override
  String get helpPriceAlertsStep1Title => 'Nouvelle alerte';

  @override
  String get helpPriceAlertsStep1Body =>
      'Appuyez sur +, ou ouvrez un actif et appuyez sur la cloche.';

  @override
  String get helpPriceAlertsStep2Title => 'Suspendez ou reprenez';

  @override
  String get helpPriceAlertsStep2Body =>
      'Utilisez l\'interrupteur. Les alertes ponctuelles se désactivent d\'elles-mêmes après s\'être déclenchées.';

  @override
  String get helpPriceAlertsStep3Title => 'Modifiez ou supprimez';

  @override
  String get helpPriceAlertsStep3Body =>
      'Appuyez sur une alerte pour la modifier ou la supprimer.';

  @override
  String get helpPriceAlertsStep4Title => 'Quand les alertes arrivent';

  @override
  String get helpPriceAlertsStep4Body =>
      'Les prix sont vérifiés environ toutes les 15 minutes en arrière-plan, une alerte peut donc arriver avec quelques minutes de retard.';

  @override
  String get helpPriceAlertsStep5Title => 'Pas de notifications ?';

  @override
  String get helpPriceAlertsStep5Body =>
      'Autorisez les notifications pour Qima dans les réglages système, sinon les alertes ne pourront pas vous parvenir.';

  @override
  String get helpAlertEditorTitle => 'Éditeur d\'alerte';

  @override
  String get helpAlertEditorSummary =>
      'Choisissez quand Qima doit vous avertir au sujet de cet actif.';

  @override
  String get helpAlertEditorStep1Title => 'Prix';

  @override
  String get helpAlertEditorStep1Body =>
      'Avertit quand le prix dépasse ou descend sous votre cible.';

  @override
  String get helpAlertEditorStep2Title => '% de variation';

  @override
  String get helpAlertEditorStep2Body =>
      'Avertit en cas de variation à la hausse, à la baisse, ou dans les deux sens, de 1 à 10 % en 24 heures ou 7 jours.';

  @override
  String get helpAlertEditorStep3Title => 'Vérifiez le déclencheur';

  @override
  String get helpAlertEditorStep3Body =>
      'La ligne sous votre choix indique exactement quels prix la déclencheront.';

  @override
  String get helpAlertEditorStep4Title => 'Répétition';

  @override
  String get helpAlertEditorStep4Body =>
      'Désactivé : l’alerte se déclenche une fois puis s’éteint. Activé : elle se déclenche à chaque fois.';

  @override
  String get helpSettingsTitle => 'Réglages';

  @override
  String get helpSettingsSummary =>
      'Choix qui s\'appliquent à toute l\'application.';

  @override
  String get helpSettingsStep1Title => 'Apparence';

  @override
  String get helpSettingsStep1Body => 'Système, Clair ou Sombre.';

  @override
  String get helpSettingsStep2Title => 'Confidentialité et sécurité';

  @override
  String get helpSettingsStep2Body =>
      'Masquez les montants et verrouillez Qima avec Face ID ou une empreinte digitale.';

  @override
  String get helpSettingsStep3Title => 'Alertes';

  @override
  String get helpSettingsStep3Body =>
      'Consultez toutes les alertes de prix et vérifiez que les notifications sont autorisées.';

  @override
  String get helpSettingsStep4Title => 'Sauvegarde';

  @override
  String get helpSettingsStep4Body =>
      'Enregistrez tout dans un fichier et restaurez-le plus tard.';

  @override
  String get helpSettingsStep5Title => 'Valeurs par défaut';

  @override
  String get helpSettingsStep5Body =>
      'Devise de base, période du graphique, actualisation du widget et langue.';

  @override
  String get helpBackupTitle => 'Sauvegarde et restauration';

  @override
  String get helpBackupSummary =>
      'Qima n\'a pas de compte : un fichier de sauvegarde est le moyen de conserver vos données si ce téléphone est perdu ou réinitialisé.';

  @override
  String get helpBackupStep1Title => 'Sauvegarde complète';

  @override
  String get helpBackupStep1Body =>
      'Enregistre votre liste de suivi, vos avoirs, vos tickers personnalisés et vos réglages dans un fichier .json.';

  @override
  String get helpBackupStep2Title => 'Ajoutez un mot de passe';

  @override
  String get helpBackupStep2Body =>
      'Facultatif. Vous en aurez besoin pour restaurer, et il ne peut pas être récupéré.';

  @override
  String get helpBackupStep3Title => 'Enregistrez ou partagez';

  @override
  String get helpBackupStep3Body =>
      'Conservez le fichier dans Fichiers ou iCloud Drive, ou envoyez-le-vous.';

  @override
  String get helpBackupStep4Title => 'Restaurer';

  @override
  String get helpBackupStep4Body =>
      'Importez une sauvegarde .json. Fusionner ajoute ce qui manque et ne supprime rien ; Remplacer échange tout contre le fichier.';

  @override
  String get helpBackupStep5Title => 'Feuille de calcul des avoirs';

  @override
  String get helpBackupStep5Body =>
      'Un .csv pour la comptabilité. Il ne peut pas être restauré.';

  @override
  String get helpWidgetsTitle => 'Widgets';

  @override
  String get helpWidgetsSummary =>
      'Affichez les prix en direct et votre portefeuille sur l\'écran d\'accueil et de verrouillage.';

  @override
  String get helpWidgetsStep1Title =>
      'Touchez et maintenez l\'écran d\'accueil';

  @override
  String get helpWidgetsStep1Body =>
      'Quand les applis se mettent à trembler, appuyez sur Modifier, puis Ajouter un widget.';

  @override
  String get helpWidgetsStep2Title => 'Trouvez Qima';

  @override
  String get helpWidgetsStep2Body =>
      'Recherchez Qima, choisissez Prix ou Portefeuille, sélectionnez une taille et appuyez sur Ajouter le widget.';

  @override
  String get helpWidgetsStep3Title => 'Choisissez ce qu\'il affiche';

  @override
  String get helpWidgetsStep3Body =>
      'Touchez et maintenez le widget, appuyez sur Modifier le widget, puis choisissez l\'actif, l\'unité, le carat, la devise et la période.';

  @override
  String get helpWidgetsStep4Title => 'Écran verrouillé';

  @override
  String get helpWidgetsStep4Body =>
      'Touchez et maintenez l’écran verrouillé, appuyez sur Personnaliser, puis ajoutez un widget Qima.';

  @override
  String get helpWidgetsNote =>
      'Les widgets s\'actualisent toutes les 15 minutes par défaut. Modifiez cela dans Réglages, sous Intervalle d\'actualisation du widget.';

  @override
  String get helpHoldingsTitle => 'Avoirs';

  @override
  String get helpHoldingsSummary =>
      'Chaque lot que vous avez acheté de cet actif, et ce qu\'ils totalisent.';

  @override
  String get helpHoldingsStep1Title => 'Lisez les totaux';

  @override
  String get helpHoldingsStep1Body =>
      'Quantité, coût moyen, valeur actuelle et gain sur l’ensemble des lots.';

  @override
  String get helpHoldingsStep2Title => 'Ajoutez un lot';

  @override
  String get helpHoldingsStep2Body =>
      'Appuyez sur + pour enregistrer un autre achat.';

  @override
  String get helpHoldingsStep3Title => 'Modifiez ou supprimez un lot';

  @override
  String get helpHoldingsStep3Body =>
      'Appuyez sur un lot pour le modifier, ou balayez pour le supprimer.';

  @override
  String get helpCardConfigTitle => 'Réglages de l\'actif';

  @override
  String get helpCardConfigSummary =>
      'Choisissez la devise, l’unité et le carat affichés par cette carte avant de l’ajouter.';

  @override
  String get helpCardConfigStep1Title => 'Devise';

  @override
  String get helpCardConfigStep1Body =>
      'Les prix s’affichent dans cette devise sur la carte et son graphique.';

  @override
  String get helpCardConfigStep2Title => 'Unité';

  @override
  String get helpCardConfigStep2Body =>
      'Pour les métaux, choisissez once troy, gramme ou kilogramme.';

  @override
  String get helpCardConfigStep3Title => 'Carat';

  @override
  String get helpCardConfigStep3Body =>
      'Pour l\'or au poids, choisissez la pureté à coter.';

  @override
  String get helpCardConfigStep4Title => 'Ajoutez-le';

  @override
  String get helpCardConfigStep4Body =>
      'Vous pourrez modifier ces réglages plus tard depuis la page de détail de l’actif.';

  @override
  String get helpCustomTickerTitle => 'Ticker personnalisé';

  @override
  String get helpCustomTickerSummary =>
      'Suivez une action, un ETF ou un indice absent du catalogue Qima grâce à son symbole.';

  @override
  String get helpCustomTickerStep1Title => 'Saisissez le symbole';

  @override
  String get helpCustomTickerStep1Body =>
      'Saisissez le symbole exact du ticker, comme TSLA ou VOO.';

  @override
  String get helpCustomTickerStep2Title => 'Qima le vérifie';

  @override
  String get helpCustomTickerStep2Body =>
      'Il est d\'abord recherché auprès du fournisseur de prix, ce qui permet de détecter une faute de frappe avant l\'ajout.';

  @override
  String get helpCustomTickerStep3Title => 'Ajoutez-le';

  @override
  String get helpCustomTickerStep3Body =>
      'Il est ajouté à votre liste de suivi avec son nom et son prix réels.';

  @override
  String get helpCurrencyPickerTitle => 'Sélecteur de devise';

  @override
  String get helpCurrencyPickerSummary =>
      'Choisissez la devise dans laquelle afficher les prix et les totaux.';

  @override
  String get helpCurrencyPickerStep1Title => 'Recherchez';

  @override
  String get helpCurrencyPickerStep1Body =>
      'Saisissez un code ISO ou le nom d’une devise, comme EUR ou dirham.';

  @override
  String get helpCurrencyPickerStep2Title => 'Choisissez-en une';

  @override
  String get helpCurrencyPickerStep2Body =>
      'Appuyez sur une devise pour l’utiliser immédiatement.';

  @override
  String get helpImportPreviewTitle => 'Aperçu de la restauration';

  @override
  String get helpImportPreviewSummary =>
      'Consultez le contenu d\'un fichier de sauvegarde avant qu\'il ne modifie quoi que ce soit sur ce téléphone.';

  @override
  String get helpImportPreviewStep1Title => 'Vérifiez le contenu';

  @override
  String get helpImportPreviewStep1Body =>
      'Vérifiez le nombre de cartes, lots et alertes contenus dans le fichier avant de restaurer.';

  @override
  String get helpImportPreviewStep2Title => 'Fusionner ou Remplacer';

  @override
  String get helpImportPreviewStep2Body =>
      'Fusionner ajoute ce qui manque et ne supprime rien. Remplacer échange tout contre le fichier.';

  @override
  String get helpImportPreviewStep3Title => 'Confirmez';

  @override
  String get helpImportPreviewStep3Body =>
      'Un fichier protégé par mot de passe demande d\'abord ce mot de passe.';

  @override
  String get settingsHelpGroup => 'Aide';

  @override
  String get settingsHelpReplayTour => 'Revoir la visite';

  @override
  String get settingsHelpReplayTourSubtitle =>
      'Revoyez l’introduction en cinq étapes';

  @override
  String get settingsHelpHowQimaWorks => 'Comment fonctionne Qima';

  @override
  String get settingsHelpHowQimaWorksSubtitle =>
      'Un guide rapide de chaque page';

  @override
  String get settingsHelpAddWidget => 'Ajoutez un widget';

  @override
  String get settingsHelpAddWidgetSubtitle =>
      'Écran d\'accueil et de verrouillage';
}
