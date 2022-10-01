// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, implementation_imports, unused_field, prefer_final_fields, prefer_const_literals_to_create_immutables, non_constant_identifier_names, avoid_unnecessary_containers, sized_box_for_whitespace, unnecessary_string_interpolations

import 'dart:async';
import 'dart:io';

import 'package:chat/allCostants/color_costants.dart';
import 'package:chat/allCostants/constants.dart';
import 'package:chat/allModels/popup_choices.dart';
import 'package:chat/allModels/user_chat.dart';
import 'package:chat/allProviders/auth_provider.dart';
import 'package:chat/allProviders/home_provider.dart';
import 'package:chat/allScreens/chat_screen.dart';
import 'package:chat/allScreens/login_screen.dart';
import 'package:chat/allScreens/settings_screen.dart';
import 'package:chat/allWidgets/loading_view.dart';
import 'package:chat/main.dart';
import 'package:chat/utilities/debouncer.dart';
import 'package:chat/utilities/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController listScrollController = ScrollController();
  TextEditingController searchBarTec = TextEditingController();

  int _limit = 29;
  int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;

  late String currentUserId;
  late AuthProvider authProvider;
  late HomeProvider homeProvider;
  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  StreamController<bool> btnClearController = StreamController<bool>();

  List<PopupChoices> choices = [
    PopupChoices(title: 'Settings', icon: Icons.settings),
    PopupChoices(title: 'Sign Out', icon: Icons.exit_to_app),
  ];

  Future<void> handleSignOut() async {
    authProvider.handleSignOut();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ));
  }

  void scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onItemMenuPressed(PopupChoices choice) {
    if (choice.title == "Sign Out") {
      handleSignOut();
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsScreen(),
          ));
    }
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<void> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            clipBehavior: Clip.hardEdge,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                color: ColorConstants.themeColor,
                padding: EdgeInsets.only(bottom: 10, top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10),
                    ),
                    Text(
                      'Exit App',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Are you sure to exit app',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: ColorConstants.primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Text(
                      'Cancel',
                      style: TextStyle(
                        color: ColorConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: ColorConstants.primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Text(
                      'Yes',
                      style: TextStyle(
                        color: ColorConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
    }
  }

  @override
  void dispose() {
    btnClearController.close();
    super.dispose();
  }

  @override
  void initState() {
    authProvider = context.read<AuthProvider>();
    homeProvider = context.read<HomeProvider>();

    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false);
    }
    listScrollController.addListener(scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isWhite ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isWhite ? Colors.white : Colors.black,
        leading: IconButton(
          onPressed: () => "",
          icon: Switch(
            value: isWhite,
            onChanged: (value) {
              setState(() {
                isWhite = value;
              });
            },
            activeTrackColor: Colors.grey,
            activeColor: Colors.white,
            inactiveTrackColor: Colors.grey,
            inactiveThumbColor: Colors.black45,
          ),
        ),
        actions: <Widget>[
          buildPopupMenu(),
        ],
      ),
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                buildSearchBar(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: homeProvider.getStreamFirestore(
                      FirestoreConstants.pathUserCollection,
                      _limit,
                      _textSearch,
                    ),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        if ((snapshot.data?.docs.length ?? 0) > 0) {
                          return ListView.builder(
                            padding: EdgeInsets.all(10),
                            itemBuilder: ((context, index) =>
                                BuildItem(context, snapshot.data?.docs[index])),
                            itemCount: snapshot.data?.docs.length,
                            controller: listScrollController,
                          );
                        } else {
                          return Center(
                            child: Text(
                              'No user found',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.grey,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              child: isLoading ? LoadingView() : SizedBox.shrink(),
            ),
          ],
        ),
        onWillPop: onBackPress,
      ),
    );
  }

  Widget buildSearchBar() {
    return Container(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.search,
            color: ColorConstants.greyColor,
            size: 20,
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.search,
              controller: searchBarTec,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  btnClearController.add(true);
                  setState(() {
                    _textSearch = value;
                  });
                } else {
                  btnClearController.add(false);
                  setState(() {
                    _textSearch = "";
                  });
                }
              },
              decoration: InputDecoration.collapsed(
                hintText: 'Search here',
                hintStyle:
                    TextStyle(fontSize: 13, color: ColorConstants.greyColor),
              ),
              style: TextStyle(fontSize: 13),
            ),
          ),
          StreamBuilder(
            builder: (context, snapshot) {
              return snapshot.data == true
                  ? GestureDetector(
                      onTap: () {
                        searchBarTec.clear();
                        btnClearController.add(false);
                        setState(() {
                          _textSearch = "";
                        });
                      },
                      child: Icon(
                        Icons.clear_rounded,
                        color: ColorConstants.greyColor,
                        size: 20,
                      ),
                    )
                  : SizedBox.shrink();
            },
            stream: btnClearController.stream,
          )
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: ColorConstants.greyColor2,
      ),
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
    );
  }

  Widget buildPopupMenu() {
    return PopupMenuButton(
        icon: Icon(
          Icons.more_vert,
          color: Colors.grey,
        ),
        onSelected: onItemMenuPressed,
        itemBuilder: ((context) {
          return choices.map((choice) {
            return PopupMenuItem(
              value: choice,
              child: Row(
                children: <Widget>[
                  Icon(
                    choice.icon,
                    color: ColorConstants.primaryColor,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    choice.title,
                    style: TextStyle(color: ColorConstants.primaryColor),
                  ),
                ],
              ),
            );
          }).toList();
        }));
  }

  Widget BuildItem(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      UserChat userChat = UserChat.fromDocument(document);
      if (userChat.id == currentUserId) {
        return SizedBox.shrink();
      } else {
        return Container(
          child: TextButton(
            onPressed: () {
              if (Utilities.isKeyboardShowing()) {
                Utilities.closeKeyboard(context);
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      peerId: userChat.id,
                      peerAvatar: userChat.photoUrl,
                      peerNickname: userChat.nickname,
                    ),
                  ));
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.grey.withOpacity(.2)),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                Material(
                  child: userChat.photoUrl.isNotEmpty
                      ? Image.network(
                          userChat.photoUrl,
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Container(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(
                                  color: Colors.grey,
                                  value: loadingProgress.expectedTotalBytes !=
                                              null &&
                                          loadingProgress.expectedTotalBytes !=
                                              null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            }
                          },
                          errorBuilder: (context, object, stackTrace) {
                            return Icon(
                              Icons.account_circle,
                              size: 50,
                              color: ColorConstants.greyColor,
                            );
                          },
                        )
                      : Icon(
                          Icons.account_circle,
                          size: 50,
                          color: ColorConstants.greyColor,
                        ),
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  clipBehavior: Clip.hardEdge,
                ),
                Flexible(
                    child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          '${userChat.nickname}',
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                      ),
                      Container(
                        child: Text(
                          '${userChat.aboutMe}',
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20),
                )),
              ],
            ),
          ),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }
}
