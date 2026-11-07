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
  String get watchlistAdd => 'Ajouter au suivi';

  @override
  String get watchlistEmptyTitle => 'Votre liste de suivi est vide';

  @override
  String get watchlistEmptyMessage =>
      'Ajoutez des métaux, cryptomonnaies, actions ou devises pour suivre leurs prix.';

  @override
  String get watchlistFilterAll => 'Tous';

  @override
  String get addTitle => 'Ajouter au suivi';

  @override
  String get addSearchHint => 'Rechercher ou décrire un achat';

  @override
  String get addWatchSearchHint => 'Cherchez or, Bitcoin, AAPL…';

  @override
  String addSearchCustomTickerTitle(String query) {
    return 'Ajouter « $query » comme symbole personnalisé';
  }

  @override
  String addSearchMatchedAlias(String alias) {
    return 'Aussi « $alias »';
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
      'Or, argent, crypto, actions, indices et devises, additionnés dans votre devise, avec un résumé simple de chaque mois.';

  @override
  String get onboardingStep2Title => 'Des prix comme vous achetez';

  @override
  String get onboardingStep2Body =>
      'Prix en direct au gramme, à l\'once ou au kilo, de 24K à 18K, dans n\'importe quelle devise. Touchez + pour ajouter au suivi, touchez une carte pour son graphique.';

  @override
  String get onboardingStep3Title => 'Sachez ce que vous détenez';

  @override
  String get onboardingStep3Body =>
      'Touchez +, puis Ajouter une position, et saisissez votre achat, ou dictez-le ou scannez un reçu. Il est lu sur cet appareil et enregistré seulement quand vous confirmez. Voyez ce que vous détenez, votre coût moyen, la valeur et le gain.';

  @override
  String get onboardingStep4Title => 'Ne manquez plus aucun mouvement';

  @override
  String get onboardingStep4Body =>
      'Recevez une notification quand un prix franchit un niveau ou évolue d\'un pourcentage. Affichez les prix sur votre écran d\'accueil et de verrouillage.';

  @override
  String get onboardingStep4BodyApple =>
      'Soyez averti quand un prix franchit un seuil ou bouge d\'un pourcentage. Mettez des prix sur l\'écran d\'accueil et l\'écran verrouillé, ou demandez à Siri la valeur de votre portefeuille.';

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
  String get helpHomeSummary =>
      'Votre patrimoine net : tout ce que vous possédez moins tout ce que vous devez, avec les cartes que vous utilisez le plus.';

  @override
  String get helpHomeStep1Title => 'Patrimoine net';

  @override
  String get helpHomeStep1Body =>
      'Touchez-le pour ouvrir le bilan : ce que vous possédez et ce que vous devez, poste par poste.';

  @override
  String get helpHomeStep2Title => 'Vos cartes';

  @override
  String get helpHomeStep2Body =>
      'Comptes, Reste à dépenser, À venir et d’autres apparaissent quand vous les utilisez. Touchez une carte pour l’ouvrir.';

  @override
  String get helpHomeStep3Title => 'Modifier l’accueil';

  @override
  String get helpHomeStep3Body =>
      'Déplacez les cartes ou masquez celles dont vous n’avez pas besoin. Qima ne remet jamais une carte masquée.';

  @override
  String get helpHomeStep4Title => 'Masquer les soldes';

  @override
  String get helpHomeStep4Body =>
      'Touchez l’œil pour masquer tous les montants quand quelqu’un regarde.';

  @override
  String get helpHomeStep5Title => 'Tout ajouter';

  @override
  String get helpHomeStep5Body =>
      'Touchez + pour une opération, un relevé, un placement ou tout ce qui se trouve sous Plus.';

  @override
  String get helpMoneySummary =>
      'Où est passé l’argent ce mois-ci, ce qui est entré et ce qui est sorti.';

  @override
  String get helpMoneyStep1Title => 'Choisir un mois';

  @override
  String get helpMoneyStep1Body =>
      'Utilisez les flèches en haut pour voir un autre mois.';

  @override
  String get helpMoneyStep2Title => 'Dépensé et rythme';

  @override
  String get helpMoneyStep2Body =>
      'Ce que vous avez dépensé jusqu’ici, et où vous en serez en fin de mois à ce rythme.';

  @override
  String get helpMoneyStep3Title => 'Où il est passé';

  @override
  String get helpMoneyStep3Body =>
      'Les dépenses par catégorie, les plus grosses d’abord.';

  @override
  String get helpMoneyStep4Title => 'Flux de trésorerie';

  @override
  String get helpMoneyStep4Body =>
      'L’argent entré, sorti et ce qui reste. Les virements entre vos comptes ne comptent pas.';

  @override
  String get helpMoneyStep5Title => 'À regarder';

  @override
  String get helpMoneyStep5Body =>
      'Des remarques sur les budgets et les opérations à classer, quand il y a quelque chose à voir.';

  @override
  String get helpNewTransactionSummary =>
      'Enregistrez de l’argent dépensé, gagné ou déplacé entre vos comptes.';

  @override
  String get helpNewTransactionStep1Title => 'Choisir le type';

  @override
  String get helpNewTransactionStep1Body =>
      'Dépense, Revenu ou Virement. Le montant et la date restent quand vous changez.';

  @override
  String get helpNewTransactionStep2Title => 'Dites-le';

  @override
  String get helpNewTransactionStep2Body =>
      'Touchez le micro et dites par exemple « Payé 45 chez Carrefour avec la Visa hier ». Qima remplit le formulaire sur cet appareil ; vérifiez-le puis touchez Enregistrer.';

  @override
  String get helpNewTransactionStep3Title => 'Catégorie';

  @override
  String get helpNewTransactionStep3Body =>
      'Les dépenses et revenus vont dans une catégorie. Un virement entre vos comptes n’est jamais une dépense.';

  @override
  String get helpNewTransactionStep4Title => 'Refusée';

  @override
  String get helpNewTransactionStep4Body =>
      'Activez Refusée pour un paiement qui n’est pas passé : il apparaît barré et ne compte jamais.';

  @override
  String get helpTransactionsSummary =>
      'Toutes les opérations, les plus récentes d’abord, et leur effet sur vos comptes.';

  @override
  String get helpTransactionsStep1Title => 'En ouvrir une';

  @override
  String get helpTransactionsStep1Body =>
      'Touchez une opération pour voir chaque compte touché, et de combien.';

  @override
  String get helpTransactionsStep2Title => 'Comment elle compte';

  @override
  String get helpTransactionsStep2Body =>
      'Chacune indique s’il s’agit d’une dépense, d’un revenu, d’un virement entre vos comptes ou d’une variation de valeur.';

  @override
  String get helpTransactionsStep3Title => 'Modifier ou supprimer';

  @override
  String get helpTransactionsStep3Body =>
      'Ouvrez-la, puis modifiez-la ou supprimez-la. La suppression remet chaque compte comme avant.';

  @override
  String get helpAccountsSummary =>
      'Comptes bancaires, espèces, cartes et prêts, avec le solde de chacun aujourd’hui.';

  @override
  String get helpAccountsStep1Title => 'Ajouter un compte';

  @override
  String get helpAccountsStep1Body =>
      'Donnez-lui un nom, un type et son solde du jour. Qima part de ce chiffre.';

  @override
  String get helpAccountsStep2Title => 'Vérifier le solde';

  @override
  String get helpAccountsStep2Body =>
      'Ouvrez un compte et saisissez ce qu’affiche votre banque. En cas d’écart, choisissez : ajouter une opération, ou modifier le solde d’ouverture pour que rien ne compte comme dépense.';

  @override
  String get helpAccountsStep3Title => 'Compter les espèces';

  @override
  String get helpAccountsStep3Body =>
      'Pour les espèces, comptez ce qu’il y a dans votre portefeuille et Qima ajuste le solde.';

  @override
  String get helpAccountsStep4Title => 'Payer une carte ou un prêt';

  @override
  String get helpAccountsStep4Body =>
      'Ouvrez la carte ou le prêt et touchez Payer pour enregistrer un paiement depuis un autre compte.';

  @override
  String get helpAccountsStep5Title => 'En retirer un';

  @override
  String get helpAccountsStep5Body =>
      'Un compte avec des opérations est archivé pour que l’historique reste juste. Un compte jamais utilisé est supprimé.';

  @override
  String get helpBalanceSheetSummary =>
      'Tout ce que vous possédez et tout ce que vous devez, jusqu’à votre patrimoine net.';

  @override
  String get helpBalanceSheetStep1Title => 'Ce que vous possédez';

  @override
  String get helpBalanceSheetStep1Body =>
      'Les comptes, les placements aux prix en direct et les biens à la valeur que vous fixez.';

  @override
  String get helpBalanceSheetStep2Title => 'Ce que vous devez';

  @override
  String get helpBalanceSheetStep2Body =>
      'Les cartes, les prêts (capital seulement) et l’argent que vous devez à des personnes.';

  @override
  String get helpBalanceSheetStep3Title => 'Comment le total est calculé';

  @override
  String get helpBalanceSheetStep3Body =>
      'Ouvrez-le pour voir chaque règle, comme le taux en direct utilisé pour les autres devises.';

  @override
  String get helpBalanceSheetStep4Title => 'En exclure un';

  @override
  String get helpBalanceSheetStep4Body =>
      'Désactivez Compter dans la valeur nette sur un compte ou un bien ; son historique reste juste.';

  @override
  String get helpAssetsSummary =>
      'Un logement, un terrain, une voiture ou une part d’entreprise, à la valeur que vous fixez.';

  @override
  String get helpAssetsStep1Title => 'Ajouter un bien';

  @override
  String get helpAssetsStep1Body =>
      'Choisissez un type, puis donnez une valeur et une date. L’or et l’argent au poids sont des placements.';

  @override
  String get helpAssetsStep2Title => 'Mettre à jour la valeur';

  @override
  String get helpAssetsStep2Body =>
      'Chaque mise à jour est datée. La plus récente compte ; les anciennes restent dans l’historique.';

  @override
  String get helpAssetsStep3Title => 'Un prêt dessus';

  @override
  String get helpAssetsStep3Body =>
      'Liez le prêt garanti par ce bien pour voir ce qui reste dû à côté de sa valeur.';

  @override
  String get helpAssetsStep4Title => 'Vendu';

  @override
  String get helpAssetsStep4Body =>
      'Enregistrez la vente : l’argent va sur un compte et le bien quitte votre bilan.';

  @override
  String get helpImportStatementSummary =>
      'Importez des opérations depuis le PDF, l’Excel ou le CSV de votre banque, des captures d’écran ou un fichier copié.';

  @override
  String get helpImportStatementStep1Title => 'Choisir les fichiers';

  @override
  String get helpImportStatementStep1Body =>
      'Depuis Fichiers, Photos, le presse-papiers, ou Partager › Qima depuis n’importe quelle app. Ils sont lus sur cet appareil.';

  @override
  String get helpImportStatementStep2Title => 'Vérifier chaque ligne';

  @override
  String get helpImportStatementStep2Body =>
      'Choisissez le compte, décochez ce que vous ne voulez pas et corrigez les catégories. Les lignes déjà dans Qima sont décochées.';

  @override
  String get helpImportStatementStep3Title => 'Aligner le solde';

  @override
  String get helpImportStatementStep3Body =>
      'Quand le relevé affiche un solde, cochez Ramener le solde. Puis choisissez : modifier le solde d’ouverture, ou ajouter une opération pour l’écart.';

  @override
  String get helpImportStatementStep4Title => 'Les ajouter';

  @override
  String get helpImportStatementStep4Body =>
      'Touchez Ajouter. Les fichiers sont supprimés une fois importés.';

  @override
  String get helpBankMessagesSummary =>
      'Ajoutez les achats depuis les messages de votre banque, après les avoir vérifiés un par un.';

  @override
  String get helpBankMessagesStep1Title => 'Sur Android';

  @override
  String get helpBankMessagesStep1Body =>
      'Activez Lire les nouveaux messages bancaires et autorisez l’accès. Importez les 60 derniers jours la première fois.';

  @override
  String get helpBankMessagesStep2Title => 'Sur iPhone';

  @override
  String get helpBankMessagesStep2Body =>
      'Configurez une fois une automatisation Raccourcis, pour que chaque message aille à l’action « Add a bank message » de Qima.';

  @override
  String get helpBankMessagesStep3Title => 'Vérifier avant d’ajouter';

  @override
  String get helpBankMessagesStep3Body =>
      'Les messages attendent dans la revue d’import. Les codes, offres et doublons sont ignorés.';

  @override
  String get helpBankMessagesStep4Title => 'Privé';

  @override
  String get helpBankMessagesStep4Body =>
      'Les messages sont lus sur cet appareil et ne le quittent jamais.';

  @override
  String get helpCategoriesSummary =>
      'Classez les dépenses par catégorie et apprenez à Qima où va chaque nom.';

  @override
  String get helpCategoriesStep1Title => 'À classer';

  @override
  String get helpCategoriesStep1Body =>
      'Choisissez une catégorie une fois par nom. Les imports de ce nom l’utiliseront désormais.';

  @override
  String get helpCategoriesStep2Title => 'Opérations précédentes';

  @override
  String get helpCategoriesStep2Body =>
      'Qima propose aussi de déplacer les opérations précédentes du même nom.';

  @override
  String get helpCategoriesStep3Title => 'Vos catégories';

  @override
  String get helpCategoriesStep3Body =>
      'Ajoutez, renommez ou supprimez des catégories. Les opérations d’une catégorie supprimée la gardent dans leur historique.';

  @override
  String get helpCategoriesStep4Title => 'Oublier un nom';

  @override
  String get helpCategoriesStep4Body =>
      'Oubliez ce que Qima a appris pour un nom, et ses imports se classent de nouveau à la main.';

  @override
  String get helpBudgetSummary =>
      'Un montant mensuel pour chaque catégorie à surveiller.';

  @override
  String get helpBudgetStep1Title => 'Fixer un montant';

  @override
  String get helpBudgetStep1Body =>
      'Touchez une catégorie et saisissez son montant mensuel. Zéro le retire.';

  @override
  String get helpBudgetStep2Title => 'Reste à dépenser';

  @override
  String get helpBudgetStep2Body =>
      'L’accueil montre ce qui reste ce mois-ci, et Argent signale une catégorie en avance sur son rythme.';

  @override
  String get helpBudgetStep3Title => 'Ce qui compte';

  @override
  String get helpBudgetStep3Body =>
      'Les paiements de carte, virements et le capital des prêts ne comptent jamais.';

  @override
  String get helpRecurringSummary =>
      'Loyer, factures et abonnements, affichés dans À venir avant l’échéance.';

  @override
  String get helpRecurringStep1Title => 'En ajouter un';

  @override
  String get helpRecurringStep1Body =>
      'Donnez-lui un nom, un montant, le compte qui le paie et son jour du mois.';

  @override
  String get helpRecurringStep2Title => 'À venir';

  @override
  String get helpRecurringStep2Body =>
      'L’accueil liste les prochains à payer, pour éviter les surprises.';

  @override
  String get helpRecurringStep3Title => 'Modifier ou retirer';

  @override
  String get helpRecurringStep3Body =>
      'Touchez-en un pour le modifier ou le retirer.';

  @override
  String get helpPeopleSummary =>
      'Qui vous doit, à qui vous devez, et les remboursements.';

  @override
  String get helpPeopleStep1Title => 'Prêté ou emprunté';

  @override
  String get helpPeopleStep1Body =>
      'Touchez + › Plus › Prêté ou Emprunté, puis tapez le nom de la personne.';

  @override
  String get helpPeopleStep2Title => 'Remboursements';

  @override
  String get helpPeopleStep2Body =>
      'Enregistrez Remboursement reçu ou Remboursement versé, et ce qui est dû baisse.';

  @override
  String get helpPeopleStep3Title => 'Partage d’addition';

  @override
  String get helpPeopleStep3Body =>
      'Payez toute l’addition et partagez-la : seule votre part est une dépense, le reste vous est dû.';

  @override
  String get helpFeaturesSummary =>
      'Activez ou désactivez des parties de Qima. Elles s’activent aussi d’elles-mêmes à la première utilisation.';

  @override
  String get helpFeaturesStep1Title => 'En désactiver une';

  @override
  String get helpFeaturesStep1Body =>
      'Ses écrans se masquent, jamais votre argent : ses montants comptent toujours dans le bilan.';

  @override
  String get helpFeaturesStep2Title => 'Activée à l’usage';

  @override
  String get helpFeaturesStep2Body =>
      'Enregistrez votre premier remboursement de prêt et Prêts s’active, avec Annuler si vous n’en voulez pas.';

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
  String get helpWatchlistTitle => 'Prix';

  @override
  String get helpWatchlistSummary =>
      'Les prix en direct de tout ce que vous suivez.';

  @override
  String get helpWatchlistStep1Title => 'Ouvrez une carte';

  @override
  String get helpWatchlistStep1Body =>
      'Appuyez sur une carte pour son graphique, ses statistiques clés et vos avoirs.';

  @override
  String get helpWatchlistStep2Title => 'Ajoutez un actif';

  @override
  String get helpWatchlistStep2Body =>
      'Touchez + en bas, puis Ajouter au suivi.';

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
  String get helpPortfolioStep3Body =>
      'Touchez + en bas, puis Ajouter une position. Ou ouvrez un actif et touchez Positions.';

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
  String get helpPortfolioStep6Title => 'Le mois dernier';

  @override
  String get helpPortfolioStep6Body =>
      'Un court résumé de l\'évolution de vos positions, calculé à partir de vos propres données. Désactivez-le dans Réglages.';

  @override
  String get helpPortfolioStep7Title => 'Demandez à Siri';

  @override
  String get helpPortfolioStep7Body =>
      'Demandez à Siri ou utilisez Raccourcis pour connaître la valeur de votre portefeuille ou un prix, sans ouvrir Qima.';

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
  String get helpAddAssetTitle => 'Ajouter au suivi ou une position';

  @override
  String get helpAddAssetSummary =>
      'Suivez un prix dans votre liste de suivi, ou enregistrez un achat.';

  @override
  String get helpAddAssetStep1Title => 'Recherchez';

  @override
  String get helpAddAssetStep1Body =>
      'Touchez +, puis Ajouter au suivi. Cherchez par nom ou symbole dans n\'importe quelle langue de l\'app, comme or, ذهب ou BTC.';

  @override
  String get helpAddAssetStep2Title => 'Choisissez un résultat';

  @override
  String get helpAddAssetStep2Body =>
      'Choisissez la devise et l\'unité de son prix, puis ajoutez-le à votre liste.';

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
  String get helpSettingsStep6Title => 'Intelligence sur l\'appareil';

  @override
  String get helpSettingsStep6Body =>
      'Si vous le souhaitez, laissez le modèle de langage de cet appareil aider à lire les achats et à rédiger le résumé. Il ne fonctionne qu\'ici, ne donne jamais de conseil et ne fournit jamais de nombre.';

  @override
  String get helpBackupTitle => 'Sauvegarde et restauration';

  @override
  String get helpBackupSummary =>
      'Qima n\'a pas de compte : un fichier de sauvegarde est le moyen de conserver vos données si ce téléphone est perdu ou réinitialisé.';

  @override
  String get helpBackupStep1Title => 'Sauvegarde complète';

  @override
  String get helpBackupStep1Body =>
      'Enregistre vos comptes, opérations, biens, liste de suivi, placements et réglages dans un fichier .json.';

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
      'Qima calcule la zakat à partir de ce que vous possédez aux prix du jour. Il calcule ; les choix derrière le calcul vous appartiennent.';

  @override
  String get helpZakatStep1Title => 'Nisab';

  @override
  String get helpZakatStep1Body =>
      'Le seuil est de 85 g d’or fin ou 595 g d’argent, au cours du moment. Choisissez la base dans les réglages ; celle de l’argent est plus basse, donc plus de personnes sont redevables.';

  @override
  String get helpZakatStep2Title => 'Ce qui compte';

  @override
  String get helpZakatStep2Body =>
      'Les espèces, métaux et cryptos comptent par défaut, et les biens destinés à la vente à leur valeur ; pas les actions. Les soldes de carte et l’argent dû à des personnes sont déduits. Désactivez n’importe quel élément.';

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

  @override
  String get settingsSummaries => 'Résumés';

  @override
  String get settingsPlainSummaries => 'Le mois en une phrase';

  @override
  String get settingsPlainSummariesFooter =>
      'Affiche dans Portefeuille, en une phrase, ce qui a fait bouger vos avoirs le mois dernier. Rédigé sur cet appareil à partir de vos propres chiffres.';

  @override
  String get summaryTitle => 'Le mois dernier';

  @override
  String summaryUp(String amount, String percent) {
    return 'Le mois dernier, vos avoirs ont gagné $amount ($percent).';
  }

  @override
  String summaryDown(String amount, String percent) {
    return 'Le mois dernier, vos avoirs ont perdu $amount ($percent).';
  }

  @override
  String get summaryFlat => 'Vos avoirs ont à peine bougé le mois dernier.';

  @override
  String summaryTopMover(String asset, String amount) {
    return '$asset les a le plus fait bouger, $amount.';
  }

  @override
  String summaryTransactions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vous avez enregistré $count transactions.',
      one: 'Vous avez enregistré 1 transaction.',
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
    return 'Du $from au $to : de $start à $end, $change. Plus haut $high le $highDate, plus bas $low le $lowDate.';
  }

  @override
  String chartDescriptionHidden(String from, String to, String change) {
    return 'Du $from au $to : $change.';
  }

  @override
  String get dictationStart => 'Dicter un achat';

  @override
  String get dictationStop => 'Arrêter l’écoute';

  @override
  String get dictationUnsupported =>
      'La saisie vocale dans cette langue n’est pas disponible sur cet appareil. Qima n’écoute que sur l’appareil, jamais via un serveur.';

  @override
  String get dictationDenied =>
      'Le micro ou la reconnaissance vocale est désactivé pour Qima. Activez-les dans Réglages pour dicter un achat.';

  @override
  String get settingsIntelligence => 'Intelligence sur l’appareil';

  @override
  String get settingsUseModel => 'Utiliser le modèle de l’appareil';

  @override
  String get settingsUseModelFooter =>
      'Aide à lire les achats que Qima ne comprend pas seule, et rédige le résumé du mois. Il fonctionne uniquement sur cet appareil, ne donne jamais de conseil et n’apporte jamais de chiffre : chaque montant vient de vos propres données.';

  @override
  String get modelReady => 'Prêt sur cet appareil';

  @override
  String get modelUnsupported => 'Indisponible sur cet appareil';

  @override
  String get modelTurnedOff =>
      'Activez Apple Intelligence dans les Réglages du système pour l’utiliser';

  @override
  String get modelNotReady => 'Le modèle est encore en téléchargement';

  @override
  String get modelUnsupportedLanguage =>
      'Pas encore disponible dans cette langue';

  @override
  String get receiptScan => 'Scanner un reçu';

  @override
  String get receiptTakePhoto => 'Prendre une photo';

  @override
  String get receiptChoosePhoto => 'Choisir une photo';

  @override
  String get receiptNoText =>
      'Aucun texte trouvé sur cette photo. Réessayez de plus près, avec le reçu bien à plat et bien éclairé.';

  @override
  String get addButton => 'Ajouter';

  @override
  String get addSheetWatch => 'Ajouter au suivi';

  @override
  String get addSheetWatchSubtitle => 'Suivez un prix. Aucun achat nécessaire.';

  @override
  String get addHoldingTitle => 'Ajouter une position';

  @override
  String get addSheetHoldingSpeakScan =>
      'Dictez, scannez un reçu ou saisissez-le.';

  @override
  String get addSheetHoldingSpeak => 'Dictez ou saisissez votre achat.';

  @override
  String get addSheetHoldingScan => 'Scannez un reçu ou saisissez-le.';

  @override
  String get addSheetHoldingType => 'Saisissez votre achat.';

  @override
  String get addSheetSiriTip =>
      'Demandez à Siri : « Combien vaut mon portefeuille Qima »';

  @override
  String get addTypeExample => 'Par exemple : acheté 20 g d\'or 21K à 4100 EGP';

  @override
  String get currencyFieldShowIn => 'Afficher les prix en';

  @override
  String get currencyFieldTransaction => 'Devise de l\'opération';

  @override
  String currencyFieldCount(int count) {
    return '$count devises disponibles';
  }

  @override
  String get currencyFieldMore => 'Plus';

  @override
  String get helpAddAssetStep5Title => 'Ajouter une position';

  @override
  String get helpAddAssetStep5Body =>
      'Touchez +, puis Ajouter une position. Saisissez votre achat, ou dictez-le ou scannez un reçu si cet appareil le permet. Vérifiez ce qui a été lu, puis confirmez.';

  @override
  String get helpAddAssetStep6Title => 'Lu sur cet appareil';

  @override
  String get helpAddAssetStep6Body =>
      'La voix et les reçus sont lus sur cet appareil et ne sont jamais envoyés. Rien n\'est enregistré avant votre confirmation, et chaque nombre vient de ce que vous avez saisi, dit ou scanné.';

  @override
  String get navHome => 'Accueil';

  @override
  String get navMoney => 'Argent';

  @override
  String get navPrices => 'Prix';

  @override
  String get netWorth => 'Valeur nette';

  @override
  String get balanceSheet => 'Bilan';

  @override
  String get youOwn => 'Ce que vous possédez';

  @override
  String get youOweSide => 'Ce que vous devez';

  @override
  String ownOweLine(String own, String owe) {
    return 'Vous possédez $own · Vous devez $owe';
  }

  @override
  String get sheetHoldings => 'Placements';

  @override
  String get sheetHoldingsLive => 'Aux prix actuels';

  @override
  String get sheetCash => 'Espèces et banque';

  @override
  String get sheetOwedToYou => 'On vous doit';

  @override
  String get sheetAssets => 'Biens et plus';

  @override
  String get sheetCards => 'Cartes';

  @override
  String get sheetLoans => 'Prêts';

  @override
  String get sheetYouOwe => 'Vous devez à des proches';

  @override
  String get sheetNothingOwed =>
      'Aucune dette. Cartes, prêts et dettes apparaissent ici une fois ajoutés.';

  @override
  String sheetMissingRates(String codes) {
    return 'Pas encore de taux pour $codes ; ces montants sont exclus du total.';
  }

  @override
  String get acctCash => 'Espèces';

  @override
  String get acctDebit => 'Compte bancaire';

  @override
  String get acctCredit => 'Carte';

  @override
  String get acctLoan => 'Prêt';

  @override
  String get acctReceivable => 'Vous doit';

  @override
  String get acctPayable => 'Vous lui devez';

  @override
  String get acctAsset => 'Bien';

  @override
  String get acctCategory => 'Catégorie';

  @override
  String get assetKindProperty => 'Immobilier';

  @override
  String get assetKindVehicle => 'Véhicule';

  @override
  String get assetKindBusiness => 'Entreprise';

  @override
  String get assetKindValuables => 'Objets de valeur';

  @override
  String get assetKindOther => 'Autre';

  @override
  String get assetKindPropertyHint => 'Une maison, un terrain, un local';

  @override
  String get assetKindVehicleHint => 'Une voiture, une moto, un bateau';

  @override
  String get assetKindBusinessHint => 'Votre part d’une entreprise';

  @override
  String get assetKindValuablesHint => 'Une montre, une œuvre, une collection';

  @override
  String get assetKindOtherHint => 'Tout autre bien';

  @override
  String get tplOpening => 'Solde d’ouverture';

  @override
  String get tplSpend => 'Dépense';

  @override
  String get tplIncome => 'Revenu';

  @override
  String get tplTransfer => 'Virement';

  @override
  String get tplAtm => 'Retrait au distributeur';

  @override
  String get tplSwap => 'Change de devise';

  @override
  String get tplCardPayment => 'Paiement de carte';

  @override
  String get tplLoanPayment => 'Remboursement de prêt';

  @override
  String get tplLent => 'Prêté';

  @override
  String get tplBorrowed => 'Emprunté';

  @override
  String get tplRepaymentIn => 'Remboursement reçu';

  @override
  String get tplRepaymentOut => 'Remboursement versé';

  @override
  String get tplRefund => 'Remboursement';

  @override
  String get tplDeclined => 'Refusée';

  @override
  String get tplCashCount => 'Comptage d’espèces';

  @override
  String get tplBillSplit => 'Addition partagée';

  @override
  String get tplValuation => 'Nouvelle valeur';

  @override
  String get tplAssetSale => 'Vendu';

  @override
  String get tplAdjustment => 'Ajustement';

  @override
  String get catGroceries => 'Courses';

  @override
  String get catDining => 'Restaurants';

  @override
  String get catTransport => 'Transport';

  @override
  String get catBills => 'Factures';

  @override
  String get catShopping => 'Achats';

  @override
  String get catHealth => 'Santé';

  @override
  String get catHome => 'Maison';

  @override
  String get catOther => 'Autres';

  @override
  String get catSalary => 'Salaire';

  @override
  String get catOtherIncome => 'Autres revenus';

  @override
  String get catInterestFees => 'Intérêts et frais';

  @override
  String get sysOpening => 'Soldes d’ouverture';

  @override
  String get sysChange => 'Variation de valeur';

  @override
  String get sysRounding => 'Arrondi';

  @override
  String get featBudget => 'Budget';

  @override
  String get featRecurring => 'Paiements récurrents';

  @override
  String get featPeople => 'Prêts entre proches';

  @override
  String get featLoans => 'Prêts';

  @override
  String get featBillSplit => 'Partage d’addition';

  @override
  String get featZakat => 'Zakat';

  @override
  String get featBudgetDetail => 'Un montant mensuel par catégorie et le reste';

  @override
  String get featRecurringDetail => 'Factures et abonnements avant l’échéance';

  @override
  String get featPeopleDetail => 'Qui vous doit et à qui vous devez';

  @override
  String get featLoansDetail =>
      'Le restant dû et les intérêts de chaque échéance';

  @override
  String get featBillSplitDetail =>
      'Payez et partagez ; seule votre part est une dépense';

  @override
  String get featZakatDetail => 'Zakat sur placements, espèces et dettes';

  @override
  String featureTurnedOn(String feature) {
    return '$feature activé';
  }

  @override
  String get featuresTitle => 'Fonctions';

  @override
  String get featuresSubtitle => 'Budget, récurrents, prêts et plus';

  @override
  String get featuresIntro =>
      'Désactiver une fonction masque ses écrans, jamais votre argent : ses montants comptent toujours dans le bilan.';

  @override
  String get cardNeedsReview => 'À vérifier';

  @override
  String get cardComingUp => 'À venir';

  @override
  String get cardLeftToSpend => 'Reste à dépenser';

  @override
  String get cardAccounts => 'Comptes';

  @override
  String get editHome => 'Modifier l’accueil';

  @override
  String get editHomeIntro =>
      'Déplacez ou masquez des cartes. Qima ne réaffiche jamais une carte masquée.';

  @override
  String get editHomeTotalFixed => 'Toujours en premier : il ouvre le bilan';

  @override
  String get editHomeCantHide => 'N’apparaît que si quelque chose vous attend';

  @override
  String get moveUp => 'Monter';

  @override
  String get moveDown => 'Descendre';

  @override
  String get moveToTop => 'Placer en haut';

  @override
  String get startTitle => 'Commencez par ce que vous avez';

  @override
  String get startMessage =>
      'Ajoutez un compte, un placement ou un bien. Qima les additionne dans votre valeur nette.';

  @override
  String holdingsGainLine(String amount) {
    return 'Gain $amount';
  }

  @override
  String reviewValue(String name) {
    return 'Revoir la valeur de $name';
  }

  @override
  String get accountAdd => 'Ajouter un compte';

  @override
  String get accountEdit => 'Modifier le compte';

  @override
  String get accountNameLabel => 'Nom';

  @override
  String get accountCurrency => 'Devise';

  @override
  String get accountBalanceToday => 'Solde aujourd’hui';

  @override
  String get accountOwedToday => 'Dû aujourd’hui';

  @override
  String get accountLoanLeft => 'Capital restant dû';

  @override
  String get accountTheyOwe => 'Vous doit';

  @override
  String get accountYouOwe => 'Vous lui devez';

  @override
  String get accountBalanceHelp =>
      'Qima part de ce montant ; laissez vide pour zéro.';

  @override
  String get accountSince => 'En date du';

  @override
  String get accountLimit => 'Plafond de la carte';

  @override
  String get accountCounts => 'Compter dans la valeur nette';

  @override
  String get accountCountsHelp =>
      'Désactivé, il est exclu du total ; son historique reste juste.';

  @override
  String get accountErrorName => 'Donnez-lui un nom.';

  @override
  String get accountLeftOut => 'Non compté dans la valeur nette';

  @override
  String accountAvailable(String amount) {
    return '$amount disponible';
  }

  @override
  String get accountCountCash => 'Compter les espèces';

  @override
  String get accountCheckBalance => 'Vérifier le solde';

  @override
  String get accountPayCard => 'Payer la carte';

  @override
  String get accountPayLoan => 'Payer le prêt';

  @override
  String get accountRemoveTitle => 'Supprimer le compte';

  @override
  String get accountRemoveMessage =>
      'Un compte avec des opérations est archivé pour garder l’historique juste. Un compte inutilisé est supprimé.';

  @override
  String get accountsEmptyTitle => 'Aucun compte';

  @override
  String get accountsEmptyMessage =>
      'Ajoutez un compte, des espèces, une carte ou un prêt avec son solde du jour.';

  @override
  String reconcileTracked(String amount) {
    return 'Qima indique $amount.';
  }

  @override
  String get reconcileCounted => 'Ce que vous avez compté';

  @override
  String get reconcileStatement => 'Solde sur le relevé ou l’appli';

  @override
  String get reconcileDone =>
      'L’écart est noté dans Autres et le solde correspond.';

  @override
  String get entryAmount => 'Montant';

  @override
  String get entryPrincipal => 'Capital';

  @override
  String get entryProfit => 'Intérêts';

  @override
  String get entryProfitHelp =>
      'Compte comme dépense en Intérêts et frais ; jamais le capital.';

  @override
  String get entrySent => 'Envoyé';

  @override
  String get entryReceived => 'Reçu';

  @override
  String get entryPaidFrom => 'Payé avec';

  @override
  String get entryFrom => 'Depuis';

  @override
  String get entryTo => 'Vers';

  @override
  String get entryPerson => 'Personne';

  @override
  String get entryCategory => 'Catégorie';

  @override
  String get entryDate => 'Date';

  @override
  String get entryMerchant => 'Où';

  @override
  String get entryNote => 'Note';

  @override
  String get entryDeclined => 'Refusée';

  @override
  String get entryDeclinedHelp => 'Affichée barrée ; jamais dans un solde.';

  @override
  String get entryEditTitle => 'Modifier l’opération';

  @override
  String get entryDeleteTitle => 'Supprimer l’opération ?';

  @override
  String get entryDeleteMessage =>
      'Chaque compte concerné revient à son état d’avant.';

  @override
  String get entryErrorAmount => 'Saisissez un montant supérieur à zéro.';

  @override
  String get entryErrorAccount => 'Choisissez les comptes.';

  @override
  String get entryErrorSameCurrency =>
      'Les deux comptes doivent avoir la même devise. Sinon, utilisez Change de devise.';

  @override
  String get entryErrorSwap =>
      'Choisissez deux comptes de devises différentes.';

  @override
  String get entryErrorPerson => 'Indiquez qui c’est.';

  @override
  String get entryErrorRate =>
      'Pas encore de taux pour cette devise. Réessayez après la mise à jour.';

  @override
  String get entryNeedsAccountTitle => 'Ajoutez d’abord un compte';

  @override
  String get entryNeedsAccountMessage =>
      'Il faut un compte d’origine ou de destination. Ajoutez-en un dans Comptes.';

  @override
  String get howItAddsUp => 'Comment ça s’équilibre';

  @override
  String hiuUp(String name, String amount) {
    return '$name augmente de $amount';
  }

  @override
  String hiuDown(String name, String amount) {
    return '$name diminue de $amount';
  }

  @override
  String get hiuSpending => 'Dépense : elle compte dans votre budget.';

  @override
  String get hiuIncome => 'Revenu : il compte dans vos flux.';

  @override
  String get hiuRefund => 'Un remboursement réduit la dépense de sa catégorie.';

  @override
  String get hiuWorth =>
      'Une variation de valeur ne touche que la valeur nette ; jamais revenu ni dépense.';

  @override
  String get hiuMove =>
      'Un mouvement entre vos comptes : pas une dépense, votre valeur nette ne change pas.';

  @override
  String get hiuDeclined => 'Refusée : rien n’a bougé.';

  @override
  String get allTransactions => 'Toutes les opérations';

  @override
  String get transactionsSearch => 'Rechercher';

  @override
  String get transactionsEmptyTitle => 'Aucune opération';

  @override
  String get transactionsEmptyMessage => 'Ajoutez-en une avec le bouton +.';

  @override
  String get moneySpent => 'Dépensé';

  @override
  String moneySpentOf(String spent, String budget) {
    return '$spent sur $budget';
  }

  @override
  String moneySpentSoFar(String amount) {
    return '$amount dépensés ce mois-ci';
  }

  @override
  String moneyPace(String amount) {
    return 'À ce rythme : $amount en fin de mois';
  }

  @override
  String get moneyNothingSpent => 'Aucune dépense ce mois-ci.';

  @override
  String get moneyIn => 'Entrées';

  @override
  String get moneyOut => 'Sorties';

  @override
  String get moneyLeftOver => 'Excédent';

  @override
  String get moneyShort => 'Déficit';

  @override
  String get moneyTrend => 'Dépenses par mois';

  @override
  String get moneyTransactions => 'Opérations';

  @override
  String get moneyStartMessage => 'Ajoutez un compte, puis notez vos dépenses.';

  @override
  String get whereItWent => 'Où est passé l’argent';

  @override
  String get cashFlow => 'Flux de trésorerie';

  @override
  String get worthALook => 'À regarder';

  @override
  String aheadOfPace(String name) {
    return '$name dépasse le rythme de son budget';
  }

  @override
  String spareIn(String name, String amount) {
    return '$name a $amount de marge';
  }

  @override
  String get previousMonth => 'Mois précédent';

  @override
  String get nextMonth => 'Mois suivant';

  @override
  String get ask => 'Demander';

  @override
  String get askSpentMonth => 'Combien ai-je dépensé ce mois-ci ?';

  @override
  String askSpentMonthAnswer(String amount) {
    return '$amount';
  }

  @override
  String get askTopCategory => 'Où est passé l’essentiel ?';

  @override
  String askTopCategoryAnswer(String name, String amount) {
    return '$name : $amount';
  }

  @override
  String get askVsLastMonth => 'Est-ce plus que le mois dernier ?';

  @override
  String askMore(String amount) {
    return '$amount de plus que le mois dernier';
  }

  @override
  String askLess(String amount) {
    return '$amount de moins que le mois dernier';
  }

  @override
  String get askSame => 'À peu près comme le mois dernier';

  @override
  String get askOwed => 'Qui me doit de l’argent ?';

  @override
  String get askNobodyOwes => 'Personne ne vous doit d’argent.';

  @override
  String get assetAdd => 'Ajouter un bien';

  @override
  String get assetEdit => 'Modifier le bien';

  @override
  String get assetGoldNote =>
      'L’or et l’argent au poids restent des placements, car Qima les évalue. Ajoutez-les via Ajouter un placement.';

  @override
  String get assetValueToday => 'Valeur aujourd’hui';

  @override
  String get assetCost => 'Prix payé';

  @override
  String get assetBought => 'Date d’achat';

  @override
  String get optional => 'Facultatif';

  @override
  String get assetLoan => 'Prêt adossé';

  @override
  String get assetNoLoan => 'Aucun';

  @override
  String get assetForSale => 'Destiné à la vente';

  @override
  String get assetForSaleHelp =>
      'Compte pour la zakat à sa valeur. Désactivé pour ce que vous utilisez.';

  @override
  String get assetErrorValue => 'Saisissez la valeur du jour.';

  @override
  String get assetsTotal => 'Valeur totale';

  @override
  String get assetsTotalHelp => 'Valeurs fixées par vous, chacune datée';

  @override
  String get assetsEmptyTitle => 'Aucun bien';

  @override
  String get assetsEmptyMessage =>
      'Ajoutez une maison, un terrain, une voiture ou une part d’entreprise. Vous fixez la valeur, Qima garde l’historique.';

  @override
  String assetUpdated(String date) {
    return 'Mis à jour le $date';
  }

  @override
  String assetSinceBought(String amount) {
    return '$amount depuis l’achat';
  }

  @override
  String get assetUpdateValue => 'Mettre à jour la valeur';

  @override
  String get assetUpdateHelp =>
      'Chaque mise à jour est datée. La dernière compte ; les autres restent dans l’historique.';

  @override
  String get assetNewValue => 'Nouvelle valeur';

  @override
  String get assetValueSource => 'Origine de la valeur';

  @override
  String get assetSold => 'Vendu';

  @override
  String assetSellTitle(String name) {
    return 'Vendre $name';
  }

  @override
  String assetLastValue(String amount) {
    return 'Dernière valeur : $amount';
  }

  @override
  String get assetSoldInto => 'L’argent est allé sur';

  @override
  String get assetSoldFor => 'Vendu pour';

  @override
  String assetGain(String amount) {
    return 'Plus-value de $amount';
  }

  @override
  String assetLoss(String amount) {
    return 'Moins-value de $amount';
  }

  @override
  String get assetGainHelp =>
      'Par rapport à la dernière valeur. C’est une variation, jamais un revenu.';

  @override
  String assetPayOff(String name) {
    return 'La vente a soldé $name';
  }

  @override
  String assetPayOffHelp(String amount) {
    return '$amount restant, payé depuis le même compte';
  }

  @override
  String get assetYours => 'Ce qui est à vous';

  @override
  String get assetValue => 'Valeur';

  @override
  String assetStillOwed(String name) {
    return 'Restant dû sur $name';
  }

  @override
  String get assetYoursTotal => 'À vous';

  @override
  String get assetYoursHelp =>
      'Le bilan liste toujours le bien dans vos avoirs et le prêt dans vos dettes.';

  @override
  String get assetHistory => 'Historique';

  @override
  String get assetRemoveTitle => 'Supprimer le bien';

  @override
  String get assetRemoveMessage =>
      'Pour une vente, utilisez Vendu. Supprimer l’archive avec son historique.';

  @override
  String get howTotalWorked => 'Comment le total est calculé';

  @override
  String get howTotalIntro =>
      'La valeur nette est ce que vous possédez moins ce que vous devez.';

  @override
  String get howTotalHoldings =>
      'Les placements utilisent les prix actuels, comme dans Prix.';

  @override
  String get howTotalAssets =>
      'Les biens que vous évaluez utilisent leur dernière valeur datée ; chacun peut être exclu.';

  @override
  String get howTotalLoans =>
      'Les prêts ne comptent que le capital ; les intérêts futurs ne sont pas une dette avant l’échéance.';

  @override
  String get howTotalRates => 'Les autres devises utilisent le taux actuel.';

  @override
  String sheetAccountsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comptes',
      one: '1 compte',
      zero: 'Aucun compte',
    );
    return '$_temp0';
  }

  @override
  String budgetFor(String name) {
    return 'Budget pour $name';
  }

  @override
  String get budgetIntro =>
      'Fixez un montant mensuel pour les catégories à suivre. Paiements de carte, virements et capital ne comptent jamais.';

  @override
  String get budgetMonthly => 'Chaque mois';

  @override
  String get budgetZeroHelp => 'Zéro le supprime.';

  @override
  String get budgetNone => 'Sans budget';

  @override
  String budgetOf(String amount) {
    return 'Budget $amount';
  }

  @override
  String get budgetSet => 'Définir un budget';

  @override
  String get budgetTotal => 'Budget du mois';

  @override
  String get recurringAdd => 'Ajouter un paiement récurrent';

  @override
  String get recurringDay => 'Jour du mois';

  @override
  String get recurringEmptyTitle => 'Aucun paiement récurrent';

  @override
  String get recurringEmptyMessage =>
      'Ajoutez loyer, factures et abonnements pour les voir dans À venir avant l’échéance.';

  @override
  String recurringNext(String date) {
    return 'Prochain le $date';
  }

  @override
  String recurringRecord(String name, String date) {
    return 'Enregistrer $name du $date';
  }

  @override
  String get peopleEmptyTitle => 'Personne pour l’instant';

  @override
  String get peopleEmptyMessage =>
      'Notez ce que vous prêtez ou empruntez, et les remboursements.';

  @override
  String get splitTotal => 'Total de l’addition';

  @override
  String get splitWho => 'Avec qui';

  @override
  String get splitShare => 'Part';

  @override
  String get splitAddPerson => 'Ajouter une personne';

  @override
  String get splitEvenly => 'Partager à parts égales';

  @override
  String get splitMine => 'Votre part (dépense)';

  @override
  String get splitOwedToYou => 'On vous doit';

  @override
  String get splitHelp =>
      'Le montant total quitte le compte ; seule votre part est une dépense, les autres vous sont dues.';

  @override
  String get splitErrorPerson =>
      'Chaque personne doit avoir un nom et une part.';

  @override
  String get splitErrorShares =>
      'Ajoutez au moins une personne, avec des parts n’excédant pas le total.';

  @override
  String get categoriesTitle => 'Catégories';

  @override
  String get categoriesSpending => 'Dépenses';

  @override
  String get categoriesIncome => 'Revenus';

  @override
  String get categoryRename => 'Renommer la catégorie';

  @override
  String get categoryRemove => 'Supprimer la catégorie';

  @override
  String get categoryRemoveMessage =>
      'Les opérations la gardent dans leur historique.';

  @override
  String get categoryAddSpending => 'Nouvelle catégorie de dépense';

  @override
  String get categoryAddIncome => 'Nouvelle catégorie de revenu';

  @override
  String get valueReview => 'Revoir la valeur des biens';

  @override
  String get valueReviewHelp => 'Un rappel dans À vérifier';

  @override
  String get valueReviewOff => 'Désactivé';

  @override
  String valueReviewMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'Tous les $months mois',
      one: 'Chaque mois',
    );
    return '$_temp0';
  }

  @override
  String get addSheetTransaction => 'Opération';

  @override
  String get addSheetTransactionSubtitle => 'Argent dépensé, reçu ou déplacé';

  @override
  String get entryVoiceHint =>
      'Dites ce qui s’est passé, par exemple « Payé 45 chez Carrefour avec la Visa hier »';

  @override
  String get entryVoiceNothing =>
      'Aucun montant ni nom compris. Réessayez ou tapez-le.';

  @override
  String get entryNewTitle => 'Nouvelle opération';

  @override
  String get addSheetMore => 'Plus';

  @override
  String get addSheetMoreSubtitle =>
      'Revenus, virements, prêts, comptes, biens';

  @override
  String get whatsNewTitle => 'Nouveautés de Qima';

  @override
  String get whatsNewTabs =>
      'Trois onglets : Accueil pour votre situation, Argent pour vos dépenses, Prix pour le marché.';

  @override
  String get whatsNewBalanceSheet =>
      'Placements, comptes, cartes et prêts s’additionnent dans un bilan. Touchez le total pour le voir.';

  @override
  String get whatsNewAssets =>
      'Ajoutez un bien, une voiture ou une entreprise et mettez sa valeur à jour.';

  @override
  String get whatsNewPick => 'Que souhaitez-vous utiliser ?';

  @override
  String get whatsNewLater =>
      'Modifiable à tout moment dans Réglages › Fonctions.';

  @override
  String get zakatDueTitle => 'Zakat due';

  @override
  String zakatDueLine(String amount) {
    return '$amount dus';
  }

  @override
  String get zakatBelowLine => 'Sous le nisab';

  @override
  String zakatBaseLine(String amount) {
    return 'Compté : $amount';
  }

  @override
  String zakatAbove(String amount) {
    return 'Au-dessus du nisab de $amount';
  }

  @override
  String zakatBelow(String amount) {
    return 'Sous le nisab de $amount';
  }

  @override
  String get zakatNoThreshold =>
      'Le nisab s’affiche une fois les prix de l’or et de l’argent chargés.';

  @override
  String get zakatBase => 'Compté pour la zakat';

  @override
  String get zakatHeldForSale => 'Biens destinés à la vente';

  @override
  String get zakatDebtsDue => 'Dettes exigibles';

  @override
  String get zakatBookHelp =>
      'Les placements suivent vos réglages de zakat. Les cartes et dettes envers des proches sont déduites ; pas les prêts, car seule l’échéance due compterait et Qima ne connaît pas leur échéancier.';

  @override
  String get zakatHoldingsDetail => 'Détail des placements';

  @override
  String get importStatement => 'Importer un relevé';

  @override
  String get importStatementSubtitle =>
      'PDF, Excel, CSV ou captures de votre banque';

  @override
  String get importFromFiles => 'Depuis Fichiers';

  @override
  String get importFromFilesHint => 'Relevés en PDF, Excel ou CSV';

  @override
  String get importFromPhotos => 'Captures depuis Photos';

  @override
  String get importFromPhotosHint => 'Les opérations de votre appli bancaire';

  @override
  String get importFromClipboard => 'Depuis le presse-papiers';

  @override
  String get importFromClipboardHint =>
      'Un relevé, reçu, message bancaire ou capture copié';

  @override
  String get importPastedName => 'Collé';

  @override
  String get importShareTip =>
      'Vous pouvez aussi partager des fichiers vers Qima depuis n’importe quelle appli.';

  @override
  String importReadingFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lecture de $count fichiers…',
      one: 'Lecture d’1 fichier…',
    );
    return '$_temp0';
  }

  @override
  String importReadyRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opérations à vérifier',
      one: '1 opération à vérifier',
      zero: 'Rien à ajouter',
    );
    return '$_temp0';
  }

  @override
  String get importReadyBalance => 'Un solde à vérifier';

  @override
  String get bankMessagesTitle => 'Messages de la banque';

  @override
  String get bankMessagesEntry => 'Messages de la banque';

  @override
  String get bankMessagesEntryHint =>
      'Ajoutez les achats depuis les messages de votre banque';

  @override
  String get bankMessagesIntro =>
      'Votre banque vous envoie un message à chaque achat, virement et salaire. Qima peut lire ces messages et les proposer comme opérations. Vous vérifiez chacune avant qu’elle soit ajoutée.';

  @override
  String get bankMessagesRead => 'Lire les nouveaux messages bancaires';

  @override
  String get bankMessagesReadHint =>
      'Seulement les messages avec un montant. Les codes et messages personnels sont ignorés.';

  @override
  String get bankMessagesRecent => 'Importer les 60 derniers jours';

  @override
  String get bankMessagesRecentHint =>
      'Les messages déjà dans Qima sont ignorés';

  @override
  String get bankMessagesDenied =>
      'Qima a besoin de l’autorisation de lire les messages. Vous pouvez l’accorder dans les Réglages.';

  @override
  String get bankMessagesSetUp => 'Configurez-le une fois dans Raccourcis';

  @override
  String get bankMessagesStep1 =>
      'Ouvrez Raccourcis, allez dans Automatisation et touchez +, puis choisissez Message.';

  @override
  String get bankMessagesStep2 =>
      'Choisissez votre banque comme expéditeur, ou un mot toujours présent dans ses messages, comme EUR.';

  @override
  String get bankMessagesStep3 => 'Choisissez Exécuter immédiatement.';

  @override
  String get bankMessagesStep4 =>
      'Ajoutez l’action « Add a bank message » de Qima et passez-lui le message.';

  @override
  String get bankMessagesOpenShortcuts => 'Ouvrir Raccourcis';

  @override
  String get bankMessagesUnavailable =>
      'Les messages bancaires peuvent être ajoutés sur iPhone et Android.';

  @override
  String get bankMessagesPrivacy =>
      'Les messages sont lus sur cet appareil et ne le quittent jamais.';

  @override
  String bankMessagesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages bancaires à vérifier',
      one: '1 message bancaire à vérifier',
      zero: 'Aucun message bancaire trouvé',
    );
    return '$_temp0';
  }

  @override
  String get importBannerTitle => 'Partagé avec Qima';

  @override
  String get importReviewTitle => 'Vérifier l’import';

  @override
  String get importIntoAccount => 'Relevé de';

  @override
  String get importNoAccountTitle => 'Ajoutez d’abord le compte';

  @override
  String get importNoAccountBody =>
      'Ajoutez le compte bancaire ou la carte de ce relevé, puis revenez ici.';

  @override
  String importAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouter $count opérations',
      one: 'Ajouter 1 opération',
      zero: 'Ajouter',
    );
    return '$_temp0';
  }

  @override
  String importAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opérations ajoutées',
      one: '1 opération ajoutée',
    );
    return '$_temp0';
  }

  @override
  String get importDiscardAll => 'Tout ignorer';

  @override
  String get importApplyBalance => 'Appliquer le solde';

  @override
  String get importDiscardConfirm =>
      'Ignorer ces fichiers ? Rien n’en sera ajouté.';

  @override
  String get importDiscard => 'Ignorer';

  @override
  String get importRemoveFile => 'Retirer le fichier';

  @override
  String get importFlagInBook => 'Déjà dans Qima';

  @override
  String get importFlagRepeated => 'Aussi dans un autre fichier';

  @override
  String importFlagCurrency(String currency) {
    return 'En $currency, pas dans la devise du compte';
  }

  @override
  String get importDateGuessed => 'Pas de date : jour du partage utilisé';

  @override
  String get importSignGuessed => 'À vérifier : entrée ou sortie ?';

  @override
  String get importFlagNotTransaction =>
      'Ressemble à un texte de la banque, pas à une opération';

  @override
  String importRefCard(String last4) {
    return 'Carte •••• $last4';
  }

  @override
  String importRefAccount(String last4) {
    return 'Compte •••• $last4';
  }

  @override
  String importRefIban(String last4) {
    return 'IBAN •••• $last4';
  }

  @override
  String importBalances(String opening, String closing) {
    return 'Initial $opening → final $closing';
  }

  @override
  String get importAddsUp => 'Le compte est bon : rien ne manque';

  @override
  String importGap(String amount) {
    return '$amount non expliqués : vérifiez s\'il manque une opération';
  }

  @override
  String importOpeningBalance(String amount) {
    return 'Ajouter le solde initial : $amount';
  }

  @override
  String importMatchBalance(String amount) {
    return 'Ramener le solde à $amount';
  }

  @override
  String importBalanceDetail(String date, String tracked) {
    return 'Comme l\'indique le relevé au $date. Sans cela, Qima aurait $tracked.';
  }

  @override
  String get importStatusReading => 'Lecture…';

  @override
  String get importStatusWaiting => 'En attente';

  @override
  String get importStatusAlready => 'Déjà importé';

  @override
  String get importStatusUnsupported =>
      'Qima ne peut pas lire ce type de fichier';

  @override
  String get importStatusUnreadable => 'Impossible de lire ce fichier';

  @override
  String get importStatusNothing => 'Aucune opération trouvée dans ce fichier';

  @override
  String importRowFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trouvées',
      one: '1 trouvée',
    );
    return '$_temp0';
  }

  @override
  String get importEditRow => 'Opération';

  @override
  String get importCategory => 'Catégorie';

  @override
  String get importNothingSelected => 'Cochez les opérations à ajouter.';

  @override
  String get importReadOnDevice =>
      'Lu sur cet appareil. Les fichiers sont supprimés après l’import.';

  @override
  String get importEmpty => 'Rien en attente';

  @override
  String get catUncategorized => 'Non classé';

  @override
  String get catUncategorizedIncome => 'Revenus non classés';

  @override
  String get toCategorizeTitle => 'À classer';

  @override
  String toCategorizeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count à classer',
      one: '1 à classer',
    );
    return '$_temp0';
  }

  @override
  String get toCategorizeHint =>
      'Choisissez une catégorie une fois par nom. Les imports de ce nom l’utiliseront désormais.';

  @override
  String get toCategorizeEmpty => 'Tout est classé.';

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
          'Mettre aussi $count opérations antérieures de $name dans $category ? Elles sont dans $from.',
      one:
          'Mettre aussi 1 opération antérieure de $name dans $category ? Elle est dans $from.',
    );
    return '$_temp0';
  }

  @override
  String get toCategorizeAlsoYes => 'Les déplacer';

  @override
  String get categoriesLearned => 'Appris de vos choix';

  @override
  String get categoriesForgetTitle => 'Oublier ce choix ?';

  @override
  String categoriesForgetMessage(String name, String category) {
    return 'Les imports de $name n’iront plus d’eux-mêmes dans $category. Les opérations déjà classées restent.';
  }

  @override
  String get categoriesForget => 'Oublier';

  @override
  String get marketClosed => 'Fermé';

  @override
  String marketClosedOpens(String time) {
    return 'Marché fermé · ouvre $time';
  }

  @override
  String marketOpenCloses(String time) {
    return 'Marché ouvert · ferme $time';
  }

  @override
  String get marketClosedLong => 'Marché fermé';

  @override
  String holdingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count placements',
      one: '1 placement',
    );
    return '$_temp0';
  }

  @override
  String pricesAt(String time) {
    return 'cours $time';
  }

  @override
  String get balanceWayTransaction => 'Ajouter une opération';

  @override
  String balanceWayTransactionDetail(String other) {
    return 'L’écart compte comme dépense ou revenu dans $other';
  }

  @override
  String get balanceWayOpening => 'Modifier le solde d’ouverture';

  @override
  String get balanceWayOpeningDetail =>
      'Depuis son premier jour, ni dépense ni revenu';
}
