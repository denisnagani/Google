import 'package:get_storage/get_storage.dart';

class PreferenceManagerUtils {
  static GetStorage getStorage = GetStorage();

  static String login = "login";

  ///received
  static Future setLogin(bool? value) async {
    await getStorage.write(login, value);
  }

  static bool getLogin() {
    return getStorage.read(login) ?? false;
  }
}
