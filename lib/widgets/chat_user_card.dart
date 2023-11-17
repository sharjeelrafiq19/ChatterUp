import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_up/models/chat_user.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .03, vertical: 4),
      child: InkWell(
        onTap: () {},
        child: ListTile(
          // leading: const CircleAvatar(
          //   child: Icon(Icons.person),
          // ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * .3),
            child: CachedNetworkImage(
              width: MediaQuery.of(context).size.height * .055,
              height:  MediaQuery.of(context).size.height * .055,
              imageUrl: widget.user.image,
              //placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
          ),
          title: Text(widget.user.name),
          subtitle: Text(
            widget.user.about,
            maxLines: 1,
          ),
          trailing: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(color: Colors.greenAccent.shade400, borderRadius: BorderRadius.circular(10)),
          ),
          //trailing: const Text("12:00 PM", style: TextStyle(color: Colors.black54),),
        ),
      ),
    );
  }
}
