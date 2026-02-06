class Address {
  final String line1;
  final String? line2;
  final String postalCode;

  const Address({
    required this.line1,
    this.line2,
    required this.postalCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'line1': line1,
      'line2': line2,
      'postalCode': postalCode,
    };
  }
}
