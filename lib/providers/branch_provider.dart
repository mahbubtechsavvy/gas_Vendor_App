import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/storage/storage_service.dart';
import '../models/branch_model.dart';
import '../models/operating_hours_model.dart';

class BranchProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();
  final StorageService _storage = StorageService();

  List<BranchModel> _branches = [];
  BranchModel? _selectedBranch;
  bool _isLoading = false;
  String? _error;

  List<BranchModel> get branches => _branches;
  BranchModel? get selectedBranch => _selectedBranch;
  String? get currentBranchId => _selectedBranch?.id ?? _storage.getSelectedBranchId();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBranches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _client.get(ApiEndpoints.branches);
      if (res is List) {
        _branches = res.map((e) => BranchModel.fromJson(e)).toList();
      } else if (res is Map<String, dynamic> && res['branches'] is List) {
        _branches = (res['branches'] as List).map((e) => BranchModel.fromJson(e)).toList();
      }

      final savedBranchId = _storage.getSelectedBranchId();
      if (_branches.isNotEmpty) {
        if (savedBranchId != null) {
          _selectedBranch = _branches.firstWhere(
            (b) => b.id == savedBranchId,
            orElse: () => _branches.first,
          );
        } else {
          _selectedBranch = _branches.first;
          await _storage.setSelectedBranchId(_selectedBranch!.id);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> selectBranch(BranchModel branch) async {
    _selectedBranch = branch;
    await _storage.setSelectedBranchId(branch.id);
    notifyListeners();
  }

  Future<bool> toggleBranchStatus(bool open) async {
    if (_selectedBranch == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = open
          ? ApiEndpoints.openBranch(_selectedBranch!.id)
          : ApiEndpoints.closeBranch(_selectedBranch!.id);

      await _client.post(url);
      _selectedBranch = _selectedBranch!.copyWith(isOpen: open);

      final idx = _branches.indexWhere((b) => b.id == _selectedBranch!.id);
      if (idx != -1) {
        _branches[idx] = _selectedBranch!;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveOperatingHours(OperatingHoursModel hours) async {
    if (_selectedBranch == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.put(
        ApiEndpoints.deliveryHours(_selectedBranch!.id),
        body: {'schedule': hours.toJson()},
      );

      _selectedBranch = _selectedBranch!.copyWith(operatingHours: hours);
      final idx = _branches.indexWhere((b) => b.id == _selectedBranch!.id);
      if (idx != -1) {
        _branches[idx] = _selectedBranch!;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCoverage(List<String> thanas) async {
    if (_selectedBranch == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.put(
        ApiEndpoints.coverage(_selectedBranch!.id),
        body: {'coverageThanas': thanas},
      );

      _selectedBranch = _selectedBranch!.copyWith(
        isOpen: _selectedBranch!.isOpen,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
