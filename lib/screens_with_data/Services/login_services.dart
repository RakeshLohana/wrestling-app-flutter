import 'dart:convert';
import 'package:camera_recording_game/screens_with_data/constants/api_constants.dart';

import '../models/LoginRequestModel.dart';
import '../models/LoginResponseModel.dart';
import '../utils/api_service_helper.dart';

class LoginService {
  final ApiService _apiService = ApiService();

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _apiService.post( ApiConstants.loginRoute,
        data: jsonEncode(request.toJson()),
      );

      return LoginResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Login Failed: $e');
    }
  }
}
