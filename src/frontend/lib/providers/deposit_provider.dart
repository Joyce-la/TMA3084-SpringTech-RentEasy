import 'package:flutter/foundation.dart';

import '../models/deposit.dart';
import '../mock_data/deposits.dart';

class DepositProvider extends ChangeNotifier {
  DepositProvider({List<DepositData>? initialDeposits})
    : _deposits = List<DepositData>.from(initialDeposits ?? mockDeposits);

  final List<DepositData> _deposits;
  DepositStatus? _selectedStatus;

  List<DepositData> get deposits => List.unmodifiable(_deposits);
  DepositStatus? get selectedStatus => _selectedStatus;

  List<DepositData> get visibleDeposits {
    if (_selectedStatus == null) return deposits;
    return _deposits.where((deposit) {
      if (_selectedStatus == DepositStatus.pending) {
        return deposit.status == DepositStatus.pending ||
            deposit.status == DepositStatus.holding ||
            deposit.status == DepositStatus.partiallyRefunded;
      }
      return deposit.status == _selectedStatus;
    }).toList();
  }

  void setSelectedStatus(DepositStatus? status) {
    if (_selectedStatus == status) return;
    _selectedStatus = status;
    notifyListeners();
  }

  int countFor(DepositStatus? status) {
    if (status == null) return _deposits.length;
    if (status == DepositStatus.pending) {
      return _deposits.where((deposit) {
        return deposit.status == DepositStatus.pending ||
            deposit.status == DepositStatus.holding ||
            deposit.status == DepositStatus.partiallyRefunded;
      }).length;
    }
    return _deposits.where((deposit) => deposit.status == status).length;
  }

  void addDeposit(DepositData deposit) {
    _deposits.add(deposit);
    notifyListeners();
  }

  void updateDeposit(DepositData deposit) {
    final index = _deposits.indexWhere(
      (item) => item.invoiceNumber == deposit.invoiceNumber,
    );
    if (index == -1) return;
    if (identical(_deposits[index], deposit)) return;
    _deposits[index] = deposit;
    notifyListeners();
  }

  void removeDeposit(String invoiceNumber) {
    final exists = _deposits.any(
      (deposit) => deposit.invoiceNumber == invoiceNumber,
    );
    if (!exists) return;
    _deposits.removeWhere((deposit) => deposit.invoiceNumber == invoiceNumber);
    notifyListeners();
  }
}
