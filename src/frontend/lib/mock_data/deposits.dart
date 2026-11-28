import '../models/deposit.dart';
import 'database_records.dart';

final mockDeposits = List<DepositData>.unmodifiable(
  mockDatabase['Deposit']!.map(_depositFromRecord).toList()
    ..sort((a, b) => a.status.index.compareTo(b.status.index)),
);

DepositData _depositFromRecord(Map<String, Object?> deposit) {
  final rental = _findRecord('Rental', 'rentalId', deposit['rentalId']);
  final vehicle = rental == null
      ? null
      : _findRecord('Vehicle', 'vehicleId', rental['vehicleId']);
  final user = rental == null
      ? null
      : _findRecord('User', 'userId', rental['userId']);
  final invoice = _findRecord('Invoice', 'rentalId', deposit['rentalId']);
  final status = _depositStatus(deposit);

  return DepositData(
    invoiceNumber: _string(invoice, 'invoiceNo', fallback: ''),
    customerName: _string(user, 'name', fallback: 'Unknown customer'),
    plateNumber: _string(vehicle, 'plateNo', fallback: 'Unknown plate'),
    carType: _carType(vehicle),
    status: status,
    collectedAmount: _number(deposit, 'returnTotal', fallback: 0.0),
    statusDetail: _statusDetail(deposit),
    returnedDate: rental == null
        ? null
        : _string(rental, 'returnDate', fallback: ''),
    refundedAmount: _refundedAmount(deposit, status),
  );
}

String _carType(Map<String, Object?>? vehicle) {
  if (vehicle == null) return '';
  final category = _string(vehicle, 'category', fallback: '');
  final model = _string(vehicle, 'model', fallback: '');
  if (category.isEmpty) return model;
  if (model.isEmpty) return category;
  return '$category ($model)';
}

DepositStatus _depositStatus(Map<String, Object?> deposit) =>
    switch (_string(deposit, 'depositStatus', fallback: '')) {
      'eligibleToRefund' => DepositStatus.eligibleToRefund,
      'checking' => DepositStatus.checking,
      'pending' => DepositStatus.pending,
      'holding' => DepositStatus.holding,
      'partiallyRefunded' => DepositStatus.partiallyRefunded,
      'refunded' => DepositStatus.refunded,
      final status => throw StateError('Unknown deposit status: $status'),
    };

String _statusDetail(Map<String, Object?> deposit) {
  final description = _string(
    deposit,
    'description',
    fallback: 'Deposit status unavailable',
  );
  final deducted = _number(deposit, 'deductedAmount', fallback: 0.0);
  if (deducted <= 0) return description;
  return 'Deducted RM ${deducted.toStringAsFixed(2)} · $description';
}

double? _refundedAmount(Map<String, Object?> deposit, DepositStatus status) {
  if (status != DepositStatus.partiallyRefunded) return null;

  final collected = _number(deposit, 'returnTotal', fallback: 0.0);
  final deducted = _number(deposit, 'deductedAmount', fallback: 0.0);
  return (collected - deducted).clamp(0.0, collected).toDouble();
}

Map<String, Object?>? _findRecord(String table, String field, Object? value) {
  if (value == null) return null;
  for (final record in mockDatabase[table] ?? const []) {
    if (record[field] == value) return record;
  }
  return null;
}

String _string(
  Map<String, Object?>? record,
  String field, {
  required String fallback,
}) {
  final value = record?[field];
  return value is String && value.isNotEmpty ? value : fallback;
}

double _number(
  Map<String, Object?> record,
  String field, {
  required double fallback,
}) {
  final value = record[field];
  return value is num ? value.toDouble() : fallback;
}
