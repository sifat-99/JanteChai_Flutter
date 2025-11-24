import 'package:jante_chai/services/api_service.dart';
import 'package:jante_chai/services/auth_service.dart';

class UserApiService {
  static Future<List<User>> getAllUsers() async {
    try {
      final response = await ApiService.get('users');
      final List<dynamic> usersList;
      if (response is List) {
        usersList = response;
      } else {
        usersList = response['users'];
      }
      return usersList.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteUser(String userId) async {
    try {
      await ApiService.delete('users/$userId');
    } catch (e) {
      rethrow;
    }
  }
}
