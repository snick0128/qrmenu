enum TableStatus {
  vacant,
  occupied,
  reserved,
  needsService,
  cleaning;

  String get displayName {
    switch (this) {
      case TableStatus.vacant:
        return 'Vacant';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.reserved:
        return 'Reserved';
      case TableStatus.needsService:
        return 'Needs Service';
      case TableStatus.cleaning:
        return 'Cleaning';
    }
  }
}

class TableModel {
  final String id;
  final String name;
  final String number;
  final int capacity;
  final TableStatus status;
  final double currentTotal;
  final DateTime? occupiedSince;
  final String? currentOrderId;

  const TableModel({
    required this.id,
    required this.name,
    required this.number,
    required this.capacity,
    required this.status,
    this.currentTotal = 0.0,
    this.occupiedSince,
    this.currentOrderId,
  });

  String get statusText => status.displayName;

  TableModel copyWith({
    String? id,
    String? name,
    String? number,
    int? capacity,
    TableStatus? status,
    double? currentTotal,
    DateTime? occupiedSince,
    String? currentOrderId,
  }) {
    return TableModel(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      currentTotal: currentTotal ?? this.currentTotal,
      occupiedSince: occupiedSince ?? this.occupiedSince,
      currentOrderId: currentOrderId ?? this.currentOrderId,
    );
  }
}