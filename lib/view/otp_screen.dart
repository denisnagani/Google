import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_login/controller.dart';
import 'package:google_login/res/constant.dart';
import 'package:google_login/service/local_notification.dart';
import 'package:google_login/utils/shared_preference_utils.dart';
import 'package:google_login/view/home_screen.dart';

class OtpScreen extends StatelessWidget {
  OtpScreen({Key? key}) : super(key: key);

  LoginScreenController loginScreenController =
      Get.put(LoginScreenController());

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    loginScreenController.showLoading = true;
    try {
      final authCredential =
          await firebaseAuth.signInWithCredential(phoneAuthCredential);
      loginScreenController.showLoading = false;

      if (authCredential.user != null) {
        Get.off(HomeScreen());
      }
    } on FirebaseAuthException catch (e) {
      loginScreenController.showLoading = false;
      Get.showSnackbar(
        GetSnackBar(
          title: e.message!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginScreenController>(
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Get.width * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: Get.height * 0.05,
                      ),
                      Text(
                        "Otp Verify",
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
                        controller: controller.otpController,
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
                          hintText: 'Otp Number',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(
                        height: Get.height * 0.05,
                      ),
                      GestureDetector(
                        onTap: () async {
                          PhoneAuthCredential phoneAuthCredential =
                              PhoneAuthProvider.credential(
                            verificationId: controller.verificationId!,
                            smsCode: controller.otpController.text,
                          );
                          await PreferenceManagerUtils.setLogin(true);
                          LocalNotificationServices.display(
                              "Mobile Number Login", "Login Successfully");
                          signInWithPhoneAuthCredential(phoneAuthCredential);
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
                              'Verify OTP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Get.height * 0.02,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
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
            ),
          ),
        );
      },
    );
  }
}
