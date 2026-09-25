class PaymentTokenResponse {
  bool? status;
  PaymentTokenData? data;
  String? message;

  PaymentTokenResponse({
    this.status,
    this.data,
    this.message,
  });

  PaymentTokenResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];

    if (json['data'] != null) {
      data = PaymentTokenData.fromJson(json['data']);
    }

    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.toJson(),
      'message': message,
    };
  }
}

class PaymentTokenData {
  String? token;
  String? tokenType;
  int? expiresIn;

  PaymentTokenData({
    this.token,
    this.tokenType,
    this.expiresIn,
  });

  PaymentTokenData.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    tokenType = json['token_type'];
    expiresIn = json['expires_in'];
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }
}