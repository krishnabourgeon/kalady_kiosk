import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer_platform_interface.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:http/http.dart' as http;
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
import 'package:kalady_kiosk/provider/payment_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

// import 'package:razorpay_flutter/razorpay_flutter.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key, this.lanid});
  final int? lanid;
  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final ValueNotifier<bool> isEnabled = ValueNotifier<bool>(false);
   final Razorpay _razorpay = Razorpay();

  // // Kalady Sankara Madom (as.kaladyshankaramadomts.org) Razorpay live key.
   static const String razorpayKey = 'rzp_live_drsvRJJ88Gwafu';
  // // TODO: confirm the payment-mode id the backend expects for Razorpay payments.
   static const int razorpayPaymentMode = 6;

  // UPI QR payment (sib/qr/generate).
  static const String qrTransactionNote = 'test';
  // Must be unique per QR: UPI apps reject a reused reference ("tr"), which
  // is why a fixed "testing" made GPay fail. Letters + digits only.
  static String newTransactionReference() =>
      'KLDK${DateTime.now().millisecondsSinceEpoch}';
  static const int qrExpireMinutes = 15;
  // TODO: confirm the payment-mode id the backend expects for QR payments.
  static const int qrPaymentMode = 6;
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
    String? billImage,
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
        logo: await _loadLogoRaster(billImage: billImage),
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

  // Logo printed at the top of the receipt (256 of the 384 dots on 58mm paper).
  // Comes from the API's bill_image; the bundled logo is only a fallback.
  static const String _logoAsset = 'assets/images/kalady_logo.jpg';
  static const int _logoWidth = 256;
  List<int>? _logoRaster;
  String? _logoRasterSource;

  // bill_image may be a URL or base64 (optionally a data: URI).
  Future<Uint8List?> _fetchBillImage(String billImage) async {
    try {
      if (billImage.startsWith('http')) {
        final res = await http
            .get(Uri.parse(billImage))
            .timeout(const Duration(seconds: 10));
        return res.statusCode == 200 ? res.bodyBytes : null;
      }
      final base64Data =
          billImage.contains(',') ? billImage.split(',').last : billImage;
      return base64Decode(base64Data);
    } catch (e) {
      debugPrint('bill_image load error ($billImage): $e');
      return null;
    }
  }

  // Converts the logo to an ESC/POS raster image (GS v 0): each pixel darker
  // than mid-grey becomes a printed dot. Cached per image source.
  Future<List<int>?> _loadLogoRaster({String? billImage}) async {
    final source =
        (billImage ?? '').trim().isNotEmpty ? billImage!.trim() : _logoAsset;
    if (_logoRaster != null && _logoRasterSource == source) return _logoRaster;
    try {
      Uint8List? imageBytes;
      if (source != _logoAsset) imageBytes = await _fetchBillImage(source);
      imageBytes ??= (await rootBundle.load(_logoAsset)).buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: _logoWidth,
      );
      final image = (await codec.getNextFrame()).image;
      final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (rgba == null) return null;
      final width = image.width;
      final height = image.height;
      final bytesPerRow = (width + 7) ~/ 8;
      final raster = List<int>.filled(bytesPerRow * height, 0);
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final i = (y * width + x) * 4;
          final r = rgba.getUint8(i);
          final g = rgba.getUint8(i + 1);
          final b = rgba.getUint8(i + 2);
          final a = rgba.getUint8(i + 3);
          final luminance = 0.299 * r + 0.587 * g + 0.114 * b;
          if (a > 127 && luminance < 128) {
            raster[y * bytesPerRow + (x ~/ 8)] |= 0x80 >> (x % 8);
          }
        }
      }
      image.dispose();
      _logoRaster = [
        29, 118, 48, 0, // GS v 0, normal size
        bytesPerRow & 0xFF, bytesPerRow >> 8,
        height & 0xFF, height >> 8,
        ...raster,
      ];
      _logoRasterSource = source;
      return _logoRaster;
    } catch (e) {
      debugPrint('Logo load error: $e');
      return null;
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
    List<int>? logo,
  }) {
    List<int> bytes = [];

    // Initialize
    bytes += [27, 64]; // ESC @

    // ---------------- Header: temple name + address ----------------
    bytes += [27, 97, 1]; // ESC a 1 -> center align
    if (logo != null) {
      bytes += logo;
      bytes += utf8.encode("\n");
    }
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
    // Deity name(s) of the bill, e.g. "ANNADHANAM Receipt".
    final deities =
        (pooja ?? [])
            .map((item) => (item.diety ?? '').trim())
            .where((d) => d.isNotEmpty)
            .toSet()
            .join(', ');
    bytes += utf8.encode(
      "${deities.isEmpty ? '' : '${deities.toUpperCase()} '}Receipt\n",
    );
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
        // E-Hundi: print only the amount.
        if (item.name == HomeProvider.eHundiName) {
          bytes += utf8.encode(
            "${_twoColumnText('${i + 1}. Amount', 'Rs.${item.rate ?? '0'}')}\n",
          );
          if (i != pooja.length - 1) {
            bytes += utf8.encode("\n");
          }
          continue;
        }
        // "Kiosk User" is a placeholder name, not a real devotee.
        final personName = item.name == "Kiosk User" ? '' : (item.name ?? '');
        final star = item.star ?? '';

        bytes += [27, 69, 1]; // bold on
        bytes += utf8.encode(
          "${i + 1}. $personName${star.isNotEmpty ? ' - $star' : ''}\n",
        );
        bytes += [27, 69, 0]; // bold off

        // Deity is printed in the heading instead.
        // if ((item.diety ?? '').isNotEmpty) {
        //   bytes += utf8.encode("   ${item.diety}\n");
        // }

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

  // Continue: generate the UPI QR for the bill amount and show it.
  Future<void> _startQrPayment() async {
    if (isEnabled.value) return;
    final amount = context.read<HomeProvider>().grossamount;
    if (amount == null || amount <= 0) {
      Helpers.successToast("Invalid amount");
      return;
    }
    isEnabled.value = true;
    final payment = context.read<PaymentProvider>();
    await payment.generateQr(
      amount: amount,
      transactionNote: qrTransactionNote,
      transactionReference: newTransactionReference(),
      expireMinutes: qrExpireMinutes,
    );
    if (!mounted) return;
    final intentUrl = payment.intentUrl;
    if (intentUrl == null || intentUrl.isEmpty) {
      isEnabled.value = false;
      Helpers.successToast(
        payment.qrResponse?.message ?? "Unable to generate QR code",
      );
      return;
    }
    // The dialog polls sib/qr/check-status and closes with the result:
    // 'success', 'failed', or null (cancelled / expired).
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => _QrPaymentDialog(
            intentUrl: intentUrl,
            amount: amount,
            expireMinutes: qrExpireMinutes,
          ),
    );
    if (!mounted) return;
    if (result == 'success') {
      final transId = payment.paymentReference;
      payment.clearPayment();
      // Keeps the button disabled until the bill is saved and printed.
      await _saveBillAndPrint(transId: transId, paymentMode: qrPaymentMode);
      return;
    }
    payment.clearPayment();
    isEnabled.value = false;
    if (result == 'failed') {
      showPaymentStatusDialog("Payment failed");
    }
  }

  // Saves the bill and prints the receipt after the QR payment succeeds.
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
            billImage:
                home.saveBillResponse?.billimage ??
                home.previewBillResponse?.data?.billimage,
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

                                      //   // ------this is the correct --------------------------------------------------------
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
                                      //  // -----------------------------------------------------------------
                                        //_startQrPayment();


                                        


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

// Shows the UPI QR with the amount and a countdown until it expires.
class _QrPaymentDialog extends StatefulWidget {
  const _QrPaymentDialog({
    required this.intentUrl,
    required this.amount,
    required this.expireMinutes,
  });
  final String intentUrl;
  final double amount;
  final int expireMinutes;

  @override
  State<_QrPaymentDialog> createState() => _QrPaymentDialogState();
}

class _QrPaymentDialogState extends State<_QrPaymentDialog> {
  late int _secondsLeft = widget.expireMinutes * 60;
  Timer? _timer;
  Timer? _statusTimer;
  bool _checking = false;
  bool _closed = false;

  // How often sib/qr/check-status is called while the QR is shown.
  static const Duration _statusInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 1) {
        // One last check in case the payment landed just before expiry.
        _checkStatus(isFinal: true);
        return;
      }
      setState(() => _secondsLeft--);
    });
    _statusTimer = Timer.periodic(_statusInterval, (_) => _checkStatus());
  }

  Future<void> _checkStatus({bool isFinal = false}) async {
    if (_checking || _closed) return;
    _checking = true;
    final payment = context.read<PaymentProvider>();
    await payment.checkPaymentStatus();
    _checking = false;
    if (!mounted || _closed) return;
    if (payment.paymentState == 'success') {
      _close('success');
    } else if (payment.paymentState == 'failed') {
      _close('failed');
    } else if (isFinal) {
      Helpers.successToast("QR code expired. Please try again.");
      _close(null);
    }
  }

  // Check once more before closing, in case the customer already paid.
  Future<void> _cancel() async {
    await _checkStatus();
    if (!mounted || _closed) return;
    _close(null);
  }

  void _close(String? result) {
    if (_closed) return;
    _closed = true;
    _timer?.cancel();
    _statusTimer?.cancel();
    Navigator.of(context).pop(result);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Scan to pay", style: Fontpalette.blackinter50400),
          10.verticalSpace,
          Text(
            "₹ ${widget.amount.toStringAsFixed(0)}",
            style: Fontpalette.black60700,
          ),
          20.verticalSpace,
          SizedBox(
            width: 500.w,
            height: 500.w,
            child: QrImageView(
              data: widget.intentUrl,
              backgroundColor: Colors.white,
            ),
          ),
          20.verticalSpace,
          Text(
            "Scan with any UPI app",
            textAlign: TextAlign.center,
            style: Fontpalette.blackinter45400,
          ),
          10.verticalSpace,
          Text(
            "Expires in $minutes:$seconds",
            style: Fontpalette.blackinter45400.copyWith(color: Colors.red),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: Text("Cancel", style: Fontpalette.blackinter45400),
        ),
      ],
    );
  }
}
