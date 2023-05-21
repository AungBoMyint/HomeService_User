import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/dashboard_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/dashboard/component/category_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/featured_service_list_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/service_list_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/slider_and_location_component.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../component/booking_confirmed_component.dart';
import '../component/new_job_request_component.dart';

class DashboardFragment extends StatefulWidget {
  @override
  _DashboardFragmentState createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment> {
  Future<DashboardResponse>? future;

  @override
  void initState() {
    super.initState();
    init();

    setStatusBarColor(transparentColor, delayInMilliSeconds: 1000);

    LiveStream().on(LIVESTREAM_UPDATE_DASHBOARD, (p0) {
      setState(() {});
    });
  }

  void init() async {
    future = userDashboard(isCurrentLocation: appStore.isCurrentLocation, lat: getDoubleAsync(LATITUDE), long: getDoubleAsync(LONGITUDE));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(LIVESTREAM_UPDATE_DASHBOARD);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          init();
          setState(() {});
          return await 2.seconds.delay;
        },
        child: Stack(
          children: [
            FutureBuilder<DashboardResponse>(
              future: future,
              builder: (context, snap) {
                if (snap.hasData) {
                  return AnimatedScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    listAnimationType: ListAnimationType.FadeIn,
                    children: [
                      // UserInfoComponent(notificationReadCount: snap.data!.notificationUnreadCount.validate()),
                      SliderLocationComponent(
                        sliderList: snap.data!.slider.validate(),
                        notificationReadCount: snap.data!.notificationUnreadCount.validate(),
                        callback: () async {
                          init();
                          await 300.milliseconds.delay;
                          setState(() {});
                        },
                      ),
                      30.height,
                      PendingBookingComponent(upcomingData: snap.data!.upcomingData),
                      CategoryComponent(categoryList: snap.data!.category.validate()),
                      16.height,
                      FeaturedServiceListComponent(serviceList: snap.data!.featuredServices.validate()),
                      ServiceListComponent(serviceList: snap.data!.service.validate()),
                      16.height,
                      NewJobRequestComponent(),
                    ],
                  );
                }
                return snapWidgetHelper(snap, loadingWidget: Offstage(), errorBuilder: (error) {
                  return NoDataWidget(
                    title: error,
                    retryText: language.tryAgain,
                    onRetry: () {
                      init();
                      setState(() {});
                    },
                  );
                });
              },
            ),
            Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
