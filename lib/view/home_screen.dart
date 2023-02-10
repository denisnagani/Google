import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_login/repo/google_signin.dart';
import 'package:google_login/utils/shared_preference_utils.dart';
import 'package:google_login/view/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBar(
            centerTitle: true,
            title: Text("Home Screen"),
            automaticallyImplyLeading: false,
          )),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            signOutGoogle();
            await PreferenceManagerUtils.setLogin(false);
            Get.off(LoginScreen());
          },
          child: Text("SignOut"),
        ),
      ),
    );
  }
}
