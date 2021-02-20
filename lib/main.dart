import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rider/brand_colors.dart';
import 'package:rider/screens/main_page.dart';
import 'package:rider/constants/constants.dart';
import 'package:rider/screens/login_page.dart';
import 'package:rider/screens/registration_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp(
    name: 'app',
    options: FirebaseOptions(
      appId: APP_ID,
      apiKey: API_KEY,
      messagingSenderId: '297855924061',
      projectId: PROJECT_ID,
      databaseURL: FIREBASE_DATABASE,
    ),
  );

  runApp(MaterialApp(
    title: 'Flutter Database Example',
    initialRoute: MainPage.id,
    routes: {
      RegistrationPage.id: (context) => RegistrationPage(),
      LoginPage.id: (context) => LoginPage(),
      MainPage.id: (context) => MainPage()
    },
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Brand-Regular',
        primarySwatch: BrandColors.colorGreen,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
    );
  }
}
