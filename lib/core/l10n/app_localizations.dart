import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'Tuco'**
  String get appName;

  /// No description provided for @tabHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get tabHome;

  /// No description provided for @tabProgress.
  ///
  /// In fr, this message translates to:
  /// **'Progression'**
  String get tabProgress;

  /// No description provided for @tabProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// No description provided for @exchange.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get exchange;

  /// No description provided for @levelBeginner.
  ///
  /// In fr, this message translates to:
  /// **'Débutant'**
  String get levelBeginner;

  /// No description provided for @levelIntermediate.
  ///
  /// In fr, this message translates to:
  /// **'Intermédiaire'**
  String get levelIntermediate;

  /// No description provided for @levelAdvanced.
  ///
  /// In fr, this message translates to:
  /// **'Avancé'**
  String get levelAdvanced;

  /// No description provided for @stepLesson.
  ///
  /// In fr, this message translates to:
  /// **'Leçon'**
  String get stepLesson;

  /// No description provided for @stepPractice.
  ///
  /// In fr, this message translates to:
  /// **'Entraînement'**
  String get stepPractice;

  /// No description provided for @courseBanner.
  ///
  /// In fr, this message translates to:
  /// **'Cours'**
  String get courseBanner;

  /// No description provided for @practiceBanner.
  ///
  /// In fr, this message translates to:
  /// **'Entraînement'**
  String get practiceBanner;

  /// No description provided for @courseDoneBanner.
  ///
  /// In fr, this message translates to:
  /// **'Cours terminé !'**
  String get courseDoneBanner;

  /// No description provided for @yourTurn.
  ///
  /// In fr, this message translates to:
  /// **'À vous de jouer !'**
  String get yourTurn;

  /// No description provided for @typeButton.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get typeButton;

  /// No description provided for @inspirationButton.
  ///
  /// In fr, this message translates to:
  /// **'Inspiration'**
  String get inspirationButton;

  /// No description provided for @clearButton.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get clearButton;

  /// No description provided for @replyHere.
  ///
  /// In fr, this message translates to:
  /// **'Répondre ici'**
  String get replyHere;

  /// No description provided for @inspirationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quelques exemples de phrases :'**
  String get inspirationTitle;

  /// No description provided for @quitCallTitle.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr(e) ?'**
  String get quitCallTitle;

  /// No description provided for @quitCallBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne recevrez pas de rapport d\'évaluation si vous ne terminez pas cette session.'**
  String get quitCallBody;

  /// No description provided for @resumeCall.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre l\'appel'**
  String get resumeCall;

  /// No description provided for @quitCall.
  ///
  /// In fr, this message translates to:
  /// **'Quitter l\'appel'**
  String get quitCall;

  /// No description provided for @endSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Bravo, tu assures ! La maîtrise est à portée de main !'**
  String get endSubtitle;

  /// No description provided for @newWordsCard.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux Mots'**
  String get newWordsCard;

  /// No description provided for @lessonsDoneCard.
  ///
  /// In fr, this message translates to:
  /// **'Leçons Terminées'**
  String get lessonsDoneCard;

  /// No description provided for @lessonDurationCard.
  ///
  /// In fr, this message translates to:
  /// **'Durée leçon'**
  String get lessonDurationCard;

  /// No description provided for @nextLessonButton.
  ///
  /// In fr, this message translates to:
  /// **'Passer à la leçon suivante'**
  String get nextLessonButton;

  /// No description provided for @backHomeButton.
  ///
  /// In fr, this message translates to:
  /// **'Revenir sur la page d\'accueil'**
  String get backHomeButton;

  /// No description provided for @streakDays.
  ///
  /// In fr, this message translates to:
  /// **'jours de série'**
  String get streakDays;

  /// No description provided for @streakHelper.
  ///
  /// In fr, this message translates to:
  /// **'Suivez une leçon chaque jour pour maintenir votre série !'**
  String get streakHelper;

  /// No description provided for @understood.
  ///
  /// In fr, this message translates to:
  /// **'Compris !'**
  String get understood;

  /// No description provided for @streakTitle.
  ///
  /// In fr, this message translates to:
  /// **'Série'**
  String get streakTitle;

  /// No description provided for @longestStreak.
  ///
  /// In fr, this message translates to:
  /// **'Série la plus longue'**
  String get longestStreak;

  /// No description provided for @monthTraining.
  ///
  /// In fr, this message translates to:
  /// **'Entraînement du mois'**
  String get monthTraining;

  /// No description provided for @continueLearning.
  ///
  /// In fr, this message translates to:
  /// **'Continuer l\'apprentissage'**
  String get continueLearning;

  /// No description provided for @feedbackCenter.
  ///
  /// In fr, this message translates to:
  /// **'Centre de feedback'**
  String get feedbackCenter;

  /// No description provided for @grammar.
  ///
  /// In fr, this message translates to:
  /// **'Grammaire'**
  String get grammar;

  /// No description provided for @alternatives.
  ///
  /// In fr, this message translates to:
  /// **'Alternatives'**
  String get alternatives;

  /// No description provided for @times.
  ///
  /// In fr, this message translates to:
  /// **'fois'**
  String get times;

  /// No description provided for @vocabExercise.
  ///
  /// In fr, this message translates to:
  /// **'Exercice de vocabulaire'**
  String get vocabExercise;

  /// No description provided for @newWordsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux mots'**
  String get newWordsLabel;

  /// No description provided for @upcomingWordsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mots à venir'**
  String get upcomingWordsLabel;

  /// No description provided for @yourStreak.
  ///
  /// In fr, this message translates to:
  /// **'Votre série'**
  String get yourStreak;

  /// No description provided for @dailyStreak.
  ///
  /// In fr, this message translates to:
  /// **'Série quotidienne'**
  String get dailyStreak;

  /// No description provided for @nextMilestone.
  ///
  /// In fr, this message translates to:
  /// **'Prochain badge : {days} jours'**
  String nextMilestone(int days);

  /// No description provided for @allMilestonesEarned.
  ///
  /// In fr, this message translates to:
  /// **'Tous les badges sont débloqués !'**
  String get allMilestonesEarned;

  /// No description provided for @milestonesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Badges de série'**
  String get milestonesTitle;

  /// No description provided for @milestonesEarnedCount.
  ///
  /// In fr, this message translates to:
  /// **'{earned} / {total} badges débloqués'**
  String milestonesEarnedCount(int earned, int total);

  /// No description provided for @milestoneDays.
  ///
  /// In fr, this message translates to:
  /// **'{days} jours'**
  String milestoneDays(int days);

  /// No description provided for @badgeRisen.
  ///
  /// In fr, this message translates to:
  /// **'Éveil'**
  String get badgeRisen;

  /// No description provided for @badgeIgnite.
  ///
  /// In fr, this message translates to:
  /// **'Étincelle'**
  String get badgeIgnite;

  /// No description provided for @badgeHorizon.
  ///
  /// In fr, this message translates to:
  /// **'Horizon'**
  String get badgeHorizon;

  /// No description provided for @badgeAurora.
  ///
  /// In fr, this message translates to:
  /// **'Aurore'**
  String get badgeAurora;

  /// No description provided for @badgeCelestial.
  ///
  /// In fr, this message translates to:
  /// **'Céleste'**
  String get badgeCelestial;

  /// No description provided for @badgeNebula.
  ///
  /// In fr, this message translates to:
  /// **'Nébuleuse'**
  String get badgeNebula;

  /// No description provided for @badgeEternal.
  ///
  /// In fr, this message translates to:
  /// **'Éternel'**
  String get badgeEternal;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In fr, this message translates to:
  /// **'COMPTE'**
  String get settingsAccount;

  /// No description provided for @settingsUserType.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'utilisateur'**
  String get settingsUserType;

  /// No description provided for @settingsUserTypeFree.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit'**
  String get settingsUserTypeFree;

  /// No description provided for @settingsCopyUserId.
  ///
  /// In fr, this message translates to:
  /// **'Copier l\'identifiant utilisateur'**
  String get settingsCopyUserId;

  /// No description provided for @settingsUserIdCopied.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant utilisateur copié'**
  String get settingsUserIdCopied;

  /// No description provided for @settingsAbout.
  ///
  /// In fr, this message translates to:
  /// **'À PROPOS'**
  String get settingsAbout;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get settingsTermsOfService;

  /// No description provided for @settingsDangerZone.
  ///
  /// In fr, this message translates to:
  /// **'ZONE DE DANGER'**
  String get settingsDangerZone;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte ?'**
  String get settingsDeleteAccountTitle;

  /// No description provided for @settingsDeleteAccountBody.
  ///
  /// In fr, this message translates to:
  /// **'Toutes vos données seront définitivement supprimées (progression, vocabulaire, historique d\'appels, séries). Cette action est irréversible.'**
  String get settingsDeleteAccountBody;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsDeleteAccountCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get settingsDeleteAccountCancel;

  /// No description provided for @settingsDeleteAccountDone.
  ///
  /// In fr, this message translates to:
  /// **'Les données de votre compte ont été supprimées'**
  String get settingsDeleteAccountDone;

  /// No description provided for @settingsDeleteAccountError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de supprimer vos données. Veuillez réessayer.'**
  String get settingsDeleteAccountError;

  /// No description provided for @callTimeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Temps passé en appel'**
  String get callTimeTitle;

  /// No description provided for @timeSpent.
  ///
  /// In fr, this message translates to:
  /// **'Temps passé'**
  String get timeSpent;

  /// No description provided for @average.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne'**
  String get average;

  /// No description provided for @goal.
  ///
  /// In fr, this message translates to:
  /// **'Objectif'**
  String get goal;

  /// No description provided for @callHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique des appels'**
  String get callHistory;

  /// No description provided for @showAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout afficher'**
  String get showAll;

  /// No description provided for @freeConversation.
  ///
  /// In fr, this message translates to:
  /// **'Conversation Libre'**
  String get freeConversation;

  /// No description provided for @learnedTab.
  ///
  /// In fr, this message translates to:
  /// **'Appris'**
  String get learnedTab;

  /// No description provided for @upcomingTab.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get upcomingTab;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get filterAll;

  /// No description provided for @scoreExcellent.
  ///
  /// In fr, this message translates to:
  /// **'Excellent'**
  String get scoreExcellent;

  /// No description provided for @scoreCanDoBetter.
  ///
  /// In fr, this message translates to:
  /// **'Peut Mieux Faire'**
  String get scoreCanDoBetter;

  /// No description provided for @scoreNeedsImprovement.
  ///
  /// In fr, this message translates to:
  /// **'Des améliorations sont nécessaires !'**
  String get scoreNeedsImprovement;

  /// No description provided for @scoreLabel.
  ///
  /// In fr, this message translates to:
  /// **'Score: {score} | {label}'**
  String scoreLabel(int score, String label);

  /// No description provided for @noErrorsHere.
  ///
  /// In fr, this message translates to:
  /// **'Pas d\'erreurs ici ! Vous pouvez appuyer sur le bouton de commentaires dans la leçon pour vérifier vos erreurs.'**
  String get noErrorsHere;

  /// No description provided for @targetLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue cible'**
  String get targetLanguage;

  /// No description provided for @nativeLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue maternelle'**
  String get nativeLanguage;

  /// No description provided for @languageLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau de langue'**
  String get languageLevel;

  /// No description provided for @interests.
  ///
  /// In fr, this message translates to:
  /// **'Centres d\'intérêt'**
  String get interests;

  /// No description provided for @dailyGoal.
  ///
  /// In fr, this message translates to:
  /// **'Objectif quotidien'**
  String get dailyGoal;

  /// No description provided for @dailyReminder.
  ///
  /// In fr, this message translates to:
  /// **'Rappel quotidien'**
  String get dailyReminder;

  /// No description provided for @disabled.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get disabled;

  /// No description provided for @minPerDay.
  ///
  /// In fr, this message translates to:
  /// **'{minutes} min/jour'**
  String minPerDay(int minutes);

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @more.
  ///
  /// In fr, this message translates to:
  /// **'Plus...'**
  String get more;

  /// No description provided for @reviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Merci d\'utiliser Tuco !'**
  String get reviewTitle;

  /// No description provided for @reviewBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous aimez Tuco ? Laissez-nous une note, ça nous aide beaucoup !'**
  String get reviewBody;

  /// No description provided for @letsGo.
  ///
  /// In fr, this message translates to:
  /// **'C\'est parti !'**
  String get letsGo;

  /// No description provided for @maybeLater.
  ///
  /// In fr, this message translates to:
  /// **'Peut-être plus tard'**
  String get maybeLater;

  /// No description provided for @skipLessonTitle.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir passer à cet exercice ?'**
  String get skipLessonTitle;

  /// No description provided for @skipLessonBody.
  ///
  /// In fr, this message translates to:
  /// **'Suivre votre parcours personnalisé boostera votre {language}, mais vous pouvez choisir de passer directement à cet exercice si vous le souhaitez.'**
  String skipLessonBody(String language);

  /// No description provided for @followPath.
  ///
  /// In fr, this message translates to:
  /// **'Suivre le parcours'**
  String get followPath;

  /// No description provided for @goToExercise.
  ///
  /// In fr, this message translates to:
  /// **'Accéder à l\'exercice'**
  String get goToExercise;

  /// No description provided for @resumeLessonTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prêt à reprendre là où vous vous êtes arrêté ?'**
  String get resumeLessonTitle;

  /// No description provided for @resumeLessonButton.
  ///
  /// In fr, this message translates to:
  /// **'Reprenons !'**
  String get resumeLessonButton;

  /// No description provided for @restartLessonButton.
  ///
  /// In fr, this message translates to:
  /// **'Recommencer depuis le début'**
  String get restartLessonButton;

  /// No description provided for @exercisesSection.
  ///
  /// In fr, this message translates to:
  /// **'EXERCICES'**
  String get exercisesSection;

  /// No description provided for @wordsToPracticeSection.
  ///
  /// In fr, this message translates to:
  /// **'MOTS À PRATIQUER'**
  String get wordsToPracticeSection;

  /// No description provided for @lessonExercise.
  ///
  /// In fr, this message translates to:
  /// **'Leçon'**
  String get lessonExercise;

  /// No description provided for @practiceExercise.
  ///
  /// In fr, this message translates to:
  /// **'Exercice'**
  String get practiceExercise;

  /// No description provided for @wellUnderstood.
  ///
  /// In fr, this message translates to:
  /// **'Bien compris'**
  String get wellUnderstood;

  /// No description provided for @wordsChip.
  ///
  /// In fr, this message translates to:
  /// **'{count} Mots'**
  String wordsChip(int count);

  /// No description provided for @grammarChip.
  ///
  /// In fr, this message translates to:
  /// **'{count} Grammaire'**
  String grammarChip(int count);

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Veuillez réessayer.'**
  String get errorGeneric;

  /// No description provided for @errorNoInternet.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion Internet. Veuillez vous connecter et réessayer.'**
  String get errorNoInternet;

  /// No description provided for @interestTechnology.
  ///
  /// In fr, this message translates to:
  /// **'Technologie'**
  String get interestTechnology;

  /// No description provided for @interestTravel.
  ///
  /// In fr, this message translates to:
  /// **'Voyages'**
  String get interestTravel;

  /// No description provided for @interestCooking.
  ///
  /// In fr, this message translates to:
  /// **'Cuisine'**
  String get interestCooking;

  /// No description provided for @interestSports.
  ///
  /// In fr, this message translates to:
  /// **'Sport'**
  String get interestSports;

  /// No description provided for @interestMusic.
  ///
  /// In fr, this message translates to:
  /// **'Musique'**
  String get interestMusic;

  /// No description provided for @interestMovies.
  ///
  /// In fr, this message translates to:
  /// **'Cinéma'**
  String get interestMovies;

  /// No description provided for @interestArt.
  ///
  /// In fr, this message translates to:
  /// **'Art'**
  String get interestArt;

  /// No description provided for @interestBusiness.
  ///
  /// In fr, this message translates to:
  /// **'Business'**
  String get interestBusiness;

  /// No description provided for @petName.
  ///
  /// In fr, this message translates to:
  /// **'Tuco'**
  String get petName;

  /// No description provided for @shopComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get shopComingSoon;

  /// No description provided for @shopCtaBackground.
  ///
  /// In fr, this message translates to:
  /// **'Changer le décor'**
  String get shopCtaBackground;

  /// No description provided for @shopCtaHat.
  ///
  /// In fr, this message translates to:
  /// **'Acheter un chapeau'**
  String get shopCtaHat;

  /// No description provided for @shopCtaGlass.
  ///
  /// In fr, this message translates to:
  /// **'Acheter des lunettes'**
  String get shopCtaGlass;

  /// No description provided for @shopCtaScarf.
  ///
  /// In fr, this message translates to:
  /// **'Acheter une écharpe'**
  String get shopCtaScarf;

  /// No description provided for @shopCtaColor.
  ///
  /// In fr, this message translates to:
  /// **'Changer la couleur'**
  String get shopCtaColor;

  /// No description provided for @readyToContinue.
  ///
  /// In fr, this message translates to:
  /// **'Es-tu prêt(e) à continuer ?'**
  String get readyToContinue;

  /// No description provided for @continueButton.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueButton;

  /// No description provided for @onboardingContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get onboardingContinue;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Apprends l\'espagnol en parlant'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'De vraies conversations avec Tuco, ton compagnon IA.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingWelcomeCta.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get onboardingWelcomeCta;

  /// No description provided for @onboardingWelcomeJoin.
  ///
  /// In fr, this message translates to:
  /// **'Rejoins des milliers d\'apprenants qui parlent avec Tuco'**
  String get onboardingWelcomeJoin;

  /// No description provided for @onboardingAlreadyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Tu as déjà un compte ? '**
  String get onboardingAlreadyAccount;

  /// No description provided for @onboardingSignInLink.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get onboardingSignInLink;

  /// No description provided for @onboardingMeetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rencontre Tuco, ton nouveau compagnon'**
  String get onboardingMeetTitle;

  /// No description provided for @onboardingMeetSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Tuco t\'appellera chaque jour pour pratiquer de vraies conversations.'**
  String get onboardingMeetSubtitle;

  /// No description provided for @onboardingLanguageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quelle langue veux-tu apprendre ?'**
  String get onboardingLanguageTitle;

  /// No description provided for @onboardingLanguageEs.
  ///
  /// In fr, this message translates to:
  /// **'Espagnol'**
  String get onboardingLanguageEs;

  /// No description provided for @onboardingLanguageEn.
  ///
  /// In fr, this message translates to:
  /// **'Anglais'**
  String get onboardingLanguageEn;

  /// No description provided for @onboardingLanguageFr.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get onboardingLanguageFr;

  /// No description provided for @onboardingLevelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quel est ton niveau d\'espagnol ?'**
  String get onboardingLevelTitle;

  /// No description provided for @onboardingLevelSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Nous adapterons l\'expérience à ton profil.'**
  String get onboardingLevelSubtitle;

  /// No description provided for @onboardingLevelNew.
  ///
  /// In fr, this message translates to:
  /// **'Je débute en espagnol'**
  String get onboardingLevelNew;

  /// No description provided for @onboardingLevelSomeWords.
  ///
  /// In fr, this message translates to:
  /// **'Je connais quelques mots courants'**
  String get onboardingLevelSomeWords;

  /// No description provided for @onboardingLevelBasic.
  ///
  /// In fr, this message translates to:
  /// **'Je peux tenir des conversations simples'**
  String get onboardingLevelBasic;

  /// No description provided for @onboardingLevelVarious.
  ///
  /// In fr, this message translates to:
  /// **'Je peux parler de sujets variés'**
  String get onboardingLevelVarious;

  /// No description provided for @onboardingLevelDetailed.
  ///
  /// In fr, this message translates to:
  /// **'Je peux discuter de la plupart des sujets en détail'**
  String get onboardingLevelDetailed;

  /// No description provided for @onboardingChallengesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quels sont tes principaux défis ?'**
  String get onboardingChallengesTitle;

  /// No description provided for @onboardingMultiSelectHint.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionne tout ce qui s\'applique.'**
  String get onboardingMultiSelectHint;

  /// No description provided for @onboardingChallengeSpeaking.
  ///
  /// In fr, this message translates to:
  /// **'Je me bloque quand je dois parler'**
  String get onboardingChallengeSpeaking;

  /// No description provided for @onboardingChallengeVocabulary.
  ///
  /// In fr, this message translates to:
  /// **'Je manque de vocabulaire'**
  String get onboardingChallengeVocabulary;

  /// No description provided for @onboardingChallengeConsistency.
  ///
  /// In fr, this message translates to:
  /// **'Je n\'arrive pas à être régulier(ère)'**
  String get onboardingChallengeConsistency;

  /// No description provided for @onboardingChallengeConfidence.
  ///
  /// In fr, this message translates to:
  /// **'Je manque de confiance'**
  String get onboardingChallengeConfidence;

  /// No description provided for @onboardingChallengeListening.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai du mal à comprendre les natifs'**
  String get onboardingChallengeListening;

  /// No description provided for @onboardingChallengeOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get onboardingChallengeOther;

  /// No description provided for @onboardingEducation1Title.
  ///
  /// In fr, this message translates to:
  /// **'Tuco crée des résultats durables'**
  String get onboardingEducation1Title;

  /// No description provided for @onboardingEducation1Subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Notre méthode s\'appuie sur la science de l\'apprentissage.'**
  String get onboardingEducation1Subtitle;

  /// No description provided for @onboardingChartTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ta progression en espagnol'**
  String get onboardingChartTitle;

  /// No description provided for @onboardingChartTraditional.
  ///
  /// In fr, this message translates to:
  /// **'Traditionnel'**
  String get onboardingChartTraditional;

  /// No description provided for @onboardingChartMonth1.
  ///
  /// In fr, this message translates to:
  /// **'Mois 1'**
  String get onboardingChartMonth1;

  /// No description provided for @onboardingChartMonth12.
  ///
  /// In fr, this message translates to:
  /// **'Mois 12'**
  String get onboardingChartMonth12;

  /// No description provided for @onboardingChartCaption.
  ///
  /// In fr, this message translates to:
  /// **'Parler chaque jour construit des compétences qui restent, même des mois plus tard.'**
  String get onboardingChartCaption;

  /// No description provided for @onboardingInterestsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quels sont tes centres d\'intérêt ?'**
  String get onboardingInterestsTitle;

  /// No description provided for @onboardingInterestTravel.
  ///
  /// In fr, this message translates to:
  /// **'Voyages'**
  String get onboardingInterestTravel;

  /// No description provided for @onboardingInterestFood.
  ///
  /// In fr, this message translates to:
  /// **'Cuisine'**
  String get onboardingInterestFood;

  /// No description provided for @onboardingInterestTechnology.
  ///
  /// In fr, this message translates to:
  /// **'Technologie'**
  String get onboardingInterestTechnology;

  /// No description provided for @onboardingInterestSport.
  ///
  /// In fr, this message translates to:
  /// **'Sport'**
  String get onboardingInterestSport;

  /// No description provided for @onboardingInterestCulture.
  ///
  /// In fr, this message translates to:
  /// **'Culture'**
  String get onboardingInterestCulture;

  /// No description provided for @onboardingInterestBusiness.
  ///
  /// In fr, this message translates to:
  /// **'Business'**
  String get onboardingInterestBusiness;

  /// No description provided for @onboardingFluencyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quand veux-tu parler couramment espagnol ?'**
  String get onboardingFluencyTitle;

  /// No description provided for @onboardingFluencySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Fixe ton objectif. Restons réalistes.'**
  String get onboardingFluencySubtitle;

  /// No description provided for @onboardingFluencyChip.
  ///
  /// In fr, this message translates to:
  /// **'🇪🇸 Courant d\'ici {date} !'**
  String onboardingFluencyChip(String date);

  /// No description provided for @onboardingFluencyUnit.
  ///
  /// In fr, this message translates to:
  /// **'mois'**
  String get onboardingFluencyUnit;

  /// No description provided for @onboardingMinutesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Combien de temps peux-tu pratiquer par jour ?'**
  String get onboardingMinutesTitle;

  /// No description provided for @onboardingMinutesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'La régularité compte. Même 5 minutes par jour donnent des résultats.'**
  String get onboardingMinutesSubtitle;

  /// No description provided for @onboardingMinutesChip.
  ///
  /// In fr, this message translates to:
  /// **'🦜 Apprends ~{words} mots chaque mois'**
  String onboardingMinutesChip(int words);

  /// No description provided for @onboardingMinutesValue.
  ///
  /// In fr, this message translates to:
  /// **'{minutes} minutes'**
  String onboardingMinutesValue(int minutes);

  /// No description provided for @onboardingRecommended.
  ///
  /// In fr, this message translates to:
  /// **'Recommandé'**
  String get onboardingRecommended;

  /// No description provided for @onboardingEducation2Title.
  ///
  /// In fr, this message translates to:
  /// **'Progresse deux fois plus vite avec Tuco'**
  String get onboardingEducation2Title;

  /// No description provided for @onboardingEducation2Subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Apprends les langues 2,7x plus vite grâce à de vraies conversations.'**
  String get onboardingEducation2Subtitle;

  /// No description provided for @onboardingCompareOthers.
  ///
  /// In fr, this message translates to:
  /// **'Autres apps'**
  String get onboardingCompareOthers;

  /// No description provided for @onboardingCompareTuco.
  ///
  /// In fr, this message translates to:
  /// **'Avec Tuco'**
  String get onboardingCompareTuco;

  /// No description provided for @onboardingTimeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quand veux-tu pratiquer ?'**
  String get onboardingTimeTitle;

  /// No description provided for @onboardingTimeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Tuco t\'appellera au moment parfait.'**
  String get onboardingTimeSubtitle;

  /// No description provided for @onboardingNotifTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ne rate plus jamais ta leçon d\'espagnol'**
  String get onboardingNotifTitle;

  /// No description provided for @onboardingNotifSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'86 % des utilisateurs atteignent leurs objectifs grâce aux rappels quotidiens.'**
  String get onboardingNotifSubtitle;

  /// No description provided for @onboardingNotifAllow.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser les notifications'**
  String get onboardingNotifAllow;

  /// No description provided for @onboardingNotifLater.
  ///
  /// In fr, this message translates to:
  /// **'Pas maintenant'**
  String get onboardingNotifLater;

  /// No description provided for @onboardingRatingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Donne-nous une note'**
  String get onboardingRatingTitle;

  /// No description provided for @onboardingRatingCount.
  ///
  /// In fr, this message translates to:
  /// **'notes sur l\'App Store'**
  String get onboardingRatingCount;

  /// No description provided for @onboardingRatingMadeForYou.
  ///
  /// In fr, this message translates to:
  /// **'Tuco a été créé pour des gens comme toi'**
  String get onboardingRatingMadeForYou;

  /// No description provided for @onboardingRatingUsers.
  ///
  /// In fr, this message translates to:
  /// **'Des milliers d\'apprenants pratiquent avec Tuco'**
  String get onboardingRatingUsers;

  /// No description provided for @onboardingReview1Name.
  ///
  /// In fr, this message translates to:
  /// **'Rita Y.'**
  String get onboardingReview1Name;

  /// No description provided for @onboardingReview1Text.
  ///
  /// In fr, this message translates to:
  /// **'Je connaissais plein de vocabulaire mais je me bloquais dès que je devais parler. Parler avec Tuco chaque jour m\'a donné confiance pour discuter avec des natifs.'**
  String get onboardingReview1Text;

  /// No description provided for @onboardingReview2Name.
  ///
  /// In fr, this message translates to:
  /// **'Marc D.'**
  String get onboardingReview2Name;

  /// No description provided for @onboardingReview2Text.
  ///
  /// In fr, this message translates to:
  /// **'5 minutes par jour sur le trajet du travail. Après 3 mois, je tenais une vraie conversation lors de mon voyage à Madrid.'**
  String get onboardingReview2Text;

  /// No description provided for @onboardingLoadingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Création de ton plan...'**
  String get onboardingLoadingTitle;

  /// No description provided for @onboardingLoadingStep1.
  ///
  /// In fr, this message translates to:
  /// **'Analyse de ton niveau...'**
  String get onboardingLoadingStep1;

  /// No description provided for @onboardingLoadingStep2.
  ///
  /// In fr, this message translates to:
  /// **'Sélection de tes sujets...'**
  String get onboardingLoadingStep2;

  /// No description provided for @onboardingLoadingStep3.
  ///
  /// In fr, this message translates to:
  /// **'Construction de ton plan quotidien...'**
  String get onboardingLoadingStep3;

  /// No description provided for @onboardingPlanTitle.
  ///
  /// In fr, this message translates to:
  /// **'Félicitations !\nTon plan personnalisé est prêt'**
  String get onboardingPlanTitle;

  /// No description provided for @onboardingPlanDailyRecommendation.
  ///
  /// In fr, this message translates to:
  /// **'Recommandation quotidienne'**
  String get onboardingPlanDailyRecommendation;

  /// No description provided for @onboardingPlanStayConsistent.
  ///
  /// In fr, this message translates to:
  /// **'Reste régulier(ère) pour atteindre tes objectifs'**
  String get onboardingPlanStayConsistent;

  /// No description provided for @onboardingPlanStatSpeaking.
  ///
  /// In fr, this message translates to:
  /// **'Expression orale'**
  String get onboardingPlanStatSpeaking;

  /// No description provided for @onboardingPlanStatWords.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux mots'**
  String get onboardingPlanStatWords;

  /// No description provided for @onboardingPlanStatCall.
  ///
  /// In fr, this message translates to:
  /// **'Appel avec Tuco'**
  String get onboardingPlanStatCall;

  /// No description provided for @onboardingPlanTileLessons.
  ///
  /// In fr, this message translates to:
  /// **'{lessons} leçons chargées'**
  String onboardingPlanTileLessons(int lessons);

  /// No description provided for @onboardingPlanTileFluent.
  ///
  /// In fr, this message translates to:
  /// **'Courant d\'ici {date}'**
  String onboardingPlanTileFluent(String date);

  /// No description provided for @onboardingPlanTilePath.
  ///
  /// In fr, this message translates to:
  /// **'Parcours optimisé pour toi'**
  String get onboardingPlanTilePath;

  /// No description provided for @onboardingPlanTileMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{minutes} min/jour'**
  String onboardingPlanTileMinutes(int minutes);

  /// No description provided for @onboardingTrialTitle.
  ///
  /// In fr, this message translates to:
  /// **'On veut te faire essayer Tuco gratuitement'**
  String get onboardingTrialTitle;

  /// No description provided for @onboardingTrialSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Débloque ton plan complet avec un essai gratuit.'**
  String get onboardingTrialSubtitle;

  /// No description provided for @onboardingTrialPoint1.
  ///
  /// In fr, this message translates to:
  /// **'Accès complet à toutes les leçons et appels'**
  String get onboardingTrialPoint1;

  /// No description provided for @onboardingTrialPoint2.
  ///
  /// In fr, this message translates to:
  /// **'On te préviendra avant la fin de l\'essai'**
  String get onboardingTrialPoint2;

  /// No description provided for @onboardingTrialPoint3.
  ///
  /// In fr, this message translates to:
  /// **'Annulable à tout moment en deux clics'**
  String get onboardingTrialPoint3;

  /// No description provided for @onboardingSignInTitle.
  ///
  /// In fr, this message translates to:
  /// **'Finalisons ta configuration'**
  String get onboardingSignInTitle;

  /// No description provided for @onboardingSignInSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde ta progression et synchronise ton plan.'**
  String get onboardingSignInSubtitle;

  /// No description provided for @onboardingSignInApple.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter avec Apple'**
  String get onboardingSignInApple;

  /// No description provided for @onboardingSignInGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get onboardingSignInGoogle;

  /// No description provided for @onboardingSignInSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer pour l\'instant'**
  String get onboardingSignInSkip;

  /// No description provided for @onboardingSignInFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la connexion. Réessaie.'**
  String get onboardingSignInFailed;

  /// No description provided for @pronunciationSheetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prononciation'**
  String get pronunciationSheetTitle;

  /// No description provided for @pronunciationTapWordHint.
  ///
  /// In fr, this message translates to:
  /// **'Appuie sur un mot pour t\'entraîner.'**
  String get pronunciationTapWordHint;

  /// No description provided for @nativeSpeakerScore.
  ///
  /// In fr, this message translates to:
  /// **'Tu parles comme un natif à {score}% !'**
  String nativeSpeakerScore(int score);

  /// No description provided for @tryAgainButton.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer !'**
  String get tryAgainButton;

  /// No description provided for @stopRecordingButton.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter'**
  String get stopRecordingButton;

  /// No description provided for @pronAccuracy.
  ///
  /// In fr, this message translates to:
  /// **'Précision'**
  String get pronAccuracy;

  /// No description provided for @pronFluency.
  ///
  /// In fr, this message translates to:
  /// **'Fluidité'**
  String get pronFluency;

  /// No description provided for @pronProsody.
  ///
  /// In fr, this message translates to:
  /// **'Prosodie'**
  String get pronProsody;

  /// No description provided for @pronCompleteness.
  ///
  /// In fr, this message translates to:
  /// **'Complétude'**
  String get pronCompleteness;

  /// No description provided for @pronPronunciation.
  ///
  /// In fr, this message translates to:
  /// **'Prononciation'**
  String get pronPronunciation;

  /// No description provided for @pronRhythm.
  ///
  /// In fr, this message translates to:
  /// **'Rythme'**
  String get pronRhythm;

  /// No description provided for @pronExampleButton.
  ///
  /// In fr, this message translates to:
  /// **'Exemple'**
  String get pronExampleButton;

  /// No description provided for @pronListenButton.
  ///
  /// In fr, this message translates to:
  /// **'Écouter'**
  String get pronListenButton;

  /// No description provided for @pronBandExcellent.
  ///
  /// In fr, this message translates to:
  /// **'Excellent !'**
  String get pronBandExcellent;

  /// No description provided for @pronBandAlmost.
  ///
  /// In fr, this message translates to:
  /// **'Presque correct'**
  String get pronBandAlmost;

  /// No description provided for @pronBandIncorrect.
  ///
  /// In fr, this message translates to:
  /// **'Continue à t\'entraîner'**
  String get pronBandIncorrect;

  /// No description provided for @pronStatusExcellent.
  ///
  /// In fr, this message translates to:
  /// **'Excellent'**
  String get pronStatusExcellent;

  /// No description provided for @pronStatusAlmost.
  ///
  /// In fr, this message translates to:
  /// **'Presque'**
  String get pronStatusAlmost;

  /// No description provided for @pronStatusIncorrect.
  ///
  /// In fr, this message translates to:
  /// **'Incorrect'**
  String get pronStatusIncorrect;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
