import 'package:booking_system_flutter/component/background_component.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_data_model.dart';
import 'package:booking_system_flutter/model/booking_status_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/booking/booking_detail_screen.dart';
import 'package:booking_system_flutter/screens/booking/component/booking_item_component.dart';
import 'package:booking_system_flutter/screens/booking/component/status_dropdown_component.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingFragment extends StatefulWidget {
  @override
  _BookingFragmentState createState() => _BookingFragmentState();
}

class _BookingFragmentState extends State<BookingFragment> {
  UniqueKey keyForStatus = UniqueKey();

  ScrollController scrollController = ScrollController();

  Future<List<BookingData>>? future;
  List<BookingData> bookings = [];

  int page = 1;
  bool isLastPage = false;
  bool isBookingTypeChanged = false;

  String selectedValue = BOOKING_TYPE_ALL;

  @override
  void initState() {
    super.initState();
    init();

    afterBuildCreated(() {
      if (appStore.isLoggedIn) {
        setStatusBarColor(context.primaryColor);
      }
    });

    LiveStream().on(LIVESTREAM_UPDATE_BOOKING_LIST, (p0) {
      page = 1;
      init();
      setState(() {});
    });
  }

  void init() async {
    future = getBookingList(page, status: selectedValue, bookings: bookings, lastPageCallback: (b) {
      isLastPage = b;
    });
    isBookingTypeChanged = false;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    LiveStream().dispose(LIVESTREAM_UPDATE_BOOKING_LIST);
    //scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.booking,
        textColor: white,
        showBack: false,
        elevation: 3.0,
        color: context.primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          page = 1;
          init();

          setState(() {});
          return await 2.seconds.delay;
        },
        child: SizedBox(
          width: context.width(),
          height: context.height(),
          child: Stack(
            children: [
              SnapHelperWidget<List<BookingData>>(
                future: future,
                errorBuilder: (error) {
                  return NoDataWidget(
                    title: error,
                    retryText: language.tryAgain,
                    onRetry: () {
                      keyForStatus = UniqueKey();
                      page = 1;
                      init();
                      setState(() {});
                    },
                  );
                },
                loadingWidget: LoaderWidget(),
                onSuccess: (list) {
                  if (list.isEmpty) {
                    return BackgroundComponent(
                      text: language.lblNoBookingsFound,
                      subTitle: language.noBookingSubTitle,
                    );
                  }

                  return AnimatedListView(
                    controller: scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 60, top: 8, right: 16, left: 16),
                    itemCount: list.length,
                    shrinkWrap: true,
                    listAnimationType: ListAnimationType.Slide,
                    slideConfiguration: SlideConfiguration(verticalOffset: 400),
                    //disposeScrollController: false,
                    itemBuilder: (_, index) {
                      BookingData? data = list[index];

                      return GestureDetector(
                        onTap: () {
                          BookingDetailScreen(bookingId: data.id.validate()).launch(context);
                        },
                        child: BookingItemComponent(bookingData: data),
                      );
                    },
                    onNextPage: () {
                      if (!isLastPage) {
                        page++;
                        init();
                        setState(() {});
                      }
                    },
                  ).paddingOnly(left: 0, right: 0, bottom: 0, top: 76);
                },
              ),
              Positioned(
                left: 16,
                right: 16,
                top: 16,
                child: StatusDropdownComponent(
                  isValidate: false,
                  key: keyForStatus,
                  onValueChanged: (BookingStatusResponse value) {
                    selectedValue = value.value.toString();
                    isBookingTypeChanged = true;

                    page = 1;
                    init();

                    setState(() {});

                    if (bookings.isNotEmpty) {
                      scrollController.animateTo(0, duration: 1.seconds, curve: Curves.easeOutQuart);
                    } else {
                      scrollController = ScrollController();
                    }
                  },
                ),
              ),
              Positioned(
                bottom: isBookingTypeChanged ? 100 : 8,
                left: 0,
                right: 0,
                child: Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading && (page != 1 || isBookingTypeChanged)).center()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
