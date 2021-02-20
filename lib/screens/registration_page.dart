import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rider/brand_colors.dart';
import 'package:rider/components/default_button.dart';
import 'package:rider/components/progress_dialog.dart';
import 'package:rider/screens/login_page.dart';
import 'package:rider/screens/main_page.dart';
import 'package:rider/utils/utils.dart';

class RegistrationPage extends StatefulWidget {
  static const String id = 'register';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  var fullNameController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  void registerUser() async {
    try {
      showDialog(context: context, builder: (BuildContext context) => ProgressDialog(status: 'Registering',));
      UserCredential userInfos = await _auth.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      saveUserInformations(userInfos);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Navigator.pop(context);
        Utils.showSnackBar('The password provided is too weak!', scaffoldKey);
      } else if (e.code == 'email-already-in-use') {
        Navigator.pop(context);
        Utils.showSnackBar('The account already exists for that email', scaffoldKey);
      }
    } catch (e) {
      print(e);
    }
  }

  void saveUserInformations(final UserCredential user) {
    DatabaseReference newUser = FirebaseDatabase.instance.reference().child('user/${user.user.uid}');
    Map userMap = {
      'fullname': fullNameController.text,
      'phonenumber': phoneNumberController.text,
      'email': emailController.text
    };

    newUser.set(userMap);
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
  }

  Future<bool> checkInternetConnection() async{
    var connectivityResult = await Connectivity().checkConnectivity();
    return (connectivityResult  != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 70,
                  ),
                  Image(
                    alignment: Alignment.center,
                    height: 100,
                    width: 100,
                    image: AssetImage('images/logo.png'),
                  ),
                  SizedBox(height: 40),
                  Text(
                    'Create a Rider\'s account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: fullNameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              labelText: 'Full name',
                              labelStyle: TextStyle(fontSize: 14),
                              hintStyle: TextStyle(color: Colors.grey)),
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              labelText: 'Email address',
                              labelStyle: TextStyle(fontSize: 14),
                              hintStyle: TextStyle(color: Colors.grey)),
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        TextField(
                          controller: phoneNumberController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              labelText: 'Phone',
                              labelStyle: TextStyle(fontSize: 14),
                              hintStyle: TextStyle(color: Colors.grey)),
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(fontSize: 14),
                              hintStyle: TextStyle(color: Colors.grey)),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        DefaultButton(
                          callback: () async {
                            bool resultConnectivity = await checkInternetConnection();
                            if(resultConnectivity){
                              Utils.showSnackBar('There\'s no internet connection', scaffoldKey);
                              return;
                            }

                            if(fullNameController.text.length < 3){
                              Utils.showSnackBar('Please provide a valid full name', scaffoldKey);
                              return;
                            }

                            if(!emailController.text.contains('@')){
                              Utils.showSnackBar('Please provide a valid email adress', scaffoldKey);
                              return;
                            }

                            if(passwordController.text.length < 8){
                              Utils.showSnackBar('Password must be at least 8 characters', scaffoldKey);
                              return;
                            }

                            registerUser();
                          },
                          valueName: 'REGISTER',
                          customHeight: 50.0,
                        ),
                      ],
                    ),
                  ),
                  FlatButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, LoginPage.id, (route) => false);
                      },
                      child: Text('Already have an account? Login'))
                ],
              ),
            ),
          ),
        ));
  }
}
