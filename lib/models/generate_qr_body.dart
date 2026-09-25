class GenerateQrBody {
  final double amount;
  final String transactionNote;
  final String transactionReference;
  final int expireMinutes;

  GenerateQrBody({
    required this.amount,
    required this.transactionNote,
    required this.transactionReference,
    required this.expireMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "transaction_note": transactionNote,
      "transaction_reference": transactionReference,
      "expire_minutes": expireMinutes,
    };
  }
}