import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/notification_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/booking/booking_detail_screen.dart';
import 'package:booking_system_flutter/screens/notification/components/notification_widget.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/background_component.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationData> unReadNotificationList = [];
  List<NotificationData> readNotificationList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setLoading(true);
    await getNotification({NotificationKey.type: ""}).then((value) {
      if (unReadNotificationList.isNotEmpty) {
        unReadNotificationList.clear();
      }
      if (readNotificationList.isNotEmpty) {
        readNotificationList.clear();
      }
      unReadNotificationList = value.notificationData!.where((element) => element.readAt == null).toList();
      readNotificationList = value.notificationData!.where((element) => element.readAt != null).toList();

      appStore.setLoading(false);
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> readNotification({String? id}) async {
    Map request = {CommonKeys.bookingId: id};

    await getBookingDetail(request).then((value) {}).catchError((e) {
      toast(e.toString(), print: true);
    });
  }

  Widget listIterate(List<NotificationData> list) {
    return AnimatedListView(
      shrinkWrap: true,
      itemCount: list.length,
      physics: NeverScrollableScrollPhysics(),
      slideConfiguration: sliderConfigurationGlobal,
      padding: EdgeInsets.all(8),
      itemBuilder: (context, index) {
        NotificationData data = list[index];

        return GestureDetector(
          onTap: () async {
            if (data.data!.notificationType.validate() == NOTIFICATION_TYPE_BOOKING) {
              readNotification(id: data.data!.id.toString());
              await BookingDetailScreen(bookingId: data.data!.id.validate()).launch(context);
            } else if (data.data!.notificationType.validate() == NOTIFICATION_TYPE_POST_JOB) {
              //
            } else {
              //
            }
          },
          child: NotificationWidget(data: data),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.lnlNotification,
      child: RefreshIndicator(
        onRefresh: () async {
          return await init();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(8, 0, 8, 16),
              child: Column(
                children: [
                  if (unReadNotificationList.isNotEmpty)
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(language.lblUnreadNotification, style: boldTextStyle()).paddingAll(8).expand(),
                            TextButton(
                              onPressed: () async {
                                appStore.setLoading(true);

                                await getNotification({NotificationKey.type: MARK_AS_READ}).then((value) {
                                  init();
                                }).catchError((e) {
                                  log(e.toString());
                                });

                                appStore.setLoading(false);
                              },
                              child: Text(language.markAsRead, style: primaryTextStyle(size: 12)),
                            )
                          ],
                        ),
                        listIterate(unReadNotificationList),
                      ],
                    ),
                  16.height,
                  if (readNotificationList.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language.lnlNotification, style: boldTextStyle(size: LABEL_TEXT_SIZE)).paddingAll(8),
                        listIterate(readNotificationList),
                      ],
                    ),
                ],
              ),
            ),
            Observer(builder: (context) {
              return BackgroundComponent(
                text: language.noNotifications,
                subTitle: language.noNotificationsSubTitle,
              ).visible(!appStore.isLoading && readNotificationList.isEmpty && unReadNotificationList.isEmpty);
            }),
            Observer(builder: (context) => LoaderWidget().center().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
