import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer_platform_interface.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
// import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show DateFormat;
import 'package:kalady_kiosk/color_pallatte.dart';
import 'package:kalady_kiosk/extension.dart';
import 'package:kalady_kiosk/fontpallate.dart';
import 'package:kalady_kiosk/models/save_bill_body.dart';
// import 'package:kalady_kiosk/print_service.dart';
import 'package:kalady_kiosk/provider/homeprovider.dart';
import 'package:kalady_kiosk/services/helpers.dart';
import 'package:kalady_kiosk/services/provider_helper_class.dart';
// import 'package:kalady_kiosk/view/encrypt.dart';
import 'package:kalady_kiosk/view/homepage.dart';
import 'package:provider/provider.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key, this.lanid});
  final int? lanid;
  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final ValueNotifier<bool> isEnabled = ValueNotifier<bool>(false);
  final Razorpay _razorpay = Razorpay();

  // Kalady Sankara Madom (as.kaladyshankaramadomts.org) Razorpay live key.
  static const String razorpayKey = 'rzp_live_drsvRJJ88Gwafu';
  // TODO: confirm the payment-mode id the backend expects for Razorpay payments.
  static const int razorpayPaymentMode = 6;
  final _flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;

  // Characters per line on 58mm paper (use 48 for 80mm).
  static const int _lineWidth = 32;

  List<Printer> printers = [];
  Printer? connectedPrinter;
  StreamSubscription<List<Printer>>? _devicesStreamSubscription;

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletResponse);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScanAndAutoConnect();
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    _stopScan();
    super.dispose();
  }

  // Future<String?> selectPaymentMode(BuildContext context) async {
  //   return showDialog<String>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text("Select Payment Mode", style: TextStyle(fontSize: 60.sp)),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             OutlinedButton(
  //               style: OutlinedButton.styleFrom(
  //                 foregroundColor: const Color(0xFFE65C00),
  //                 side: const BorderSide(color: Color(0xFFE65C00), width: 1.5),
  //                 minimumSize: const Size(double.infinity, 55),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //               ),
  //               onPressed: () => Navigator.pop(context, "CARD"),
  //               child: Text("Card", style: TextStyle(fontSize: 56.sp)),
  //             ),
  //             20.verticalSpace,

  //             OutlinedButton(
  //               style: OutlinedButton.styleFrom(
  //                 foregroundColor: const Color(0xFFE65C00),
  //                 side: const BorderSide(color: Color(0xFFE65C00), width: 1.5),
  //                 minimumSize: const Size(double.infinity, 55),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //               ),
  //               onPressed: () => Navigator.pop(context, "UPI"),
  //               child: Text("UPI", style: TextStyle(fontSize: 56.sp)),
  //             ),
  //             30.verticalSpace,
  //             TextButton(
  //               style: TextButton.styleFrom(
  //                 foregroundColor: Colors.grey,
  //                 minimumSize: const Size(double.infinity, 55),
  //                 side: const BorderSide(color: Colors.grey, width: 1.5),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //               ),
  //               onPressed: () {
  //                 isEnabled.value = false;
  //                 Navigator.pop(context, null);
  //               },
  //               child: Text("Cancel", style: TextStyle(fontSize: 58.sp)),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // Future<String> checkStatus(String urn, String tid) async {
  //   final body = {"urn": urn, "tid": tid};
  //   print("Original Request: $body");
  //   final encryptedData = WorldlineEncryption.encryptRequest(body);

  //   final response = await http.post(
  //     Uri.parse('https://bouat.mrlpay.com/pcpos4/StatusCheck.php?source=629'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: encryptedData,
  //   );
  //   final jsonResponse = jsonDecode(response.body);
  //   final encrypted = jsonResponse['data'];
  //   final decrypt = WorldlineEncryption.decryptResponse(encrypted);

  //   final data = jsonDecode(decrypt);
  //   return data['status'];
  // }

  // Future<String> checkStatus(String urn, String tid) async {
  //   final body = {"urn": urn, "tid": tid};
  //   print("Original Request: $body");
  //   final encryptedData = WorldlineEncryption.encryptRequest(body);

  //   final response = await http.post(
  //     Uri.parse('https://lb.mrlpay.com/pcpos4/StatusCheck.php?source=941'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: encryptedData,
  //   );
  //   final jsonResponse = jsonDecode(response.body);
  //   final encrypted = jsonResponse['data'];
  //   final decrypt = WorldlineEncryption.decryptResponse(encrypted);

  //   final data = jsonDecode(decrypt);
  //   return data['status'];
  // }

  // Future<String> waitForPaymentStatus(String urn, String tid) async {
  //   while (true) {
  //     final status = await checkStatus(urn, tid);

  //     print("Status: $status");

  //     if (status == "success") {
  //       return "success";
  //     }

  //     if (status == "Failed") {
  //       return "failed";
  //     }

  //     await Future.delayed(const Duration(seconds: 5));
  //   }
  // }

  // saleTransaction(String? amt, String? mode) async {
  //   final request = {
  //     "tid": "2462204U",
  //     "amount": amt,
  //     "organization_code": "Retail",
  //     "invoiceNumber": "",
  //     "rrn": "",
  //     "type": mode == "CARD" ? "SALE" : "SALE-UPI",
  //     "cb_amt": "",
  //     "app_code": "",
  //     "tokenisedValue": "",
  //     "actionId": mode == "CARD" ? "1" : "133",
  //     "request_urn": "",
  //   };
  //   print("Original Request: $request");

  //   final encryptedData = WorldlineEncryption.encryptRequest(request);

  //   final response = await http.post(
  //     Uri.parse(
  //       'https://bouat.mrlpay.com/pcpos4/TransactionRequest.php?source=629',
  //     ),
  //     headers: {'Content-Type': 'application/json'},
  //     body: encryptedData,
  //   );

  //   final jsonResponse = jsonDecode(response.body);

  //   final encrypted = jsonResponse['data'];
  //   final decrypt = WorldlineEncryption.decryptResponse(encrypted);
  //   print("decrypt json: $decrypt");
  //   // if (decrypt == null || decrypt.startsWith("Error")) {
  //   //   print("Decryption failed: $decrypt");
  //   //   isEnabled.value = false;
  //   //   Helpers.successToast("Payment failed. Please try again.");
  //   //   return;
  //   // }
  //   final data = jsonDecode(decrypt);
  //   final String urn = data['urn'];
  //   final String tid = data['tid'];
  //   return await waitForPaymentStatus(urn, tid);
  // }

  // saleTransaction(String? amt, String? mode) async {
  //   final request = {
  //     "tid": "3419965A",
  //     "amount": amt,
  //     "organization_code": "Retail",
  //     "invoiceNumber": "",
  //     "rrn": "",
  //     "type": mode == "CARD" ? "SALE" : "SALE-UPI",
  //     "cb_amt": "",
  //     "app_code": "",
  //     "tokenisedValue": "",
  //     "actionId": mode == "CARD" ? "1" : "133",
  //     "request_urn": "",
  //   };
  //   print("Original Request: $request");

  //   final encryptedData = WorldlineEncryption.encryptRequest(request);

  //   final response = await http.post(
  //     Uri.parse(
  //       'https://lb.mrlpay.com/pcpos4/TransactionRequest.php?source=941',
  //     ),
  //     headers: {'Content-Type': 'application/json'},
  //     body: encryptedData,
  //   );

  //   final jsonResponse = jsonDecode(response.body);

  //   final encrypted = jsonResponse['data'];
  //   final decrypt = WorldlineEncryption.decryptResponse(encrypted);
  //   print("decrypt json: $decrypt");
  //   final data = jsonDecode(decrypt);
  //   final String urn = data['urn'];
  //   final String tid = data['tid'];
  //   return await waitForPaymentStatus(urn, tid);
  // }

  void showPaymentStatusDialog(String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error_outline,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 60.h,
                ),
                20.verticalSpace,
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Fontpalette.blackinter45400,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK", style: Fontpalette.blackinter45400),
              ),
            ],
          ),
    );
  }

  // Kiosk's Masung printer (same IDs UsbDriver.java looks for), in decimal
  // because the plugin reports IDs that way: VID 0x519, PID 0x2013 / 0x2015.
  static const String _printerVendorId = '1305';
  static const List<String> _printerProductIds = ['8211', '8213'];

  // Prefer the known printer; other USB devices (touchscreen, hubs, ...)
  // also show up in the list and silently swallow print data.
  Printer? _pickPrinter(List<Printer> devices) {
    for (final p in devices) {
      if (p.vendorId == _printerVendorId &&
          _printerProductIds.contains(p.productId)) {
        return p;
      }
    }
    for (final p in devices) {
      if ((p.name ?? '').toLowerCase().contains('print')) return p;
    }
    return null;
  }

  // Finds the USB receipt printer and asks for USB permission.
  Future<void> _startScanAndAutoConnect() async {
    _devicesStreamSubscription?.cancel();
    await _flutterThermalPrinterPlugin.getPrinters(
      connectionTypes: [ConnectionType.USB],
    );
    _devicesStreamSubscription = _flutterThermalPrinterPlugin.devicesStream
        .listen((event) async {
          debugPrint(
            'USB devices: ${event.map((e) => '${e.name} (${e.vendorId}:${e.productId})').toList()}',
          );
          if (!mounted) return;
          setState(() {
            printers = event;
          });
          final printer = _pickPrinter(event);
          if (printer != null && connectedPrinter == null) {
            // Only requests USB permission; the plugin always returns false.
            await _flutterThermalPrinterPlugin.connect(printer);
            Helpers.successToast("Printer found: ${printer.name}");
            if (!mounted) return;
            setState(() {
              connectedPrinter = printer;
            });
          }
        });
  }

  void _stopScan() {
    _flutterThermalPrinterPlugin.stopScan();
    _devicesStreamSubscription?.cancel();
  }

  // @override
  // void dispose() {
  //   _stopScan();
  //   super.dispose();
  // }

  Widget receiptWidgets({
    String? name,
    String? add1,
    String? add2,
    String? billno,
    String? date,
    List<PoojaDetails>? pooja,
    String? mode,
    String? total,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Material(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  name ?? "NA",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  add1 ?? "NA",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  add2 ?? "NA",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(thickness: 2),
              const SizedBox(height: 10),
              Text(
                'Bill No: ${billno ?? "NA"}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Bill Date: ${date ?? "NA"}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              if (pooja == null || pooja.isEmpty)
                SizedBox()
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < pooja.length; i++) ...[
                      Text(
                        '${i + 1}. ${pooja[i].name ?? "NA"} - ${pooja[i].star ?? "NA"}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${pooja[i].diety ?? "NA"}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${pooja[i].pooja ?? ""} - ₹ ${pooja[i].rate ?? "NA"}x${pooja[i].qty ?? "NA"}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Divider(),
                    ],
                  ],
                ),
              const Divider(thickness: 2),
              _buildReceiptRows(
                'Mode: ${mode ?? "NA"}',
                'Total: ₹ ${total ?? "NA"}',
                isBold: true,
              ),
              const SizedBox(height: 50),
              const Center(
                child: Text(
                  'Thank you!',
                  style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRows(
    String leftText,
    String rightText, {
    bool isBold = false,
  }) {
    final style = TextStyle(
      fontSize: 16,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              leftText,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              rightText,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printReceipts({
    String? name,
    String? add1,
    String? add2,
    String? billno,
    String? date,
    String? mode,
    String? total,
    String? website,
    List<PoojaDetails>? pooja,
  }) async {
    if (connectedPrinter == null) return;
    // Without USB permission the plugin drops the data without any error.
    final hasPermission = await FlutterThermalPrinterPlatform.instance
        .isConnected(connectedPrinter!);
    if (!hasPermission) {
      await _flutterThermalPrinterPlugin.connect(connectedPrinter!);
      Helpers.successToast(
        "Printer USB permission not granted. Bill saved but not printed.",
      );
      return;
    }
    try {
      // await _flutterThermalPrinterPlugin.printWidget(
      //   context,
      //   printer: connectedPrinter!,
      //   printOnBle: false, // USB only
      //   widget: Directionality(
      //     textDirection: TextDirection.ltr,
      //     child: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         Center(
      //           child: Text(
      //             name ?? "",
      //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      //           ),
      //         ),
      //         Center(child: Text(add1 ?? '')),
      //         Center(child: Text(add2 ?? "")),
      //         SizedBox(height: 10),
      //         Divider(thickness: 1),
      //         Text("Bill No: $billno"),
      //         Text("Date: $date"),
      //         Divider(thickness: 1),
      //         Text("1. Ganapathi Pooja - ₹100 x 1"),
      //         Text(
      //           "Mode: $mode",
      //           style: TextStyle(fontWeight: FontWeight.bold),
      //         ),
      //         Text(
      //           "Total: ₹$total",
      //           style: TextStyle(fontWeight: FontWeight.bold),
      //         ),
      //         SizedBox(height: 20),
      //         Center(
      //           child: Text(
      //             "Thank you!",
      //             style: TextStyle(fontStyle: FontStyle.italic),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // );

      final bytes = generateEscPosCommands(
        add1: add1,
        add2: add2,
        billno: billno,
        date: date,
        mode: mode,
        name: name,
        pooja: pooja,
        total: total,
        website: website,
      );

      // Never let a stuck printer keep the kiosk on this screen.
      await FlutterThermalPrinter.instance
          .printData(connectedPrinter!, bytes)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => Helpers.successToast("Printer not responding"),
          );
    } catch (e, st) {
      Helpers.successToast("Error while printing: $e");
      debugPrintStack(stackTrace: st);
    }
  }

  /// Right-pads [left] and right-aligns [right] within [width] characters,
  /// truncating [left] if the combined text would overflow the line.
  String _twoColumnText(String left, String right, [int width = _lineWidth]) {
    if (left.length + right.length >= width) {
      final maxLeft = width - right.length - 1;
      if (maxLeft > 0 && left.length > maxLeft) {
        left = left.substring(0, maxLeft);
      }
    }
    final spaceCount = width - left.length - right.length;
    final spaces = spaceCount > 0 ? ' ' * spaceCount : ' ';
    return '$left$spaces$right';
  }

  List<int> generateEscPosCommands({
    String? name,
    String? add1,
    String? add2,
    String? billno,
    String? date,
    String? mode,
    String? total,
    String? website,
    List<PoojaDetails>? pooja,
  }) {
    List<int> bytes = [];

    // Initialize
    bytes += [27, 64]; // ESC @

    // ---------------- Header: temple name + address ----------------
    bytes += [27, 97, 1]; // ESC a 1 -> center align
    bytes += [27, 69, 1]; // ESC E 1 -> bold on
    bytes += utf8.encode("${(name ?? 'NA').toUpperCase()}\n");
    bytes += [27, 69, 0]; // bold off

    if ((add1 ?? '').isNotEmpty) {
      bytes += utf8.encode("$add1\n");
    }
    if ((add2 ?? '').isNotEmpty) {
      bytes += utf8.encode("$add2\n");
    }
    bytes += utf8.encode("\n");

    // ---------------- Title ----------------
    bytes += [27, 69, 1]; // bold on
    bytes += utf8.encode("Seva Receipt\n");
    bytes += [27, 69, 0]; // bold off
    bytes += utf8.encode("\n");

    // ---------------- Receipt meta ----------------
    bytes += [27, 97, 0]; // ESC a 0 -> left align
    bytes += utf8.encode("Receipt No: ${billno ?? 'NA'}\n");
    bytes += utf8.encode("Date: ${date ?? 'NA'}\n");
    bytes += utf8.encode("${'-' * _lineWidth}\n");

    // ---------------- Items ----------------
    if (pooja != null && pooja.isNotEmpty) {
      for (int i = 0; i < pooja.length; i++) {
        final item = pooja[i];
        // "Kiosk User" is a placeholder name, not a real devotee.
        final personName = item.name == "Kiosk User" ? '' : (item.name ?? '');
        final star = item.star ?? '';

        bytes += [27, 69, 1]; // bold on
        bytes += utf8.encode(
          "${i + 1}. $personName${star.isNotEmpty ? ' - $star' : ''}\n",
        );
        bytes += [27, 69, 0]; // bold off

        if ((item.diety ?? '').isNotEmpty) {
          bytes += utf8.encode("   ${item.diety}\n");
        }

        final itemLabel = "   ${item.pooja ?? 'NA'} x${item.qty ?? 1}";
        final itemAmount = "Rs.${item.rate ?? '0'}";
        bytes += utf8.encode("${_twoColumnText(itemLabel, itemAmount)}\n");

        if (i != pooja.length - 1) {
          bytes += utf8.encode("\n");
        }
      }
    }

    bytes += utf8.encode("${'-' * _lineWidth}\n");

    // ---------------- Totals ----------------
    bytes += [27, 69, 1]; // bold on
    bytes += utf8.encode(
      "${_twoColumnText('Amount Paid:', 'Rs.${total ?? '0'}')}\n",
    );
    bytes += [27, 69, 0]; // bold off
    bytes += utf8.encode("${_twoColumnText('Payment Mode:', mode ?? 'NA')}\n");
    bytes += utf8.encode("${'-' * _lineWidth}\n");

    // ---------------- Footer ----------------
    bytes += [27, 97, 1]; // center align
    bytes += utf8.encode("\nThank you!\n");
    if ((website ?? '').isNotEmpty) {
      bytes += utf8.encode("$website\n");
    }
    bytes += utf8.encode("\n\n");

    // Cut (if supported)
    bytes += [29, 86, 66, 0]; // GS V B n

    return bytes;
  }

  void paymentrazorpay({num? amt}) {
    if (amt == null || amt <= 0) {
      isEnabled.value = false;
      Helpers.successToast("Invalid amount");
      return;
    }
    var options = {
      'key': razorpayKey,
      // Razorpay expects the amount in paise.
      'amount': (amt * 100).round(),
      'name': 'Kalady Sri Adi Shankara Madom',
      'description': 'Pooja Booking',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm'],
      },
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay open error: $e');
      isEnabled.value = false;
      Helpers.successToast("Unable to start payment");
    }
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    print(response.message);
    isEnabled.value = false;
    showPaymentStatusDialog("Payment failed");
  }

  void handleExternalWalletResponse(ExternalWalletResponse response) {
    isEnabled.value = false;
    Helpers.successToast("External wallet: ${response.walletName}");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) async {
    await _saveBillAndPrint(
      transId: response.paymentId,
      paymentMode: razorpayPaymentMode,
    );
  }

  Future<void> _saveBillAndPrint({String? transId, int? paymentMode}) async {
    final home = context.read<HomeProvider>();
    // bool connected = await PrinterService.connect();
    await home.saveBill(
      transid: transId,
      paymentMode: paymentMode,
      onSuccess: () async {
        Helpers.successToast(home.saveBillResponse?.message ?? 'Bill Saved');
        DateTime parsedDate = DateTime.parse(
          home.saveBillResponse?.summary?.billDate ?? '',
        );

        // Format it to desired format: dd-MM-yyyy HH:mm:ss
        String formatted = DateFormat('dd-MM-yyyy HH:mm:ss').format(parsedDate);
        // if (connected) {
        //   final templeData = home.saveBillResponse?.temple;
        //   // Malayalam selected (lanid != 1) and a
        //   // translated name is available — otherwise
        //   // fall back to the English name.
        //   final templeName =
        //       widget.lanid != 1 && (templeData?.nameMal?.isNotEmpty ?? false)
        //           ? templeData!.nameMal
        //           : templeData?.name;
        //   await PrinterService.printReceipt(
        //     temple: templeName,
        //     templeAddress: home.saveBillResponse?.temple?.addressLine1 ?? '',
        //     templePlace: home.saveBillResponse?.temple?.addressLine2 ?? '',
        //     today: formatted,
        //     id: home.saveBillResponse?.summary?.id,
        //     mode: home.saveBillResponse?.summary?.mode.toString(),
        //     total: home.saveBillResponse?.summary?.total.toString(),
        //     website: home.saveBillResponse?.temple?.website ?? '',
        //     items:
        //         home.pooja
        //             .asMap()
        //             .entries
        //             .map(
        //               (entry) => {
        //                 "personId": entry.key + 1, // index
        //                 "personName": entry.value.name,
        //                 "deity": entry.value.diety,
        //                 "star": entry.value.star,
        //                 "pooja": entry.value.pooja,
        //                 "qty": entry.value.qty,
        //                 "rate": entry.value.rate,
        //                 "date": entry.value.date,
        //                 "address": entry.value.address,
        //               },
        //             )
        //             .toList(),
        //   );
        // } else {
        //   Helpers.successToast(
        //     "Failed to connect to printer. Bill saved but printing failed.",
        //   );
        // }
        if (connectedPrinter != null) {
          final previewItems = home.previewBillResponse?.data?.poojaDetails;
          // Printed before leaving this screen, which stops the printer scan.
          // ESC/POS prints English only, so use the English temple name.
          await _printReceipts(
            name: home.saveBillResponse?.temple?.name,
            add1: home.saveBillResponse?.temple?.addressLine1 ?? '',
            add2: home.saveBillResponse?.temple?.addressLine2 ?? '',
            date: formatted,
            billno: home.saveBillResponse?.summary?.id?.toString() ?? '',
            mode: home.saveBillResponse?.summary?.mode?.toString() ?? '',
            total: home.saveBillResponse?.summary?.total?.toString() ?? '',
            website: home.saveBillResponse?.temple?.website ?? '',
            pooja:
                (previewItems != null && previewItems.isNotEmpty)
                    ? previewItems
                    : home.pooja,
          );
        } else {
          Helpers.successToast(
            "No connected printer. Bill saved but printing failed.",
          );
        }
        isEnabled.value = false;
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
          (route) => false,
        );
      },
      onFailure: () async {
        isEnabled.value = false;
        if (!mounted) return;
        showPaymentStatusDialog(
          "Payment received but the bill could not be saved.\n"
          "Please contact the counter.\n\nPayment ID: $transId",
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HomeProvider>(
        builder:
            (context, home, child) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topCenter,
                  end: AlignmentDirectional.bottomCenter,
                  colors: [
                    const Color.fromARGB(255, 243, 233, 98),
                    const Color.fromARGB(255, 244, 245, 199),
                    Colors.white,
                    Colors.white,
                    Colors.white,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -30.h,
                    right: -150.w,
                    child: Container(
                      height: 220.h,
                      width: 702.w,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage("assets/images/flwr.png"),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -45.h,
                    left: -250.w,
                    child: Container(
                      height: 220.h,
                      width: 702.w,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage("assets/images/flwr.png"),
                        ),
                      ),
                    ),
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            25.verticalSpace,
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(45.r),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Kalady Sri Adi Shankara Madom Telangana",
                                        style: Fontpalette.brown65700,
                                      ),
                                      Text(
                                        "Sri.Sri. Jagadguru Adi Shankaracharya MahaSamsthanam",
                                        style: Fontpalette.brown45600,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 80.h,
                                    width: 200.w,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.contain,
                                        image: AssetImage(
                                          "assets/images/kalady_logo.jpg",
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ).horizontalPadding(60.w).verticalPadding(15.h),
                            ),
                            20.verticalSpace,
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(45.r),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          onPressed:
                                              () => Navigator.of(context).pop(),
                                          icon: Icon(
                                            Icons.arrow_back_rounded,
                                            size: 80.w,
                                          ),
                                        ),
                                        Text(
                                          "Bill details",
                                          style: Fontpalette.blackinter50400,
                                        ),
                                        IconButton(
                                          onPressed:
                                              () => Navigator.of(context).pop(),
                                          icon: Icon(
                                            color: Colors.white,
                                            Icons.arrow_back_rounded,
                                            size: 70.w,
                                          ),
                                        ),
                                      ],
                                    ),
                                    10.verticalSpace,
                                    Container(
                                      height: 2.h,
                                      width: double.infinity,
                                      color: HexColor("#D97000"),
                                    ),
                                    20.verticalSpace,
                                    Expanded(
                                      child: ListView.separated(
                                        separatorBuilder:
                                            (context, index) =>
                                                10.verticalSpace,
                                        itemCount:
                                            home
                                                .previewBillResponse
                                                ?.data
                                                ?.poojaDetails
                                                ?.length ??
                                            0,
                                        // shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          final item =
                                              home
                                                  .previewBillResponse
                                                  ?.data
                                                  ?.poojaDetails![index];
                                          // The preview API doesn't receive/echo the pooja
                                          // name in the selected language (only IDs), so
                                          // fall back to the locally-tracked, already
                                          // localized name for display.
                                          final localPoojaName =
                                              index < home.pooja.length
                                                  ? home.pooja[index].pooja
                                                  : null;
                                          // "Kiosk User" is just a placeholder sent to
                                          // satisfy the API for Muttarukkal/Coconut/Net
                                          // Bag entries — not a real name, so don't show it.
                                          final rawDisplayName =
                                              (index < home.pooja.length
                                                  ? home.pooja[index].name
                                                  : null) ??
                                              item?.name;
                                          final displayName =
                                              rawDisplayName == "Kiosk User"
                                                  ? ""
                                                  : rawDisplayName;
                                          return Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                              border: Border.all(
                                                color: HexColor("#AD9999"),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "$displayName",
                                                        style:
                                                            Fontpalette
                                                                .black45600,
                                                      ),
                                                    ),
                                                    10.horizontalSpace,
                                                    // The Coconut line is
                                                    // always added together
                                                    // with its Muttarukkal
                                                    // line — it's removed
                                                    // automatically when the
                                                    // Muttarukkal line is
                                                    // removed, so it doesn't
                                                    // get its own button.
                                                    if (item?.poojaId ==
                                                        HomeProvider
                                                            .coconutPoojaId)
                                                      SizedBox()
                                                    else
                                                      InkWell(
                                                        onTap: () async {
                                                          final isMuttarukkal =
                                                              item?.poojaId ==
                                                              HomeProvider
                                                                  .muttarukkalPoojaId;
                                                          if (isMuttarukkal) {
                                                            await home
                                                                .removeMuttarukkalGroup(
                                                                  val:
                                                                      Navigator.of(
                                                                        context,
                                                                      ),
                                                                  index: index,
                                                                );
                                                          } else {
                                                            await home.removePooja(
                                                              val: Navigator.of(
                                                                context,
                                                              ),
                                                              index: index,
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  20.r,
                                                                ),
                                                            color:
                                                                const Color.fromARGB(
                                                                  255,
                                                                  238,
                                                                  102,
                                                                  23,
                                                                ),
                                                          ),
                                                          child:
                                                              home.poojaremoveloader ==
                                                                      LoaderState
                                                                          .loading
                                                                  ? CircularProgressIndicator(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                  ).horizontalPadding(
                                                                    20.w,
                                                                  )
                                                                  : Text(
                                                                    "Remove",
                                                                    style:
                                                                        Fontpalette
                                                                            .white38500,
                                                                  ).symmetricPadding(
                                                                    vertical:
                                                                        5.h,
                                                                    horizontal:
                                                                        20.w,
                                                                  ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                20.verticalSpace,
                                                Container(
                                                  height: 1.h,
                                                  width: double.infinity,
                                                  color: HexColor("#C9BEBE"),
                                                ),
                                                Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        item?.poojaId == null
                                                            ? SizedBox()
                                                            : Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: 600.w,
                                                                  child: Text(
                                                                    "${localPoojaName ?? item?.pooja}",
                                                                    style:
                                                                        Fontpalette
                                                                            .black45600,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "x ${item?.qty}",
                                                                  style:
                                                                      Fontpalette
                                                                          .black45600,
                                                                ),
                                                              ],
                                                            ),

                                                        Text(
                                                          "₹ ${item?.rate}",
                                                          style:
                                                              Fontpalette
                                                                  .black45600,
                                                        ),
                                                      ],
                                                    ).verticalPadding(7.h),
                                                  ],
                                                ),
                                              ],
                                            ).symmetricPadding(
                                              vertical: 15.h,
                                              horizontal: 60.w,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ).horizontalPadding(60.w).verticalPadding(20.h),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total Amount",
                                    style: Fontpalette.blackinter50400,
                                  ),
                                  Text(
                                    "₹ ${home.grossamount?.toStringAsFixed(0)}",
                                    style: Fontpalette.black60700,
                                  ),
                                ],
                              ),
                              // IconButton(
                              //   onPressed:
                              //       connectedPrinter != null
                              //           ? _printReceipts
                              //           : null,

                              //   icon: Icon(Icons.price_change),
                              // ),
                              ValueListenableBuilder<bool>(
                                valueListenable: isEnabled,
                                builder:
                                    (context, value, child) => InkWell(
                                      onTap: () {
                                        if (isEnabled.value) return;
                                        // Don't take payment without a receipt printer.
                                        if (connectedPrinter == null) {
                                          Helpers.successToast(
                                            "Please check the printer",
                                          );
                                          _startScanAndAutoConnect();
                                          return;
                                        }
                                        isEnabled.value = true;
                                        paymentrazorpay(amt: home.grossamount);
                                      },
                                      // onTap: () async {
                                      //   isEnabled.value = true;
                                      //   String? selectedPaymentMode =
                                      //       await selectPaymentMode(context);
                                      //   print(
                                      //     "Selected Payment Mode: $selectedPaymentMode",
                                      //   );
                                      //   if (selectedPaymentMode == null) {
                                      //     isEnabled.value = false;
                                      //     return;
                                      //   }
                                      //   showWaitingDialog();
                                      //   final paymentStatus =
                                      //       await saleTransaction(
                                      //         home.grossamount?.toStringAsFixed(
                                      //           2,
                                      //         ),
                                      //         selectedPaymentMode,
                                      //       );
                                      //   Navigator.pop(
                                      //     context,
                                      //   ); // Dismiss the waiting dialog

                                      //   bool connected =
                                      //       await PrinterService.connect();
                                      //   print(
                                      //     "Payment Status..button: $paymentStatus",
                                      //   );
                                      //   // if (paymentStatus == "success") {
                                      //   // AFTER
                                      //   if (paymentStatus == "timeout") {
                                      //     isEnabled.value = false;
                                      //     Helpers.successToast(
                                      //       "Payment timed out. Please try again.",
                                      //     );
                                      //     return;
                                      //   }
                                      //   if (paymentStatus == "success") {
                                      //     await home.saveBill(
                                      //       transid: "test",
                                      //       paymentMode:
                                      //           selectedPaymentMode == "CARD"
                                      //               ? 4
                                      //               : 6,
                                      //       onSuccess: () async {
                                      //         Helpers.successToast(
                                      //           home
                                      //                   .saveBillResponse
                                      //                   ?.message ??
                                      //               'Bill Saved',
                                      //         );
                                      //         DateTime parsedDate =
                                      //             DateTime.parse(
                                      //               home
                                      //                       .saveBillResponse
                                      //                       ?.summary
                                      //                       ?.billDate ??
                                      //                   '',
                                      //             );

                                      //         // Format it to desired format: dd-MM-yyyy HH:mm:ss
                                      //         String formatted = DateFormat(
                                      //           'dd-MM-yyyy HH:mm:ss',
                                      //         ).format(parsedDate);
                                      //         if (connected) {
                                      //           final templeData =
                                      //               home
                                      //                   .saveBillResponse
                                      //                   ?.temple;
                                      //           // Malayalam selected (lanid != 1) and a
                                      //           // translated name is available — otherwise
                                      //           // fall back to the English name.
                                      //           final templeName =
                                      //               widget.lanid != 1 &&
                                      //                       (templeData
                                      //                               ?.nameMal
                                      //                               ?.isNotEmpty ??
                                      //                           false)
                                      //                   ? templeData!.nameMal
                                      //                   : templeData?.name;
                                      //           await PrinterService.printReceipt(
                                      //             temple: templeName,
                                      //             templeAddress:
                                      //                 home
                                      //                     .saveBillResponse
                                      //                     ?.temple
                                      //                     ?.addressLine1 ??
                                      //                 '',
                                      //             templePlace:
                                      //                 home
                                      //                     .saveBillResponse
                                      //                     ?.temple
                                      //                     ?.addressLine2 ??
                                      //                 '',
                                      //             today: formatted,
                                      //             id:
                                      //                 home
                                      //                     .saveBillResponse
                                      //                     ?.summary
                                      //                     ?.id,
                                      //             mode:
                                      //                 home
                                      //                     .saveBillResponse
                                      //                     ?.summary
                                      //                     ?.mode
                                      //                     .toString(),
                                      //             total:
                                      //                 home
                                      //                     .saveBillResponse
                                      //                     ?.summary
                                      //                     ?.total
                                      //                     .toString(),
                                      //             website:
                                      //                 home
                                      //                     .saveBillResponse
                                      //                     ?.temple
                                      //                     ?.website ??
                                      //                 '',
                                      //             items:
                                      //                 home.pooja
                                      //                     .asMap()
                                      //                     .entries
                                      //                     .map(
                                      //                       (entry) => {
                                      //                         "personId":
                                      //                             entry.key +
                                      //                             1, // index
                                      //                         "personName":
                                      //                             entry
                                      //                                 .value
                                      //                                 .name,
                                      //                         "deity":
                                      //                             entry
                                      //                                 .value
                                      //                                 .diety,
                                      //                         "star":
                                      //                             entry
                                      //                                 .value
                                      //                                 .star,
                                      //                         "pooja":
                                      //                             entry
                                      //                                 .value
                                      //                                 .pooja,
                                      //                         "qty":
                                      //                             entry
                                      //                                 .value
                                      //                                 .qty,
                                      //                         "rate":
                                      //                             entry
                                      //                                 .value
                                      //                                 .rate,
                                      //                         "date":
                                      //                             entry
                                      //                                 .value
                                      //                                 .date,
                                      //                         "address":
                                      //                             entry
                                      //                                 .value
                                      //                                 .address,
                                      //                       },
                                      //                     )
                                      //                     .toList(),
                                      //           );
                                      //           isEnabled.value = false;
                                      //           Navigator.pushAndRemoveUntil(
                                      //             context,
                                      //             MaterialPageRoute(
                                      //               builder:
                                      //                   (context) =>
                                      //                       MyHomePage(),
                                      //             ),
                                      //             (route) => false,
                                      //           );
                                      //         } else {
                                      //           Helpers.successToast(
                                      //             "Failed to connect to printer. Bill saved but printing failed.",
                                      //           );
                                      //           isEnabled.value = false;
                                      //           Navigator.pushAndRemoveUntil(
                                      //             context,
                                      //             MaterialPageRoute(
                                      //               builder:
                                      //                   (context) =>
                                      //                       MyHomePage(),
                                      //             ),
                                      //             (route) => false,
                                      //           );
                                      //         }
                                      //       },
                                      //       onFailure: () async {
                                      //         isEnabled.value = false;
                                      //       },
                                      //     );
                                      //   } else {
                                      //     isEnabled.value = false;
                                      //     showPaymentStatusDialog(
                                      //       "Payment failed",
                                      //     );
                                      //   }
                                      // },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            27.r,
                                          ),
                                          color: HexColor("#EC5002"),
                                        ),
                                        child:
                                            // isEnabled.value == true
                                            //     ? CircularProgressIndicator(
                                            //       color: Colors.white,
                                            //     ).horizontalPadding(20.w)
                                            //     : Text(
                                            //       "Confirm",
                                            //       style: Fontpalette.white45600,
                                            //     ).symmetricPadding(
                                            //       vertical: 18.h,
                                            //       horizontal: 150.w,
                                            //     ),
                                            // AFTER
                                            isEnabled.value == true
                                                ? CircularProgressIndicator(
                                                  color: Colors.white,
                                                ).horizontalPadding(20.w)
                                                : Text(
                                                  "Continue",
                                                  style: Fontpalette.white50700,
                                                ).symmetricPadding(
                                                  vertical: 18.h,
                                                  horizontal: 150.w,
                                                ),
                                      ),
                                    ),
                              ),
                            ],
                          ),
                          20.verticalSpace,
                        ],
                      ).horizontalPadding(100.w),
                    ],
                  ).horizontalPadding(90.w).topPadding(40.h).bottomPadding(5.h),
                ],
              ),
            ),
      ),
    );
  }

  void showWaitingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: HexColor("#EC5002")),
                20.verticalSpace,
                Text(
                  "Waiting for payment...",
                  textAlign: TextAlign.center,
                  style: Fontpalette.blackinter45400,
                ),
              ],
            ),
          ),
    );
  }
}
