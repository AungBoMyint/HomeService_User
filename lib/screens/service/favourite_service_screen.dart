import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/background_component.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/service/component/service_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class FavouriteServiceScreen extends StatefulWidget {
  const FavouriteServiceScreen({Key? key}) : super(key: key);

  @override
  _FavouriteServiceScreenState createState() => _FavouriteServiceScreenState();
}

class _FavouriteServiceScreenState extends State<FavouriteServiceScreen> {
  ScrollController scrollController = ScrollController();

  Future<List<ServiceData>>? future;

  List<ServiceData> services = [];

  int page = 1;

  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    future = getWishlist(page, services: services, lastPageCallBack: (p0) => isLastPage = p0);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.lblFavorite,
        color: context.primaryColor,
        textColor: white,
        backWidget: BackWidget(),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<ServiceData>>(
            future: future,
            builder: (context, snap) {
              if (snap.hasData) {
                if (snap.data.validate().isEmpty)
                  return BackgroundComponent(
                    text: language.lblNoServicesFound,
                    subTitle: language.noFavouriteSubTitle,
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
                        return ServiceComponent(
                          serviceData: snap.data![index],
                          width: context.width() / 2 - 24,
                          isFavouriteService: true,
                          onUpdate: () async {
                            page = 1;
                            await init();
                            setState(() {});
                          },
                        );
                      },
                    )
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
