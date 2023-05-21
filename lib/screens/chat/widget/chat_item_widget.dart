import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/chat_message_model.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../services/translation_api.dart';
import '../../../utils/translations_language_code.dart';

class ChatItemWidget extends StatefulWidget {
  final ChatMessageModel? chatItemData;
  final String fromLanguage;
  final String toLanguage;

  ChatItemWidget({
    this.chatItemData,
    required this.fromLanguage,
    required this.toLanguage,
  });

  @override
  _ChatItemWidgetState createState() => _ChatItemWidgetState();
}

class _ChatItemWidgetState extends State<ChatItemWidget> {
  String? images;

  void initState() {
    super.initState();
    init();
  }

  init() async {}
  String? translation;

  @override
  Widget build(BuildContext context) {
    String time;
    String currentDateTime = widget.chatItemData!.createdAtTime != null
        ? widget.chatItemData!.createdAtTime!.toDate().toString()
        : widget.chatItemData!.createdAt.validate().toString();

    DateTime date = widget.chatItemData!.createdAtTime != null
        ? widget.chatItemData!.createdAtTime!.toDate()
        : DateTime.fromMicrosecondsSinceEpoch(
            widget.chatItemData!.createdAt! * 1000);
    if (date.day == DateTime.now().day) {
      time = formatDate(currentDateTime,
          format: DATE_FORMAT_3,
          isFromMicrosecondsSinceEpoch:
              widget.chatItemData!.createdAtTime == null);
    } else {
      time = formatDate(currentDateTime,
          format: DATE_FORMAT_1,
          isFromMicrosecondsSinceEpoch:
              widget.chatItemData!.createdAtTime == null);
    }

    Widget chatItem(String? messageTypes, String? translation) {
      switch (messageTypes) {
        case TEXT:
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: widget.chatItemData!.isMe!
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                translation ?? widget.chatItemData!.message!,
                style: primaryTextStyle(
                    color: widget.chatItemData!.isMe!
                        ? Colors.white
                        : textPrimaryColorGlobal),
                maxLines: null,
              ),
              1.height,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: primaryTextStyle(
                      color: !widget.chatItemData!.isMe.validate()
                          ? Colors.blueGrey.withOpacity(0.6)
                          : whiteColor.withOpacity(0.6),
                      size: 10,
                    ),
                  ),
                  2.width,
                  widget.chatItemData!.isMe.validate()
                      ? !widget.chatItemData!.isMessageRead.validate()
                          ? Icon(Icons.done, size: 12, color: Colors.white60)
                          : Icon(Icons.done_all,
                              size: 12, color: Colors.white60)
                      : Offstage()
                ],
              ),
            ],
          );

        default:
          return Container();
      }
    }

    EdgeInsetsGeometry customPadding(String? messageTypes) {
      switch (messageTypes) {
        case TEXT:
          return EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        default:
          return EdgeInsets.symmetric(horizontal: 4, vertical: 4);
      }
    }

    Widget message(String? translation, BuildContext context,
        ChatMessageModel? chatItemData) {
      return GestureDetector(
        onLongPress: () async {
          showConfirmDialogCustom(
            context,
            title: language.lblConfirmationForDeleteMsg,
            dialogType: DialogType.DELETE,
            positiveText: language.lblYes,
            negativeText: language.lblNo,
            onAccept: (_) {
              hideKeyboard(context);
              chatServices
                  .deleteSingleMessage(
                      senderId: appStore.uid,
                      receiverId: chatItemData.receiverId!,
                      documentId: widget.chatItemData!.uid.validate())
                  .then((value) {
                //
              }).catchError((e) {
                log(e.toString());
              });
            },
          );
        },
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: chatItemData!.isMe.validate()
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisAlignment: chatItemData.isMe!
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Container(
                margin: chatItemData.isMe.validate()
                    ? EdgeInsets.only(
                        top: 0.0,
                        bottom: 0.0,
                        left: isRTL ? 0 : context.width() * 0.25,
                        right: 8)
                    : EdgeInsets.only(
                        top: 2.0,
                        bottom: 2.0,
                        left: 8,
                        right: isRTL ? 0 : context.width() * 0.25),
                padding: customPadding(chatItemData.messageType),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: gray,
                        blurRadius: 0.1,
                        spreadRadius: 0.2), //BoxShadow
                  ],
                  color: chatItemData.isMe.validate()
                      ? primaryColor
                      : context.cardColor,
                  borderRadius: chatItemData.isMe.validate()
                      ? radiusOnly(
                          bottomLeft: 12,
                          topLeft: 12,
                          bottomRight: 0,
                          topRight: 12)
                      : radiusOnly(
                          bottomLeft: 0,
                          topLeft: 12,
                          bottomRight: 12,
                          topRight: 12),
                ),
                child: chatItem(chatItemData.messageType, translation),
              ),
            ],
          ),
          margin: EdgeInsets.only(top: 2, bottom: 2),
        ),
      );
    }

    final fromLanguageCode = Translations.getLanguageCode(widget.fromLanguage);

    final toLanguageCode = Translations.getLanguageCode(widget.toLanguage);
    log("FromLanguage: ${widget.fromLanguage}\n ToLanguage: ${widget.toLanguage}");
    return FutureBuilder(
        future: TranslationApi.translate(widget.chatItemData!.message!,
            fromLanguageCode /* , toLanguageCode */),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return message(translation, context, widget.chatItemData);
            default:
              if (snapshot.hasError) {
                log("Translate Error: ${snapshot.error}");
                translation = 'Could not translate due to Network problems';
              } else {
                translation = snapshot.data;
              }
              return message(translation!, context, widget.chatItemData);
          }
        });
  }
}
