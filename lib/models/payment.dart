class Payment {
  final int paymentId;
  final int userId;
  final double amount;
  final String paymentDate;
  final String paymentMethod;
  final String deliveryOption;
  final String? userName;

  Payment({
    required this.paymentId,
    required this.userId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.deliveryOption,
    this.userName,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['payment_id'],
      userId: json['user_id'],
      amount: (json['amount'] as num).toDouble(),
      paymentDate: json['payment_date'],
      paymentMethod: json['payment_method'],
      deliveryOption: json['delivery_option'],
      userName: json['user_name'],
    );
  }
}
