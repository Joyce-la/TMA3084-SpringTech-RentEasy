import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../mock_data/invoices.dart';

class InvoiceProvider extends ChangeNotifier {
  InvoiceProvider({List<InvoiceData>? initialInvoices})
    : _invoices = List<InvoiceData>.from(initialInvoices ?? mockInvoices);

  final List<InvoiceData> _invoices;
  String _searchQuery = '';
  InvoicePaymentStatus? _selectedStatus;

  List<InvoiceData> get invoices =>
      UnmodifiableListView<InvoiceData>(_invoices);
  InvoicePaymentStatus? get selectedStatus => _selectedStatus;

  List<InvoiceData> get visibleInvoices {
    final query = _searchQuery.trim().toLowerCase();
    return _invoices.where((invoice) {
      final matchesStatus =
          _selectedStatus == null || invoice.status == _selectedStatus;
      final matchesSearch =
          query.isEmpty ||
          invoice.customerName.toLowerCase().contains(query) ||
          invoice.plateNumber.toLowerCase().contains(query) ||
          invoice.invoiceNumber.toLowerCase().contains(query);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  void setSelectedStatus(InvoicePaymentStatus? status) {
    if (_selectedStatus == status) return;
    _selectedStatus = status;
    notifyListeners();
  }

  int countFor(InvoicePaymentStatus? status) {
    if (status == null) return _invoices.length;
    return _invoices.where((invoice) => invoice.status == status).length;
  }

  void updateInvoice(InvoiceData invoice) {
    final index = _invoices.indexWhere(
      (item) => item.invoiceNumber == invoice.invoiceNumber,
    );
    if (index == -1) return;
    if (identical(_invoices[index], invoice)) return;
    _invoices[index] = invoice;
    notifyListeners();
  }

  void addInvoice(InvoiceData invoice) {
    _invoices.add(invoice);
    notifyListeners();
  }

  void removeInvoice(String invoiceNumber) {
    final exists = _invoices.any(
      (invoice) => invoice.invoiceNumber == invoiceNumber,
    );
    if (!exists) return;
    _invoices.removeWhere((invoice) => invoice.invoiceNumber == invoiceNumber);
    notifyListeners();
  }
}
