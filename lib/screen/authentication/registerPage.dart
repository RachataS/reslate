import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reslate/screen/authentication/login.dart';

import '../../../model/profile.dart';

class registerPage extends StatefulWidget {
  const registerPage({super.key});

  @override
  State<registerPage> createState() => _registerPageState();
}

class _registerPageState extends State<registerPage> {
  var password1;
  var password2;
  final formKey = GlobalKey<FormState>();
  Profile profile = Profile();
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  CollectionReference emailLogin =
      FirebaseFirestore.instance.collection("Profile");

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Error!"),
              centerTitle: true,
            ),
            body: Center(
              child: Text("${snapshot.error}"),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              body: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                    Colors.blue[600]!,
                    Colors.blue[300]!,
                    Colors.blue[100]!,
                  ]),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 100, 10, 20),
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(0, 20, 200, 20),
                              child: Text(
                                'Raslate',
                                style: GoogleFonts.josefinSans(
                                    textStyle: TextStyle(
                                        fontSize: 50, color: Colors.white)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 200, 20),
                              child: Text(
                                'Register\nyour account',
                                style: GoogleFonts.josefinSans(
                                    textStyle: TextStyle(
                                        fontSize: 30, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.blue[900]!,
                                  blurRadius: 30,
                                  offset: Offset(0, 10))
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(60),
                                topRight: Radius.circular(60))),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(30, 50, 30, 20),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.blue[400]!,
                                            blurRadius: 20,
                                            offset: Offset(0, 10))
                                      ]),
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[200]!))),
                                        child: TextFormField(
                                            validator: RequiredValidator(
                                                errorText:
                                                    'กรุณากรอก Username'),
                                            onSaved: (var username) {
                                              profile.username = username;
                                            },
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              labelText: 'Enter Username',
                                            )),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[200]!))),
                                        child: TextFormField(
                                            validator: MultiValidator([
                                              RequiredValidator(
                                                  errorText: 'กรุณากรอก Email'),
                                              EmailValidator(
                                                  errorText:
                                                      'รูปแบบ Email ไม่ถูกต้อง กรุณากรอกอีกครั้ง')
                                            ]),
                                            onSaved: (var email) {
                                              profile.email = email;
                                            },
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              labelText: 'Enter Email',
                                            )),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[200]!))),
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
                                              border: InputBorder.none,
                                              labelText: 'Password',
                                            )),
                                      ),
                                      Container(
                                        child: TextFormField(
                                            controller: password2,
                                            validator: ((password2) {
                                              if (password2!.isEmpty) {
                                                return 'โปรดยืนยันรหัสผ่าน';
                                              } else if (password2.length < 8) {
                                                return 'รหัสผ่านต้องยาวกว่า 8 ตัวอักษร';
                                              }
                                            }),
                                            onSaved: (password2) {
                                              profile.conpassword = password2;
                                            },
                                            obscureText: true,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              labelText: 'Confirm Password',
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 45,
                                ),
                                Center(
                                  child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[400],
                                          fixedSize: const Size(300, 50),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50))),
                                      onPressed: () async {
                                        if (formKey.currentState!.validate()) {
                                          formKey.currentState?.save();
                                          if (profile.password !=
                                              profile.conpassword) {
                                            Fluttertoast.showToast(
                                                msg: 'รหัสผ่านไม่ตรงกัน',
                                                gravity: ToastGravity.TOP);
                                          } else {
                                            try {
                                              await FirebaseAuth.instance
                                                  .createUserWithEmailAndPassword(
                                                      email: profile.email,
                                                      password:
                                                          profile.password);
                                              await emailLogin.add({
                                                "Username": profile.username,
                                                "Email": profile.email,
                                                "password": profile.password,
                                                "wordLength": 0
                                              });
                                              Fluttertoast.showToast(
                                                  msg: "สร้างบัญชีผู้ใช้สำเร็จ",
                                                  gravity: ToastGravity.TOP);
                                              Navigator.pushReplacement(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return loginPage();
                                              }));
                                              formKey.currentState?.reset();
                                            } on FirebaseAuthException catch (e) {
                                              var message;
                                              if (e.code ==
                                                  "email-already-in-use") {
                                                message =
                                                    "อีเมลนี้เคยถูกใช้ลงทะเบียนแล้ว โปรดใช้อีเมลอื่นหรือเข้าสู่ระบบ";
                                              } else if (e.code ==
                                                  "weak-password") {
                                                message =
                                                    "รหัสผ่านต้องมีความยาวมากกว่า 8 ตัวอักษร";
                                              } else {
                                                message == e.code;
                                              }
                                              Fluttertoast.showToast(
                                                  msg: message,
                                                  gravity: ToastGravity.TOP);
                                              formKey.currentState?.reset();
                                            }
                                          }
                                        }
                                      },
                                      icon: Icon(Icons.add),
                                      label: Text("Register")),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return loginPage();
                                      }));
                                    },
                                    child: Text(
                                      "Already have an account? Sign in now",
                                      style: btTextStyle.nameOfTextStyle,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
