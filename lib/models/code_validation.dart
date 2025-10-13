class CodeValidationResult {
  final bool isValid;
  final String? sessionType; // 'dine_in' or 'parcel'
  final String? tableNumber;
  final String code;

  const CodeValidationResult({
    required this.isValid,
    this.sessionType,
    this.tableNumber,
    required this.code,
  });

  bool get isDineIn => sessionType == 'dine_in';
  bool get isParcel => sessionType == 'parcel';
}
