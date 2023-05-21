import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/background_component.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/screens/dashboard/component/customer_rating_widget.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CustomerRatingScreen extends StatefulWidget {
  @override
  State<CustomerRatingScreen> createState() => _CustomerRatingScreenState();
}

class _CustomerRatingScreenState extends State<CustomerRatingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(language.lblReviewsOnServices, textColor: Colors.white, color: context.primaryColor, backWidget: BackWidget()),
      body: reviewData.validate().isEmpty
          ? BackgroundComponent(
              text: language.lblNoRateYet,
              image: no_rating_bar,
              subTitle: language.customerRatingMessage,
            )
          : AnimatedListView(
              padding: EdgeInsets.fromLTRB(8, 16, 8, 80),
              slideConfiguration: sliderConfigurationGlobal,
              itemCount: reviewData.length,
              itemBuilder: (context, index) {
                return CustomerRatingWidget(
                  data: reviewData[index],
                  onDelete: (data) {
                    reviewData.remove(data);
                    setState(() {});
                  },
                );
              },
            ),
    );
  }
}
