import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/background_component.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/screens/blog/blog_repository.dart';
import 'package:booking_system_flutter/screens/blog/component/blog_item_component.dart';
import 'package:booking_system_flutter/screens/blog/model/blog_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/base_scaffold_widget.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({Key? key}) : super(key: key);

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  Future<List<BlogData>>? future;

  List<BlogData> blogList = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getBlogListAPI(
      blogData: blogList,
      page: page,
      lastPageCallback: (b) {
        isLastPage = b;
      },
    );
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
      child: AppScaffold(
        appBarTitle: language.blogs,
        child: Stack(
          children: [
            SnapHelperWidget<List<BlogData>>(
              future: future,
              loadingWidget: LoaderWidget(),
              onSuccess: (snap) {
                if (snap.isEmpty) return BackgroundComponent(text: language.noBlogsFound);

                return AnimatedListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(8),
                  itemCount: snap.length,
                  onNextPage: () {
                    if (!isLastPage) {
                      page++;
                      init();
                      setState(() {});
                    }
                  },
                  disposeScrollController: false,
                  itemBuilder: (BuildContext context, index) {
                    BlogData data = snap[index];

                    return BlogItemComponent(blogData: data);
                  },
                );
              },
              errorBuilder: (e) {
                return Text(e.toString(), style: primaryTextStyle()).center();
              },
            ),
            Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading && page != 1))
          ],
        ),
      ),
    );
  }
}
