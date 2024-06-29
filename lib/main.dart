import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flixstar/common/update_screen.dart';
import 'package:flixstar/core/const/const.dart';
import 'package:flixstar/features/history/presentation/bloc/history_bloc.dart';
import 'package:flixstar/features/home/presentation/bloc/home_bloc.dart';
import 'package:flixstar/features/library/presentation/bloc/library_bloc.dart';
import 'package:flixstar/features/search/presentation/bloc/search_bloc.dart';
import 'package:flixstar/firebase_options.dart';
import 'package:flixstar/injection_container.dart';
import 'package:flixstar/core/utils/theme_data.dart';
import 'package:flixstar/features/home/presentation/pages/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:startapp_sdk/startapp.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await fetchFirebaseData();
  await checkForNewUpdate();

  await Hive.initFlutter();
  await Future.wait([
    sl<StartAppSdk>().setTestAdsEnabled(false),
    Hive.openBox('library'),
    Hive.openBox('settings'),
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]);

  if (isUpdateAvailable) {
    runApp(UpdateWarningScreen());
  } else {
    runApp(App());
  }
}

Future<void> checkForNewUpdate() async {
  final dio = sl<Dio>();
  const url =
      'https://api.github.com/repos/godstark82/flixstar/releases/latest';
  final response = await dio.get(url);
  final packageInfo = await PackageInfo.fromPlatform();
  print('latest Version: ${response.data['tag_name']}');
  final String cloudVersion = response.data['tag_name'];
  final String localVersion = 'v${packageInfo.version}';
  if (cloudVersion == localVersion) {
    return;
  } else {
    isUpdateAvailable = true;
  }
}

Future<void> fetchFirebaseData() async {
  try {
    final db = FirebaseFirestore.instance;
    final ref = await db.collection('config').doc('settings').get();
    final settings = ref.data();
    log(settings.toString());
    bool _streamMode = settings?['streamMode'] ?? false;
    bool _showAds = settings?['showAds'] ?? false;
    bool _forceUpdate = settings?['forceUpdate'] ?? false;
    streamMode = _streamMode;
    showAds = _showAds;
    forceUpdate = _forceUpdate;
  } catch (e) {
    debugPrint(e.toString());
    rethrow;
  }
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<HomeBloc>(create: (context) => sl<HomeBloc>()),
          BlocProvider(create: (context) => LibraryBloc()), // Library Bloc
          BlocProvider(create: (context) => HistoryBloc(sl())), // Episode Bloc
          BlocProvider(create: (context) => SearchBloc()), // History Bloc
        ],
        child: GetMaterialApp(
          title: 'FlixStar',
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: Home(),
        ));
  }
}
