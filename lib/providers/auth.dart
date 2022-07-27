import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shop_app/models/http_exeption.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String ?_token;
  DateTime ?_expiryDateTime;
  String ?_userId;
  Timer ?_authTimer;
  
  bool get isAuth {
    return token != '';
  }
  
  String get token {
    if (_expiryDateTime != null && _expiryDateTime!.isAfter(DateTime.now()) && _token != null) 
      {
        return _token!;
      }
    return '';
  }

  String get userId {
    return _userId!;
  }

  Future<void> _authenticate(String email, String password, String urlSegment) async {
    try {
      final url = Uri.parse(
          'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDbFEeIEG2MzUYXWLQcVJnUnNj_915dsr0');
      final res = await http.post(url, body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }));
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        throw HttpException(resData['error']['message']);
      } 
      _token = resData['idToken'];
      _userId = resData['localId'];
      _expiryDateTime = DateTime.now().add(Duration(seconds: int.parse(resData['expiresIn'])));
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': userId,
        'expiryDate': _expiryDateTime!.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch(error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return await _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return await _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')!) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryData'] as String);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'] as String;
    _userId = extractedUserData['userId'] as String;
    _expiryDateTime = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout()
  async {
    _token = '';
    _userId = '';
    _expiryDateTime = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDateTime!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}





// import 'dart:convert';
//
// import 'package:flutter/widgets.dart';
// import 'package:http/http.dart' as http;
// import 'package:shop_app/models/http_exeption.dart';
//
// class Auth with ChangeNotifier {
//   String ?_token;
//     DateTime ?_expiryDate;
//     String ?_userId;
//
//     bool get isAuth {
//       return token != '';
//     }
//
//     String get token{
//     if(_expiryDate != null && _expiryDate!.isAfter(DateTime.now()) && _token != null) {
//       return _token!;
//     } else {
//       return '';
//     }
//   }
//
//   Future<void> _authenticate(
//       String email, String password, String urlSegment) async {
//     final url =
//     Uri.parse(('https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=AIzaSyC13spCwP_f_SalxEbkB-wjedoF8iYENlQ'));
//         try {
//         final response = await http.post(
//         url,
//         body: json.encode(
//         {
//         'email': email,
//         'password': password,
//         'returnSecureToken': true,
//         },
//         ),
//         );
//         final responseData = json.decode(response.body);
//         if (responseData['error'] != null) {
//         throw HttpException(responseData['error']['message']);
//         }
//         _token = responseData['idToken'];
//         _userId = responseData['localId'];
//         _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
//         } catch (error) {
//       throw error;
//     }
//   }
//
//   Future<void> signup(String email, String password) async {
//     return _authenticate(email, password, 'signupNewUser');
//   }
//
//   Future<void> login(String email, String password) async {
//     return _authenticate(email, password, 'verifyPassword');
//   }
// }
