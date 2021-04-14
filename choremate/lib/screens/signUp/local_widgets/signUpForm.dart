import 'package:choremate/services/auth.dart';
import 'package:choremate/widgets/shadowContainer.dart';
import 'package:flutter/material.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  void _signUpUser(String email, String password, BuildContext context,
      String fullName) async {
    try {
      String _returnString = await Auth().signUpUser(email, password, fullName);
      if (_returnString == "success") {
        Navigator.pop(context);
      } else {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(_returnString),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }
  // void _signUpUser(String email, String password, BuildContext context) async {
  //   CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: false);

  //   try {
  //     if (await _currentUser.signUpUser(email, password)) {
  //       Navigator.pop(context);
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    Color green = const Color(0xFFa8e1a6);
    Color blue = const Color(0xFF5ac9fc);
    return ShadowContainer(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
            child: Text(
              "Sign Up",
              style: TextStyle(
                color: blue,
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person_outline, color: blue),
              hintText: "Full Name",
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.alternate_email, color: blue),
              hintText: "Email",
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock_outline, color: blue),
              hintText: "Password",
            ),
            obscureText: true,
          ),
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock_open, color: blue),
              hintText: "Confirm Password",
            ),
            obscureText: true,
          ),
          SizedBox(
            height: 20.0,
          ),
          RaisedButton(
            color: green,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 100),
              child: Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            onPressed: () {
              if (_passwordController.text == _confirmPasswordController.text) {
                _signUpUser(_emailController.text, _passwordController.text,
                    context, _fullNameController.text);
              } else {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Passwords do not match"),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
