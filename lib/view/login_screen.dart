import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_login/controller.dart';
import 'package:google_login/repo/google_signin.dart';
import 'package:google_login/res/constant.dart';
import 'package:google_login/service/local_notification.dart';
import 'package:google_login/utils/shared_preference_utils.dart';
import 'package:google_login/view/home_screen.dart';
import 'package:google_login/view/otp_screen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  LoginScreenController loginScreenController =
      Get.put(LoginScreenController());

  ///==================================///

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GetBuilder<LoginScreenController>(
          builder: (controller) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Get.height * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: Get.height * 0.05,
                      ),
                      Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: Get.width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: Get.height * 0.2,
                      ),
                      TextField(
                        controller: controller.phoneController,
                        decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          hintText: 'Phone Number',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(
                        height: Get.height * 0.05,
                      ),
                      GestureDetector(
                        onTap: () async {
                          controller.showLoading = true;

                          await firebaseAuth.verifyPhoneNumber(
                            phoneNumber:
                                '+91${controller.phoneController.text}',
                            verificationCompleted: (phoneAuthCredential) async {
                              controller.showLoading = false;
                              Get.off(() => OtpScreen());
                            },
                            verificationFailed: (verificationFailed) async {
                              Get.showSnackbar(
                                GetSnackBar(
                                  message: verificationFailed.message,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              controller.showLoading = false;
                            },
                            codeSent: (verificationId, resendingToken) async {
                              controller.showLoading = false;
                              log("======showLoading========${controller.showLoading}");
                              controller.verificationId = verificationId;
                            },
                            codeAutoRetrievalTimeout: (verificationId) async {},
                          );
                        },
                        child: Container(
                          height: Get.height * 0.07,
                          width: Get.width,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'GET OTP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Get.height * 0.02,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: Get.height * 0.05,
                      ),
                      GestureDetector(
                        onTap: () async {
                          String user = await signInWithGoogle();
                          if (user != null) {
                            LocalNotificationServices.display(
                              "Mobile Number Login",
                              "Login Successfully",
                            );
                            Get.off(HomeScreen());
                            await PreferenceManagerUtils.setLogin(true);
                          }
                        },
                        child: Container(
                          height: Get.height * 0.07,
                          width: Get.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 5,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: Get.width * 0.05,
                              ),
                              CircleAvatar(
                                radius: Get.height * 0.03,
                                backgroundImage:
                                    AssetImage("assets/images/google.png"),
                              ),
                              SizedBox(
                                width: Get.width * 0.1,
                              ),
                              Text(
                                "Signin With Google",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: Get.height * 0.02,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SignInWithAppleButton(
                        borderRadius: BorderRadius.circular(10),
                        height: 50,
                        style: SignInWithAppleButtonStyle.black,
                        onPressed: () async {
                          signInWithApple();
                        },
                      ),
                    ],
                  ),
                ),
                if (controller.showLoading == true)
                  Container(
                    height: Get.height,
                    width: Get.width,
                    color: Colors.white.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Future<String> signInWithApple() async {
  final rawNonce = generateNonce();

  try {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: '',
        redirectUri: Uri.parse(
          'https://login-8bf0a.firebaseapp.com/__/auth/handler',
        ),
      ),
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: '',
    );

    print(appleCredential.authorizationCode);

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    final authResult = await firebaseAuth.signInWithCredential(oauthCredential);
    final displayName =
        '${appleCredential.givenName} ${appleCredential.familyName}';
    final userEmail = '${appleCredential.email}';

    User firebaseUser = authResult.user!;
    print(displayName);
    await firebaseUser.updateProfile(displayName: displayName);
    await firebaseUser.updateEmail(userEmail);

    return "${firebaseUser}";
  } catch (exception) {
    print(exception);
  }
  return "";
}
