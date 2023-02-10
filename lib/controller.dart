import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreenController extends GetxController {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  String? verificationId;

  bool _showLoading = false;

  bool get showLoading => _showLoading;

  set showLoading(bool value) {
    _showLoading = value;
    update();
  }
}
