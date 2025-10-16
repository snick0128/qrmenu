import '../../shared/models/cart_item_model.dart';

enum FirestoreOrderStatus {
  pending,
  preparing,
  ready,
  delivered,
  served,
  cancelled
}

extension FirestoreOrderStatusX on FirestoreOrderStatus {
  String toFirestore() {
    return toString().split('.').last;
  }

  static FirestoreOrderStatus fromFirestore(String value) {
    return FirestoreOrderStatus.values.firstWhere(
      (status) => status.toString().split('.').last == value,
      orElse: () => FirestoreOrderStatus.pending,
    );
  }
}

// Convert between app OrderStatus and Firestore status
extension OrderStatusFirestoreExt on OrderStatus {
  String toFirestore() {
    return toString().split('.').last;
  }

  static OrderStatus fromFirestore(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.toString().split('.').last == value,
      orElse: () => OrderStatus.pending,
    );
  }
}