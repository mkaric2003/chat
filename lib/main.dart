// ignore_for_file: use_key_in_widget_constructors, unnecessary_this, prefer_const_constructors

import 'package:chat/allCostants/app_costants.dart';
import 'package:chat/allProviders/auth_provider.dart';
import 'package:chat/allProviders/home_provider.dart';
import 'package:chat/allProviders/settings_provider.dart';
import 'package:chat/allScreens/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isWhite = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  MyApp({required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            firebaseAuth: FirebaseAuth.instance,
            googleSignIn: GoogleSignIn(),
            prefs: this.prefs,
            firebaseFirestore: this.firebaseFirestore,
          ),
        ),
        Provider<SettingProvider>(
          create: (context) => SettingProvider(
              firebaseFirestore: this.firebaseFirestore,
              firebaseStorage: this.firebaseStorage,
              prefs: this.prefs),
        ),
        Provider<HomeProvider>(
          create: (context) =>
              HomeProvider(firebaseFirestore: this.firebaseFirestore),
        )
      ],
      child: MaterialApp(
        title: AppConstants.appTitle,
        theme: ThemeData(
          primaryColor: Colors.black,
        ),
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
