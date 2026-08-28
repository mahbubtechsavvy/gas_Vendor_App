import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/staff_model.dart';

class StaffProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  List<StaffModel> _staffList = [];
  bool _isLoading = false;
  String? _error;

  List<StaffModel> get staffList => _staffList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStaff() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _client.get(ApiEndpoints.staff);
      if (res is List) {
        _staffList = res.map((e) => StaffModel.fromJson(e)).toList();
      } else if (res is Map<String, dynamic> && res['staff'] is List) {
        _staffList = (res['staff'] as List).map((e) => StaffModel.fromJson(e)).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> inviteStaff({
    required String fullName,
    required String email,
    required StaffRole role,
    required List<String> branchIds,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.post(
        ApiEndpoints.staff,
        body: {
          'fullName': fullName.trim(),
          'email': email.trim().toLowerCase(),
          'role': role.name.toUpperCase(),
          'assignedBranchIds': branchIds,
        },
      );
      await fetchStaff();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
