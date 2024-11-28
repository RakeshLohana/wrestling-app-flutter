import 'dart:convert';
/// statusCode : 200
/// message : "Successfully Logged In"
/// token : "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJyYWtlc2hsb2hhbmExMEBnbWFpbC5jb20iLCJpYXQiOjE3MzI3MDkzNzgsImV4cCI6MTczMjc5NTc3OH0.pbreWnx8lMcuCUm_QFKeF7PTzLubSi493kbWDDID19g"
/// refreshToken : "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJyYWtlc2hsb2hhbmExMEBnbWFpbC5jb20iLCJpYXQiOjE3MzI3MDkzNzgsImV4cCI6MTczMjc5NTc3OH0.pbreWnx8lMcuCUm_QFKeF7PTzLubSi493kbWDDID19g"
/// expirationTime : "24Hrs"
/// role : "ADMIN"

LoginResponseModel loginResponseModelFromJson(String str) => LoginResponseModel.fromJson(json.decode(str));
String loginResponseModelToJson(LoginResponseModel data) => json.encode(data.toJson());
class LoginResponseModel {
  LoginResponseModel({
      num? statusCode, 
      String? message, 
      String? token, 
      String? refreshToken, 
      String? expirationTime, 
      String? role,}){
    _statusCode = statusCode;
    _message = message;
    _token = token;
    _refreshToken = refreshToken;
    _expirationTime = expirationTime;
    _role = role;
}

  LoginResponseModel.fromJson(dynamic json) {
    _statusCode = json['statusCode'];
    _message = json['message'];
    _token = json['token'];
    _refreshToken = json['refreshToken'];
    _expirationTime = json['expirationTime'];
    _role = json['role'];
  }
  num? _statusCode;
  String? _message;
  String? _token;
  String? _refreshToken;
  String? _expirationTime;
  String? _role;
LoginResponseModel copyWith({  num? statusCode,
  String? message,
  String? token,
  String? refreshToken,
  String? expirationTime,
  String? role,
}) => LoginResponseModel(  statusCode: statusCode ?? _statusCode,
  message: message ?? _message,
  token: token ?? _token,
  refreshToken: refreshToken ?? _refreshToken,
  expirationTime: expirationTime ?? _expirationTime,
  role: role ?? _role,
);
  num? get statusCode => _statusCode;
  String? get message => _message;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  String? get expirationTime => _expirationTime;
  String? get role => _role;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['statusCode'] = _statusCode;
    map['message'] = _message;
    map['token'] = _token;
    map['refreshToken'] = _refreshToken;
    map['expirationTime'] = _expirationTime;
    map['role'] = _role;
    return map;
  }

}