import 'dart:convert';
import 'dart:math';

import 'package:chatter_up/api/apis.dart';
import 'package:chatter_up/auth/profile_screen.dart';
import 'package:chatter_up/models/chat_user.dart';
import 'package:chatter_up/widgets/chat_user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// For storing all users
  List<ChatUser> _list = [];

  /// For searching all users
  final List<ChatUser> _searchList = [];

  /// For storing search
  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        // if search is on & back button is pressed then close search
        // or else simple close current screen on back button click
        onWillPop: (){
          if(_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          }else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          //backgroundColor: Color(0xff2c462b),
          appBar: AppBar(
            //backgroundColor: Color(0xff2c462b),
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: _isSearching
                ? TextField(
                    style: TextStyle(color: Colors.white, letterSpacing: 1),
                    cursorColor: Colors.cyan,

                    /// when search text changes then updated search list
                    onChanged: (value) {
                      // search logic
                      _searchList.clear();

                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(value.toLowerCase()) ||
                            i.email.toLowerCase().contains(value.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                    autofocus: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search...",
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                  )
                : Text("ChatterUp"),
            leading: const Icon(CupertinoIcons.home),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(_isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search),
              ),
              PopupMenuButton(
                  itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileScreen(user: APIs.me!)));
                          },
                          child: const Text("Profile Screen"),
                        ),
                      ]),
              // IconButton(
              //   onPressed: () {
              //     Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(user: list[0])));
              //   },
              //   icon: const Icon(Icons.more_vert),
              // ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () async {
                await APIs.auth.signOut();
                await GoogleSignIn().signOut();
              },
              child: const Icon(Icons.add),
              backgroundColor: const Color(0xff2c462b),
            ),
          ),
          body: StreamBuilder(
              stream: APIs.getAllUsers(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  ///if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());

                  ///if some or all data is loading than  show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    print("Hello $data");
                    _list = data
                            ?.map((error) => ChatUser.fromJson(error.data()))
                            .toList() ??
                        [];

                    if (_list.isNotEmpty) {
                      return ListView.builder(
                          itemCount: _isSearching ? _searchList.length : _list.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            //return Text("Name: ${list[index]}");
                            return ChatUserCard(
                              user: _isSearching? _searchList[index] : _list[index],
                            );
                          });
                    } else {
                      return const Center(
                          child: Text(
                        "User Not Found!",
                        style: TextStyle(fontSize: 20),
                      ));
                    }
                }
              }),
        ),
      ),
    );
  }
}
