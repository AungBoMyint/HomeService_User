import 'dart:async';

import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nb_utils/nb_utils.dart';

import 'base_services.dart';

class UserService extends BaseService {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  StreamSubscription? tokenSubscription;
  UserService() {
    ref = fireStore.collection(USER_COLLECTION);
  }

  Future<UserData> getUserByID({String? key, int? providerID}) {
    return ref!
        .where(key ?? "id", isEqualTo: providerID)
        .limit(1)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        return UserData.fromJson(
            value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw USER_NOT_FOUND;
      }
    });
  }

  Future<UserData> getUser({String? key, String? email}) {
    return ref!
        .where(key ?? "email", isEqualTo: email)
        .limit(1)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        return UserData.fromJson(
            value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw USER_NOT_FOUND;
      }
    });
  }

  Stream<List<UserData>> users({String? searchText}) {
    return ref!
        .where('caseSearch',
            arrayContains: searchText.validate().isEmpty
                ? null
                : searchText!.toLowerCase())
        .snapshots()
        .map((x) {
      return x.docs.map((y) {
        return UserData.fromJson(y.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<UserData> userByEmail(String? email) async {
    return await ref!
        .where('email', isEqualTo: email)
        .limit(1)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        return UserData.fromJson(
            value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw '${language.lblNoUserFound}';
      }
    });
  }

  Stream<UserData> singleUser(String? id, {String? searchText}) {
    return ref!.where('uid', isEqualTo: id).limit(1).snapshots().map((event) {
      return UserData.fromJson(event.docs.first.data() as Map<String, dynamic>);
    });
  }

  Future<UserData> userByMobileNumber(String? phone) async {
    log("Phone $phone");
    return await ref!
        .where('phoneNumber', isEqualTo: phone)
        .limit(1)
        .get()
        .then(
      (value) {
        log(value);
        if (value.docs.isNotEmpty) {
          return UserData.fromJson(
              value.docs.first.data() as Map<String, dynamic>);
        } else {
          throw "${language.lblNoUserFound}";
        }
      },
    );
  }

  Future<void> saveToContacts(
      {required String senderId, required String receiverId}) async {
    return ref!
        .doc(senderId)
        .collection(CONTACT_COLLECTION)
        .doc(receiverId)
        .update({
      'lastMessageTime': DateTime.now().millisecondsSinceEpoch
    }).catchError((e) {
      throw "${language.lblUserNotCreated}";
    });
  }

  Future<void> updatePlayerIdInFirebase(
      {required String email, required String playerId}) async {
    await userByEmail(email).then((value) {
      ref!.doc(value.uid.validate()).update({
        'player_id': playerId,
        'updated_at': Timestamp.now().toDate().toString(),
      });
      log("=============Finish Updating Player ID: $playerId");
      //for listen token change//
      if (!(tokenSubscription == null)) {
        tokenSubscription?.cancel();
      }
      tokenSubscription =
          FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        await userByEmail(email).then((value) {
          ref!.doc(value.uid.validate()).update({
            'player_id': token,
            'updated_at': Timestamp.now().toDate().toString(),
          });
        });
      });
    }).catchError((e) {
      toast(e.toString());
    });
  }

  Future<void> deleteUser() async {
    await FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signOut();
  }
}
