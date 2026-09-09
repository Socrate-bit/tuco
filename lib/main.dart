import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app/onboarding_gate.dart';
import 'core/l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'core/service/analytics_service.dart';
import 'core/service/data_repository.dart';
import 'core/cubit/connectivity_cubit.dart';
import 'core/theme/app_theme.dart';
import 'features/consent/cubit/ai_consent_cubit.dart';
import 'features/consent/service/ai_consent_service.dart';
import 'features/feedback/cubit/feedback_cubit.dart';
import 'features/game/cubit/game_cubit.dart';
import 'features/game/cubit/shop_cubit.dart';
import 'features/home/cubit/path_cubit.dart';
import 'features/onboarding/cubit/onboarding_cubit.dart';
import 'features/profile/cubit/profile_cubit.dart';
import 'features/subscription/cubit/subscription_cubit.dart';
import 'features/subscription/service/superwall_service.dart';
import 'features/progression/cubit/stats_cubit.dart';
import 'features/vocabulary/cubit/vocab_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait orientation.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Firebase is optional until the project is configured (flutterfire configure).
  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    // App Check protects the Firebase AI Logic (Gemini) backend. Debug builds use
    // the debug provider (register the printed token in the console); release
    // builds attest with App Attest. Must run before any protected Firebase call.
    await FirebaseAppCheck.instance.activate(
      providerApple: kDebugMode
          ? const AppleDebugProvider()
          : const AppleAppAttestProvider(),
    );
    // Only when nobody is signed in: signing in anonymously would otherwise
    // replace a real account (the review sign-in) on every relaunch.
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    firebaseReady = true;
    debugPrint('[Main] Firebase initialized, App Check active, '
        'session ready (${FirebaseAuth.instance.currentUser?.isAnonymous ?? false ? 'anonymous' : 'account'})');
  } catch (e) {
    debugPrint('[Main] Firebase unavailable, using in-memory store: $e');
  }

  final analytics = AnalyticsService();
  await analytics.init();

  // Paywall SDK (no-op without a SUPERWALL_KEY dart-define).
  SuperwallService.configure();

  // Skip the funnel for users who already completed it.
  final onboardingDone = await OnboardingCubit.readCompletedFlag();

  // Read the AI consent decision before the first frame, so the gate is
  // accurate on the very first request. Users updating from a build without
  // this screen start at "not granted" and are asked before their next AI call.
  await AiConsentService.load();

  runApp(TucoApp(
    repository: DataRepository(useFirestore: firebaseReady),
    analytics: analytics,
    onboardingDone: onboardingDone,
  ));
}

class TucoApp extends StatelessWidget {
  final DataRepository repository;
  final AnalyticsService analytics;
  final bool onboardingDone;

  const TucoApp({
    super.key,
    required this.repository,
    required this.analytics,
    required this.onboardingDone,
  });

  // Maps the teaching-language code to a locale the app has translations for.
  static String _supportedCode(String code) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == code)
          ? code
          : 'en';

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: repository),
        RepositoryProvider.value(value: analytics),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ConnectivityCubit()),
          BlocProvider(create: (_) => ProfileCubit(repository)),
          BlocProvider(create: (_) => PathCubit(repository)),
          BlocProvider(create: (_) => StatsCubit(repository)),
          BlocProvider(create: (_) => VocabCubit(repository)),
          BlocProvider(create: (_) => FeedbackCubit(repository)),
          BlocProvider(create: (_) => GameCubit(repository)),
          BlocProvider(create: (_) => ShopCubit()),
          BlocProvider(
              create: (_) => OnboardingCubit(repository, analytics,
                  alreadyComplete: onboardingDone)),
          BlocProvider(create: (_) => SubscriptionCubit(analytics)),
          BlocProvider(create: (_) => AiConsentCubit(analytics)),
        ],
        child: ScreenUtilInit(
          designSize: const Size(414, 896),
          minTextAdapt: true,
          builder: (context, _) => MaterialApp(
            title: 'Tuco',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            // App language follows the "Langue d'enseignement" picker;
            // languages without a translation fall back to English.
            locale: Locale(_supportedCode(
                context.watch<ProfileCubit>().state.nativeLanguage)),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const OnboardingGate(),
          ),
        ),
      ),
    );
  }
}
