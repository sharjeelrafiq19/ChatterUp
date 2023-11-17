import 'package:chatter_up/models/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class APIs {
  /// for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  /// for accessing cloud  firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// to return current user
  static User get user => auth.currentUser!;

  /// for storing self information
  static ChatUser? me;

  /// for checking if user exists or not
  static Future<bool> userExists() async {
    return (await firestore.collection("Users").doc(user!.uid).get()).exists;
  }



  /// for getting current user information
  static Future<void> getSelfInfo() async {
    await firestore.collection("users").doc(user !.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        print("My Data: ${user.data()}");
      } else {
        await createUser().then((value) => getAllUsers());
      }
    });
  }

  /// for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey! I'm using ChatterUp",
      image: user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: "",
    );
    return await firestore
        .collection("users")
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  /// to get all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection("users")
        .where("id", isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateUserInfo() async{
    await firestore.collection("users").doc(user.uid).update({
      "name" : me!.name,
      "about" : me!.about,
    });
  }

}
