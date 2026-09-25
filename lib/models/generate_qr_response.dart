class GenerateQrResponse {
  bool? status;
  String? message;
  GenerateQrData? data;

  GenerateQrResponse({
    this.status,
    this.message,
    this.data,
  });

  GenerateQrResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];

    data = json['data'] != null
        ? GenerateQrData.fromJson(json['data'])
        : null;
  }
}

class GenerateQrData {
  String? intentUrl;
  String? tid;
  String? transactionReference;

  GenerateQrData({
    this.intentUrl,
    this.tid,
    this.transactionReference,
  });

  GenerateQrData.fromJson(Map<String, dynamic> json) {
    intentUrl = json['intent_url'];
    tid = json['tid'];
    transactionReference = json['transaction_reference'];
  }
}