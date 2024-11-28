import 'dart:developer';

import 'package:camera_recording_game/screens_with_data/constants/api_constants.dart';
import 'package:camera_recording_game/screens_with_data/utils/token_storage_helper.dart';
import 'package:dio/dio.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
     _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        // headers: {
        //   'Content-Type': 'application/json',
        // },
      ),
    );

    // Add interceptors if needed
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // String? token = await TokenStorage.getToken();
        // if (token != null ||token !="") {
        //   options.headers["Authorization"] = "Bearer $token";
        // }
        log("Request: ${options.method} ${options.path}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        log("Response: ${response.statusCode} ${response.data}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        log("Error: ${e.message}");
        return handler.next(e);
      },
    ));
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      log("Endpoint using ----->"+endpoint);
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      return await _dio.put(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String endpoint, {dynamic data}) async {
    try {
      return await _dio.delete(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      return "Error: ${error.response?.statusCode} - ${error.response?.data}";
    } else {
      return "Error: ${error.message}";
    }
  }
}
