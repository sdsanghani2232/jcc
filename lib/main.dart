import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jcc/bloc/auth/auth_bloc.dart';
import 'package:jcc/bloc/complaint/complaint_bloc.dart';
import 'package:jcc/bloc/complaint/register/complaint_register_bloc.dart';
import 'package:jcc/bloc/complaint/stats/complaint_stats_bloc.dart';
import 'package:jcc/bloc/login/login_bloc.dart';
import 'package:jcc/bloc/notification/notification_bloc.dart';
import 'package:jcc/bloc/user/register/user_register_bloc.dart';
import 'package:jcc/config/router.dart';
import 'package:jcc/firebase_options.dart';
import 'package:jcc/repositories/auth/auth_repository.dart';
import 'package:jcc/repositories/complaint_repository.dart';
import 'package:jcc/repositories/notification_repository.dart';
import 'package:jcc/repositories/user_repository.dart';
import 'package:jcc/theme/app_theme.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:jcc/config/onesignal_config.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer' as dev;

import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // OneSignal.Notifications.clearAll();
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(OneSignalConfig.oneSignalAppId);
  OneSignal.Notifications.requestPermission(true);
  dev.log("${OneSignal.Notifications.permission}",
      name: 'Notification Permissions ');

  // dev.log(OneSignal.User.pushSubscription.token);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final complaintRepository = ComplaintRepository();
    final userRepository = UserRepository();
    final notificationRepository = NotificationRepository();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
          AuthBloc(authRepository: AuthRepository())..add(AppStarted()),
        ),
        BlocProvider(
          create: (context) => LogInBloc(authRepository: AuthRepository()),
        ),
        BlocProvider(
          create: (context) =>
          ComplaintBloc(complaintRepository: complaintRepository)
            ..add(LoadComplaint()),
        ),
        BlocProvider(
          create: (context) => UserRegisterBloc(userRepository: userRepository),
        ),
        BlocProvider(
          create: (context) =>
          NotificationBloc(notificationRepository: notificationRepository)
            ..add(LoadNotifications()),
        ),
        BlocProvider(
          create: (context) => ComplaintRegisterBloc(
            complaintRepository: complaintRepository,
            notificationRepository: notificationRepository,
          ),
        ),
        BlocProvider(
          create: (context) =>
          ComplaintStatsBloc(complaintRepository: complaintRepository)
            ..add(GetComplaintStats()),
        ),
      ],
      child: FutureBuilder<String>(
        future: _getLocaleFromPreferences(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MaterialApp.router(
              theme: AppTheme.getTheme(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale(snapshot.data as String, ''),
              routerConfig: router,
            );
          } else {
            return MaterialApp.router(
              theme: AppTheme.getTheme(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('en', ''),
              routerConfig: router,
            );
          }
        },
      ),
    );
  }
  Future<String> _getLocaleFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('selected_language') ?? 'en'; // Default to English
    return languageCode;
  }
}

//MaterialApp.router(
//         theme: AppTheme.getTheme(),
//         routerConfig: router,
//         localizationsDelegates: AppLocalizations.localizationsDelegates,
//         supportedLocales: AppLocalizations.supportedLocales,
//         locale: Locale(_getLocaleFromPreferences() as String, ''),
//       ),