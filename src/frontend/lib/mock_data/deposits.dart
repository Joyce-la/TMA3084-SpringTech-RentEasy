import '../models/deposit.dart';
import 'database_records.dart';

final mockDeposits = List<DepositData>.unmodifiable(
  <int>[304, 303, 301, 302, 305].map((rentalId) {
    final deposit = _findRecord('Deposit', 'rentalId', rentalId);
    return deposit == null
        ? DepositData(
            invoiceNumber: '',
            customerName: '',
            plateNumber: '',
            status: DepositStatus.pending,
            collectedAmount: 0,
            statusDetail: 'No deposit record',
          )
        : _depositFromRecord(deposit);
  }),
);

DepositData _depositFromRecord(Map<String, Object?> deposit) {
  final rentalId = _integer(deposit, 'rentalId');
  final rental = _findRecord('Rental', 'rentalId', rentalId);
  final vehicle = rental == null
      ? null
      : _findRecord('Vehicle', 'vehicleId', rental['vehicleId']);
  final user = rental == null
      ? null
      : _findRecord('User', 'userId', rental['userId']);
  final invoice = _findRecord('Invoice', 'rentalId', rentalId);

  return DepositData(
    invoiceNumber: _string(invoice, 'invoiceNo', fallback: ''),
    customerName: _string(user, 'name', fallback: 'Unknown customer'),
    plateNumber: _string(vehicle, 'plateNo', fallback: 'Unknown plate'),
    status: _depositStatus(deposit),
    collectedAmount: _collectedAmount(deposit),
    statusDetail: _statusDetail(deposit),
    refundedAmount: _refundedAmount(deposit),
    actionLabel: _actionLabel(deposit),
  );
}

DepositStatus _depositStatus(Map<String, Object?> deposit) {
  final rentalId = _integer(deposit, 'rentalId');
  final rawStatus = _string(deposit, 'depositStatus', fallback: '');

  if (rawStatus == 'pending') return DepositStatus.pending;
  if (rawStatus == 'holding') return DepositStatus.holding;
  if (rawStatus == 'refunded') {
    return switch (rentalId) {
      303 => DepositStatus.checking,
      304 => DepositStatus.eligibleToRefund,
      305 => DepositStatus.partiallyRefunded,
      _ => DepositStatus.pending,
    };
  }

  return switch (rentalId) {
    303 => DepositStatus.checking,
    304 => DepositStatus.eligibleToRefund,
    305 => DepositStatus.partiallyRefunded,
    _ => DepositStatus.pending,
  };
}

double _collectedAmount(Map<String, Object?> deposit) {
  final rentalId = _integer(deposit, 'rentalId');
  if (rentalId == 301) return 0.0;
  return _number(deposit, 'returnTotal', fallback: 0.0);
}

double? _refundedAmount(Map<String, Object?> deposit) {
  final rentalId = _integer(deposit, 'rentalId');
  if (rentalId != 305) return null;
  final refunded = rentalId == 305
      ? 60.0
      : _number(deposit, 'returnTotal', fallback: 100.0);
  final deducted = _number(deposit, 'deductedAmount', fallback: 0.0);
  return deducted > 0 ? refunded - deducted : null;
}

String _statusDetail(Map<String, Object?> deposit) {
  final rentalId = _integer(deposit, 'rentalId');
  return switch (rentalId) {
    301 => 'Awaiting payment',
    302 => 'Car not returned · due 18 Nov',
    303 => 'Day 1 of 3 · opens 10 Nov',
    304 => 'Check ended 7 Nov',
    305 => 'Deducted RM 40.00 · damage',
    _ => _string(deposit, 'description', fallback: 'Deposit status unavailable'),
  };
}

String? _actionLabel(Map<String, Object?> deposit) {
  final rentalId = _integer(deposit, 'rentalId');
  return switch (rentalId) {
    303 => 'Record Incident',
    304 => 'Refund',
    _ => null,
  };
}

Map<String, Object?>? _findRecord(
  String table,
  String field,
  Object? value,
) {
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

int _integer(Map<String, Object?> record, String field) {
  final value = record[field];
  return value is num ? value.toInt() : 0;
}

double _number(
  Map<String, Object?> record,
  String field, {
  required double fallback,
}) {
  final value = record[field];
  return value is num ? value.toDouble() : fallback;
}
