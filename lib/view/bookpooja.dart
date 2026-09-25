import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show DateFormat;
import 'package:kalady_kiosk/color_pallatte.dart';
import 'package:kalady_kiosk/extension.dart';
import 'package:kalady_kiosk/fontpallate.dart';
import 'package:kalady_kiosk/provider/homeprovider.dart';
import 'package:kalady_kiosk/services/helpers.dart';
import 'package:kalady_kiosk/services/provider_helper_class.dart';
import 'package:kalady_kiosk/view/billpreview.dart';
import 'package:kalady_kiosk/view/homepage.dart';
import 'package:provider/provider.dart';

class Bookpoojascreen extends StatefulWidget {
  const Bookpoojascreen({
    super.key,
    this.lanid,
    this.deityId,
    this.deityName,
    this.rateEditable = false,
    this.isEHundi = false,
  });
  // E-Hundi: only the amount is asked; name/star/date are filled in.
  final bool isEHundi;
  final int? lanid;
  // Deity's rate_editable == 1: always show the Amount field, even with poojas.
  final bool rateEditable;
  // Deity chosen on the previous screen; when set, the deity picker is hidden.
  final int? deityId;
  final String? deityName;
  @override
  State<Bookpoojascreen> createState() => _BookpoojascreenState();
}

class _BookpoojascreenState extends State<Bookpoojascreen> {
  TextEditingController name = TextEditingController();
  TextEditingController amt = TextEditingController();
  DateTime? selectedDate;

  // Live English-to-Malayalam transliteration for the Name field.
  // _romanName tracks what the user actually typed (Latin letters); the
  // visible `name` field is replaced with the transliterated Malayalam
  // once they pause typing, only when the Malayalam language is selected.
  String _romanName = '';
  int _lastNameFieldLength = 0;
  bool _isProgrammaticNameUpdate = false;
  Timer? _transliterateDebounce;

  void _resetNameTransliterationState() {
    _romanName = '';
    _lastNameFieldLength = 0;
    _transliterateDebounce?.cancel();
  }

  void _onNameChanged(String value) {
    if (_isProgrammaticNameUpdate) {
      _isProgrammaticNameUpdate = false;
      _lastNameFieldLength = value.length;
      return;
    }

    if (widget.lanid == 1) {
      // English selected — type as-is, no transliteration.
      _lastNameFieldLength = value.length;
      return;
    }

    // Mirror this edit onto the roman (Latin) buffer.
    final delta = value.length - _lastNameFieldLength;
    if (delta > 0) {
      _romanName += value.substring(value.length - delta);
    } else if (delta < 0) {
      final removeCount = -delta;
      _romanName =
          _romanName.length >= removeCount
              ? _romanName.substring(0, _romanName.length - removeCount)
              : '';
    }
    _lastNameFieldLength = value.length;

    _transliterateDebounce?.cancel();
    if (_romanName.trim().isEmpty) return;
    _transliterateDebounce = Timer(
      const Duration(milliseconds: 1500),
      _transliterateName,
    );
  }

  Future<void> _transliterateName() async {
    final source = _romanName;
    if (source.trim().isEmpty) return;
    try {
      final uri = Uri.parse(
        'https://inputtools.google.com/request?text=${Uri.encodeComponent(source)}'
        '&itc=ml-t-i0-und&num=1&cp=0&cs=1&ie=utf-8&oe=utf-8',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return;
      final decoded = jsonDecode(response.body);
      if (decoded is! List || decoded.isEmpty || decoded[0] != 'SUCCESS') {
        return;
      }
      final results = decoded[1] as List;
      if (results.isEmpty) return;
      final suggestions = results[0][1] as List;
      if (suggestions.isEmpty) return;
      final malayalam = suggestions[0] as String;

      if (!mounted || source != _romanName) return;
      _isProgrammaticNameUpdate = true;
      name.value = TextEditingValue(
        text: malayalam,
        selection: TextSelection.collapsed(offset: malayalam.length),
      );
      _lastNameFieldLength = malayalam.length;
    } catch (e) {
      debugPrint('Transliteration error: $e');
    }
  }

  @override
  void dispose() {
    _transliterateDebounce?.cancel();
    super.dispose();
  }

  Future<void> pickDate() async {
    final home = context.read<HomeProvider>();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      home.updateSelectedDate(date: picked);
    }
  }

  final ValueNotifier<bool> isEnabled = ValueNotifier<bool>(false);

  // Amount is typed in when the deity has no poojas or its rate is editable.
  bool _showAmount(HomeProvider home) =>
      widget.rateEditable || widget.isEHundi || home.isAmountOnly;

  // E-Hundi: send name "E-HUNDI", star 28 and today's date with the amount.
  Future<void> _continueEHundi(HomeProvider home) async {
    final enteredAmount = double.tryParse(amt.text);
    if (enteredAmount == null || enteredAmount <= 0) {
      Helpers.successToast("Please enter a valid  amount");
      return;
    }
    FocusScope.of(context).unfocus();
    isEnabled.value = true;
    final eHundiStars =
        home.starsResponse?.data
            ?.where((s) => s.id == HomeProvider.eHundiStarId)
            .toList() ??
        [];
    home.clearGrossAmount();
    await home.addToPoojaDetails(
      name: HomeProvider.eHundiName,
      starid: HomeProvider.eHundiStarId,
      star:
          eHundiStars.isEmpty
              ? null
              : (widget.lanid == 1
                  ? eHundiStars.first.nameEng
                  : eHundiStars.first.nameMal),
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      dietyid: home.dietyId,
      diety: home.dietyIName,
      poojaname: home.selectedPoojaName ?? home.dietyIName,
      poojaid: HomeProvider.eHundiPoojaId,
      rate: amt.text,
    );
    await home.getPreviewBill(
      onSuccess: () async {
        navigatescrren(page: PreviewScreen(), context: context);
        home.clearStoredData();
        amt.clear();
        isEnabled.value = false;
      },
      onFailure: () {
        isEnabled.value = false;
      },
    );
  }

  // Rate-editable deity: pre-fill the amount with the pooja's rate.
  void _onPoojaSelected(String? rate) {
    if (!widget.rateEditable) return;
    final value = double.tryParse(rate ?? '');
    amt.text =
        value == null
            ? ''
            : value == value.roundToDouble()
            ? value.toStringAsFixed(0)
            : value.toString();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final home = context.read<HomeProvider>();
      if (widget.deityId != null) {
        home.updateDietyId(id: widget.deityId, name: widget.deityName);
        home.updateSelextedPoojaId(poojaid: null, poojaname: null, rate: null);
      } else {
        if (home.deitiesResponse?.data != null &&
            home.deitiesResponse!.data!.isNotEmpty) {
          final firstDeity = home.deitiesResponse!.data!.first;
          home.updateDietyId(
            id: firstDeity.id,
            name: widget.lanid == 1 ? firstDeity.name : firstDeity.nameMal,
          );
          home.updateSelextedPoojaId(
            poojaid: null,
            poojaname: null,
            rate: null,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
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

            Consumer<HomeProvider>(
              builder: (context, home, child) {
                return Column(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Kalady Sri Adi Shankara Madom Telangana",
                                      style: Fontpalette.brown65700,
                                    ),
                                    Text(
                                      "Sri.Sri. Jagadguru Adi Shankaracharya MahaSamsthanam",
                                      style: Fontpalette.grey45600,
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
                                  if (!widget.isEHundi) ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Name",
                                                style:
                                                    Fontpalette.blackinter40400,
                                              ),
                                              5.verticalSpace,
                                              Container(
                                                height: 50.h,

                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        21.r,
                                                      ),
                                                  border: Border.all(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                child: TextField(
                                                  controller: name,
                                                  //onChanged: _onNameChanged,
                                                  style:
                                                      Fontpalette
                                                          .blackinter45400,
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                          vertical: 15.h,
                                                          horizontal: 40.w,
                                                        ),

                                                    hintText: " ",
                                                    hintStyle:
                                                        Fontpalette
                                                            .blackinter24400,
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        30.horizontalSpace,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Choose date",
                                              style:
                                                  Fontpalette.blackinter40400,
                                            ),
                                            5.verticalSpace,
                                            InkWell(
                                              onTap: () => pickDate(),
                                              child: Container(
                                                height: 50.h,
                                                width: 500.w,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        21.r,
                                                      ),
                                                  border: Border.all(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      home.selecteddate ?? '',
                                                      style:
                                                          Fontpalette
                                                              .blackinter45400,
                                                    ).horizontalPadding(40.w),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    10.verticalSpace,
                                    Row(
                                      children: [
                                        Text(
                                          "Select star",
                                          style: Fontpalette.blackinter40400,
                                        ),
                                      ],
                                    ),
                                    5.verticalSpace,
                                    SizedBox(
                                      height: 35.h,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            home.starsResponse?.data?.length ??
                                            0,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              right: 15.w,
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                FocusScope.of(
                                                  context,
                                                ).unfocus();
                                                home.updateSelextedStarId(
                                                  starid:
                                                      home
                                                          .starsResponse
                                                          ?.data![index]
                                                          .id,
                                                  starname:
                                                      widget.lanid == 1
                                                          ? home
                                                              .starsResponse
                                                              ?.data![index]
                                                              .nameEng
                                                          : home
                                                              .starsResponse
                                                              ?.data![index]
                                                              .nameMal,
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.r,
                                                      ),
                                                  color:
                                                      home.selectedStarId ==
                                                              home
                                                                  .starsResponse
                                                                  ?.data![index]
                                                                  .id
                                                          ? Colors.black
                                                              .withOpacity(0.5)
                                                          : Colors.white,
                                                  border: Border.all(
                                                    color: HexColor("#D2D2D2"),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    widget.lanid == 1
                                                        ? "${home.starsResponse?.data![index].nameEng}"
                                                        : "${home.starsResponse?.data![index].nameMal}",
                                                    style:
                                                        home.selectedStarId !=
                                                                home
                                                                    .starsResponse
                                                                    ?.data![index]
                                                                    .id
                                                            ? Fontpalette
                                                                .black52700
                                                            : Fontpalette
                                                                .white52700,
                                                  ).horizontalPadding(30.w),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                  if (widget.deityId == null) ...[
                                    Row(
                                      children: [
                                        Text(
                                          "Select diety",
                                          style: Fontpalette.blackinter40400,
                                        ),
                                      ],
                                    ),
                                    5.verticalSpace,
                                    Builder(
                                      builder: (context) {
                                        final filteredDeities =
                                            (home.deitiesResponse?.data ?? [])
                                                .where(
                                                  (d) =>
                                                      d.name?.toUpperCase() !=
                                                      "DONATION",
                                                )
                                                .toList();
                                        return SizedBox(
                                          height: 65.h,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: filteredDeities.length,
                                            itemBuilder: (context, index) {
                                              final deity =
                                                  filteredDeities[index];
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                  right: 30.w,
                                                ),
                                                child: InkWell(
                                                  onTap: () {
                                                    FocusScope.of(
                                                      context,
                                                    ).unfocus();
                                                    home.updateDietyId(
                                                      id: deity.id,
                                                      name:
                                                          widget.lanid == 1
                                                              ? deity.name
                                                              : deity.nameMal,
                                                    );
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Expanded(
                                                        child: Stack(
                                                          children: [
                                                            Container(
                                                              width: 200.w,
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      27.r,
                                                                    ),
                                                                image: DecorationImage(
                                                                  image: AssetImage(
                                                                    "assets/images/pooja.png",
                                                                  ),
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                ),
                                                              ),
                                                            ),
                                                            if (home.dietyId ==
                                                                deity.id)
                                                              Container(
                                                                width: 200.w,
                                                                decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                        0.5,
                                                                      ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        27.r,
                                                                      ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      5.verticalSpace,
                                                      Text(
                                                        widget.lanid == 1
                                                            ? "${deity.name}"
                                                            : "${deity.nameMal}",
                                                        style:
                                                            Fontpalette
                                                                .black45600,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                  10.verticalSpace,
                                  if (!home.isAmountOnly && !widget.isEHundi)
                                    home.len > 15
                                        ? SizedBox(
                                          height: 400.h,
                                          child: Listpooja(
                                            len: home.len,
                                            lanid: widget.lanid,
                                            onPoojaSelected: _onPoojaSelected,
                                          ),
                                        )
                                        : Listpooja(
                                          len: home.len,
                                          lanid: widget.lanid,
                                          onPoojaSelected: _onPoojaSelected,
                                        ),
                                  if (_showAmount(home))
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (!home.isAmountOnly)
                                          10.verticalSpace,
                                        Text(
                                          "Amount",
                                          style: Fontpalette.blackinter40400,
                                        ),
                                        5.verticalSpace,
                                        Container(
                                          height: 50.h,

                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              21.r,
                                            ),
                                            border: Border.all(
                                              color: Colors.black,
                                            ),
                                          ),
                                          child:
                                          // TextField(
                                          //   keyboardType:
                                          //       TextInputType.numberWithOptions(decimal: true),
                                          //   controller: amt,
                                          //   style:
                                          //       Fontpalette.blackinter45400,
                                          //   textAlignVertical:
                                          //       TextAlignVertical.center,
                                          //   decoration: InputDecoration(
                                          //     isDense: true,
                                          //     contentPadding:
                                          //         EdgeInsets.symmetric(
                                          //           vertical: 15.h,
                                          //           horizontal: 40.w,
                                          //         ),
                                          //     hintText: " ",
                                          //     hintStyle:
                                          //         Fontpalette.blackinter24400,
                                          //     border: InputBorder.none,
                                          //   ),
                                          // ),
                                          TextField(
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            controller: amt,
                                            style: Fontpalette.blackinter45400,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 15.h,
                                                    horizontal: 40.w,
                                                  ),

                                              hintText: " ",
                                              hintStyle:
                                                  Fontpalette.blackinter24400,
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  10.verticalSpace,
                                  Container(
                                    height: 2.h,
                                    color: HexColor("#D97000"),
                                  ),
                                  15.verticalSpace,
                                  if (!home.isAmountOnly && !widget.isEHundi)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            if (name.text.isEmpty) {
                                              Helpers.successToast(
                                                "Please enter your name",
                                              );
                                              return;
                                            }
                                            if (home.selectedStarId == null) {
                                              Helpers.successToast(
                                                "Please select your star",
                                              );
                                              return;
                                            }
                                            if (home.selectedPoojaId == null &&
                                                !home.isAmountOnly) {
                                              Helpers.successToast(
                                                "Please a pooja",
                                              );
                                              return;
                                            }
                                            if (amt.text.isEmpty &&
                                                _showAmount(home)) {
                                              Helpers.successToast(
                                                "Please enter the amount",
                                              );
                                              return;
                                            }
                                            if (_showAmount(home)) {
                                              final enteredAmount =
                                                  double.tryParse(amt.text);
                                              if (enteredAmount == null ||
                                                  enteredAmount <= 0) {
                                                Helpers.successToast(
                                                  "Please enter a valid  amount",
                                                );
                                                return;
                                              }
                                            }
                                            FocusScope.of(context).unfocus();
                                            await home.addToPoojaDetails(
                                              name: name.text,
                                              star: home.selectedStarrname,
                                              date: home.dateapi,
                                              dietyid: home.dietyId,
                                              diety: home.dietyIName,

                                              poojaname:
                                                  home.isAmountOnly
                                                      ? home.dietyIName
                                                      : home.selectedPoojaName,
                                              poojaid: home.selectedPoojaId,

                                              rate:
                                                  _showAmount(home)
                                                      ? amt.text
                                                      : home.selectedpoojarate,
                                              starid: home.selectedStarId,
                                            );
                                            home.clearStoredData();
                                            name.clear();
                                            _resetNameTransliterationState();
                                            amt.clear();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: HexColor("#FDEFD3"),
                                              borderRadius:
                                                  BorderRadius.circular(33.r),
                                            ),
                                            child: Text(
                                              "Add more person",
                                              style:
                                                  Fontpalette.blackinter40400,
                                            ).symmetricPadding(
                                              vertical: 10.h,
                                              horizontal: 50.w,
                                            ),
                                          ),
                                        ),
                                      ],
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
                              children: [],
                            ),
                            ValueListenableBuilder<bool>(
                              valueListenable: isEnabled,
                              builder:
                                  (context, value, child) => InkWell(
                                    onTap: () async {
                                      if (widget.isEHundi) {
                                        await _continueEHundi(home);
                                        return;
                                      }
                                      if (home.isAmountOnly) {
                                        home.clearGrossAmount();
                                      }
                                      if (home.pooja.isEmpty) {
                                        print("no pooja added");
                                        if (name.text.isEmpty) {
                                          Helpers.successToast(
                                            "Please enter your name",
                                          );
                                          return;
                                        }
                                        if (home.selectedStarId == null) {
                                          Helpers.successToast(
                                            "Please select your star",
                                          );
                                          return;
                                        }
                                        if (home.selectedPoojaId == null &&
                                            !home.isAmountOnly) {
                                          Helpers.successToast(
                                            "Please a pooja",
                                          );
                                          return;
                                        }
                                        if (amt.text.isEmpty &&
                                            _showAmount(home)) {
                                          Helpers.successToast(
                                            "Please enter the amount",
                                          );
                                          return;
                                        }
                                        if (_showAmount(home)) {
                                          final enteredAmount = double.tryParse(
                                            amt.text,
                                          );
                                          if (enteredAmount == null ||
                                              enteredAmount <= 0) {
                                            Helpers.successToast(
                                              "Please enter a valid  amount",
                                            );
                                            return;
                                          }
                                        }
                                        isEnabled.value = true;
                                        await home.addToPoojaDetails(
                                          name: name.text,
                                          diety: home.dietyIName,
                                          star: home.selectedStarrname,

                                          poojaname:
                                              home.isAmountOnly
                                                  ? home.dietyIName
                                                  : home.selectedPoojaName,
                                          date: home.dateapi,
                                          dietyid: home.dietyId,

                                          poojaid: home.selectedPoojaId,

                                          rate:
                                              _showAmount(home)
                                                  ? amt.text
                                                  : home.selectedpoojarate,
                                          starid: home.selectedStarId,
                                        );

                                        await home.getPreviewBill(
                                          onSuccess: () async {
                                            navigatescrren(
                                              page: PreviewScreen(),
                                              context: context,
                                            );
                                            home.clearStoredData();
                                            name.clear();
                                            _resetNameTransliterationState();
                                            amt.clear();
                                            isEnabled.value = false;
                                          },
                                          onFailure: () {
                                            isEnabled.value = false;
                                          },
                                        );
                                      } else {
                                        print(" pooja added");
                                        isEnabled.value = true;
                                        if (name.text.isNotEmpty &&
                                            home.selectedStarId != null) {
                                          if (home.selectedPoojaId == null &&
                                                  home.isAmountOnly ||
                                              home.selectedPoojaId != null) {
                                            await home.addToPoojaDetails(
                                              name: name.text,
                                              diety: home.dietyIName,
                                              star: home.selectedStarrname,

                                              poojaname:
                                                  home.isAmountOnly
                                                      ? home.dietyIName
                                                      : home.selectedPoojaName,
                                              poojaid: home.selectedPoojaId,
                                              date: home.dateapi,
                                              dietyid: home.dietyId,
                                              rate:
                                                  _showAmount(home)
                                                      ? amt.text
                                                      : home.selectedpoojarate,
                                              starid: home.selectedStarId,
                                            );
                                          }
                                        }
                                        await home.getPreviewBill(
                                          onSuccess: () async {
                                            navigatescrren(
                                              page: PreviewScreen(),
                                              context: context,
                                            );
                                            amt.clear();
                                            home.clearStoredData();
                                            name.clear();
                                            _resetNameTransliterationState();
                                            isEnabled.value = false;
                                          },
                                          onFailure: () {
                                            isEnabled.value = false;
                                          },
                                        );
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          27.r,
                                        ),
                                        color: HexColor("#EC5002"),
                                      ),
                                      child:
                                          isEnabled.value == true
                                              ? CircularProgressIndicator(
                                                color: Colors.white,
                                              ).horizontalPadding(190.w)
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
                        Text(
                          "www.punnyamtemplesuite.com",
                          style: Fontpalette.brown30600,
                        ),
                      ],
                    ).horizontalPadding(100.w),
                  ],
                ).horizontalPadding(90.w).topPadding(40.h).bottomPadding(5.h);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Listpooja extends StatelessWidget {
  const Listpooja({super.key, this.len = 0, this.lanid, this.onPoojaSelected});
  final int? len;
  final int? lanid;
  // Called with the tapped pooja's rate.
  final ValueChanged<String?>? onPoojaSelected;
  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController =
        ScrollController(); // Place this in your State class

    return Consumer<HomeProvider>(
      builder:
          (context, home, child) =>
              home.poojaload == LoaderState.loading
                  ? SizedBox()
                  : Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: GridView.count(
                      controller: scrollController,
                      crossAxisCount: 3,
                      childAspectRatio: 400.w / 80.h,
                      mainAxisSpacing: 10.h,
                      crossAxisSpacing: 10.w,
                      shrinkWrap: len! <= 15,
                      physics:
                          len! > 15
                              ? AlwaysScrollableScrollPhysics()
                              : NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(8.w),
                      children: List.generate(len ?? 0, (index) {
                        final item = home.poojaResponse!.data![index];
                        return InkWell(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            home.updateSelextedPoojaId(
                              poojaname: lanid == 1 ? item.name : item.nameMal,
                              poojaid: item.poojaId,
                              rate: item.rate,
                            );
                            onPoojaSelected?.call(item.rate);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  home.selectedPoojaId == item.poojaId
                                      ? Colors.black.withOpacity(0.5)
                                      : Colors.white,
                              border: Border.all(color: HexColor("#D2D2D2")),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 5.w,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  lanid == 1
                                      ? item.name ?? ''
                                      : item.nameMal ?? '',
                                  textAlign: TextAlign.center,

                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 5,
                                  style:
                                      home.selectedPoojaId == item.poojaId
                                          ? Fontpalette.white45600
                                          : Fontpalette.black45600,
                                ),
                                3.verticalSpace,
                                Text(
                                  "₹ ${item.rate}",
                                  style:
                                      home.selectedPoojaId == item.poojaId
                                          ? Fontpalette.white38500
                                          : Fontpalette.black38500,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
    );
  }
}
