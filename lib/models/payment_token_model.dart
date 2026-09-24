// To parse this JSON data, do
//
//     final paymentToken = paymentTokenFromJson(jsonString);

import 'dart:convert';

PaymentToken paymentTokenFromJson(String str) => PaymentToken.fromJson(json.decode(str));

String paymentTokenToJson(PaymentToken data) => json.encode(data.toJson());

class PaymentToken {
    bool status;
    Data data;
    String message;

    PaymentToken({
        required this.status,
        required this.data,
        required this.message,
    });

    factory PaymentToken.fromJson(Map<String, dynamic> json) => PaymentToken(
        status: json["status"],
        data: Data.fromJson(json["data"]),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
        "message": message,
    };
}

class Data {
    String token;
    String tokenType;
    int expiresIn;

    Data({
        required this.token,
        required this.tokenType,
        required this.expiresIn,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        token: json["token"],
        tokenType: json["token_type"],
        expiresIn: json["expires_in"],
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "token_type": tokenType,
        "expires_in": expiresIn,
    };
}
