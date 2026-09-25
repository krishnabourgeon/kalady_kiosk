class PaymentStatusResponse {
  bool? status;
  String? message;
  String? error;
  dynamic data;

  PaymentStatusResponse({
    this.status,
    this.message,
    this.error,
    this.data,
  });

  PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    error = json['error'];
    data = json['data'];
  }
}