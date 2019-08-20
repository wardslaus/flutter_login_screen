import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sqflite/sqflite.dart';
import 'package:log_in_screen/CustomIcons.dart';
import 'package:log_in_screen/Widgets/SocialIcons.dart';
import 'dart:convert';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:log_in_screen/Objects/user.dart';
import 'package:log_in_screen/Screens/Test.dart';


bool _signUpActive = false;
bool _signInActive = true;
TextEditingController _emailController = TextEditingController();
TextEditingController _passwordController = TextEditingController();
TextEditingController _newUsernameController = TextEditingController();
TextEditingController _newEmailController = TextEditingController();
TextEditingController _newPasswordController = TextEditingController();

void main() =>
    runApp(MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    )
  );

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => new _MyAppState();
}

Widget horizontalLine() => Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: ScreenUtil.getInstance().setWidth(120),
        height: 1.0,
        color: Colors.white.withOpacity(0.6),
      ),
    );

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  var profileData;

  var facebookLogin = FacebookLogin();

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()
      ..init(context);
    ScreenUtil.instance =
    ScreenUtil(width: 750, height: 1304, allowFontScaling: true)
      ..init(context);
    return new Scaffold(
      resizeToAvoidBottomPadding: true,
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(247, 140, 123, 1),
                  Color.fromRGBO(197, 112, 98, 1)
                ])),
        child: Padding(
          padding: EdgeInsets.only(top: 40.0),
          //Sets the main padding all widgets has to adhere to.
          child: Column(
            children: <Widget>[
              Container(
                child: Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "MOMENTUM",
                          style: TextStyle(
                            //fontFamily: 'Open Sans',
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "GROWTH * HAPPENS * TODAY",
                          style: TextStyle(
                            //fontFamily: 'Open Sans',
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )),
                width: ScreenUtil.getInstance().setWidth(750),
                height: ScreenUtil.getInstance().setHeight(190),
              ),
              SizedBox(
                height: ScreenUtil.getInstance().setHeight(60),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 25.0),
                  child: IntrinsicWidth(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        OutlineButton(
                          onPressed: () => setState(() => changeToSignIn()),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          borderSide: new BorderSide(
                            style: BorderStyle.none,
                          ),
                          child: new Text('SIGN IN',
                              style: _signInActive
                                  ? TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)
                                  : TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal)),
                        ),
                        OutlineButton(
                          onPressed: () => setState(() => changeToSignUp()),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          borderSide: BorderSide(
                            style: BorderStyle.none,
                          ),
                          child: Text('SIGN UP',
                              style: _signUpActive
                                  ? TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)
                                  : TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal)),
                        )
                      ],
                    ),
                  ),
                ),
                width: ScreenUtil.getInstance().setWidth(750),
                height: ScreenUtil.getInstance().setHeight(170),
              ),
              SizedBox(
                height: ScreenUtil.getInstance().setHeight(10),
              ),
              Container(
                child: Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: _signInActive ? showSignIn() : showSignUp()),
                width: ScreenUtil.getInstance().setWidth(750),
                height: ScreenUtil.getInstance().setHeight(778),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

  void _navigateToNextScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Test()),
    );

  void initiateFacebookLogin() async {
    var facebookLoginResult =
        await facebookLogin.logInWithReadPermissions(['email']);

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=${facebookLoginResult
                .accessToken.token}');

        var profile = json.decode(graphResponse.body);

        print(profile.toString());
        
        onLoginStatusChanged(true, profileData: profile);

        new User.facebook(profileData['email'], profileData['name'], profileData['id'], profileData);
        _navigateToNextScreen(context);
        //print("TEST: ${profile['email']} "+" | "+" ${profileData['name']} "+" | "+"${profileData['id']}");
        //print("User object data: "+user.email + user.name + user.fbID);
        break;
    }

    
  }
}



Widget showSignIn() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      SizedBox(
        height: ScreenUtil.getInstance().setHeight(30),
      ),
      Container(
        child: Padding(
          padding: EdgeInsets.only(),
          child: TextField(
            style: TextStyle(color: Colors.white),
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Username',
              hintStyle: TextStyle(fontSize: 18.0, color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.0)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.0)),
              prefixIcon: const Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      SizedBox(
        height: ScreenUtil.getInstance().setHeight(50),
      ),
      Container(
        child: Padding(
          padding: EdgeInsets.only(),
          child: TextField(
            obscureText: true,
            style: TextStyle(color: Colors.white),
            controller: _passwordController,
            decoration: InputDecoration(
              //Add th Hint text here.
              hintText: 'Password',
              hintStyle: TextStyle(fontSize: 18.0, color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.0)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.0)),
              prefixIcon: const Icon(
                Icons.lock,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      SizedBox(
        height: ScreenUtil.getInstance().setHeight(80),
      ),
      Container(
        child: Padding(
          padding: EdgeInsets.only(),
          child: RaisedButton(
            child: Text(
              'SIGN IN',
              style: TextStyle(
                color: Color.fromRGBO(247, 140, 123, 1),
                fontSize: 24.0,
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            color: Colors.white,
            onPressed: () => tryToSignIn(_emailController, _passwordController),
          ),
        ),
      ),
      SizedBox(
        height: ScreenUtil.getInstance().setHeight(50),
      ),
      Container(
        child: Padding(
          padding: EdgeInsets.only(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              horizontalLine(),
              Text('Social Login',
                  style: TextStyle(color: Colors.white)
              ),
              horizontalLine()
            ],
          ),
        ),
      ),
      SizedBox(
        height: ScreenUtil.getInstance().setHeight(40),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SocialIcon(
            colors: [
              Color(0xFF3C5A99),
              Color(0xFF3C5A99),
            ],
            iconData: CustomIcons.facebook,
            onPressed: () => initiateFacebookLogin(),
          ),
          SizedBox(
            width: 30,
          ),
          SocialIcon(
            colors: [
              Color(0xFF1DA1F2),
              Color(0xFF1DA1F2),
            ],
            iconData: CustomIcons.twitter,
            onPressed: () {},
          ),
          SizedBox(
            width: 30,
          ),
          SocialIcon(
            colors: [
              Color(0xFF0077B5),
              Color(0xFF0077B5),
            ],
            iconData: CustomIcons.linkedin,
            onPressed: () {},
          )
        ],
      )
    ],
  );
}

Widget showSignUp() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      SizedBox(
        height: ScreenUtil.getInstance().setHeight(30),
      ),
      Container(
        child: Padding(
          padding: EdgeInsets.only(),
          child: TextField(
            style: TextStyle(color: Colors.white),
            controller: _newUsernameController,
            decoration: InputDecoration(
              hintText: 'Enter your Name',
              hintStyle: TextStyle(fontSize: 18.0, color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.0)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.0)),
              prefixIcon: const Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      SizedBox(
        height: ScreenUtil.getInstance().setHeight(50),
      ),
      Container(
        child: Padding(
          padding: EdgeInsets.only(),
          child: TextField(
            obscureText: true,
            style: TextStyle(color: Colors.white),
            controller: _newEmailController,
            decoration: InputDecoration(
              //Add th Hint text here.
              hintText: 'Enter your Email',
              hintStyle: TextStyle(fontSize: 18.0, color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.0)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.0)),
              prefixIcon: const Icon(
                Icons.email,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      SizedBox(
        height: ScreenUtil.getInstance().setHeight(50),
      ),
      Container(
        child: Padding(
          padding: EdgeInsets.only(),
          child: TextField(
            obscureText: true,
            style: TextStyle(color: Colors.white),
            controller: _newPasswordController,
            decoration: InputDecoration(
              //Add the Hint text here.
              hintText: 'Enter a Password',
              hintStyle: TextStyle(fontSize: 18.0, color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.0)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.0)),
              prefixIcon: const Icon(
                Icons.lock,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      SizedBox(
        height: ScreenUtil.getInstance().setHeight(80),
      ),
      Container(
        child: Padding(
          padding: EdgeInsets.only(),
          child: RaisedButton(
            child: Text(
              'SIGN UP',
              style: TextStyle(
                color: Color.fromRGBO(247, 140, 123, 1),
                fontSize: 24.0,
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            color: Colors.white,
            onPressed: () =>
                tryToSignUp(_newUsernameController, _newPasswordController, _newEmailController),
          ),
        ),
      ),
    ],
  );
}

void tryToSignIn(TextEditingController _email, TextEditingController _password) {
    var email = _email;
    var password = _password;
    }

void tryToSignUp(TextEditingController _name, TextEditingController _password, TextEditingController _email) {
  var enteredName = _name;
  var enteredmail = _email;
  var enteredPassword = _password;
}

void changeToSignUp() {
  _signUpActive = true;
  _signInActive = false;
}

void changeToSignIn() {
  _signUpActive = false;
  _signInActive = true;
}
}