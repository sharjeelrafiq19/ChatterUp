import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_up/api/apis.dart';
import 'package:chatter_up/auth/login_screen.dart';
import 'package:chatter_up/helper/dialogs.dart';
import 'package:chatter_up/models/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Profile Screen"),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * .05),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.height * .1),
                        child: CachedNetworkImage(
                          width: MediaQuery.of(context).size.height * .2,
                          height: MediaQuery.of(context).size.height * .2,
                          fit: BoxFit.fill,
                          imageUrl: widget.user.image,
                          //placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          onPressed: () {
                            _showBottomSheet();
                          },
                          color: Colors.white,
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xff2c462b),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .03),
                  Text(
                    widget.user.email,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .05),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * .06),
                    child: TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => APIs.me!.name = val ?? "",
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : "Required Fill",
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Color(0xff2c462b),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: "eg. Username"),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .02),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * .06),
                    child: TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => APIs.me!.about = val ?? "",
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : "Required Fill",
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.info,
                            color: Color(0xff2c462b),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: "eg. About"),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .05),
                  // update profile button
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackbar(context, "Updated Successfully");
                        });
                        print("inside validator");
                      }
                    },
                    icon: const Icon(Icons.update),
                    label: const Text("Update"),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            onPressed: () async {
              // for showing progress dialog
              Dialogs.showProgressBar(context);

              // SignOut from app
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  // for hiding progress dialog
                  Navigator.pop(context);
                  // for moving to home screen
                  Navigator.pop(context);
                  // replacing home screen with Login screen
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                });
              });
            },
            icon: const Icon(
              Icons.logout,
            ),
            backgroundColor: Colors.red,
            label: const Text("logout"),
          ),
        ),
      ),
    );
  }

  // bottom sheet for a picking profile
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * .03,
                bottom: MediaQuery.of(context).size.width * .05),
            children: [
              const Text(
                "Pick Profile Image",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        fixedSize: Size(MediaQuery.of(context).size.width * .4,
                            MediaQuery.of(context).size.height * .15)),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if(image != null){
                        print("Image Path: ${image.path} -- MimeType: ${image.mimeType}");

                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset("assets/images/gallery.png"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        fixedSize: Size(MediaQuery.of(context).size.width * .4,
                            MediaQuery.of(context).size.height * .15)),
                    onPressed: () {},
                    child: Image.asset("assets/images/camera.png"),
                  ),
                ],
              )
            ],
          );
        });
  }
}
