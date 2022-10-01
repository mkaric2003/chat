// ignore_for_file: use_key_in_widget_constructors, override_on_non_overriding_member, annotate_overrides, implementation_imports, prefer_const_constructors, sized_box_for_whitespace

import 'package:chat/allCostants/constants.dart';
import 'package:chat/allProviders/auth_provider.dart';
import 'package:chat/allScreens/home_screen.dart';
import 'package:chat/allScreens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      checkSignedIn();
    });
  }

  void checkSignedIn() async {
    AuthProvider authProvider = context.read<AuthProvider>();
    bool isLoggedIn = await authProvider.isLoggedIn();
    if (isLoggedIn) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
      return;
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              "images/splash.png",
              width: 300,
              height: 300,
            ),
            SizedBox(
              height: 20,
            ),
            const Text(
              'My Chat App',
              style: TextStyle(color: ColorConstants.themeColor),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: ColorConstants.themeColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
