import 'package:shared_preferences/shared_preferences.dart';

class FarmerSessionData {
  static bool? isLogin;
  static String? role;
  static String? fid;
  static String? Name;
  static String? cattleType;
  static String? email;
  static String? address;
  static String? number;
  static String? profilePic;

  // Set Session Data
  static Future<void> setFarmerSessionData({
    required bool loginData,
    required String role,
    required String id,
    required String Name,
    required String cattleType,
    required String email,
    required String address,
    required String number,
    required String profilePic,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool('isLogin', loginData);
    await sharedPreferences.setString('role', role);
    await sharedPreferences.setString('id', id);
    await sharedPreferences.setString('Name', Name);
    await sharedPreferences.setString('cattleType', cattleType);
    await sharedPreferences.setString('email', email);
    await sharedPreferences.setString('address', address);
    await sharedPreferences.setString('number', number);
    await sharedPreferences.setString('profilePic', profilePic);

    getSessionData();
  }

  // Get Session Data
  static Future<void> getSessionData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    // Retrieve data and assign to static variables
    isLogin = sharedPreferences.getBool("isLogin") ?? false;
    role = sharedPreferences.getString("role");
    fid = sharedPreferences.getString("id");
    Name = sharedPreferences.getString("Name");
    cattleType = sharedPreferences.getString("cattleType");
    email = sharedPreferences.getString("email");
    address = sharedPreferences.getString("address");
    number = sharedPreferences.getString("number");
    profilePic = sharedPreferences.getString("profilePic");
  }

  // Clear Session Data
  static Future<void> clearFarmerSessionData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();

    // Reset local static variables
    isLogin = false;
    role = null;
  }
}
