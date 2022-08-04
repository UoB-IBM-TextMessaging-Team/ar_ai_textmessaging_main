
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fireAuth;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart' as log;
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

const streamKey = 'cehah339gsxg';

var logger = log.Logger();

/// Extensions can be used to add functionality to the SDK.
extension StreamChatContext on BuildContext {
  /// Fetches the current user image.
  String? get currentUserImage => currentUser!.image;

  /// Fetches the current user.
  User? get currentUser => StreamChatCore.of(this).currentUser;

}
/*

ValueNotifier<List<String>> fListNotifier = ValueNotifier<List<String>>(['WooHoo']);

class friendListNotifier{
  final docRef = FirebaseFirestore.instance.collection("users").doc(fireAuth.FirebaseAuth.instance.currentUser?.email);

  updateFriendList(){
    docRef.get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      var FriList = data['friendList'] as Map<String,dynamic>;
      fListNotifier.value = FriList.keys.toList();
    }, onError: (e) => print("Error getting document: $e"),);
  }

  emptyFriendList(){
    fListNotifier.value = ['WooHaa'];
  }
}
*/

class ZeroDurationRoute extends MaterialPageRoute {
  ZeroDurationRoute({required WidgetBuilder builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => Duration(seconds: 0);
}
