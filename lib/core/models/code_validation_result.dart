class CodeValidationResult {
  final bool isValid;
  final String code;
  final String? restaurantId;
  final String? tableId;
  final bool isDineIn;
  final String? tableNumber;
  final String? sessionType;

  const CodeValidationResult({
    required this.isValid,
    required this.code,
    this.restaurantId,
    this.tableId,
    this.isDineIn = false,
    this.tableNumber,
    this.sessionType,
  });
}