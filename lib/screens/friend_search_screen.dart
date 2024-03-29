import 'dart:async';

import 'package:ar_ai_messaging_client_frontend/app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart' as core;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../pages/home_list.dart';
import '../widgets/avatar.dart';
import '../widgets/display_error_message.dart';
import '../widgets/search_bars.dart';

class FriendSearchScreen extends StatefulWidget {
  static Route get route => MaterialPageRoute(
        builder: (context) => FriendSearchScreen(),
      );

  FriendSearchScreen({Key? key}) : super(key: key);

  @override
  State<FriendSearchScreen> createState() => FriendSearchScreenState();
}

class FriendSearchScreenState extends State<FriendSearchScreen> {
  String autoCompleteText = 'to search';

  final core.UserListController _userListController = core.UserListController();

  @override
  Widget build(BuildContext context) {
    bool shouldPop = true;
    return WillPopScope(
      onWillPop: () async {
        //TODO
        return shouldPop;
      },
      child: Scaffold(
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
                  child: core.UserListCore(
                    userListController: _userListController,
                    limit: 50,
                    filter: core.Filter.and([
                      core.Filter.autoComplete('name', autoCompleteText),
                      core.Filter.notEqual('id', context.currentUser!.id)
                    ]),
                    emptyBuilder: (context) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Center(
                            child:
                                Text('No User found, please try a vaild user name')),
                      );
                    },
                    loadingBuilder: (context) {
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error) {
                      return DisplayErrorMessage(error: error);
                    },
                    listBuilder: (context, items) {
                      return Scrollbar(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(0),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return items[index].when(
                              headerItem: (_) => const SizedBox.shrink(),
                              userItem: (user) => _SearchContactAddTile(
                                user: user,
                                context: context
                              ),
                        );
                      },
                    ),
                  );
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}



class _SearchContactAddTile extends StatelessWidget {
  _SearchContactAddTile({
    Key? key,
    required this.user, this.context,
  }) : super(key: key);

  final core.User user;
  final context;

  final useremail = FirebaseAuth.instance.currentUser?.email;

  //late bool isInFriendList = false;

  addFriendUIDToFirestore() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(useremail)
        .set({"friendList":{user.id:user.name}},SetOptions(merge: true));

    Timer? timer = Timer(Duration(milliseconds: 1000), (){
      Navigator.of(context, rootNavigator: true).pop();
    });
    showDialog(context: context, builder: (BuildContext context) =>
      CupertinoAlertDialog(
          title: Text(
            'Friend Added!',
            style: GoogleFonts.openSans(fontSize: 26),
          ),
        content: Text('🤖💓',style: TextStyle(
          fontSize: 40,
        )),
      ),
    ).then((value){
      // dispose the timer in case something else has triggered the dismiss.
      timer?.cancel();
      timer = null;
    });

  }


  addFriendInOthers() async{
    var extraData = user.extraData as Map<String,dynamic>;
    String toAddEmail = extraData['email'];
    await FirebaseFirestore.instance
        .collection("users")
        .doc(toAddEmail)
        .set({"friendList":{useremail:core.StreamChatCore.of(context).currentUser?.name}},SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    //isInFriendList = fListNotifier.value.contains(user.id);
    return InkWell(
      onTap: () {
      },
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
            leading: Avatar.small(url: user.image),
            title: Text(user.name),
            trailing: ElevatedButton(
                  onPressed: () {
                    addFriendUIDToFirestore();
                  },
                  child: Icon(CupertinoIcons.person_add_solid),
                ),
          ),
        ),
      ),
    );
  }
}


