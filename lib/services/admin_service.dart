import 'package:jante_chai/services/api_service.dart';
import 'package:jante_chai/services/auth_service.dart';

class AdminService {
  // Fetch all reporters
  static Future<List<User>> fetchReporters() async {
    try {
      // Assuming the endpoint returns a list of users/reporters
      // Adjust the endpoint based on actual backend implementation
      final response = await ApiService.get('reporters');

      if (response is List) {
        return response.map((json) => User.fromJson(json)).toList();
      } else if (response is Map && response['reporters'] != null) {
        final List<dynamic> reportersJson = response['reporters'];
        return reportersJson.map((json) => User.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching reporters: $e');
      throw Exception('Failed to fetch reporters');
    }
  }

  // Update reporter status
  static Future<bool> updateReporterStatus(
    String reporterId,
    Map<String, dynamic> data,
  ) async {
    try {
      print(data);
      await ApiService.put('reporters/$reporterId', data);

      // Assuming backend returns success message or updated object
      return true;
    } catch (e) {
      print('Error updating reporter status: $e');
      return false;
    }
  }
}
