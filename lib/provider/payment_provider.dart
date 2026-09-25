import 'package:flutter/material.dart';
import 'package:kalady_kiosk/models/generate_qr_response.dart';
import 'package:kalady_kiosk/models/payment_response_status.dart';
import 'package:kalady_kiosk/services/provider_helper_class.dart';

class PaymentProvider extends ProviderHelperClass with ChangeNotifier {
  @override
  void updateLoadState(LoaderState state) {}

  LoaderState qrLoader = LoaderState.initial;

  LoaderState statusLoader = LoaderState.initial;

  PaymentStatusResponse? paymentStatusResponse;

  // Result of the last status check: 'success', 'failed' or 'pending'.
  String paymentState = 'pending';

  static const _failedStates = {
    'FAILED', 'FAILURE', 'FAIL', 'DECLINED', 'REJECTED', 'EXPIRED', 'CANCELLED',
  };
  static const _pendingStates = {
    'PENDING', 'INITIATED', 'PROCESSING', 'CREATED', 'IN_PROGRESS', 'WAITING',
  };

  // Payment state from the check-status response. The field that carries it
  // isn't documented yet, so the usual names are checked; the raw response
  // is logged by the service (PAYMENT STATUS RESPONSE) to confirm.
  String _stateFrom(PaymentStatusResponse? response, {required bool apiOk}) {
    final data = response?.data;
    String? state;
    if (data is Map) {
      for (final key in const [
        'status',
        'payment_status',
        'txn_status',
        'transaction_status',
        'result',
      ]) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) {
          state = value.trim().toUpperCase();
          break;
        }
      }
    }
    if (state != null) {
      if (_failedStates.contains(state)) return 'failed';
      if (_pendingStates.contains(state)) return 'pending';
      if (const {'SUCCESS', 'PAID', 'COMPLETED', 'CAPTURED'}.contains(state)) {
        return 'success';
      }
    }
    // No explicit state: status true = paid, otherwise not paid yet.
    return apiOk ? 'success' : 'pending';
  }

  // Bank reference for the paid transaction, saved as the bill's transaction id.
  String? get paymentReference {
    final data = paymentStatusResponse?.data;
    if (data is Map) {
      for (final key in const ['rrn', 'bank_ref_no', 'psp_ref_no', 'txn_id']) {
        final value = data[key];
        if (value != null && value.toString().isNotEmpty) {
          return value.toString();
        }
      }
    }
    return tid;
  }

  void updateStatusLoader(LoaderState state) {
    statusLoader = state;
    notifyListeners();
  }
  GenerateQrResponse? qrResponse;

  String? intentUrl;
  String? tid;
  String? transactionReference;

  void updateQrLoader(LoaderState state) {
    qrLoader = state;
    notifyListeners();
  }

  Future<void> generateQr({
    required double amount,
    required String transactionNote,
    required String transactionReference,
    int expireMinutes = 5,
    Function? onSuccess,
    Function? onFailure,
  }) async {
    updateQrLoader(LoaderState.loading);

    try {
      final res = await serviceConfig.generatePaymentQr(
        amount: amount,
        transactionNote: transactionNote,
        transactionReference: transactionReference,
        expireMinutes: expireMinutes,
      );

      if (res.isValue) {
        qrResponse = res.asValue!.value;

        intentUrl = qrResponse?.data?.intentUrl;
        tid = qrResponse?.data?.tid;
        this.transactionReference =
            qrResponse?.data?.transactionReference;

        if (qrResponse?.status == true &&
            intentUrl != null &&
            intentUrl!.isNotEmpty) {
          updateQrLoader(LoaderState.loaded);

          if (onSuccess != null) {
            onSuccess();
          }
        } else {
          updateQrLoader(LoaderState.error);

          if (onFailure != null) {
            onFailure();
          }
        }
      } else {
        updateQrLoader(LoaderState.error);

        if (onFailure != null) {
          onFailure();
        }
      }
    } catch (e) {
      debugPrint("QR Provider Exception: $e");

      updateQrLoader(LoaderState.error);

      if (onFailure != null) {
        onFailure();
      }
    }
  }

  Future<void> checkPaymentStatus({
  Function? onSuccess,
  Function? onFailure,
}) async {
  // tid is the terminal id (same for every QR), so the per-payment
  // transaction_reference identifies this payment.
  final pspRefNo =
      (transactionReference?.isNotEmpty ?? false) ? transactionReference! : tid;
  if (pspRefNo == null || pspRefNo.isEmpty) {
    debugPrint("psp_ref_no is empty");
    return;
  }

  updateStatusLoader(LoaderState.loading);

  try {
    final res = await serviceConfig.checkPaymentStatus(
      pspRefNo: pspRefNo,
      transactionReference: transactionReference,
    );

    if (res.isValue) {
      paymentStatusResponse = res.asValue!.value;
      paymentState = _stateFrom(paymentStatusResponse, apiOk: true);

      debugPrint(
        "Payment Status: ${paymentStatusResponse?.message} -> $paymentState",
      );

      updateStatusLoader(LoaderState.loaded);

      if (onSuccess != null) {
        onSuccess();
      }
    } else {
      final error = res.asError?.error;
      if (error is PaymentStatusResponse) {
        paymentStatusResponse = error;
        paymentState = _stateFrom(error, apiOk: false);
      } else {
        paymentState = 'pending';
      }
      debugPrint("Payment Status (not paid yet): $paymentState");
      updateStatusLoader(LoaderState.error);

      if (onFailure != null) {
        onFailure();
      }
    }
  } catch (e) {
    debugPrint("Payment status provider exception: $e");

    updateStatusLoader(LoaderState.error);

    if (onFailure != null) {
      onFailure();
    }
  }
}

  void clearPayment() {
    qrResponse = null;
    intentUrl = null;
    tid = null;
    transactionReference = null;
    paymentStatusResponse = null;
    paymentState = 'pending';
    qrLoader = LoaderState.initial;

    notifyListeners();
  }
}