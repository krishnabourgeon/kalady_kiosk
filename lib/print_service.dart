import 'package:flutter/services.dart';

class PrinterService {
  static const MethodChannel _channel = MethodChannel('masung_printer');

  static Future<bool> connect() async {
    return await _channel.invokeMethod('connect');
  }

  static Future<void> printText(String text) async {
    await _channel.invokeMethod('printText', {'text': text});
  }

  static Future<void> cutPaper() async {
    await _channel.invokeMethod('cutPaper');
  }

  static Future<void> printReceipt({
    String? temple,
    String? templeAddress,
    String? templePlace,
    int? id,
    String? today,
    String? mode,
    String? total,
    String? website,
    List<Map<String, dynamic>>? items,
  }) async {
    await _channel.invokeMethod('printReceipt', {
      'temple': temple,
      'templeAddress': templeAddress,
      'templePlace': templePlace,
      'billNo': id.toString(),
      'date': today,
      'mode': mode,
      'total': total,
      'website': website,
      'items': items,
    });
  }
}
