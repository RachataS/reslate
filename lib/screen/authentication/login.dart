import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reslate/screen/bottomBar.dart';
import 'package:reslate/screen/Translate.dart';
import 'package:reslate/screen/authentication/registerPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/profile.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  final formKey = GlobalKey<FormState>();
  Profile profile = Profile();
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text("Error!")),
            body: Center(
              child: Text("${snapshot.error}"),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
              body: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 100, 10, 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 200, 20),
                          child: Text(
                            'Raslate',
                            style: GoogleFonts.josefinSans(
                                textStyle: TextStyle(
                                    fontSize: 50, color: Colors.blueGrey)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 200, 20),
                          child: Text(
                            'Login\nyour account',
                            style: GoogleFonts.josefinSans(
                                textStyle: TextStyle(
                                    fontSize: 30, color: Colors.blueGrey)),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                      child: TextFormField(
                          validator: MultiValidator([
                            RequiredValidator(errorText: 'กรุณากรอก Email'),
                            EmailValidator(
                                errorText:
                                    'รูปแบบ Email ไม่ถูกต้อง กรุณากรอกอีกครั้ง')
                          ]),
                          onSaved: (var email) {
                            profile.email = email;
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Enter Email',
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                      child: TextFormField(
                          validator: ((password1) {
                            if (password1!.isEmpty) {
                              return 'โปรดกรอกรหัสผ่าน';
                            } else if (password1.length < 8) {
                              return 'รหัสผ่านต้องยาวกว่า 8 ตัวอักษร';
                            }
                          }),
                          onSaved: (password1) {
                            profile.password = password1;
                          },
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Password',
                          )),
                    ),
                    Center(
                      child: SizedBox(
                        width: 300,
                        child: ElevatedButton.icon(
                            onPressed: () {
                              handleLogin();
                            },
                            icon: Icon(Icons.login),
                            label: Text("Login")),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 30, 15, 15),
                        child: Text("OR"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                      child: ElevatedButton(
                        onPressed: () {
                          try {
                            GooglesignInProvider().googleLogin().then((value) {
                              try {
                                var user = FirebaseAuth.instance.currentUser!;
                                googleRegister(user.displayName, user.email);
                              } catch (e) {
                                print("can't get user data");
                              }
                              Fluttertoast.showToast(
                                  msg: "เข้าสู่ระบบสำเร็จ",
                                  gravity: ToastGravity.TOP);

                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return bottombar();
                              }));
                            });
                          } catch (e) {
                            Fluttertoast.showToast(
                                msg: "เข้าสู่ระบบด้วย google ไม่สำเร็จ",
                                gravity: ToastGravity.TOP);
                          }
                        },
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                  child: Image.asset('assets/images/Glogo.png',
                                      fit: BoxFit.cover)
                                  //Icon(Icons.apple)
                                  ),
                            ],
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return registerPage();
                          }));
                        },
                        child: Text(
                          "Don't have an account? Register now!",
                          style: btTextStyle.nameOfTextStyle,
                        ))
                  ],
                ),
              ),
            ),
          ));
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  googleRegister(
    username,
    email,
  ) async {
    CollectionReference googleAccount =
        FirebaseFirestore.instance.collection("Profile");
    String password = 'SocialLogin';
    await googleAccount.add({
      "Username": username,
      "Email": email,
      "password": password,
    });
  }

  Future<void> handleLogin() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState?.save();
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: profile.email, password: profile.password)
            .then((value) {
          formKey.currentState?.reset();
          Fluttertoast.showToast(
              msg: "เข้าสู่ระบบสำเร็จ", gravity: ToastGravity.TOP);
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return bottombar();
          }));
          saveLoginStatus(true);
        });
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(msg: e.code, gravity: ToastGravity.TOP);
      }
      formKey.currentState?.reset();
    }
  }
}

Future<void> saveLoginStatus(bool isLoggedIn) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('isLoggedIn', isLoggedIn);
  print(isLoggedIn);
}

class btTextStyle {
  static const TextStyle nameOfTextStyle =
      TextStyle(fontSize: 12, color: Colors.black);
}

class Googlebt {
  static const TextStyle style = TextStyle(fontSize: 25);
}

class GooglesignInProvider extends ChangeNotifier {
  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;
    _user = googleUser;

    final googleAutn = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAutn.accessToken,
      idToken: googleAutn.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);

    notifyListeners();
    saveLoginStatus(true);
  }
}
