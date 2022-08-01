import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart' as StrCore;
import '../app.dart';
import '../screens/screens.dart';
import '../widgets/widgets.dart';

import 'package:flutter/services.dart';
/*
class ContactsPage extends StatefulWidget{




  @override
  State<ContactsPage> createState() => ContactsPageState();
}


 */


class ContactsPage extends StatelessWidget {

  ContactsPage( {Key? key}) : super(key: key);

/*
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: StreamBuilder<QuerySnapshot>(
          stream: _usersStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(
                  child: DisplayErrorMessage(error: "Error Unknown"));
            }

            if (!snapshot.hasData){
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              children: snapshot.data.docs.((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                print(data.toString());
                return StrCore.UserListCore(
                  limit: 50,
                  filter: StrCore.Filter.in_(
                      'id',
                      data[FirebaseAuth.instance.currentUser?.email]
                              ['friendList']
                          .keys
                          .toList()),
                  emptyBuilder: (context) {
                    return const Center(child: Text('There are no users'));
                  },
                  loadingBuilder: (context) {
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error) {
                    return DisplayErrorMessage(error: error);
                  },
                  listBuilder: (context, items) {
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return items[index].when(
                          headerItem: (_) => const SizedBox.shrink(),
                          userItem: (user) => _ContactTile(user: user),
                        );
                      },
                    );
                  },
                );
              }).toList(),
            );
          }),
    );
  }

*/
/*
  @override
  void initState() {
    Notifier.updateFriendList();
    super.initState();
  }

 */

  @override
  Widget build(BuildContext context) {
    print("build chat listy");
    print(fListNotifier);
    print("WTF");
    print(fListNotifier.value);
    friendListNotifier()?.updateFriendList();
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: ValueListenableBuilder<List<String>>(
        builder: (BuildContext context, List<String> value, Widget? child) {
          return StrCore.UserListCore(
            limit: 20,
            filter: StrCore.Filter.in_('id', value),
            emptyBuilder: (context) {
              return const Center(child: Text('There are no users'));
            },
            loadingBuilder: (context) {
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error) {
              return DisplayErrorMessage(error: error);
            },
            listBuilder: (context, items) {
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return items[index].when(
                    headerItem: (_) => const SizedBox.shrink(),
                    userItem: (user) => _ContactTile(user: user),
                  );
                },
              );
            },
          );
        },
        valueListenable: fListNotifier,
      )
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    Key? key,
    required this.user,
  }) : super(key: key);

  final StrCore.User user;

  Future<void> createChannel(BuildContext context) async {
    final core = StrCore.StreamChatCore.of(context);
    final channel = core.client.channel('messaging', extraData: {
      'members': [
        core.currentUser!.id,
        user.id,
      ]
    });
    await channel.watch();

    Navigator.of(context).push(
      ChateScreen.routeWithChannel(channel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        createChannel(context);
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
          ),
        ),
      ),
    );
  }
}
