// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Tuco';

  @override
  String get tabHome => 'Home';

  @override
  String get tabProgress => 'Progress';

  @override
  String get tabProfile => 'Profile';

  @override
  String get exchange => 'Call';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String get stepLesson => 'Lesson';

  @override
  String get stepPractice => 'Practice';

  @override
  String get courseBanner => 'Course';

  @override
  String get practiceBanner => 'Practice';

  @override
  String get courseDoneBanner => 'Course complete!';

  @override
  String get yourTurn => 'Your turn!';

  @override
  String get typeButton => 'Type';

  @override
  String get inspirationButton => 'Inspiration';

  @override
  String get clearButton => 'Delete';

  @override
  String get replyHere => 'Reply here';

  @override
  String get inspirationTitle => 'Some example sentences:';

  @override
  String get quitCallTitle => 'Are you sure?';

  @override
  String get quitCallBody =>
      'You won\'t receive an evaluation report if you don\'t finish this session.';

  @override
  String get resumeCall => 'Resume the call';

  @override
  String get quitCall => 'Quit the call';

  @override
  String get endSubtitle => 'Well done, you rock! Mastery is within reach!';

  @override
  String get newWordsCard => 'New Words';

  @override
  String get lessonsDoneCard => 'Lessons Completed';

  @override
  String get lessonDurationCard => 'Lesson time';

  @override
  String get nextLessonButton => 'Go to the next lesson';

  @override
  String get backHomeButton => 'Back to the home page';

  @override
  String get streakDays => 'day streak';

  @override
  String get streakHelper => 'Take a lesson every day to keep your streak!';

  @override
  String get understood => 'Got it!';

  @override
  String get streakTitle => 'Streak';

  @override
  String get longestStreak => 'Longest streak';

  @override
  String get monthTraining => 'Practice this month';

  @override
  String get continueLearning => 'Continue learning';

  @override
  String get feedbackCenter => 'Feedback center';

  @override
  String get grammar => 'Grammar';

  @override
  String get alternatives => 'Alternatives';

  @override
  String get times => 'times';

  @override
  String get vocabExercise => 'Vocabulary exercise';

  @override
  String get newWordsLabel => 'New words';

  @override
  String get upcomingWordsLabel => 'Upcoming words';

  @override
  String get yourStreak => 'Your streak';

  @override
  String get dailyStreak => 'Daily streak';

  @override
  String nextMilestone(int days) {
    return 'Next badge: $days days';
  }

  @override
  String get allMilestonesEarned => 'All badges earned!';

  @override
  String get milestonesTitle => 'Streak badges';

  @override
  String milestonesEarnedCount(int earned, int total) {
    return '$earned / $total badges earned';
  }

  @override
  String milestoneDays(int days) {
    return '$days days';
  }

  @override
  String get badgeRisen => 'Risen';

  @override
  String get badgeIgnite => 'Ignite';

  @override
  String get badgeHorizon => 'Horizon';

  @override
  String get badgeAurora => 'Aurora';

  @override
  String get badgeCelestial => 'Celestial';

  @override
  String get badgeNebula => 'Nebula';

  @override
  String get badgeEternal => 'Eternal';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'ACCOUNT';

  @override
  String get settingsUserType => 'User type';

  @override
  String get settingsUserTypeFree => 'Free';

  @override
  String get settingsCopyUserId => 'Copy user ID';

  @override
  String get settingsUserIdCopied => 'User ID copied';

  @override
  String get settingsAbout => 'ABOUT';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsTermsOfService => 'Terms of service';

  @override
  String get settingsDangerZone => 'DANGER ZONE';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteAccountTitle => 'Delete account?';

  @override
  String get settingsDeleteAccountBody =>
      'This will permanently delete all your data (progress, vocabulary, call history, streaks). This cannot be undone.';

  @override
  String get settingsDeleteAccountConfirm => 'Delete';

  @override
  String get settingsDeleteAccountCancel => 'Cancel';

  @override
  String get settingsDeleteAccountDone => 'Your account data has been deleted';

  @override
  String get settingsDeleteAccountError =>
      'Could not delete your data. Please try again.';

  @override
  String get callTimeTitle => 'Time spent on calls';

  @override
  String get timeSpent => 'Time spent';

  @override
  String get average => 'Average';

  @override
  String get goal => 'Goal';

  @override
  String get callHistory => 'Call history';

  @override
  String get showAll => 'Show all';

  @override
  String get freeConversation => 'Free Conversation';

  @override
  String get learnedTab => 'Learned';

  @override
  String get upcomingTab => 'Upcoming';

  @override
  String get filterAll => 'All';

  @override
  String get scoreExcellent => 'Excellent';

  @override
  String get scoreCanDoBetter => 'Can Do Better';

  @override
  String get scoreNeedsImprovement => 'Improvements are needed!';

  @override
  String scoreLabel(int score, String label) {
    return 'Score: $score | $label';
  }

  @override
  String get noErrorsHere =>
      'No errors here! You can tap the feedback button in the lesson to check your mistakes.';

  @override
  String get learningLanguage => 'Learning language';

  @override
  String get teachingLanguage => 'Teaching language';

  @override
  String get languageLevel => 'Language level';

  @override
  String get interests => 'Interests';

  @override
  String get dailyGoal => 'Daily goal';

  @override
  String get dailyReminder => 'Daily reminder';

  @override
  String get disabled => 'Disabled';

  @override
  String minPerDay(int minutes) {
    return '$minutes min/day';
  }

  @override
  String get save => 'Save';

  @override
  String get more => 'More...';

  @override
  String get reviewTitle => 'Thanks for using Tuco!';

  @override
  String get reviewBody =>
      'Do you like Tuco? Leave us a rating, it helps us a lot!';

  @override
  String get letsGo => 'Let\'s go!';

  @override
  String get maybeLater => 'Maybe later';

  @override
  String get skipLessonTitle =>
      'Are you sure you want to skip to this exercise?';

  @override
  String skipLessonBody(String language) {
    return 'Following your personalized path will boost your $language, but you can choose to jump straight to this exercise if you wish.';
  }

  @override
  String get followPath => 'Follow the path';

  @override
  String get goToExercise => 'Go to the exercise';

  @override
  String get resumeLessonTitle => 'Ready to pick up where you left off?';

  @override
  String get resumeLessonButton => 'Let\'s resume!';

  @override
  String get restartLessonButton => 'Restart from the beginning';

  @override
  String get exercisesSection => 'EXERCISES';

  @override
  String get wordsToPracticeSection => 'WORDS TO PRACTICE';

  @override
  String get lessonExercise => 'Lesson';

  @override
  String get practiceExercise => 'Exercise';

  @override
  String get wellUnderstood => 'Got it';

  @override
  String wordsChip(int count) {
    return '$count Words';
  }

  @override
  String grammarChip(int count) {
    return '$count Grammar';
  }

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNoInternet =>
      'No internet connection. Please connect and try again.';

  @override
  String get interestTechnology => 'Technology';

  @override
  String get interestTravel => 'Travel';

  @override
  String get interestCooking => 'Cooking';

  @override
  String get interestSports => 'Sports';

  @override
  String get interestMusic => 'Music';

  @override
  String get interestMovies => 'Movies';

  @override
  String get interestArt => 'Art';

  @override
  String get interestBusiness => 'Business';

  @override
  String get petName => 'Tuco';

  @override
  String get shopComingSoon => 'Coming soon';

  @override
  String get shopCtaBackground => 'Change background';

  @override
  String get shopCtaHat => 'Buy new hat';

  @override
  String get shopCtaGlass => 'Buy new glasses';

  @override
  String get shopCtaScarf => 'Buy new scarf';

  @override
  String get shopCtaColor => 'Change color';

  @override
  String get readyToContinue => 'Are you ready to continue?';

  @override
  String get continueButton => 'Continue';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingWelcomeTitle => 'Learn Spanish by talking';

  @override
  String get onboardingWelcomeSubtitle =>
      'Real conversations with Tuco, your AI companion.';

  @override
  String get onboardingWelcomeCta => 'Get started';

  @override
  String get onboardingWelcomeJoin =>
      'Join thousands of learners speaking with Tuco';

  @override
  String get onboardingAlreadyAccount => 'Already have an account? ';

  @override
  String get onboardingSignInLink => 'Sign in';

  @override
  String get onboardingMeetTitle => 'Meet Tuco, your new companion';

  @override
  String get onboardingMeetSubtitle =>
      'Tuco will call you every day to practice real conversations.';

  @override
  String get onboardingLanguageTitle => 'What language do you want to learn?';

  @override
  String get onboardingLanguageEs => 'Spanish';

  @override
  String get onboardingLanguageEn => 'English';

  @override
  String get onboardingLanguageFr => 'French';

  @override
  String get onboardingLevelTitle => 'What is your Spanish level?';

  @override
  String get onboardingLevelSubtitle =>
      'We\'ll use this to tailor the experience to you.';

  @override
  String get onboardingLevelNew => 'I\'m new to Spanish';

  @override
  String get onboardingLevelSomeWords => 'I know some common words';

  @override
  String get onboardingLevelBasic => 'I can have basic conversations';

  @override
  String get onboardingLevelVarious => 'I can talk about various topics';

  @override
  String get onboardingLevelDetailed => 'I can discuss most topics in detail';

  @override
  String get onboardingChallengesTitle => 'What are your main challenges?';

  @override
  String get onboardingMultiSelectHint => 'Select all that apply.';

  @override
  String get onboardingChallengeSpeaking => 'I freeze when I have to speak';

  @override
  String get onboardingChallengeVocabulary => 'I lack vocabulary';

  @override
  String get onboardingChallengeConsistency => 'I can\'t stay consistent';

  @override
  String get onboardingChallengeConfidence => 'I lack confidence';

  @override
  String get onboardingChallengeListening => 'I struggle to understand natives';

  @override
  String get onboardingChallengeOther => 'Other';

  @override
  String get onboardingEducation1Title => 'Tuco creates long-term results';

  @override
  String get onboardingEducation1Subtitle =>
      'Our method is backed by proven learning science.';

  @override
  String get onboardingChartTitle => 'Your Spanish progress';

  @override
  String get onboardingChartTraditional => 'Traditional';

  @override
  String get onboardingChartMonth1 => 'Month 1';

  @override
  String get onboardingChartMonth12 => 'Month 12';

  @override
  String get onboardingChartCaption =>
      'Speaking every day builds skills that stick, even months later.';

  @override
  String get onboardingInterestsTitle => 'What are your topics of interest?';

  @override
  String get onboardingInterestTravel => 'Travel';

  @override
  String get onboardingInterestFood => 'Food';

  @override
  String get onboardingInterestTechnology => 'Technology';

  @override
  String get onboardingInterestSport => 'Sport';

  @override
  String get onboardingInterestCulture => 'Culture';

  @override
  String get onboardingInterestBusiness => 'Business';

  @override
  String get onboardingFluencyTitle =>
      'When do you want to be fluent in Spanish?';

  @override
  String get onboardingFluencySubtitle =>
      'Set your fluency goal. Let\'s make it realistic.';

  @override
  String onboardingFluencyChip(String date) {
    return '🇪🇸 Fluent by $date!';
  }

  @override
  String get onboardingFluencyUnit => 'months';

  @override
  String get onboardingMinutesTitle =>
      'How much time can you practice each day?';

  @override
  String get onboardingMinutesSubtitle =>
      'Consistency matters. Even 5 minutes a day gets results.';

  @override
  String onboardingMinutesChip(int words) {
    return '🦜 Learn ~$words words each month';
  }

  @override
  String onboardingMinutesValue(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get onboardingRecommended => 'Recommended';

  @override
  String get onboardingEducation2Title =>
      'Make twice as much progress with Tuco';

  @override
  String get onboardingEducation2Subtitle =>
      'Learn new languages 2.7x faster with real conversations.';

  @override
  String get onboardingCompareOthers => 'Other apps';

  @override
  String get onboardingCompareTuco => 'With Tuco';

  @override
  String get onboardingTimeTitle => 'When do you want to practice?';

  @override
  String get onboardingTimeSubtitle =>
      'Tuco will call you at the perfect moment.';

  @override
  String get onboardingNotifTitle => 'Never miss a Spanish lesson again';

  @override
  String get onboardingNotifSubtitle =>
      '86% of users hit their goals with daily reminders.';

  @override
  String get onboardingNotifAllow => 'Allow notifications';

  @override
  String get onboardingNotifLater => 'Not now';

  @override
  String get onboardingRatingTitle => 'Give us a rating';

  @override
  String get onboardingRatingCount => 'App Store ratings';

  @override
  String get onboardingRatingMadeForYou => 'Tuco was made for people like you';

  @override
  String get onboardingRatingUsers =>
      'Thousands of learners practice with Tuco';

  @override
  String get onboardingReview1Name => 'Rita Y.';

  @override
  String get onboardingReview1Text =>
      'I knew tons of vocab but froze every time I tried to speak. Talking with Tuco every day gave me the confidence to actually chat with natives.';

  @override
  String get onboardingReview2Name => 'Marc D.';

  @override
  String get onboardingReview2Text =>
      '5 minutes a day on my way to work. After 3 months I could hold a real conversation on my trip to Madrid.';

  @override
  String get onboardingLoadingTitle => 'Making your plan...';

  @override
  String get onboardingLoadingStep1 => 'Analyzing your level...';

  @override
  String get onboardingLoadingStep2 => 'Picking your topics...';

  @override
  String get onboardingLoadingStep3 => 'Building your daily plan...';

  @override
  String get onboardingPlanTitle =>
      'Congratulations!\nYour custom plan is ready';

  @override
  String get onboardingPlanDailyRecommendation => 'Daily recommendation';

  @override
  String get onboardingPlanStayConsistent =>
      'Stay consistent to reach your goals';

  @override
  String get onboardingPlanStatSpeaking => 'Speaking';

  @override
  String get onboardingPlanStatWords => 'New words';

  @override
  String get onboardingPlanStatCall => 'Call with Tuco';

  @override
  String onboardingPlanTileLessons(int lessons) {
    return '$lessons lessons loaded';
  }

  @override
  String onboardingPlanTileFluent(String date) {
    return 'Fluent by $date';
  }

  @override
  String get onboardingPlanTilePath => 'Path optimised for you';

  @override
  String onboardingPlanTileMinutes(int minutes) {
    return '$minutes min/day';
  }

  @override
  String get onboardingTrialTitle => 'We want you to try Tuco for free';

  @override
  String get onboardingTrialSubtitle =>
      'Unlock your full plan with a free trial.';

  @override
  String get onboardingTrialPoint1 => 'Full access to every lesson and call';

  @override
  String get onboardingTrialPoint2 => 'We\'ll remind you before the trial ends';

  @override
  String get onboardingTrialPoint3 => 'Cancel anytime in two taps';

  @override
  String get onboardingSignInTitle => 'Let\'s finish your set-up';

  @override
  String get onboardingSignInSubtitle =>
      'Save your progress and sync your plan.';

  @override
  String get onboardingSignInApple => 'Sign in with Apple';

  @override
  String get onboardingSignInGoogle => 'Continue with Google';

  @override
  String get onboardingSignInSkip => 'Skip for now';

  @override
  String get onboardingSignInFailed => 'Sign-in failed. Please try again.';
}
