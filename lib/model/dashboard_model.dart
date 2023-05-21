import 'dart:convert';

import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/model/country_list_model.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';

import 'booking_data_model.dart';
import 'service_data_model.dart';

class DashboardResponse {
  List<CategoryData>? category;
  List<Configuration>? configurations;
  List<UserData>? provider;
  List<ServiceData>? service;
  List<ServiceData>? featuredServices;
  List<SliderModel>? slider;
  List<PaymentSetting>? paymentSettings;
  List<DashboardCustomerReview>? dashboardCustomerReview;
  bool? status;
  bool? isPayPalConfiguration;
  int? notificationUnreadCount;
  PrivacyPolicy? privacyPolicy;
  AppDownload? appDownload;
  PrivacyPolicy? termConditions;
  String? inquiryEmail;
  String? helplineNumber;
  List<LanguageOption>? languageOption;
  BookingData? bookingData;
  List<BookingData>? upcomingData;
  String? isAdvancedPaymentAllowed;

  DashboardResponse({
    this.category,
    this.configurations,
    this.isPayPalConfiguration,
    this.featuredServices,
    this.provider,
    this.service,
    this.appDownload,
    this.slider,
    this.status,
    this.paymentSettings,
    this.dashboardCustomerReview,
    this.notificationUnreadCount,
    this.privacyPolicy,
    this.termConditions,
    this.inquiryEmail,
    this.helplineNumber,
    this.languageOption,
    this.bookingData,
    this.upcomingData,
    this.isAdvancedPaymentAllowed,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      category: json['category'] != null ? (json['category'] as List).map((i) => CategoryData.fromJson(i)).toList() : null,
      configurations: json['configurations'] != null ? (json['configurations'] as List).map((i) => Configuration.fromJson(i)).toList() : null,
      isPayPalConfiguration: json['is_paypal_configuration'],
      provider: json['provider'] != null ? (json['provider'] as List).map((i) => UserData.fromJson(i)).toList() : null,
      service: json['service'] != null ? (json['service'] as List).map((i) => ServiceData.fromJson(i)).toList() : null,
      featuredServices: json['featured_service'] != null ? (json['featured_service'] as List).map((i) => ServiceData.fromJson(i)).toList() : null,
      slider: json['slider'] != null ? (json['slider'] as List).map((i) => SliderModel.fromJson(i)).toList() : null,
      paymentSettings: json['payment_settings'] != null ? (json['payment_settings'] as List).map((i) => PaymentSetting.fromJson(i)).toList() : null,
      dashboardCustomerReview: json['customer_review'] != null ? (json['customer_review'] as List).map((i) => DashboardCustomerReview.fromJson(i)).toList() : null,
      status: json['status'],
      notificationUnreadCount: json['notification_unread_count'],
      privacyPolicy: json['privacy_policy'] != null ? PrivacyPolicy.fromJson(json['privacy_policy']) : null,
      appDownload: json['app_download'] != null ? AppDownload.fromJson(json['app_download']) : null,
      termConditions: json['term_conditions'] != null ? PrivacyPolicy.fromJson(json['term_conditions']) : null,
      inquiryEmail: json['inquriy_email'],
      helplineNumber: json['helpline_number'],
      isAdvancedPaymentAllowed: json['is_advanced_payment_allowed'],
      languageOption: json['language_option'] != null ? (json['language_option'] as List).map((i) => LanguageOption.fromJson(i)).toList() : null,
      bookingData: json['booking_data'] != null ? BookingData.fromJson(json['booking_data']) : null,
      upcomingData: json['upcomming_booking'] != null ? (json['upcomming_booking'] as List).map((i) => BookingData.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['is_paypal_configuration'] = this.isPayPalConfiguration;
    data['status'] = this.status;
    data['notification_unread_count'] = this.notificationUnreadCount;
    if (this.category != null) {
      data['category'] = this.category!.map((v) => v.toJson()).toList();
    }
    if (this.configurations != null) {
      data['configurations'] = this.configurations!.map((v) => v.toJson()).toList();
    }
    if (this.provider != null) {
      data['provider'] = this.provider!.map((v) => v.toJson()).toList();
    }
    if (this.service != null) {
      data['service'] = this.service!.map((v) => v.toJson()).toList();
    }
    if (this.featuredServices != null) {
      data['featured_service'] = this.service!.map((v) => v.toJson()).toList();
    }
    if (this.slider != null) {
      data['slider'] = this.slider!.map((v) => v.toJson()).toList();
    }
    if (this.paymentSettings != null) {
      data['payment_settings'] = this.paymentSettings!.map((v) => v.toJson()).toList();
    }
    if (this.dashboardCustomerReview != null) {
      data['customer_review'] = this.dashboardCustomerReview!.map((v) => v.toJson()).toList();
    }
    if (this.privacyPolicy != null) {
      data['privacy_policy'] = this.privacyPolicy;
    }
    if (this.appDownload != null) {
      data['app_download'] = this.appDownload;
    }
    if (this.termConditions != null) {
      data['term_conditions'] = this.termConditions;
    }
    data['inquriy_email'] = this.inquiryEmail;
    data['helpline_number'] = this.helplineNumber;
    data['is_advanced_payment_allowed'] = this.isAdvancedPaymentAllowed;

    if (this.languageOption != null) {
      data['language_option'] = this.languageOption!.map((v) => v.toJson()).toList();
    }
    if (this.upcomingData != null) {
      data['upcomming_booking'] = this.upcomingData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PrivacyPolicy {
  int? id;
  String? key;
  String? type;
  String? value;

  PrivacyPolicy({this.id, this.key, this.type, this.value});

  factory PrivacyPolicy.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicy(
      id: json['id'],
      key: json['key'],
      type: json['type'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['key'] = this.key;
    data['type'] = this.type;
    data['value'] = this.value;
    return data;
  }
}

class Configuration {
  CountryListResponse? country;
  int? id;
  String? key;
  String? type;
  String? value;

  Configuration({this.country, this.id, this.key, this.type, this.value});

  factory Configuration.fromJson(Map<String, dynamic> json) {
    return Configuration(
      country: json['country'] != null ? CountryListResponse.fromJson(json['country']) : null,
      id: json['id'],
      key: json['key'],
      type: json['type'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['key'] = this.key;
    data['type'] = this.type;
    data['value'] = this.value;
    if (this.country != null) {
      data['country'] = this.country!.toJson();
    }
    return data;
  }
}

class SliderModel {
  String? description;
  int? id;
  String? serviceName;
  String? sliderImage;
  int? status;
  String? title;
  String? type;
  String? typeId;

  SliderModel({
    this.description,
    this.id,
    this.serviceName,
    this.sliderImage,
    this.status,
    this.title,
    this.type,
    this.typeId,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      description: json['description'],
      id: json['id'],
      serviceName: json['service_name'],
      sliderImage: json['slider_image'],
      status: json['status'],
      title: json['title'],
      type: json['type'],
      typeId: json['type_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['id'] = this.id;
    data['service_name'] = this.serviceName;
    data['slider_image'] = this.sliderImage;
    data['status'] = this.status;
    data['title'] = this.title;
    data['type'] = this.type;
    data['type_id'] = this.typeId;
    return data;
  }
}

class PaymentSetting {
  int? id;
  int? isTest;
  LiveValue? liveValue;
  int? status;
  String? title;
  String? type;
  LiveValue? testValue;

  PaymentSetting({this.id, this.isTest, this.liveValue, this.status, this.title, this.type, this.testValue});

  static String encode(List<PaymentSetting> paymentList) {
    return json.encode(paymentList.map<Map<String, dynamic>>((payment) => payment.toJson()).toList());
  }

  static List<PaymentSetting> decode(String musics) {
    return (json.decode(musics) as List<dynamic>).map<PaymentSetting>((item) => PaymentSetting.fromJson(item)).toList();
  }

  factory PaymentSetting.fromJson(Map<String, dynamic> json) {
    return PaymentSetting(
      id: json['id'],
      isTest: json['is_test'],
      liveValue: json['live_value'] != null ? LiveValue.fromJson(json['live_value']) : null,
      status: json['status'],
      title: json['title'],
      type: json['type'],
      testValue: json['value'] != null ? LiveValue.fromJson(json['value']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['is_test'] = this.isTest;
    data['status'] = this.status;
    data['title'] = this.title;
    data['type'] = this.type;
    if (this.liveValue != null) {
      data['live_value'] = this.liveValue?.toJson();
    }
    if (this.testValue != null) {
      data['value'] = this.testValue?.toJson();
    }
    return data;
  }
}

class LiveValue {
  /// For Stripe
  String? stripeUrl;
  String? stripeKey;
  String? stripePublickey;

  /// For Razor Pay
  String? razorUrl;
  String? razorKey;
  String? razorSecret;

  /// For Flutter Wave
  String? flutterwavePublic;
  String? flutterwaveSecret;
  String? flutterwaveEncryption;

  /// For PayStack
  String? paypalUrl;

  /// For Sadad
  String? sadadId;
  String? sadadKey;
  String? sadadDomain;

  /// For CinetPay
  String? cinetId;
  String? cinetKey;
  String? cinetPublicKey;

  LiveValue({
    this.stripeUrl,
    this.stripeKey,
    this.stripePublickey,
    this.razorUrl,
    this.razorKey,
    this.razorSecret,
    this.flutterwavePublic,
    this.flutterwaveSecret,
    this.flutterwaveEncryption,
    this.paypalUrl,
    this.sadadId,
    this.sadadKey,
    this.sadadDomain,
    this.cinetId,
    this.cinetKey,
    this.cinetPublicKey,
  });

  factory LiveValue.fromJson(Map<String, dynamic> json) {
    return LiveValue(
      stripeUrl: json['stripe_url'],
      stripeKey: json['stripe_key'],
      stripePublickey: json['stripe_publickey'],
      razorUrl: json['razor_url'],
      razorKey: json['razor_key'],
      razorSecret: json['razor_secret'],
      flutterwavePublic: json['flutterwave_public'],
      flutterwaveSecret: json['flutterwave_secret'],
      flutterwaveEncryption: json['flutterwave_encryption'],
      paypalUrl: json['paypal_url'],
      sadadId: json['sadad_id'],
      sadadKey: json['sadad_key'],
      sadadDomain: json['sadad_domain'],
      cinetId: json['cinet_id'],
      cinetKey: json['cinet_key'],
      cinetPublicKey: json['cinet_publickey'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stripe_url'] = this.stripeUrl;
    data['stripe_key'] = this.stripeKey;
    data['stripe_publickey'] = this.stripePublickey;
    data['razor_url'] = this.razorUrl;
    data['razor_key'] = this.razorKey;
    data['razor_secret'] = this.razorSecret;
    data['flutterwave_public'] = this.flutterwavePublic;
    data['flutterwave_secret'] = this.flutterwaveSecret;
    data['flutterwave_encryption'] = this.flutterwaveEncryption;
    data['paypal_url'] = this.paypalUrl;
    data['sadad_id'] = this.sadadId;
    data['sadad_key'] = this.sadadKey;
    data['sadad_domain'] = this.sadadDomain;
    data['cinet_id'] = this.cinetId;
    data['cinet_key'] = this.cinetKey;
    data['cinet_publickey'] = this.cinetPublicKey;

    return data;
  }
}

class DashboardCustomerReview {
  List<String>? attchments;
  int? bookingId;
  String? createdAt;
  int? customerId;
  String? customerName;
  int? id;
  String? profileImage;
  num? rating;
  String? review;
  int? serviceId;
  String? serviceName;

  DashboardCustomerReview(
      {this.attchments, this.bookingId, this.createdAt, this.customerId, this.customerName, this.id, this.profileImage, this.rating, this.review, this.serviceId, this.serviceName});

  factory DashboardCustomerReview.fromJson(Map<String, dynamic> json) {
    return DashboardCustomerReview(
      attchments: json['attchments'] != null ? new List<String>.from(json['attchments']) : null,
      bookingId: json['booking_id'],
      createdAt: json['created_at'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      id: json['id'],
      profileImage: json['profile_image'],
      rating: json['rating'],
      review: json['review'],
      serviceId: json['service_id'],
      serviceName: json['service_name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['booking_id'] = this.bookingId;
    data['created_at'] = this.createdAt;
    data['customer_id'] = this.customerId;
    data['customer_name'] = this.customerName;
    data['id'] = this.id;
    data['profile_image'] = this.profileImage;
    data['rating'] = this.rating;
    data['review'] = this.review;
    data['service_id'] = this.serviceId;
    data['service_name'] = this.serviceName;
    if (this.attchments != null) {
      data['attchments'] = this.attchments;
    }
    return data;
  }
}

class LanguageOption {
  String? flagImage;
  String? id;
  String? title;

  LanguageOption({this.flagImage, this.id, this.title});

  factory LanguageOption.fromJson(Map<String, dynamic> json) {
    return LanguageOption(
      flagImage: json['flag_image'],
      id: json['id'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['flag_image'] = this.flagImage;
    data['id'] = this.id;
    data['title'] = this.title;
    return data;
  }
}

class AppDownload {
  String? appstore_url;
  String? created_at;
  String? description;
  int? id;
  String? playstore_url;
  String? provider_appstore_url;
  String? provider_playstore_url;
  String? title;
  String? updated_at;

  AppDownload({
    this.appstore_url,
    this.created_at,
    this.description,
    this.id,
    this.playstore_url,
    this.provider_appstore_url,
    this.provider_playstore_url,
    this.title,
    this.updated_at,
  });

  factory AppDownload.fromJson(Map<String, dynamic> json) {
    return AppDownload(
      appstore_url: json['appstore_url'],
      created_at: json['created_at'],
      description: json['description'],
      id: json['id'],
      playstore_url: json['playstore_url'],
      provider_appstore_url: json['provider_appstore_url'],
      provider_playstore_url: json['provider_playstore_url'],
      title: json['title'],
      updated_at: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['appstore_url'] = this.appstore_url;
    data['created_at'] = this.created_at;
    data['description'] = this.description;
    data['id'] = this.id;
    data['playstore_url'] = this.playstore_url;
    data['provider_appstore_url'] = this.provider_appstore_url;
    data['provider_playstore_url'] = this.provider_playstore_url;
    data['title'] = this.title;
    data['updated_at'] = this.updated_at;
    return data;
  }
}
