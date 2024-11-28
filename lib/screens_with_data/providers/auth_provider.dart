import 'dart:developer';

import 'package:camera_recording_game/screens_with_data/Services/login_services.dart';
import 'package:camera_recording_game/screens_with_data/models/LoginRequestModel.dart';
import 'package:camera_recording_game/screens_with_data/models/LoginResponseModel.dart';
import 'package:camera_recording_game/screens_with_data/utils/token_storage_helper.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  LoginResponseModel? _loginResponse;

  bool get isLoading => _isLoading;
  LoginResponseModel? get loginResponse => _loginResponse;

  final LoginService _loginService = LoginService();

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final request = LoginRequestModel(email: email, password: password);
      _loginResponse = await _loginService.login(request);
      if(_loginResponse!=null){
        String token = _loginResponse?.token??"";
        await TokenStorage.saveToken(token);
      }

    } catch (e) {
      log("Login error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<void> logout() async {
    try {
      await TokenStorage.clearToken();
      log("Token cleared successfully!");
    } catch (e) {
      log("Error clearing token: $e");
    }
  }
}
