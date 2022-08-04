import 'dart:async';

import 'package:ar_ai_messaging_client_frontend/app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart' as core;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../app_theme.dart';
import '../pages/home_list.dart';
import '../widgets/avatar.dart';
import '../widgets/display_error_message.dart';
import '../widgets/search_bars.dart';

class FriendSearchScreenFb extends StatefulWidget {
  static Route get route => ZeroDurationRoute(
        builder: (context) => FriendSearchScreenFb(),
      );

  FriendSearchScreenFb({Key? key}) : super(key: key);

  @override
  State<FriendSearchScreenFb> createState() => FriendSearchScreenFbState();
}

class FriendSearchScreenFbState extends State<FriendSearchScreenFb> {
  String autoCompleteText = 'to search';

  addFriendUIDToFirestore(DocumentSnapshot fbUser) async {
    final useremail = FirebaseAuth.instance.currentUser?.email;
    await FirebaseFirestore.instance.collection("users").doc(useremail).set({
      "friendList": {fbUser['userEmail']: fbUser['userName']}
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection("users")
        .doc(fbUser['userEmail'])
        .set({"friendList":{useremail:core.StreamChatCore.of(context).currentUser?.name}},SetOptions(merge: true));

    Timer? timer = Timer(Duration(milliseconds: 1000), () {
      Navigator.of(context, rootNavigator: true).pop();
    });
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(
          'Friend Added!',
          style: GoogleFonts.openSans(fontSize: 26),
        ),
        content: Text('🤖💓',
            style: TextStyle(
              fontSize: 40,
            )),
      ),
    ).then((value) {
      // dispose the timer in case something else has triggered the dismiss.
      timer?.cancel();
      timer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool shouldPop = true;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, // 首页列表背景色 <=========
          ),
          padding: const EdgeInsets.only(top: 70),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 27, bottom: 3),
                    child: Text(
                      'Search',
                      style: GoogleFonts.grandHotel(fontSize: 36),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
                child: Searcher(onEnterPress: (String s) {
                  if (s.isNotEmpty) {
                    setState(() {
                      autoCompleteText = s;
                    });
                  }
                }),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('userName',
                          isGreaterThanOrEqualTo: autoCompleteText,
                          isLessThanOrEqualTo: autoCompleteText+'\uf8ff')
                        .snapshots(),
                    builder: (context, snapshots) {
                      return (snapshots.connectionState ==
                              ConnectionState.waiting)
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Scrollbar(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(0),
                                itemCount: snapshots.data?.docs.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot FbUser = snapshots.data?.docs[index] as DocumentSnapshot<Object?>;
                                  return InkWell(
                                    onTap: () {},
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Container(
                                        // message bar height
                                        height: 64,
                                        margin: const EdgeInsets.symmetric(horizontal: 8),

                                        // bottom grey line
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey,
                                              width: 0.2,
                                            ),
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: Avatar.small(url: FbUser['profilePicURL']),
                                          title: Text(FbUser['userName']),
                                          trailing: ElevatedButton(
                                            onPressed: () {
                                              addFriendUIDToFirestore(FbUser);
                                            },
                                            child: Icon(CupertinoIcons.person_add_solid),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                  /*
                                  return items[index].when(
                                    headerItem: (_) => const SizedBox.shrink(),
                                    userItem: (user) => _SearchContactAddTile(
                                        user: user, context: context),
                                   */
                                },
                              ),
                            );
                    }),
              )
            ],
          ),
        ),
    );
  }
}
