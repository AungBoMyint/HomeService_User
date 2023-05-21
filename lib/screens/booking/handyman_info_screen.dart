import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/component/user_info_widget.dart';
import 'package:booking_system_flutter/component/view_all_label_component.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/provider_info_response.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/review/rating_view_all_screen.dart';
import 'package:booking_system_flutter/screens/review/review_widget.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/colors.dart';
import '../../utils/common.dart';
import '../../utils/images.dart';

class HandymanInfoScreen extends StatefulWidget {
  final int? handymanId;

  HandymanInfoScreen({this.handymanId});

  @override
  HandymanInfoScreenState createState() => HandymanInfoScreenState();
}

class HandymanInfoScreenState extends State<HandymanInfoScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBodyWidget(AsyncSnapshot<ProviderInfoResponse> snap) {
      if (snap.hasError) {
        return Text(snap.error.toString()).center();
      } else if (snap.hasData) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: context.statusBarHeight),
                color: context.primaryColor,
                child: Row(
                  children: [
                    BackWidget(),
                    16.width,
                    Text(language.lblAboutHandyman, style: boldTextStyle(color: Colors.white, size: 20)),
                  ],
                ),
              ),
              UserInfoWidget(data: snap.data!.userData!, isOnTapEnabled: true, forProvider: false),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (snap.data!.userData!.knownLanguagesArray.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.knownLanguages, style: boldTextStyle()),
                            8.height,
                            Wrap(
                              children: snap.data!.userData!.knownLanguagesArray.map((e) {
                                return Container(
                                  decoration: boxDecorationWithRoundedCorners(
                                    borderRadius: BorderRadius.all(Radius.circular(4)),
                                    backgroundColor: appStore.isDarkMode ? cardDarkColor : primaryColor.withOpacity(0.1),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  margin: EdgeInsets.all(4),
                                  child: Text(e, style: secondaryTextStyle(size: 12, weight: FontWeight.bold)),
                                );
                              }).toList(),
                            ),
                            16.height,
                          ],
                        ),
                      if (snap.data!.userData!.skillsArray.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.essentialSkills, style: boldTextStyle()),
                            8.height,
                            Wrap(
                              children: snap.data!.userData!.skillsArray.map((e) {
                                return Container(
                                  decoration: boxDecorationWithRoundedCorners(
                                    borderRadius: BorderRadius.all(Radius.circular(4)),
                                    backgroundColor: appStore.isDarkMode ? cardDarkColor : primaryColor.withOpacity(0.1),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  margin: EdgeInsets.all(4),
                                  child: Text(e, style: secondaryTextStyle(size: 12, weight: FontWeight.bold)),
                                );
                              }).toList(),
                            ),
                            16.height,
                          ],
                        ),
                      if (snap.data!.userData!.description != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.lblAboutHandyman, style: boldTextStyle()),
                            8.height,
                            Text(snap.data!.userData!.description.validate(), style: secondaryTextStyle()),
                            16.height,
                          ],
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.personalInfo, style: boldTextStyle()),
                          8.height,
                          TextIcon(
                            spacing: 10,
                            onTap: () {
                              launchMail("${snap.data!.userData!.email.validate()}");
                            },
                            prefix: Image.asset(ic_message, width: 16, height: 16, color: appStore.isDarkMode ? Colors.white : context.primaryColor),
                            text: snap.data!.userData!.email.validate(),
                            textStyle: secondaryTextStyle(size: 16),
                            expandedText: true,
                          ),
                          4.height,
                          TextIcon(
                            spacing: 10,
                            onTap: () {
                              launchCall("${snap.data!.userData!.contactNumber.validate()}");
                            },
                            prefix: Image.asset(ic_calling, width: 16, height: 16, color: appStore.isDarkMode ? Colors.white : context.primaryColor),
                            text: snap.data!.userData!.contactNumber.validate(),
                            textStyle: secondaryTextStyle(size: 16),
                            expandedText: true,
                          ),
                        ],
                      ),
                      8.height,
                    ],
                  ),
                  ViewAllLabel(
                    label: language.review,
                    list: snap.data!.handymanRatingReviewList,
                    onTap: () {
                      RatingViewAllScreen(handymanId: snap.data!.userData!.id).launch(context);
                    },
                  ),
                  snap.data!.handymanRatingReviewList.validate().isNotEmpty
                      ? AnimatedListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          slideConfiguration: sliderConfigurationGlobal,
                          padding: EdgeInsets.symmetric(vertical: 6),
                          itemCount: snap.data!.handymanRatingReviewList.validate().length,
                          itemBuilder: (context, index) => ReviewWidget(data: snap.data!.handymanRatingReviewList.validate()[index], isCustomer: true),
                        )
                      : Text(language.lblNoReviews, style: secondaryTextStyle()).center().paddingOnly(top: 16),
                ],
              ).paddingAll(16),
            ],
          ),
        );
      }
      return LoaderWidget().center();
    }

    return FutureBuilder<ProviderInfoResponse>(
      future: getProviderDetail(widget.handymanId.validate(), userId: appStore.userId.validate()),
      builder: (context, snap) {
        return Scaffold(
          /*appBar: appBarWidget(
            language.lblAboutHandyman,
            textColor: white,
            elevation: 1.5,
            color: context.primaryColor,
            backWidget: BackWidget(),
          ),*/
          body: buildBodyWidget(snap),
        );
      },
    );
  }
}
