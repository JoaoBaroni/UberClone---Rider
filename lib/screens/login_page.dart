import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rider/brand_colors.dart';
import 'package:rider/components/default_button.dart';
import 'package:rider/components/progress_dialog.dart';
import 'package:rider/screens/main_page.dart';
import 'package:rider/screens/registration_page.dart';
import 'package:rider/utils/utils.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey<ScaffoldState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  void loginUser() async{
    try {
      showDialog(context: context, builder: (BuildContext context) => ProgressDialog(status: 'Logging you in',));
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
    } on FirebaseAuthException catch(e){
      if(e.code == 'user-not-found'){
        Navigator.pop(context);
        Utils.showSnackBar('No user found for that email', _scaffoldState);
      }else if(e.code == 'wrong-password'){
        Navigator.pop(context);
        Utils.showSnackBar('Wrong password provided for that user', _scaffoldState);
      }
    }catch(e){
      print(e);
    }

    Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldState,
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
                    'Sign In as a Rider',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
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
                        DefaultButton(callback: (){loginUser();}, valueName: 'LOGIN', customHeight: 50.0,),
                      ],
                    ),
                  ),
                  FlatButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, RegistrationPage.id, (route) => false);
                      },
                      child: Text('Dont\'t have an account, sign up here'))
                ],
              ),
            ),
          ),
        ));
  }
}


