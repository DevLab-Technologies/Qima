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
  String get watchlistAdd => 'Ajouter un actif';

  @override
  String get watchlistEmptyTitle => 'Votre liste de suivi est vide';

  @override
  String get watchlistEmptyMessage =>
      'Ajoutez des métaux, cryptomonnaies, actions ou devises pour suivre leurs prix.';

  @override
  String get watchlistFilterAll => 'Tous';

  @override
  String get addTitle => 'Ajouter un actif';

  @override
  String get addSearchHint => 'Rechercher ou décrire un achat';

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
      'Aucune transaction pour l’instant. Ajoutez un achat pour suivre cet avoir.';

  @override
  String get holdingsValue => 'Valeur';

  @override
  String get holdingsCost => 'Coût';

  @override
  String get holdingsGain => 'Gain';

  @override
  String get holdingsGainPercent => '% de gain';

  @override
  String get holdingsQuantity => 'Quantité';

  @override
  String get holdingsCostModePerUnit => 'Par unité';

  @override
  String get holdingsCostModeTotal => 'Total';

  @override
  String get holdingsTotalCost => 'Coût total';

  @override
  String get holdingsDate => 'Date';

  @override
  String get holdingsSave => 'Enregistrer';

  @override
  String get holdingsTotalHeld => 'Total détenu';

  @override
  String get holdingsAverageCost => 'Coût moyen';

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
      'Aucune valeur de portefeuille pour l’instant — ajoutez un achat à un actif pour commencer.';

  @override
  String get portfolioNoChange =>
      'Pas encore assez d\'historique pour cette période';

  @override
  String get portfolioNoHistory =>
      'Ajoutez un achat pour voir le graphique de votre portefeuille';

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
      'Utilisée à la première ouverture d\'un actif.';

  @override
  String get settingsWidgetRefresh => 'Intervalle d\'actualisation du widget';

  @override
  String get settingsWidgetRefreshFooter =>
      'Fréquence à laquelle les widgets en arrière-plan récupèrent de nouveaux prix.';

  @override
  String get settingsLanguage => 'Langue';

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
      'Masque les montants du portefeuille, des positions et des transactions dans toute l’app.';

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
      'Vos positions pour cet actif sont conservées.';

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
  String get alertsCardEmpty => 'Aucune alerte pour cet actif pour l\'instant.';

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
  String get alertsScreenEmptyTitle => 'Aucune alerte pour l\'instant';

  @override
  String get alertsScreenEmptyMessage =>
      'Ouvrez un actif et touchez la cloche pour définir une alerte de prix.';

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
  String settingsBackupSubtitle(
    String date,
    int instruments,
    int transactions,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      transactions,
      locale: localeName,
      other: '$transactions transactions',
      one: '1 transaction',
    );
    return 'Dernière sauvegarde $date · $instruments actifs, $_temp0';
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
      'Toutes les transactions dans un tableur (.csv), réimportable';

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
    int transactions,
    int customTickers,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      transactions,
      locale: localeName,
      other: '$transactions transactions',
      one: '1 transaction',
    );
    return '$cards cartes de suivi · $_temp0 · $customTickers tickers personnalisés';
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
      'C’est un tableur, pas une sauvegarde Qima. Vous pouvez importer ses lignes comme transactions.';

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
  String get backupCsvHeaderInstrument => 'Actif';

  @override
  String get backupCsvHeaderSymbol => 'Symbole';

  @override
  String get backupCsvHeaderQuantity => 'Quantité';

  @override
  String get backupCsvHeaderUnit => 'Unité';

  @override
  String get backupCsvHeaderKarat => 'Carat';

  @override
  String get backupCsvHeaderUnitCost => 'Prix unitaire';

  @override
  String get backupCsvHeaderCostCurrency => 'Devise';

  @override
  String get backupCsvHeaderTotalCost => 'Total';

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
      'Appuyez sur + dans la carte Alertes pour être averti quand le prix franchit un niveau ou évolue d’un pourcentage.';

  @override
  String get helpAssetDetailStep5Title => 'Suivez ce que vous détenez';

  @override
  String get helpAssetDetailStep5Body =>
      'Appuyez sur Positions pour voir vos transactions ou ajouter un achat ou une vente.';

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
      'Appuyez sur une ligne pour voir ses transactions, son coût moyen et son gain.';

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
  String get helpLotEditorTitle => 'Transaction';

  @override
  String get helpLotEditorSummary =>
      'Enregistrez un achat, une vente, un transfert ou des frais. Votre avoir, votre coût moyen et vos gains en découlent.';

  @override
  String get helpLotEditorStep1Title => 'Type';

  @override
  String get helpLotEditorStep1Body =>
      'Achat ajoute à un coût. Vente retire et réalise un gain ou une perte. Transfert fait entrer ou sortir une quantité. Frais enregistre une charge.';

  @override
  String get helpLotEditorStep2Title => 'Carat';

  @override
  String get helpLotEditorStep2Body =>
      'Pour l’or au gramme ou au kilo, choisissez 24K, 22K, 21K ou 18K. Tout est compté en or fin, les carats se combinent donc correctement.';

  @override
  String get helpLotEditorStep3Title => 'Prix et frais';

  @override
  String get helpLotEditorStep3Body =>
      'Saisissez le prix unitaire ou le total, et l’éventuelle commission. Une vente affiche ce qu’elle réalise avant l’enregistrement.';

  @override
  String get helpLotEditorStep4Title => 'Date';

  @override
  String get helpLotEditorStep4Body =>
      'Le jour où elle a eu lieu. Une vente ne peut pas être datée d’avant que vous déteniez assez.';

  @override
  String get helpLotEditorStep5Title => 'Enregistrez';

  @override
  String get helpLotEditorStep5Body =>
      'Modifiez ou supprimez une transaction à tout moment depuis le registre de l’avoir.';

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
  String get helpBackupStep5Title => 'Tableurs';

  @override
  String get helpBackupStep5Body =>
      'Exportez toutes les transactions en .csv ou importez-en un depuis Qima, un tableur ou un courtier. Cela ajoute des transactions, sans restaurer les réglages.';

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
      'Toutes les transactions de cet actif — achats, ventes, transferts et frais — et leur résultat.';

  @override
  String get helpHoldingsStep1Title => 'Lisez les totaux';

  @override
  String get helpHoldingsStep1Body =>
      'Ce que vous détenez, votre coût moyen, sa valeur et son gain, ainsi que ce que les ventes ont réalisé.';

  @override
  String get helpHoldingsStep2Title => 'Ajouter une transaction';

  @override
  String get helpHoldingsStep2Body =>
      'Touchez Ajouter pour enregistrer un achat, une vente, un transfert ou des frais.';

  @override
  String get helpHoldingsStep3Title => 'Modifier ou supprimer';

  @override
  String get helpHoldingsStep3Body =>
      'Touchez une ligne pour la modifier ou glissez pour la supprimer. Qima refuse toute modification qui ferait vendre plus que ce que vous déteniez.';

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
      'Voyez combien de cartes, transactions et alertes contient le fichier avant de restaurer.';

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

  @override
  String get commonDone => 'OK';

  @override
  String get zakatTitle => 'Zakat';

  @override
  String get zakatSettingsTitle => 'Réglages de la zakat';

  @override
  String get settingsZakatSubtitle =>
      'Base du nisab, ce qui compte, date du hawl et rappel';

  @override
  String get zakatEmptyTitle => 'Rien à calculer pour l’instant';

  @override
  String get zakatEmptyMessage =>
      'La zakat se calcule à partir de vos avoirs. Ajoutez un achat à un actif : il apparaîtra ici, avec ce qui compte pour le nisab.';

  @override
  String get zakatNisabSection => 'Nisab';

  @override
  String get zakatWhatCountsSection => 'Ce qui compte';

  @override
  String get zakatStatusAbove => 'Au-dessus du nisab';

  @override
  String get zakatStatusBelow => 'En dessous du nisab';

  @override
  String get zakatStatusUnknown => 'Nisab pas encore évalué';

  @override
  String zakatDueLabel(String rate) {
    return 'Zakat due · $rate';
  }

  @override
  String zakatExplainAboveNoHawl(String base) {
    return 'Sur une assiette de $base. Indiquez la date de votre hawl pour savoir quand elle est due.';
  }

  @override
  String zakatExplainAboveToday(String base) {
    return 'Sur une assiette de $base. Votre hawl s’achève aujourd’hui.';
  }

  @override
  String zakatExplainAboveUpcoming(String base, String date, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'dans $days jours',
      one: 'dans 1 jour',
    );
    return 'Sur une assiette de $base. Due à la fin de votre hawl, le $date ($_temp0), si votre patrimoine reste au-dessus du nisab.';
  }

  @override
  String zakatExplainBelow(String base, String threshold) {
    return 'Votre assiette de $base est inférieure au nisab du jour, $threshold : aucune zakat n’est due.';
  }

  @override
  String zakatExplainUnknown(String metal) {
    return 'Le cours du jour de l’$metal n’est pas encore chargé : impossible de vérifier le nisab pour l’instant.';
  }

  @override
  String get zakatRetry => 'Réessayer';

  @override
  String get zakatUnpricedNote =>
      'Certains actifs n’ont pas encore de cours et ne sont pas comptés. Ils le seront dès que leur cours sera chargé.';

  @override
  String get zakatBasisRow => 'Base';

  @override
  String zakatBasisValue(String metal, String grams) {
    return '$metal · $grams g';
  }

  @override
  String zakatOtherBasisLine(String metal, String amount) {
    return 'Sur la base de l’$metal : $amount';
  }

  @override
  String get zakatThresholdToday => 'Seuil du jour';

  @override
  String get zakatYourBase => 'Votre assiette';

  @override
  String get zakatHawlStart => 'Début du hawl';

  @override
  String get zakatHawlSet => 'Choisir';

  @override
  String get zakatHawlNotSetSubtitle =>
      'Le jour où votre patrimoine a atteint le nisab pour la première fois';

  @override
  String get zakatHawlCompletesToday => 's’achève aujourd’hui';

  @override
  String zakatHawlNext(String date) {
    return 'prochain le $date';
  }

  @override
  String get zakatWhatCountsFooter =>
      'Désactivez un actif pour l’exclure, par exemple des bijoux portés au quotidien si vous suivez l’avis qui les exempte.';

  @override
  String zakatExcludedClass(String cls) {
    return '$cls désactivé';
  }

  @override
  String get zakatExcludedHolding => 'exclu';

  @override
  String get zakatExcludedNoPrice => 'pas encore de cours';

  @override
  String zakatLineTitle(String name, String quantity) {
    return '$name · $quantity';
  }

  @override
  String get zakatDisclaimer =>
      'Qima calcule, il ne rend pas d’avis. La base et ce qui compte sont à vous de fixer : en cas de doute, consultez un savant de confiance.';

  @override
  String get assetGroupMetals => 'Métaux';

  @override
  String get assetGroupCrypto => 'Crypto';

  @override
  String get assetGroupEquities => 'Actions';

  @override
  String get assetGroupCash => 'Liquidités et devises';

  @override
  String get zakatClassMetalsSubtitle => 'Or, argent, platine, palladium';

  @override
  String get zakatClassCryptoSubtitle => 'Traitées comme un actif négociable';

  @override
  String get zakatClassEquitiesSubtitle =>
      'Désactivé par défaut : les avis divergent sur les actions détenues à long terme';

  @override
  String get zakatClassCashSubtitle => 'Les devises que vous détenez';

  @override
  String zakatOverridesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actifs réglés individuellement',
      one: '1 actif réglé individuellement',
    );
    return '$_temp0';
  }

  @override
  String get zakatOverridesSubtitle =>
      'Choisis sur l’écran zakat, en dérogation à leur catégorie';

  @override
  String get zakatOverridesReset => 'Réinitialiser';

  @override
  String get zakatNisabBasisSection => 'Base du nisab';

  @override
  String get zakatClassesSection => 'Catégories soumises';

  @override
  String get zakatHawlSection => 'Hawl';

  @override
  String get zakatBasisPriceMissing => 'Cours pas encore chargé';

  @override
  String zakatBasisToday(String amount) {
    return '$amount aujourd’hui';
  }

  @override
  String zakatBasisHigher(String amount) {
    return 'Seuil plus élevé · $amount aujourd’hui';
  }

  @override
  String zakatBasisLower(String amount) {
    return 'Seuil plus bas · $amount aujourd’hui · plus de personnes redevables';
  }

  @override
  String get zakatCalendar => 'Calendrier';

  @override
  String get zakatCalendarHijri => 'Hégirien';

  @override
  String get zakatCalendarGregorian => 'Grégorien';

  @override
  String zakatGregorianNote(String solarRate, String rate) {
    return 'Une année grégorienne compte environ 11 jours de plus qu’une année lunaire. Certains savants portent le taux à $solarRate pour en tenir compte ; Qima garde $rate.';
  }

  @override
  String get zakatHawlClear => 'Effacer la date du hawl';

  @override
  String get zakatRemind => 'Me le rappeler';

  @override
  String get zakatRemindSubtitle =>
      'Une notification le jour où votre hawl s’achève';

  @override
  String get zakatRemindNeedsStart =>
      'Indiquez d’abord la date de début du hawl';

  @override
  String get zakatRemindNotificationsOff =>
      'Les notifications de Qima sont désactivées : activez-les dans les réglages du système pour recevoir ce rappel';

  @override
  String get zakatHawlPickerTitle => 'Début du hawl';

  @override
  String get zakatHawlPickerDay => 'Jour';

  @override
  String get zakatHawlPickerMonth => 'Mois';

  @override
  String get zakatHawlPickerYear => 'Année';

  @override
  String get zakatHawlPickerFuture =>
      'Un hawl ne peut pas commencer dans le futur';

  @override
  String zakatHawlPickerGregorian(String date) {
    return 'Grégorien : $date';
  }

  @override
  String zakatEntryDue(String amount) {
    return '$amount dus · au-dessus du nisab';
  }

  @override
  String get zakatEntryCalculate => 'Voir ce qui est dû';

  @override
  String get zakatReminderNotificationTitle => 'Votre hawl est achevé';

  @override
  String get zakatReminderNotificationBody =>
      'Votre année de zakat s’est achevée aujourd’hui. Ouvrez Qima pour voir ce qui est dû.';

  @override
  String get hijriMonth1 => 'Mouharram';

  @override
  String get hijriMonth2 => 'Safar';

  @override
  String get hijriMonth3 => 'Rabia al-Awal';

  @override
  String get hijriMonth4 => 'Rabia ath-Thani';

  @override
  String get hijriMonth5 => 'Joumada al-Oula';

  @override
  String get hijriMonth6 => 'Joumada ath-Thania';

  @override
  String get hijriMonth7 => 'Rajab';

  @override
  String get hijriMonth8 => 'Chaabane';

  @override
  String get hijriMonth9 => 'Ramadan';

  @override
  String get hijriMonth10 => 'Chawwal';

  @override
  String get hijriMonth11 => 'Dhou al-Qi’da';

  @override
  String get hijriMonth12 => 'Dhou al-Hijja';

  @override
  String hijriDate(int day, String month, int year) {
    return '$day $month $year H';
  }

  @override
  String get helpZakatTitle => 'Zakat';

  @override
  String get helpZakatSummary =>
      'Qima calcule la zakat à partir de vos avoirs aux cours du jour. Il calcule ; les choix derrière le calcul vous appartiennent.';

  @override
  String get helpZakatStep1Title => 'Nisab';

  @override
  String get helpZakatStep1Body =>
      'Le seuil est de 85 g d’or fin ou 595 g d’argent, au cours du moment. Choisissez la base dans les réglages ; celle de l’argent est plus basse, donc plus de personnes sont redevables.';

  @override
  String get helpZakatStep2Title => 'Ce qui compte';

  @override
  String get helpZakatStep2Body =>
      'Les métaux, la crypto et les liquidités comptent par défaut, pas les actions. L’or en carats compte pour sa teneur en or. Excluez n’importe quel actif depuis l’écran zakat.';

  @override
  String get helpZakatStep3Title => 'Hawl';

  @override
  String get helpZakatStep3Body =>
      'Indiquez le jour où votre patrimoine a atteint le nisab. La zakat est due chaque année lunaire ensuite, et Qima peut vous le rappeler le jour venu.';

  @override
  String get helpZakatStep4Title => 'Un calculateur, pas une fatwa';

  @override
  String get helpZakatStep4Body =>
      'Les savants divergent sur la base, les actions et les bijoux. Chaque réglage par défaut peut être modifié ; en cas de doute, consultez un savant de confiance.';

  @override
  String get allocationTitle => 'Répartition';

  @override
  String get allocationDetails => 'Détails';

  @override
  String get allocationByGroup => 'Par catégorie';

  @override
  String get allocationMetalsByForm => 'Métaux · par carat et type';

  @override
  String allocationMetalForm(String metal, String karat) {
    return '$metal $karat';
  }

  @override
  String get allocationDriftTitle => 'Évolution';

  @override
  String allocationDriftSince(String date) {
    return 'Évolution · depuis le $date';
  }

  @override
  String allocationDriftChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get allocationDriftPendingTitle => 'Avant d’avoir un historique';

  @override
  String allocationDriftPending(String date) {
    return 'L’évolution de votre répartition apparaîtra quand vos avoirs auront 14 jours, le $date. D’ici là, voici la répartition du jour : aucune tendance n’est inventée.';
  }

  @override
  String get allocationDriftNoHistory =>
      'Il n’y a pas encore assez de cours enregistrés pour connaître votre répartition à cette date. Elle se complétera au fil du chargement de l’historique.';

  @override
  String allocationSingleGroup(String group) {
    return 'Tout en $group';
  }

  @override
  String get backupImportCountTransactions => 'Transactions';

  @override
  String portfolioTransactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0';
  }

  @override
  String get portfolioClosedPositions => 'Positions clôturées';

  @override
  String ledgerTitleWithKarat(String name, String karat) {
    return '$name · $karat';
  }

  @override
  String get ledgerAdd => 'Ajouter';

  @override
  String get ledgerAddFirst => 'Ajouter une transaction';

  @override
  String get ledgerHolding => 'Détention';

  @override
  String get ledgerNothingHeld => 'Plus rien de détenu';

  @override
  String ledgerPerUnit(String amount, String unit) {
    return '$amount / $unit';
  }

  @override
  String get ledgerMarketValue => 'Valeur de marché';

  @override
  String get ledgerUnrealised => 'Latent';

  @override
  String get ledgerRealised => 'Réalisé';

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
    return '$date · $price · frais $fee';
  }

  @override
  String get ledgerNoCostBasis => 'sans coût de base';

  @override
  String get ledgerCostCarried => 'coût reporté';

  @override
  String get ledgerFootnote =>
      'Le coût de base est calculé à partir de ce registre, il n’est pas stocké. Modifier une ligne recalcule l’avoir.';

  @override
  String get ledgerOverdrawnBanner =>
      'Une vente ici dépasse ce qui était détenu à sa date, souvent après des modifications sur deux appareils à la fois. Elle compte comme la vente du reste ; modifiez-la ou supprimez-la pour corriger les totaux.';

  @override
  String ledgerClosedLine(String amount) {
    return 'Plus rien de détenu · réalisé $amount';
  }

  @override
  String get ledgerConflictSaveTitle => 'Cela vendrait trop';

  @override
  String get ledgerConflictDeleteTitle =>
      'Suppression impossible pour l’instant';

  @override
  String ledgerConflictMessage(String kind, String date) {
    return 'L’opération « $kind » du $date vendrait alors plus que ce qui était détenu. Modifiez-la ou supprimez-la d’abord.';
  }

  @override
  String get confirmDeleteTransactionTitle => 'Supprimer cette transaction ?';

  @override
  String confirmDeleteTransactionMessage(String details) {
    return '$details. L’avoir sera recalculé sans elle. Action irréversible.';
  }

  @override
  String get transactionNewTitle => 'Nouvelle transaction';

  @override
  String get transactionEditTitle => 'Modifier la transaction';

  @override
  String get transactionKindBuy => 'Achat';

  @override
  String get transactionKindSell => 'Vente';

  @override
  String get transactionKindTransfer => 'Transfert';

  @override
  String get transactionKindTransferIn => 'Transfert entrant';

  @override
  String get transactionKindTransferOut => 'Transfert sortant';

  @override
  String get transactionKindFee => 'Frais';

  @override
  String get transactionTransferInLabel => 'Entrant';

  @override
  String get transactionTransferOutLabel => 'Sortant';

  @override
  String transactionFineHint(String quantity) {
    return '= $quantity d’or fin';
  }

  @override
  String transactionPerUnitKarat(String unit, String karat) {
    return '$unit · $karat';
  }

  @override
  String transactionBuyPrice(String unit) {
    return 'Prix payé (par $unit)';
  }

  @override
  String transactionSalePrice(String unit) {
    return 'Prix de vente (par $unit)';
  }

  @override
  String transactionCarriedCost(String unit) {
    return 'Coût d’origine (par $unit, facultatif)';
  }

  @override
  String get transactionTotalProceeds => 'Montant total de la vente';

  @override
  String get transactionTotalCarriedCost => 'Coût total d’origine (facultatif)';

  @override
  String get transactionTransferCostHelper =>
      'Son coût d’origine, si vous le connaissez. Laissé vide, il s’ajoute sans coût de base.';

  @override
  String get transactionFee => 'Frais (facultatif)';

  @override
  String get transactionFeeAmount => 'Montant des frais';

  @override
  String get transactionFeeLabel => 'Motif (facultatif)';

  @override
  String get transactionNote => 'Note (facultatif)';

  @override
  String get transactionNeedsQuantity => 'Saisissez une quantité.';

  @override
  String get transactionNeedsPrice => 'Saisissez un prix.';

  @override
  String get transactionNeedsFee => 'Saisissez le montant des frais.';

  @override
  String transactionMoreThanHeld(String held) {
    return 'C’est plus que ce que vous déteniez à cette date ($held).';
  }

  @override
  String get transactionPreviewTitle => 'Aperçu du gain réalisé';

  @override
  String get transactionProceeds => 'Produit';

  @override
  String get transactionBasisReleased => 'Coût de base libéré';

  @override
  String get transactionRealisedGain => 'Gain réalisé';

  @override
  String transactionPreviewRemaining(String quantity, String average) {
    return 'Base du coût moyen pondéré. Restera détenu : $quantity à $average.';
  }

  @override
  String get transactionPreviewClosesPosition =>
      'Base du coût moyen pondéré. Cela vend tout ce que vous détenez.';

  @override
  String get backupCsvHeaderType => 'Type';

  @override
  String get backupCsvHeaderFee => 'Frais';

  @override
  String get backupCsvHeaderNote => 'Note';

  @override
  String get csvImportTitle => 'Importer depuis un tableur';

  @override
  String get csvImportEntryTitle => 'Importer des transactions depuis un CSV';

  @override
  String get csvImportEntrySubtitle =>
      'Depuis un tableur, un courtier ou une autre app';

  @override
  String get csvImportFromBackupError => 'Les importer comme transactions';

  @override
  String csvImportRowCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignes',
      one: '1 ligne',
    );
    return '$_temp0';
  }

  @override
  String get csvImportEmptyFile =>
      'Ce fichier a une ligne d’en-tête mais aucune donnée.';

  @override
  String get csvImportColumnsSection => 'Colonnes';

  @override
  String get csvImportColumnsFooter =>
      'Associées depuis la ligne d’en-tête quand c’était possible. Un prix ou un total suffit ; l’actif peut être un symbole ou un nom. * requis.';

  @override
  String get csvImportNotInFile => 'Absent du fichier';

  @override
  String get csvImportOptionsSection => 'Lecture du fichier';

  @override
  String get csvImportFallbackCurrency => 'Devise';

  @override
  String get csvImportFallbackCurrencySubtitle =>
      'Pour les lignes qui n’en indiquent pas';

  @override
  String get csvImportDateOrder => 'Les dates comme 03/04/2026 signifient';

  @override
  String get csvImportDayFirst => '3 avril';

  @override
  String get csvImportMonthFirst => '4 mars';

  @override
  String get csvImportDecimalComma => 'La virgule est le séparateur décimal';

  @override
  String get csvImportDecimalCommaSubtitle =>
      'Lire 1.234,56 comme mille deux cents…';

  @override
  String get csvImportNeedsColumns =>
      'Choisissez au moins l’actif, la date et la quantité.';

  @override
  String get csvImportReview => 'Vérifier les lignes';

  @override
  String get csvImportReadyCount => 'Prêtes';

  @override
  String get csvImportDuplicateCount => 'Déjà dans Qima';

  @override
  String get csvImportProblemCount => 'Non importables';

  @override
  String get csvImportSkipNote =>
      'Les lignes illisibles ou déjà dans Qima sont ignorées. Rien n’est deviné.';

  @override
  String get csvImportShowAll => 'Toutes';

  @override
  String get csvImportShowProblems => 'Ignorées seulement';

  @override
  String get csvImportSkipped => 'Ignorée';

  @override
  String get csvImportDuplicate => 'Doublon';

  @override
  String get csvImportBackToColumns => 'Colonnes';

  @override
  String csvImportConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importer $count transactions',
      one: 'Importer 1 transaction',
      zero: 'Rien à importer',
    );
    return '$_temp0';
  }

  @override
  String csvImportDoneTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions importées',
      one: '1 transaction importée',
    );
    return '$_temp0';
  }

  @override
  String get csvImportDoneMessage =>
      'Elles sont dans le registre de chaque actif. Si quelque chose cloche, annuler retire exactement ce que cet import a ajouté.';

  @override
  String get csvImportUndo => 'Annuler cet import';

  @override
  String csvImportUndone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions importées supprimées',
      one: '1 transaction importée supprimée',
    );
    return '$_temp0';
  }

  @override
  String get csvFieldType => 'Type';

  @override
  String get csvFieldAsset => 'Nom de l’actif';

  @override
  String get csvFieldSymbol => 'Symbole';

  @override
  String get csvFieldQuantity => 'Quantité';

  @override
  String get csvFieldUnit => 'Unité';

  @override
  String get csvFieldKarat => 'Carats';

  @override
  String get csvFieldUnitPrice => 'Prix unitaire';

  @override
  String get csvFieldTotal => 'Total';

  @override
  String get csvFieldFee => 'Frais';

  @override
  String get csvFieldCurrency => 'Devise';

  @override
  String get csvFieldDate => 'Date';

  @override
  String get csvFieldNote => 'Note';

  @override
  String get csvProblemUnknownAsset => 'actif inconnu';

  @override
  String get csvProblemMissingQuantity => 'pas de quantité';

  @override
  String get csvProblemBadNumber => 'un nombre est illisible';

  @override
  String get csvProblemMissingPrice => 'pas de prix';

  @override
  String get csvProblemMissingDate => 'pas de date';

  @override
  String get csvProblemBadDate => 'date illisible';

  @override
  String get csvProblemFutureDate => 'date dans le futur';

  @override
  String get csvProblemUnknownType => 'type inconnu';

  @override
  String get csvProblemUnknownCurrency => 'devise inconnue';

  @override
  String get csvProblemUnsupportedUnit => 'unité inadaptée à cet actif';

  @override
  String get csvProblemUnsupportedKarat => 'carats inadaptés à cet actif';

  @override
  String get csvProblemOversell => 'vend plus que ce qui était détenu';

  @override
  String get csvProblemDuplicate => 'déjà dans Qima';

  @override
  String get transactionBuyPricePlain => 'Prix payé';

  @override
  String get transactionSalePricePlain => 'Prix de vente';

  @override
  String get transactionCarriedCostPlain => 'Coût d’origine (facultatif)';

  @override
  String settingsVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get watchlistEditOrder => 'Modifier l\'ordre';

  @override
  String get watchlistSortBy => 'Trier par';

  @override
  String get watchlistSortName => 'Nom';

  @override
  String get watchlistSortChange => 'Meilleures performances';

  @override
  String get watchlistSortAssetClass => 'Classe d\'actifs';

  @override
  String watchlistDragHandle(String name) {
    return 'Déplacer $name';
  }

  @override
  String get watchlistEditOrderHint =>
      'Faites glisser les poignées pour réorganiser. Un tri fixe un nouvel ordre que vous pouvez encore ajuster.';

  @override
  String get shareAction => 'Partager';

  @override
  String shareTitle(String name) {
    return 'Partager $name';
  }

  @override
  String get shareToWhatsappMessage => 'Message WhatsApp';

  @override
  String get shareToWhatsappStatus => 'Statut WhatsApp';

  @override
  String get shareToInstagramPost => 'Publication Instagram';

  @override
  String get shareToInstagramStory => 'Story Instagram';

  @override
  String get shareToFacebookPost => 'Publication Facebook';

  @override
  String get shareToFacebookStory => 'Story Facebook';

  @override
  String get shareToLinkedinPost => 'Publication LinkedIn';

  @override
  String shareCaption(String name, String price) {
    return '$name est à $price.';
  }

  @override
  String shareCaptionWithChange(
    String name,
    String price,
    String change,
    String range,
  ) {
    return '$name est à $price ($change, $range).';
  }

  @override
  String shareCaptionFooter(String url) {
    return 'Suivi avec Qima : $url';
  }

  @override
  String get shareCaptionCopied =>
      'Texte copié. Collez-le si l\'app ne l\'ajoute pas.';

  @override
  String get shareFailed => 'Impossible de créer l\'image. Réessayez.';

  @override
  String get helpWatchlistStep6Title => 'Changez l\'ordre';

  @override
  String get helpWatchlistStep6Body =>
      'Touchez les flèches en haut pour faire glisser les cartes par leurs poignées, ou triez-les par nom, performance ou classe d\'actifs. Vous pouvez aussi maintenir une carte appuyée pour la déplacer.';

  @override
  String get helpAssetDetailStep6Title => 'Partagez-le';

  @override
  String get helpAssetDetailStep6Body =>
      'Touchez partager pour publier le prix et le graphique en image au format WhatsApp, Instagram, Facebook ou LinkedIn, avec un texte prêt.';

  @override
  String get captureRecordThis => 'Enregistrer ceci';

  @override
  String get captureCheckTitle => 'Vérifiez';

  @override
  String get captureYouWrote => 'Vous avez écrit';

  @override
  String get captureRead => 'Compris comme';

  @override
  String get captureFieldType => 'Type';

  @override
  String get captureFieldAsset => 'Actif';

  @override
  String get captureFieldQuantity => 'Quantité';

  @override
  String get captureFieldPrice => 'Prix';

  @override
  String get captureFieldFee => 'Frais';

  @override
  String get captureFieldDate => 'Date';

  @override
  String captureFrom(String words) {
    return 'de « $words »';
  }

  @override
  String get captureBaseCurrency => 'votre devise de référence';

  @override
  String get captureTotalDivided => 'total ÷ quantité';

  @override
  String get captureAssumed => 'supposé';

  @override
  String get captureToday => 'aujourd’hui';

  @override
  String get captureCheck => 'à vérifier';

  @override
  String get captureConfirm => 'Confirmer';

  @override
  String get captureEditFields => 'Modifier';

  @override
  String get captureFootnote =>
      'Chaque champ indique d’où il vient, et rien n’est enregistré avant votre confirmation.';

  @override
  String get captureOnDevice => 'Sur l’appareil';

  @override
  String get captureNothingSent =>
      'Lu sur cet appareil. Rien n’est envoyé nulle part.';

  @override
  String get captureNeedsPrice =>
      'Aucun prix trouvé. Modifiez les champs pour en ajouter un.';

  @override
  String captureRecorded(String summary) {
    return 'Enregistré : $summary';
  }
}
