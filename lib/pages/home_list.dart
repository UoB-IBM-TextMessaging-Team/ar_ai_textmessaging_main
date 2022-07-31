import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:ar_ai_messaging_client_frontend/app.dart';
import '../screens/screens.dart';
import '../widgets/widgets.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({Key? key}) : super(key: key);


  getFriendList(){

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: UserListCore(
        limit: 20,
        filter: Filter.notEqual('id', context.currentUser!.id),
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
          return Scrollbar(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return items[index].when(
                  headerItem: (_) => const SizedBox.shrink(),
                  userItem: (user) => _ContactTile(user: user),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  Future<void> createChannel(BuildContext context) async {
    final core = StreamChatCore.of(context);
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
