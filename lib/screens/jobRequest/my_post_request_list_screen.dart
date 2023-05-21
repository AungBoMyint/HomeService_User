import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/get_my_post_job_list_response.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/jobRequest/components/my_post_request_item_component.dart';
import 'package:booking_system_flutter/screens/jobRequest/create_post_request_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/background_component.dart';

class MyPostRequestListScreen extends StatefulWidget {
  @override
  _MyPostRequestListScreenState createState() => _MyPostRequestListScreenState();
}

class _MyPostRequestListScreenState extends State<MyPostRequestListScreen> {
  late Future<List<PostJobData>> future;
  List<PostJobData> postJobList = [];

  int page = 1;
  bool isLastPage = false;
  bool isApiCalled = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    future = getPostJobList(page, postJobList: postJobList, lastPageCallBack: (val) {
      isLastPage = val;
    });
  }

  @override
  void dispose() {
    setStatusBarColor(Colors.transparent, statusBarIconBrightness: Brightness.light);
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        page = 1;
        init();
        setState(() {});

        return await 2.seconds.delay;
      },
      child: Scaffold(
        appBar: appBarWidget(language.myPostJobList, textColor: white, elevation: 0.0, color: context.primaryColor, backWidget: BackWidget()),
        body: Stack(
          children: [
            SnapHelperWidget<List<PostJobData>>(
              future: future,
              onSuccess: (data) {
                if (data.isEmpty) {
                  return BackgroundComponent(
                    text: language.noPostJobFound,
                    subTitle: language.noPostJobFoundSubtitle,
                  );
                }

                return AnimatedListView(
                  itemCount: data.length,
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(top: 12, bottom: 70),
                  itemBuilder: (_, i) {
                    PostJobData postJob = data[i];

                    return MyPostRequestItemComponent(
                      data: postJob,
                      callback: (v) {
                        appStore.setLoading(v);

                        if (v) {
                          page = 1;
                          init();
                          setState(() {});
                        }
                      },
                    );
                  },
                );
              },
              loadingWidget: LoaderWidget(),
            ),
            Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading && page != 1))
          ],
        ),
        bottomNavigationBar: AppButton(
          child: Text(language.requestNewJob, style: boldTextStyle(color: white)),
          color: context.primaryColor,
          width: context.width(),
          onTap: () async {
            bool? res = await CreatePostRequestScreen().launch(context);

            if (res ?? false) {
              page = 1;
              init();
              setState(() {});
            }
          },
        ).paddingAll(16),
      ),
    );
  }
}
