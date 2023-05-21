import 'dart:convert';

import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/base_response_model.dart';
import 'package:booking_system_flutter/model/booking_data_model.dart';
import 'package:booking_system_flutter/model/booking_detail_model.dart';
import 'package:booking_system_flutter/model/booking_list_model.dart';
import 'package:booking_system_flutter/model/booking_status_model.dart';
import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/model/city_list_model.dart';
import 'package:booking_system_flutter/model/country_list_model.dart';
import 'package:booking_system_flutter/model/dashboard_model.dart';
import 'package:booking_system_flutter/model/get_my_post_job_list_response.dart';
import 'package:booking_system_flutter/model/login_model.dart';
import 'package:booking_system_flutter/model/notification_model.dart';
import 'package:booking_system_flutter/model/post_job_detail_response.dart';
import 'package:booking_system_flutter/model/provider_info_response.dart';
import 'package:booking_system_flutter/model/provider_list_model.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/model/service_response.dart';
import 'package:booking_system_flutter/model/service_review_response.dart';
import 'package:booking_system_flutter/model/state_list_model.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/model/verify_transaction_response.dart';
import 'package:booking_system_flutter/network/network_utils.dart';
import 'package:booking_system_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/configs.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../model/payment_list_reasponse.dart';
import '../model/wallet_response.dart';

//region Auth Api
Future<LoginResponse> createUser(Map request) async {
  return LoginResponse.fromJson(await (handleResponse(await buildHttpResponse('register', request: request, method: HttpMethod.POST))));
}

Future<LoginResponse> loginUser(Map request, {bool isSocialLogin = false}) async {
  LoginResponse res = LoginResponse.fromJson(await handleResponse(await buildHttpResponse(isSocialLogin ? 'social-login' : 'login', request: request, method: HttpMethod.POST)));

  if (res.userData != null && res.userData!.userType != USER_TYPE_USER) {
    throw language.lblNotValidUser;
  }

  if (!isSocialLogin) await appStore.setLoginType(LOGIN_TYPE_USER);

  return res;
}

Future<void> saveUserData(UserData data) async {
  if (data.apiToken.validate().isNotEmpty) await appStore.setToken(data.apiToken.validate());

  await appStore.setUserId(data.id.validate());
  await appStore.setFirstName(data.firstName.validate());
  await appStore.setLastName(data.lastName.validate());
  await appStore.setUserEmail(data.email.validate());
  await appStore.setUserName(data.username.validate());
  await appStore.setCountryId(data.countryId.validate());
  await appStore.setStateId(data.stateId.validate());
  await appStore.setCityId(data.cityId.validate());
  await appStore.setContactNumber(data.contactNumber.validate());
  if (data.loginType.validate().isNotEmpty) await appStore.setLoginType(data.loginType.validate());
  await appStore.setAddress(data.address.validate());

  if (data.loginType != LOGIN_TYPE_GOOGLE) {
    await appStore.setUserProfile(data.profileImage.validate());
  }

  appStore.setLoggedIn(true);

  if (data.uid.validate().isEmpty) {
    await userService.getUser(email: data.email.validate()).then((value) async {
      appStore.setUId(value.uid.validate());

      if (data.loginType == LOGIN_TYPE_GOOGLE) {
        appStore.setUserProfile(value.profileImage.validate());
      }
    }).catchError((e) {
      log(e.toString());

      if (e.toString() == USER_NOT_FOUND) {
        toast(USER_NOT_FOUND);
      }
    });
  } else {
    appStore.setUId(data.uid.validate());
  }
}

Future<void> clearPreferences() async {
  if (!getBoolAsync(IS_REMEMBERED)) await appStore.setUserEmail('');

  await appStore.setFirstName('');
  await appStore.setLastName('');
  await appStore.setUserId(0);
  await appStore.setUserName('');
  await appStore.setContactNumber('');
  await appStore.setCountryId(0);
  await appStore.setStateId(0);
  await appStore.setUserProfile('');
  await appStore.setCityId(0);
  await appStore.setUId('');
  await appStore.setLatitude(0.0);
  await appStore.setLongitude(0.0);
  await appStore.setCurrentAddress('');

  await appStore.setCurrentLocation(false);

  await appStore.setToken('');
  await appStore.setPrivacyPolicy('');
  await appStore.setTermConditions('');
  await appStore.setInquiryEmail('');
  await appStore.setHelplineNumber('');

  await appStore.setLoggedIn(false);
  await removeKey(LOGIN_TYPE);

  await OneSignal.shared.clearOneSignalNotifications();
}

Future<void> logout(BuildContext context) async {
  return showInDialog(
    context,
    contentPadding: EdgeInsets.zero,
    builder: (p0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(logout_image, width: context.width(), fit: BoxFit.cover),
          32.height,
          Text(language.lblLogoutTitle, style: boldTextStyle(size: 20)),
          16.height,
          Text(language.lblLogoutSubTitle, style: secondaryTextStyle()),
          28.height,
          Row(
            children: [
              AppButton(
                child: Text(language.lblNo, style: boldTextStyle()),
                elevation: 0,
                onTap: () {
                  finish(context);
                },
              ).expand(),
              16.width,
              AppButton(
                child: Text(language.lblYes, style: boldTextStyle(color: white)),
                color: primaryColor,
                elevation: 0,
                onTap: () async {
                  finish(context);

                  if (await isNetworkAvailable()) {
                    appStore.setLoading(true);

                    logoutApi().then((value) async {
                      //
                    }).catchError((e) {
                      log(e.toString());
                    });

                    await clearPreferences();

                    appStore.setLoading(false);
                    DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
                  }
                },
              ).expand(),
            ],
          ),
        ],
      ).paddingSymmetric(horizontal: 16, vertical: 24);
    },
  );
}

Future<void> logoutApi() async {
  return await handleResponse(await buildHttpResponse('logout', method: HttpMethod.GET));
}

Future<BaseResponseModel> changeUserPassword(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('change-password', request: request, method: HttpMethod.POST)));
}

Future<BaseResponseModel> forgotPassword(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('forgot-password', request: request, method: HttpMethod.POST)));
}

Future<BaseResponseModel> deleteAccountCompletely() async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('delete-user-account', request: {}, method: HttpMethod.POST)));
}

//endregion

//region Country Api
Future<List<CountryListResponse>> getCountryList() async {
  Iterable res = await (handleResponse(await buildHttpResponse('country-list', method: HttpMethod.POST)));
  return res.map((e) => CountryListResponse.fromJson(e)).toList();
}

Future<List<StateListResponse>> getStateList(Map request) async {
  Iterable res = await (handleResponse(await buildHttpResponse('state-list', request: request, method: HttpMethod.POST)));
  return res.map((e) => StateListResponse.fromJson(e)).toList();
}

Future<List<CityListResponse>> getCityList(Map request) async {
  Iterable res = await (handleResponse(await buildHttpResponse('city-list', request: request, method: HttpMethod.POST)));
  return res.map((e) => CityListResponse.fromJson(e)).toList();
}
//endregion

//region User Api
Future<DashboardResponse> userDashboard({bool isCurrentLocation = false, double? lat, double? long}) async {
  appStore.setLoading(true);
  DashboardResponse? _dashboardResponse;

  /// If any below condition not satisfied, call this
  String endPoint = 'dashboard-detail';

  if (isCurrentLocation && appStore.isLoggedIn && appStore.userId.validate() != 0) {
    endPoint = "$endPoint?latitude=$lat&longitude=$long&?customer_id=${appStore.userId.validate()}}";
  } else if (isCurrentLocation) {
    endPoint = "$endPoint?latitude=$lat&longitude=$long";
  } else if (appStore.isLoggedIn && appStore.userId.validate() != 0) {
    endPoint = "$endPoint?customer_id=${appStore.userId.validate()}";
  }

  try {
    _dashboardResponse = DashboardResponse.fromJson(await handleResponse(await buildHttpResponse(endPoint, method: HttpMethod.GET)));

    reviewData = _dashboardResponse.dashboardCustomerReview.validate();

    if (_dashboardResponse.appDownload != null) {
      setValue(APPSTORE_URL, _dashboardResponse.appDownload!.appstore_url.validate());
      setValue(PLAY_STORE_URL, _dashboardResponse.appDownload!.playstore_url.validate());
      setValue(PROVIDER_PLAY_STORE_URL, _dashboardResponse.appDownload!.provider_playstore_url.validate());
      setValue(PROVIDER_APPSTORE_URL, _dashboardResponse.appDownload!.provider_appstore_url.validate());
    }

    if (_dashboardResponse.privacyPolicy != null) {
      if (_dashboardResponse.privacyPolicy!.value != null) {
        appStore.setPrivacyPolicy(_dashboardResponse.privacyPolicy!.value.validate());
      } else {
        appStore.setPrivacyPolicy(PRIVACY_POLICY_URL);
      }
    } else {
      appStore.setPrivacyPolicy(PRIVACY_POLICY_URL);
    }

    if (_dashboardResponse.termConditions != null) {
      if (_dashboardResponse.termConditions?.value != null) {
        appStore.setTermConditions(_dashboardResponse.termConditions!.value.validate());
      } else {
        appStore.setTermConditions(TERMS_CONDITION_URL);
      }
    } else {
      appStore.setTermConditions(TERMS_CONDITION_URL);
    }

    if (!_dashboardResponse.inquiryEmail.isEmptyOrNull) {
      appStore.setInquiryEmail(_dashboardResponse.inquiryEmail.validate());
    } else {
      appStore.setInquiryEmail(HELP_SUPPORT_URL);
    }

    if (!_dashboardResponse.helplineNumber.isEmptyOrNull) {
      appStore.setHelplineNumber(_dashboardResponse.helplineNumber.validate());
    } else {
      appStore.setHelplineNumber(HELP_SUPPORT_URL);
    }

    if (_dashboardResponse.languageOption != null) {
      setValue(SERVER_LANGUAGES, jsonEncode(_dashboardResponse.languageOption!.toList()));
    }

    _dashboardResponse.configurations.validate().forEach((data) {
      if (data.key == CONFIGURATION_KEY_CURRENCY_COUNTRY_ID) {
        if (data.country != null) {
          if (data.country!.currencyCode.validate() != appStore.currencyCode) appStore.setCurrencyCode(data.country!.currencyCode.validate());
          if (data.country!.id.validate().toString() != appStore.countryId.toString()) appStore.setCurrencyCountryId(data.country!.id.validate().toString());
          if (data.country!.symbol.validate() != appStore.currencySymbol) appStore.setCurrencySymbol(data.country!.symbol.validate());
        }
      } else if (data.key == CONFIGURATION_TYPE_CURRENCY_POSITION) {
        if (data.value.validate().isNotEmpty) {
          setValue(CURRENCY_POSITION, data.value);
        }
      } else if (data.key == ONESIGNAL_API_KEY) {
        if (data.value.validate().isNotEmpty) {
          setValue(ONESIGNAL_API_KEY, data.value);
        }
      } else if (data.key == ONESIGNAL_REST_API_KEY) {
        if (data.value.validate().isNotEmpty) {
          setValue(ONESIGNAL_REST_API_KEY, data.value);
        }
      } else if (data.key == ONESIGNAL_CHANNEL_KEY) {
        if (data.value.validate().isNotEmpty) {
          setValue(ONESIGNAL_CHANNEL_KEY, data.value);
        }
      }
    });
    1.seconds.delay.then((value) {
      initializeOneSignal();
    });

    if (_dashboardResponse.paymentSettings != null) {
      setValue(PAYMENT_LIST, PaymentSetting.encode(_dashboardResponse.paymentSettings.validate()));
    }

    setValue(IS_ADVANCE_PAYMENT_ALLOWED, _dashboardResponse.isAdvancedPaymentAllowed == '1');

    appStore.setLoading(false);

    return _dashboardResponse;
  } catch (e) {
    appStore.setLoading(false);
    throw e;
  }
}

Future<num> getUserWalletBalance() async {
  var res = WalletResponse.fromJson(await handleResponse(await buildHttpResponse('user-wallet-balance', method: HttpMethod.GET)));

  return res.balance.validate();
}
//endregion

//region Service Api
Future<ServiceDetailResponse> getServiceDetail(Map request) async {
  return ServiceDetailResponse.fromJson(await handleResponse(await buildHttpResponse('service-detail', request: request, method: HttpMethod.POST)));
}

Future<ServiceDetailResponse> getServiceDetails({required int serviceId, int? customerId, bool fromBooking = false}) async {
  if (fromBooking) {
    toast('Please wait');
  }
  Map request = {CommonKeys.serviceId: serviceId, if (appStore.isLoggedIn) CommonKeys.customerId: customerId};
  var res = ServiceDetailResponse.fromJson(await handleResponse(await buildHttpResponse('service-detail', request: request, method: HttpMethod.POST)));

  appStore.setLoading(false);
  return res;
}

Future<ServiceResponse> getSearchListServices({
  String categoryId = '',
  String providerId = '',
  String handymanId = '',
  String isPriceMin = '',
  String isPriceMax = '',
  String search = '',
  String latitude = '',
  String longitude = '',
  String isFeatured = '',
  String subCategory = '',
  int page = 1,
}) async {
  String categoryIds = categoryId.isNotEmpty ? 'category_id=$categoryId&' : '';
  String searchPara = search.isNotEmpty ? 'search=$search&' : '';
  String providerIds = providerId.isNotEmpty ? 'provider_id=$providerId&' : '';
  String isPriceMinPara = isPriceMin.isNotEmpty ? 'is_price_min=$isPriceMin&' : '';
  String isPriceMaxPara = isPriceMax.isNotEmpty ? 'is_price_max=$isPriceMax&' : '';
  String latitudes = latitude.isNotEmpty ? 'latitude=$latitude&' : '';
  String longitudes = longitude.isNotEmpty ? 'longitude=$longitude&' : '';
  String isFeatures = isFeatured.isNotEmpty ? 'is_featured=$isFeatured&' : '';
  String subCategorys = subCategory.validate().isNotEmpty
      ? subCategory != "-1"
          ? 'subcategory_id=$subCategory&'
          : ''
      : '';
  String pages = 'page=$page&';
  String perPages = 'per_page=$PER_PAGE_ITEM';
  String customerId = appStore.isLoggedIn ? 'customer_id=${appStore.userId}&' : '';

  return ServiceResponse.fromJson(await handleResponse(
    await buildHttpResponse('search-list?$categoryIds$customerId$providerIds$isPriceMinPara$isPriceMaxPara$subCategorys$searchPara$latitudes$longitudes$isFeatures$pages$perPages'),
  ));
}
//endregion

//region Category Api

Future<CategoryResponse> getCategoryList(String page) async {
  return CategoryResponse.fromJson(await handleResponse(await buildHttpResponse('category-list?page=$page&per_page=50', method: HttpMethod.GET)));
}

Future<List<CategoryData>> getCategoryListWithPagination(int page, {var perPage = PER_PAGE_CATEGORY_ITEM, required List<CategoryData> categoryList, Function(bool)? lastPageCallBack}) async {
  appStore.setLoading(true);

  try {
    CategoryResponse res = CategoryResponse.fromJson(await handleResponse(await buildHttpResponse('category-list?per_page=$perPage&page=$page', method: HttpMethod.GET)));

    if (page == 1) categoryList.clear();
    categoryList.addAll(res.categoryList.validate());

    lastPageCallBack?.call(res.categoryList.validate().length != PER_PAGE_CATEGORY_ITEM);

    appStore.setLoading(false);
  } catch (e) {
    appStore.setLoading(false);
    throw e;
  }

  return categoryList;
}
//endregion

//region SubCategory Api
Future<CategoryResponse> getSubCategoryList({required int catId}) async {
  return CategoryResponse.fromJson(await handleResponse(await buildHttpResponse('subcategory-list?category_id=$catId&per_page=all', method: HttpMethod.GET)));
}
//endregion

//region Provider Api
Future<ProviderInfoResponse> getProviderDetail(int id, {int? userId}) async {
  return ProviderInfoResponse.fromJson(await handleResponse(await buildHttpResponse('user-detail?id=$id&login_user_id=$userId', method: HttpMethod.GET)));
}

Future<ProviderListResponse> getProvider({String? userType = "provider"}) async {
  return ProviderListResponse.fromJson(await handleResponse(await buildHttpResponse('user-list?user_type=$userType&per_page=all', method: HttpMethod.GET)));
}
//endregion

//region Handyman Api
Future<UserData> getHandymanDetail(int id) async {
  return UserData.fromJson(await handleResponse(await buildHttpResponse('user-detail?id=$id', method: HttpMethod.GET)));
}

Future<BaseResponseModel> handymanRating(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('save-handyman-rating', request: request, method: HttpMethod.POST)));
}
//endregion

//region Booking Api
Future<List<BookingData>> getBookingList(int page, {var perPage = PER_PAGE_ITEM, String status = '', required List<BookingData> bookings, Function(bool)? lastPageCallback}) async {
  appStore.setLoading(true);
  BookingListResponse res;

  if (status == BOOKING_TYPE_ALL) {
    res = BookingListResponse.fromJson(await handleResponse(await buildHttpResponse('booking-list?&per_page=$perPage&page=$page', method: HttpMethod.GET)));
  } else {
    res = BookingListResponse.fromJson(await handleResponse(await buildHttpResponse('booking-list?status=$status&per_page=$perPage&page=$page', method: HttpMethod.GET)));
  }

  if (page == 1) bookings.clear();
  bookings.addAll(res.data.validate());
  lastPageCallback?.call(res.data.validate().length != PER_PAGE_ITEM);

  appStore.setLoading(false);

  return bookings;
}

Future<BookingDetailResponse> getBookingDetail(Map request) async {
  BookingDetailResponse bookingDetailResponse = BookingDetailResponse.fromJson(await handleResponse(await buildHttpResponse('booking-detail', request: request, method: HttpMethod.POST)));
  calculateTotalAmount(
    serviceDiscountPercent: bookingDetailResponse.service!.discount.validate(),
    qty: bookingDetailResponse.bookingDetail!.quantity!.toInt(),
    detail: bookingDetailResponse.service,
    servicePrice: bookingDetailResponse.service!.price.validate(),
    taxes: bookingDetailResponse.bookingDetail!.taxes.validate(),
    couponData: bookingDetailResponse.couponData,
    extraCharges: bookingDetailResponse.bookingDetail!.extraCharges,
  );
  return bookingDetailResponse;
}

Future<BaseResponseModel> updateBooking(Map request) async {
  BaseResponseModel baseResponse = BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('booking-update', request: request, method: HttpMethod.POST)));
  LiveStream().emit(LIVESTREAM_UPDATE_BOOKING_LIST);

  return baseResponse;
}

Future bookTheServices(Map request) async {
  return await handleResponse(await buildHttpResponse('booking-save', request: request, method: HttpMethod.POST));
}

Future<List<BookingStatusResponse>> bookingStatus() async {
  Iterable res = await (handleResponse(await buildHttpResponse('booking-status', method: HttpMethod.GET)));
  return res.map((e) => BookingStatusResponse.fromJson(e)).toList();
}
//endregion

//region Payment Api
Future<BaseResponseModel> savePayment(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('save-payment', request: request, method: HttpMethod.POST)));
}

Future<List<PaymentData>> getPaymentList(int page, int id, List<PaymentData> list, Function(bool)? lastPageCallback) async {
  appStore.setLoading(true);
  var res = PaymentListResponse.fromJson(await handleResponse(await buildHttpResponse('payment-list?booking_id=$id', method: HttpMethod.GET)));

  if (page == 1) list.clear();

  list.addAll(res.data.validate());
  appStore.setLoading(false);

  lastPageCallback?.call(res.data.validate().length != PER_PAGE_ITEM);

  return list;
}

//endregion

//region Notification Api
Future<NotificationListResponse> getNotification(Map request, {int? page = 1}) async {
  return NotificationListResponse.fromJson(await handleResponse(await buildHttpResponse('notification-list?customer_id=${appStore.userId}', request: request, method: HttpMethod.POST)));
}
//endregion

//region Review Api
Future<BaseResponseModel> updateReview(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('save-booking-rating', request: request, method: HttpMethod.POST)));
}

Future<List<RatingData>> serviceReviews(Map request) async {
  ServiceReviewResponse res = ServiceReviewResponse.fromJson(await handleResponse(await buildHttpResponse('service-reviews?per_page=all', request: request, method: HttpMethod.POST)));
  return res.ratingList.validate();
}

Future<List<RatingData>> handymanReviews(Map request) async {
  ServiceReviewResponse res = ServiceReviewResponse.fromJson(await handleResponse(await buildHttpResponse('handyman-reviews?per_page=all', request: request, method: HttpMethod.POST)));
  return res.ratingList.validate();
}

Future<BaseResponseModel> deleteReview({required int id}) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('delete-booking-rating', request: {"id": id}, method: HttpMethod.POST)));
}

Future<BaseResponseModel> deleteHandymanReview({required int id}) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('delete-handyman-rating', request: {"id": id}, method: HttpMethod.POST)));
}
//endregion

//region WishList Api
Future<List<ServiceData>> getWishlist(int page, {var perPage = PER_PAGE_ITEM, required List<ServiceData> services, Function(bool)? lastPageCallBack}) async {
  appStore.setLoading(true);

  try {
    ServiceResponse serviceResponse = ServiceResponse.fromJson(await (handleResponse(await buildHttpResponse('user-favourite-service?per_page=$perPage&page=$page', method: HttpMethod.GET))));

    if (page == 1) services.clear();
    services.addAll(serviceResponse.serviceList.validate());

    lastPageCallBack?.call(serviceResponse.serviceList.validate().length != PER_PAGE_ITEM);

    appStore.setLoading(false);
  } catch (e) {
    appStore.setLoading(false);
    throw e;
  }
  return services;
}

Future<BaseResponseModel> addWishList(request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('save-favourite', method: HttpMethod.POST, request: request)));
}

Future<BaseResponseModel> removeWishList(request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('delete-favourite', method: HttpMethod.POST, request: request)));
}

//endregion

//region Provider WishList Api
Future<List<UserData>> getProviderWishlist(int page, {var perPage = PER_PAGE_ITEM, required List<UserData> providers, Function(bool)? lastPageCallBack}) async {
  appStore.setLoading(true);

  try {
    ProviderListResponse res = ProviderListResponse.fromJson(await (handleResponse(await buildHttpResponse('user-favourite-provider?per_page=$perPage&page=$page', method: HttpMethod.GET))));

    if (page == 1) providers.clear();
    providers.addAll(res.providerList.validate());

    lastPageCallBack?.call(res.providerList.validate().length != PER_PAGE_ITEM);

    appStore.setLoading(false);
  } catch (e) {
    appStore.setLoading(false);
    throw e;
  }
  return providers;
}

Future<BaseResponseModel> addProviderWishList(request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('save-favourite-provider', method: HttpMethod.POST, request: request)));
}

Future<BaseResponseModel> removeProviderWishList(request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('delete-favourite-provider', method: HttpMethod.POST, request: request)));
}
//endregion

//region Get My Service List API
Future<ServiceResponse> getMyServiceList() async {
  return ServiceResponse.fromJson(await handleResponse(await buildHttpResponse('service-list?customer_id=${appStore.userId.validate()}', method: HttpMethod.GET)));
}
//endregion

//region Get My post job

Future<BaseResponseModel> savePostJob(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('save-post-job', request: request, method: HttpMethod.POST)));
}

Future<BaseResponseModel> deletePostRequest({required num id}) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('post-job-delete/$id', request: {}, method: HttpMethod.POST)));
}

Future<BaseResponseModel> deleteServiceRequest(int id) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('service-delete/$id', request: {}, method: HttpMethod.POST)));
}

Future<List<PostJobData>> getPostJobList(int page, {var perPage = PER_PAGE_ITEM, required List<PostJobData> postJobList, Function(bool)? lastPageCallBack}) async {
  appStore.setLoading(true);

  try {
    var res = GetPostJobResponse.fromJson(await handleResponse(await buildHttpResponse('get-post-job?per_page=$perPage&page=$page', method: HttpMethod.GET)));

    if (page == 1) postJobList.clear();
    postJobList.addAll(res.myPostJobData.validate());

    lastPageCallBack?.call(res.myPostJobData.validate().length != PER_PAGE_ITEM);

    appStore.setLoading(false);
  } catch (e) {
    appStore.setLoading(false);
    throw e;
  }

  return postJobList;
}

Future<PostJobDetailResponse> getPostJobDetail(Map request) async {
  return PostJobDetailResponse.fromJson(await handleResponse(await buildHttpResponse('get-post-job-detail', request: request, method: HttpMethod.POST)));
}

//endregion

//region FlutterWave Verify Transaction API
Future<VerifyTransactionResponse> verifyPayment({required String transactionId, required String flutterWaveSecretKey}) async {
  return VerifyTransactionResponse.fromJson(
      await handleResponse(await buildHttpResponse("https://api.flutterwave.com/v3/transactions/$transactionId/verify", isFlutterWave: true, flutterWaveSecretKey: flutterWaveSecretKey)));
}
//endregion

//region Sadad Payment Api
Future<String> sadadLogin(Map request) async {
  var res = await handleResponse(
    await buildHttpResponse('$SADAD_API_URL/api/userbusinesses/login', method: HttpMethod.POST, request: request, isSadadPayment: true),
    false,
    true,
  );
  return res['accessToken'];
}

Future sadadCreateInvoice({required Map<String, dynamic> request, required String sadadToken}) async {
  return handleResponse(
    await buildHttpResponse('$SADAD_API_URL/api/invoices/createInvoice', method: HttpMethod.POST, request: request, isSadadPayment: true, sadadToken: sadadToken),
    false,
    true,
  );
}
//endregion

// region Send Invoice on Email
Future<BaseResponseModel> sentInvoiceOnMail(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('download-invoice', request: request, method: HttpMethod.POST)));
}
//endregion
