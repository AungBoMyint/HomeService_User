import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/background_component.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../component/favourite_provider_component.dart';
import '../network/rest_apis.dart';

class FavouriteProviderScreen extends StatefulWidget {
  const FavouriteProviderScreen({Key? key}) : super(key: key);

  @override
  _FavouriteProviderScreenState createState() => _FavouriteProviderScreenState();
}

class _FavouriteProviderScreenState extends State<FavouriteProviderScreen> {
  ScrollController scrollController = ScrollController();

  Future<List<UserData>>? future;

  List<UserData> providers = [];

  int page = 1;

  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    future = getProviderWishlist(page, providers: providers, lastPageCallBack: (p0) => isLastPage = p0);
  }

  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: context.cardColor,
      appBar: appBarWidget(
        language.favouriteProvider,
        color: context.primaryColor,
        textColor: white,
        backWidget: BackWidget(),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<UserData>>(
            future: future,
            builder: (context, snap) {
              if (snap.hasData) {
                if (snap.data.validate().isEmpty)
                  return BackgroundComponent(
                    text: language.noProviderFound,
                    subTitle: language.noProviderFoundMessage,
                  );
                return AnimatedScrollView(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 60),
                  onNextPage: () {
                    if (!isLastPage) {
                      page++;
                      init();
                      setState(() {});
                    }
                  },
                  controller: scrollController,
                  children: [
                    AnimatedWrap(
                      spacing: 16,
                      runSpacing: 16,
                      listAnimationType: ListAnimationType.Scale,
                      scaleConfiguration: ScaleConfiguration(duration: 300.milliseconds, delay: 50.milliseconds),
                      itemCount: snap.data!.length,
                      itemBuilder: (_, index) {
                        return FavouriteProviderComponent(
                          data: snap.data![index],
                          width: context.width() * 0.5 - 26,
                          onUpdate: () {
                            page = 1;
                            init();
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ],
                );
              }

              return snapWidgetHelper(snap, loadingWidget: LoaderWidget());
            },
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading && page != 1)),
          ),
        ],
      ),
    );
  }
}
