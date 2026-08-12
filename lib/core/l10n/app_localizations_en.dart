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
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageSpanishName => 'Spanish';

  @override
  String get languageEnglishName => 'English';

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
}
